import json
import logging
from collections.abc import Iterator
from datetime import UTC, datetime
from decimal import Decimal
from typing import Any, get_args
from uuid import UUID, uuid4
from zoneinfo import ZoneInfo

import pytest
from fastapi import FastAPI
from fastapi.testclient import TestClient
from pydantic import BaseModel
from sqlalchemy import Engine
from sqlalchemy.orm import Session

from mimi.api.app import create_app
from mimi.api.chat import get_conversation_engine
from mimi.application.conversation_engine import Turn
from mimi.application.conversation_results import (
    AmountCurrencyConflict,
    AwaitingConfirmationResult,
    BalancesResult,
    BeneficiariesResult,
    CardsResult,
    CollectingDataResult,
    ExpenseAnalysisResult,
    ExpenseComparisonResult,
    FieldIssue,
    IncompleteQueryResult,
    NoPendingOperationResult,
    OperationCancelledResult,
    OperationCompletedResult,
    OperationFailedResult,
    PendingOperationConflictResult,
    PreValidationFailedResult,
    TransactionsResult,
    TurnResult,
    UnhandledIntentResult,
)
from mimi.application.errors import (
    ApplicationError,
    ConversationClosedError,
    ConversationNotFoundError,
    ConversationStateCorruptedError,
    InsufficientFundsError,
    InvalidCardStateError,
    InvalidConversationStateError,
    InvalidInteractionError,
    LLMUnavailableError,
)
from mimi.application.interactions import Cancel, Confirm, Interaction, SelectCard
from mimi.application.interpretation import Intent
from mimi.application.llm import LLMProvider
from mimi.application.pending_operations import (
    FreezeCardOperationData,
    PendingField,
    PendingOperation,
    TransferOperationData,
    UnfreezeCardOperationData,
)
from mimi.application.repositories import ConversationRecord
from mimi.application.use_cases.analyze_expenses import (
    CategoryExpense,
    CurrencyExpenses,
    ExpenseAnalysis,
    Period,
)
from mimi.application.use_cases.compare_expenses import (
    CurrencyComparison,
    ExpenseChange,
    ExpenseComparison,
)
from mimi.composition import Container
from mimi.config import Settings
from mimi.domain.entities import (
    Account,
    Beneficiary,
    Card,
    Conversation,
    Money,
    Transaction,
    Transfer,
)
from mimi.domain.enums import (
    AccountStatus,
    CardBrand,
    CardStatus,
    CardType,
    ConversationFlowState,
    ConversationStatus,
    Currency,
    PendingOperationType,
    TransactionCategory,
    TransactionType,
    TransferStatus,
)
from mimi.infrastructure.database.models import (
    AccountModel,
    BeneficiaryModel,
    CustomerModel,
)
from mimi.infrastructure.database.session import create_session_factory

BUENOS_AIRES = ZoneInfo("America/Argentina/Buenos_Aires")
NOW = datetime(2026, 10, 9, 16, 30, tzinfo=UTC)
CONVERSATION_ID = uuid4()
OPERATION_ID = uuid4()
CUSTOMER_ID = uuid4()

SAVINGS = Account(
    uuid4(),
    CUSTOMER_ID,
    "Caja de ahorro",
    Money(Decimal("150000.5"), Currency.ARS),
    AccountStatus.ACTIVE,
)
DOLLARS = Account(
    uuid4(),
    CUSTOMER_ID,
    "Cuenta en dólares",
    Money(Decimal("1200.00"), Currency.USD),
    AccountStatus.ACTIVE,
)
LAURA = Beneficiary(uuid4(), CUSTOMER_ID, "Laura", "0000003100012345674582", None)
JUAN_PEREZ = Beneficiary(uuid4(), CUSTOMER_ID, "Juan Pérez", "1234", "Banco")
JUAN_GARCIA = Beneficiary(uuid4(), CUSTOMER_ID, "Juan García", "5678", None)
VISA_DEBIT = Card(
    uuid4(), SAVINGS.id, CardType.DEBIT, CardBrand.VISA, "4821", CardStatus.ACTIVE
)
MASTER_CREDIT = Card(
    uuid4(),
    SAVINGS.id,
    CardType.CREDIT,
    CardBrand.MASTERCARD,
    "9314",
    CardStatus.FROZEN,
)
ARS_25000 = Money(Decimal("25000"), Currency.ARS)
TRANSFER_TO_LAURA = PendingOperation(
    PendingOperationType.TRANSFER,
    TransferOperationData(SAVINGS.id, LAURA.id, ARS_25000),
    OPERATION_ID,
)
FREEZE_VISA = PendingOperation(
    PendingOperationType.FREEZE_CARD, FreezeCardOperationData(VISA_DEBIT.id)
)
OCTOBER = Period(
    datetime(2026, 10, 1, tzinfo=BUENOS_AIRES),
    datetime(2026, 11, 1, tzinfo=BUENOS_AIRES),
)
SEPTEMBER = Period(
    datetime(2026, 9, 1, tzinfo=BUENOS_AIRES),
    datetime(2026, 10, 1, tzinfo=BUENOS_AIRES),
)


def ars(amount: str) -> dict[str, str]:
    return {"amount": amount, "currency": "ARS"}


def card_json(card: Card) -> dict[str, Any]:
    return {
        "id": str(card.id),
        "brand": card.brand.value,
        "type": card.type.value,
        "last_four": card.last_four,
        "status": card.status.value,
    }


class StubEngine:
    """Records the calls it receives and answers with ``turn``'s parts, or
    raises ``error`` when set."""

    def __init__(self) -> None:
        self.calls: list[tuple[Any, ...]] = []
        self.error: Exception | None = None
        self.result: TurnResult = UnhandledIntentResult(Intent.UNKNOWN)
        self.intent = Intent.UNKNOWN
        self.flow_state = ConversationFlowState.READY

    def start(self, customer_id: UUID) -> ConversationRecord:
        self.calls.append(("start", customer_id))
        self._raise_error()
        return ConversationRecord(
            Conversation(
                CONVERSATION_ID, customer_id, ConversationStatus.ACTIVE, NOW, NOW
            ),
            ConversationFlowState.READY,
        )

    def handle_message(
        self, customer_id: UUID, conversation_id: UUID, content: str
    ) -> Turn:
        self.calls.append(("message", customer_id, conversation_id, content))
        return self._turn(conversation_id)

    def handle_interaction(
        self, customer_id: UUID, conversation_id: UUID, interaction: Interaction
    ) -> Turn:
        self.calls.append(("interaction", customer_id, conversation_id, interaction))
        return self._turn(conversation_id)

    def _raise_error(self) -> None:
        if self.error is not None:
            raise self.error

    def _turn(self, conversation_id: UUID) -> Turn:
        self._raise_error()
        return Turn(conversation_id, self.flow_state, None, self.intent, self.result)


@pytest.fixture
def stub() -> StubEngine:
    return StubEngine()


@pytest.fixture
def chat_client(app: FastAPI, stub: StubEngine) -> Iterator[TestClient]:
    app.dependency_overrides[get_conversation_engine] = lambda: stub
    with TestClient(app) as client:
        yield client


def post_message(client: TestClient, message: str = "Hola") -> Any:
    return client.post(
        "/chat", json={"conversation_id": str(CONVERSATION_ID), "message": message}
    )


# Conversations.


def test_start_conversation_for_the_demo_customer(
    chat_client: TestClient, stub: StubEngine, test_settings: Settings
) -> None:
    response = chat_client.post("/conversations")

    assert response.status_code == 201
    body = response.json()
    assert body["conversation_id"] == str(CONVERSATION_ID)
    assert body["conversation_state"] == "READY"
    assert set(body["metadata"]) == {"request_id", "timestamp"}
    assert stub.calls == [("start", test_settings.demo_customer_id)]


def test_app_requires_a_demo_customer(container: Container) -> None:
    settings = container.settings.model_copy(update={"demo_customer_id": None})

    with pytest.raises(ValueError, match="MIMI_DEMO_CUSTOMER_ID"):
        create_app(Container(**{**vars(container), "settings": settings}))


# Requests.


@pytest.mark.parametrize(
    ("body", "call"),
    [
        (
            {"message": "¿Cuánta plata tengo?"},
            ("message", "¿Cuánta plata tengo?"),
        ),
        (
            {"interaction": "CONFIRM", "payload": {"operation_id": str(OPERATION_ID)}},
            ("interaction", Confirm(OPERATION_ID)),
        ),
        ({"interaction": "CANCEL"}, ("interaction", Cancel())),
        (
            {"interaction": "SELECT_CARD", "payload": {"card_id": str(VISA_DEBIT.id)}},
            ("interaction", SelectCard(VISA_DEBIT.id)),
        ),
    ],
    ids=["message", "confirm", "cancel", "select_card"],
)
def test_requests_are_handled_by_the_engine(
    chat_client: TestClient,
    stub: StubEngine,
    test_settings: Settings,
    body: dict[str, Any],
    call: tuple[str, Any],
) -> None:
    response = chat_client.post(
        "/chat", json={"conversation_id": str(CONVERSATION_ID), **body}
    )

    assert response.status_code == 200
    method, argument = call
    customer_id = test_settings.demo_customer_id
    assert stub.calls == [(method, customer_id, CONVERSATION_ID, argument)]


def test_invalid_request_never_reaches_the_engine(
    chat_client: TestClient, stub: StubEngine
) -> None:
    response = chat_client.post(
        "/chat",
        json={
            "conversation_id": str(CONVERSATION_ID),
            "message": "Sí",
            "interaction": "CONFIRM",
            "payload": {"operation_id": str(OPERATION_ID)},
        },
    )

    assert response.status_code == 422
    assert response.json()["code"] == "INVALID_REQUEST"
    assert stub.calls == []


# Responses.

PRESENTATIONS: list[tuple[str, TurnResult, Intent, ConversationFlowState, str, Any]]
PRESENTATIONS = [
    (
        "balances",
        BalancesResult((SAVINGS, DOLLARS)),
        Intent.GET_BALANCE,
        ConversationFlowState.READY,
        "Estos son tus saldos: Caja de ahorro: 150000.50 ARS; "
        "Cuenta en dólares: 1200.00 USD.",
        {"type": "TEXT", "data": {}},
    ),
    (
        "single_balance",
        BalancesResult((SAVINGS,)),
        Intent.GET_BALANCE,
        ConversationFlowState.READY,
        "El saldo de Caja de ahorro es 150000.50 ARS.",
        {"type": "TEXT", "data": {}},
    ),
    (
        "transactions",
        TransactionsResult(
            (
                Transaction(
                    UUID("9eab44a2-c710-4a0c-beb7-c24de95a9820"),
                    SAVINGS.id,
                    Money(Decimal("24500"), Currency.ARS),
                    TransactionType.DEBIT,
                    TransactionCategory.GROCERIES,
                    "Supermarket",
                    datetime(2026, 10, 8, 18, 30, tzinfo=UTC),
                    None,
                ),
            ),
            OCTOBER,
        ),
        Intent.GET_TRANSACTIONS,
        ConversationFlowState.READY,
        "Encontré 1 movimiento.",
        {
            "type": "TRANSACTION_LIST",
            "data": {
                "transactions": [
                    {
                        "id": "9eab44a2-c710-4a0c-beb7-c24de95a9820",
                        "description": "Supermarket",
                        "amount": ars("24500.00"),
                        "type": "DEBIT",
                        "category": "GROCERIES",
                        "occurred_at": "2026-10-08T18:30:00Z",
                    }
                ]
            },
        },
    ),
    (
        "expense_summary",
        ExpenseAnalysisResult(
            ExpenseAnalysis(
                OCTOBER,
                None,
                (
                    CurrencyExpenses(
                        Currency.ARS,
                        Money(Decimal("85000"), Currency.ARS),
                        (
                            CategoryExpense(
                                TransactionCategory.DINING,
                                Money(Decimal("85000"), Currency.ARS),
                            ),
                        ),
                    ),
                    CurrencyExpenses(
                        Currency.USD,
                        Money(Decimal("120"), Currency.USD),
                        (
                            CategoryExpense(
                                TransactionCategory.SUBSCRIPTIONS,
                                Money(Decimal("120"), Currency.USD),
                            ),
                        ),
                    ),
                ),
            )
        ),
        Intent.ANALYZE_EXPENSES,
        ConversationFlowState.READY,
        "Tus gastos del período suman 85000.00 ARS y 120.00 USD.",
        {
            "type": "EXPENSE_SUMMARY",
            "data": {
                "period": {"from": "2026-10-01", "to": "2026-10-31"},
                "currencies": [
                    {
                        "total": ars("85000.00"),
                        "categories": [
                            {"category": "DINING", "amount": ars("85000.00")}
                        ],
                    },
                    {
                        "total": {"amount": "120.00", "currency": "USD"},
                        "categories": [
                            {
                                "category": "SUBSCRIPTIONS",
                                "amount": {"amount": "120.00", "currency": "USD"},
                            }
                        ],
                    },
                ],
            },
        },
    ),
    (
        "no_expenses",
        ExpenseAnalysisResult(ExpenseAnalysis(OCTOBER, None, ())),
        Intent.ANALYZE_EXPENSES,
        ConversationFlowState.READY,
        "No hay gastos en ese período.",
        {
            "type": "EXPENSE_SUMMARY",
            "data": {
                "period": {"from": "2026-10-01", "to": "2026-10-31"},
                "currencies": [],
            },
        },
    ),
    (
        "expense_comparison",
        ExpenseComparisonResult(
            ExpenseComparison(
                ExpenseAnalysis(OCTOBER, None, ()),
                ExpenseAnalysis(SEPTEMBER, None, ()),
                (
                    CurrencyComparison(
                        Currency.ARS,
                        Money(Decimal("185000"), Currency.ARS),
                        Money(Decimal("160000"), Currency.ARS),
                        Money(Decimal("25000"), Currency.ARS),
                        ExpenseChange.INCREASE,
                    ),
                    CurrencyComparison(
                        Currency.USD,
                        Money(Decimal("80"), Currency.USD),
                        Money(Decimal("120"), Currency.USD),
                        Money(Decimal("40"), Currency.USD),
                        ExpenseChange.DECREASE,
                    ),
                ),
            )
        ),
        Intent.COMPARE_EXPENSES,
        ConversationFlowState.READY,
        "Respecto del período comparado, en ARS gastaste 25000.00 ARS más y "
        "en USD gastaste 40.00 USD menos.",
        {
            "type": "EXPENSE_COMPARISON",
            "data": {
                "current_period": {"from": "2026-10-01", "to": "2026-10-31"},
                "previous_period": {"from": "2026-09-01", "to": "2026-09-30"},
                "currencies": [
                    {
                        "current_total": ars("185000.00"),
                        "previous_total": ars("160000.00"),
                        "difference": ars("25000.00"),
                        "change": "INCREASE",
                    },
                    {
                        "current_total": {"amount": "80.00", "currency": "USD"},
                        "previous_total": {"amount": "120.00", "currency": "USD"},
                        "difference": {"amount": "40.00", "currency": "USD"},
                        "change": "DECREASE",
                    },
                ],
            },
        },
    ),
    (
        "cards",
        CardsResult((VISA_DEBIT, MASTER_CREDIT)),
        Intent.GET_CARDS,
        ConversationFlowState.READY,
        "Encontré 2 tarjetas.",
        {
            "type": "CARD_LIST",
            "data": {"cards": [card_json(VISA_DEBIT), card_json(MASTER_CREDIT)]},
        },
    ),
    (
        "beneficiaries",
        BeneficiariesResult((LAURA,)),
        Intent.GET_BENEFICIARIES,
        ConversationFlowState.READY,
        "Estos son tus destinatarios guardados.",
        {
            "type": "BENEFICIARY_LIST",
            "data": {
                "beneficiaries": [
                    {
                        "id": str(LAURA.id),
                        "name": "Laura",
                        "account_reference": "****4582",
                        "bank_name": None,
                    }
                ]
            },
        },
    ),
    (
        "incomplete_query",
        IncompleteQueryResult(
            Intent.COMPARE_EXPENSES,
            missing_fields=frozenset({"comparison_period"}),
            unsupported_fields=frozenset({"category"}),
        ),
        Intent.COMPARE_EXPENSES,
        ConversationFlowState.READY,
        "Necesito que me indiques el período a comparar. "
        "Todavía no puedo usar la categoría que indicaste.",
        {"type": "TEXT", "data": {}},
    ),
    (
        "follow_up_stating_nothing",
        IncompleteQueryResult(Intent.ANALYZE_EXPENSES),
        Intent.ANALYZE_EXPENSES,
        ConversationFlowState.READY,
        "No entendí tu mensaje. ¿Podés reformularlo?",
        {"type": "TEXT", "data": {}},
    ),
    (
        "follow_up_without_context",
        IncompleteQueryResult(Intent.UNKNOWN, missing_fields=frozenset({"context"})),
        Intent.UNKNOWN,
        ConversationFlowState.READY,
        "No tengo una consulta anterior a la cual referirme. ¿Qué querés consultar?",
        {"type": "TEXT", "data": {}},
    ),
    (
        "general_conversation",
        UnhandledIntentResult(Intent.GENERAL_CONVERSATION),
        Intent.GENERAL_CONVERSATION,
        ConversationFlowState.READY,
        "Puedo ayudarte con saldos, movimientos, gastos, tarjetas y transferencias.",
        {"type": "TEXT", "data": {}},
    ),
    (
        "typed_cancel",
        UnhandledIntentResult(Intent.CANCEL),
        Intent.CANCEL,
        ConversationFlowState.WAITING_CONFIRMATION,
        "Para cancelar una operación, usá la opción Cancelar.",
        {"type": "TEXT", "data": {}},
    ),
    (
        "unknown",
        UnhandledIntentResult(Intent.UNKNOWN),
        Intent.UNKNOWN,
        ConversationFlowState.READY,
        "No entendí tu mensaje. ¿Podés reformularlo?",
        {"type": "TEXT", "data": {}},
    ),
    (
        "ambiguous_card",
        CollectingDataResult(
            PendingOperation(
                PendingOperationType.FREEZE_CARD, FreezeCardOperationData()
            ),
            {PendingField.CARD_ID: FieldIssue.AMBIGUOUS},
            card_candidates=(VISA_DEBIT, MASTER_CREDIT),
        ),
        Intent.FREEZE_CARD,
        ConversationFlowState.COLLECTING_DATA,
        "¿Qué tarjeta querés congelar?",
        {
            "type": "CARD_SELECTOR",
            "data": {"cards": [card_json(VISA_DEBIT), card_json(MASTER_CREDIT)]},
        },
    ),
    (
        "card_without_candidates",
        CollectingDataResult(
            PendingOperation(
                PendingOperationType.UNFREEZE_CARD, UnfreezeCardOperationData()
            ),
        ),
        Intent.UNFREEZE_CARD,
        ConversationFlowState.COLLECTING_DATA,
        "¿Qué tarjeta querés descongelar?",
        {"type": "TEXT", "data": {}},
    ),
    (
        "card_not_found",
        CollectingDataResult(
            PendingOperation(
                PendingOperationType.FREEZE_CARD, FreezeCardOperationData()
            ),
            {PendingField.CARD_ID: FieldIssue.NOT_FOUND},
        ),
        Intent.FREEZE_CARD,
        ConversationFlowState.COLLECTING_DATA,
        "No encontré esa tarjeta. ¿Qué tarjeta querés congelar?",
        {"type": "TEXT", "data": {}},
    ),
    (
        "ambiguous_beneficiary",
        CollectingDataResult(
            PendingOperation(
                PendingOperationType.TRANSFER,
                TransferOperationData(SAVINGS.id, None, ARS_25000),
            ),
            {PendingField.BENEFICIARY_ID: FieldIssue.AMBIGUOUS},
            beneficiary_candidates=(JUAN_PEREZ, JUAN_GARCIA),
        ),
        Intent.TRANSFER_MONEY,
        ConversationFlowState.COLLECTING_DATA,
        "Encontré varios destinatarios: Juan Pérez y Juan García. "
        "¿A quién querés transferir?",
        {"type": "TEXT", "data": {}},
    ),
    (
        "amount_conflict",
        CollectingDataResult(
            PendingOperation(
                PendingOperationType.TRANSFER,
                TransferOperationData(DOLLARS.id, LAURA.id),
            ),
            amount_conflict=AmountCurrencyConflict(ARS_25000, Currency.USD),
        ),
        Intent.TRANSFER_MONEY,
        ConversationFlowState.COLLECTING_DATA,
        "El monto de 25000.00 ARS no corresponde a la moneda de la cuenta "
        "elegida (USD). ¿Cuánto querés transferir?",
        {"type": "TEXT", "data": {}},
    ),
    (
        "transfer_confirmation",
        AwaitingConfirmationResult(
            TRANSFER_TO_LAURA, source_account=SAVINGS, beneficiary=LAURA
        ),
        Intent.TRANSFER_MONEY,
        ConversationFlowState.WAITING_CONFIRMATION,
        "¿Confirmás la transferencia de 25000.00 ARS a Laura desde Caja de ahorro?",
        {
            "type": "CONFIRMATION",
            "data": {
                "operation_id": str(OPERATION_ID),
                "title": "Confirmar transferencia",
                "summary": {
                    "type": "TRANSFER",
                    "amount": ars("25000.00"),
                    "beneficiary": "Laura",
                },
                "actions": [
                    {"type": "CONFIRM", "label": "Confirmar"},
                    {"type": "CANCEL", "label": "Cancelar"},
                ],
            },
        },
    ),
    (
        "card_confirmation",
        AwaitingConfirmationResult(
            PendingOperation(
                PendingOperationType.FREEZE_CARD,
                FreezeCardOperationData(VISA_DEBIT.id),
                OPERATION_ID,
            ),
            card=VISA_DEBIT,
        ),
        Intent.FREEZE_CARD,
        ConversationFlowState.WAITING_CONFIRMATION,
        "¿Confirmás que querés congelar la tarjeta Visa de débito terminada en 4821?",
        {
            "type": "CONFIRMATION",
            "data": {
                "operation_id": str(OPERATION_ID),
                "title": "Congelar tarjeta",
                "summary": {"type": "CARD", "card": card_json(VISA_DEBIT)},
                "actions": [
                    {"type": "CONFIRM", "label": "Confirmar"},
                    {"type": "CANCEL", "label": "Cancelar"},
                ],
            },
        },
    ),
    (
        "transfer_completed",
        OperationCompletedResult(
            TRANSFER_TO_LAURA,
            transfer=Transfer(
                UUID("c919db94-a92f-4bc5-9355-32e90a10c632"),
                SAVINGS.id,
                LAURA.id,
                ARS_25000,
                TransferStatus.COMPLETED,
                NOW,
                NOW,
            ),
            beneficiary=LAURA,
        ),
        Intent.TRANSFER_MONEY,
        ConversationFlowState.READY,
        "La transferencia de 25000.00 ARS a Laura se realizó con éxito.",
        {
            "type": "TRANSFER_SUMMARY",
            "data": {
                "transfer_id": "c919db94-a92f-4bc5-9355-32e90a10c632",
                "beneficiary": "Laura",
                "amount": ars("25000.00"),
                "status": "COMPLETED",
                "executed_at": "2026-10-09T16:30:00Z",
            },
        },
    ),
    (
        "card_completed",
        OperationCompletedResult(
            FREEZE_VISA, card=Card(**{**vars(VISA_DEBIT), "status": CardStatus.FROZEN})
        ),
        Intent.FREEZE_CARD,
        ConversationFlowState.READY,
        "Tu tarjeta Visa de débito terminada en 4821 quedó congelada.",
        {
            "type": "CARD_LIST",
            "data": {"cards": [{**card_json(VISA_DEBIT), "status": "FROZEN"}]},
        },
    ),
    (
        "cancelled",
        OperationCancelledResult(TRANSFER_TO_LAURA),
        Intent.CANCEL,
        ConversationFlowState.READY,
        "Listo, cancelé la transferencia. No se realizó ningún cambio.",
        {"type": "TEXT", "data": {}},
    ),
    (
        "confirm_without_pending",
        NoPendingOperationResult(Confirm(OPERATION_ID)),
        Intent.UNKNOWN,
        ConversationFlowState.READY,
        "No hay ninguna operación pendiente de confirmación.",
        {"type": "TEXT", "data": {}},
    ),
    (
        "cancel_without_pending",
        NoPendingOperationResult(Cancel()),
        Intent.CANCEL,
        ConversationFlowState.READY,
        "No hay ninguna operación pendiente para cancelar.",
        {"type": "TEXT", "data": {}},
    ),
]


def test_every_successful_result_type_is_presented() -> None:
    presented = {type(result) for _, result, *_ in PRESENTATIONS}
    failing = {
        PreValidationFailedResult,
        OperationFailedResult,
        PendingOperationConflictResult,
    }

    assert presented | failing == set(get_args(TurnResult.__value__))


@pytest.mark.parametrize(
    ("result", "intent", "flow_state", "message", "ui"),
    [case[1:] for case in PRESENTATIONS],
    ids=[case[0] for case in PRESENTATIONS],
)
def test_results_are_presented_as_chat_responses(
    chat_client: TestClient,
    stub: StubEngine,
    result: TurnResult,
    intent: Intent,
    flow_state: ConversationFlowState,
    message: str,
    ui: Any,
) -> None:
    stub.result, stub.intent, stub.flow_state = result, intent, flow_state

    response = post_message(chat_client)

    assert response.status_code == 200
    body = response.json()
    metadata = body.pop("metadata")
    assert body == {
        "conversation_id": str(CONVERSATION_ID),
        "message": message,
        "intent": intent.value,
        "conversation_state": flow_state.value,
        "ui": ui,
    }
    assert metadata["request_id"]
    assert datetime.fromisoformat(metadata["timestamp"]).tzinfo is not None


def test_periods_are_presented_as_local_days(
    chat_client: TestClient, stub: StubEngine
) -> None:
    # A persisted period may come back in UTC.
    in_utc = Period(OCTOBER.start.astimezone(UTC), OCTOBER.end.astimezone(UTC))
    stub.result = ExpenseAnalysisResult(ExpenseAnalysis(in_utc, None, ()))
    stub.intent = Intent.ANALYZE_EXPENSES

    response = post_message(chat_client)

    assert response.json()["ui"]["data"]["period"] == {
        "from": "2026-10-01",
        "to": "2026-10-31",
    }


@pytest.mark.parametrize(
    ("result", "status", "code"),
    [
        (
            PreValidationFailedResult(TRANSFER_TO_LAURA, InsufficientFundsError()),
            422,
            "INSUFFICIENT_FUNDS",
        ),
        (
            OperationFailedResult(FREEZE_VISA, InvalidCardStateError()),
            409,
            "INVALID_CARD_STATE",
        ),
        (
            PendingOperationConflictResult(
                Intent.FREEZE_CARD, PendingOperationType.TRANSFER
            ),
            409,
            "PENDING_OPERATION_CONFLICT",
        ),
    ],
    ids=["pre_validation_failed", "revalidation_failed", "conflict"],
)
def test_failed_operations_are_error_responses(
    chat_client: TestClient,
    stub: StubEngine,
    result: TurnResult,
    status: int,
    code: str,
) -> None:
    stub.result = result

    response = post_message(chat_client)

    assert response.status_code == status
    assert response.json()["code"] == code


# Errors.


def assert_api_error(response: Any, status: int, code: str) -> dict[str, Any]:
    assert response.status_code == status
    body: dict[str, Any] = response.json()
    assert set(body) == {"code", "message", "request_id", "timestamp"}
    assert body["code"] == code
    UUID(body["request_id"])
    return body


@pytest.fixture
def failing_client(app: FastAPI, stub: StubEngine) -> Iterator[TestClient]:
    """A client that receives unexpected errors as responses, like a real one."""
    app.dependency_overrides[get_conversation_engine] = lambda: stub
    with TestClient(app, raise_server_exceptions=False) as client:
        yield client


@pytest.mark.parametrize(
    ("error", "status"),
    [
        (ConversationNotFoundError(), 404),
        (ConversationClosedError(), 409),
        (InvalidConversationStateError(), 409),
        (InvalidInteractionError(), 409),
        (LLMUnavailableError(), 503),
    ],
    ids=[
        "conversation_not_found",
        "conversation_closed",
        "invalid_conversation_state",
        "invalid_interaction",
        "service_unavailable",
    ],
)
def test_engine_errors_are_error_responses(
    chat_client: TestClient,
    stub: StubEngine,
    error: ApplicationError,
    status: int,
) -> None:
    stub.error = error

    body = assert_api_error(post_message(chat_client), status, error.code)

    assert body["message"] == error.message


_CONVERSATION = str(CONVERSATION_ID)


@pytest.mark.parametrize(
    "content",
    [
        "{not json",
        json.dumps({"message": "Hola"}),
        json.dumps({"conversation_id": "not-a-uuid", "message": "Hola"}),
        json.dumps({"conversation_id": _CONVERSATION, "message": "Hola", "x": 1}),
        json.dumps({"conversation_id": _CONVERSATION, "message": "   "}),
        json.dumps({"conversation_id": _CONVERSATION}),
        json.dumps({"conversation_id": _CONVERSATION, "interaction": "CONFIRM"}),
        json.dumps(
            {
                "conversation_id": _CONVERSATION,
                "interaction": "CONFIRM",
                "payload": {"card_id": str(VISA_DEBIT.id)},
            }
        ),
        json.dumps(
            {
                "conversation_id": _CONVERSATION,
                "interaction": "CANCEL",
                "payload": {"operation_id": str(OPERATION_ID)},
            }
        ),
        json.dumps({"conversation_id": _CONVERSATION, "interaction": "TRANSFER"}),
    ],
    ids=[
        "malformed_json",
        "missing_conversation_id",
        "malformed_conversation_id",
        "unknown_field",
        "blank_message",
        "neither_message_nor_interaction",
        "missing_payload",
        "incompatible_payload",
        "unexpected_payload",
        "unknown_interaction",
    ],
)
def test_invalid_requests_are_invalid_request_errors(
    chat_client: TestClient, stub: StubEngine, content: str
) -> None:
    response = chat_client.post(
        "/chat", content=content, headers={"Content-Type": "application/json"}
    )

    body = assert_api_error(response, 422, "INVALID_REQUEST")
    assert body["message"] == "The request is invalid."
    assert stub.calls == []


@pytest.mark.parametrize(
    ("path", "body", "error"),
    [
        ("/conversations", None, RuntimeError("database password is s3cret")),
        (
            "/chat",
            {"conversation_id": _CONVERSATION, "message": "Hola"},
            ConversationStateCorruptedError("stored flow state s3cret is invalid"),
        ),
    ],
    ids=["conversations", "chat"],
)
def test_unexpected_errors_are_internal_errors_without_details(
    failing_client: TestClient,
    stub: StubEngine,
    caplog: pytest.LogCaptureFixture,
    path: str,
    body: dict[str, Any] | None,
    error: Exception,
) -> None:
    stub.error = error

    response = failing_client.post(path, json=body)

    error_body = assert_api_error(response, 500, "INTERNAL_ERROR")
    assert error_body["message"] == "An unexpected error occurred."
    assert "s3cret" not in response.text
    assert type(error).__name__ not in response.text
    [record] = [r for r in caplog.records if error_body["request_id"] in r.message]
    assert record.levelno == logging.ERROR


@pytest.mark.parametrize(
    ("error", "level"),
    [
        (ConversationNotFoundError(), logging.INFO),
        (LLMUnavailableError(), logging.WARNING),
    ],
    ids=["client_error", "service_unavailable"],
)
def test_handled_errors_are_logged_with_their_request_id(
    chat_client: TestClient,
    stub: StubEngine,
    caplog: pytest.LogCaptureFixture,
    error: Exception,
    level: int,
) -> None:
    caplog.set_level(logging.INFO, logger="mimi.api.errors")
    stub.error = error

    request_id = post_message(chat_client).json()["request_id"]

    [record] = [r for r in caplog.records if request_id in r.message]
    assert record.levelno == level


def test_each_request_has_its_own_request_id(chat_client: TestClient) -> None:
    first = post_message(chat_client).json()["metadata"]["request_id"]
    second = chat_client.post("/conversations").json()["metadata"]["request_id"]

    assert UUID(first) != UUID(second)


def test_openapi_documents_the_chat_contract(chat_client: TestClient) -> None:
    schema = chat_client.get("/openapi.json").json()

    chat = schema["paths"]["/chat"]["post"]
    variants = chat["requestBody"]["content"]["application/json"]["schema"]["oneOf"]
    assert {ref["$ref"].rsplit("/", 1)[1] for ref in variants} == {
        "MessageRequest",
        "ConfirmRequest",
        "CancelRequest",
        "SelectCardRequest",
    }
    assert chat["responses"]["200"]["content"]["application/json"]["schema"] == {
        "$ref": "#/components/schemas/ChatResponse"
    }
    conversations = schema["paths"]["/conversations"]["post"]
    assert conversations["responses"]["201"]["content"]["application/json"][
        "schema"
    ] == {"$ref": "#/components/schemas/ConversationResponse"}


def test_openapi_documents_error_responses(chat_client: TestClient) -> None:
    schema = chat_client.get("/openapi.json").json()

    expected = {
        "/chat": {"404", "409", "422", "500", "503"},
        "/conversations": {"500"},
    }
    for path, statuses in expected.items():
        responses = schema["paths"][path]["post"]["responses"]
        errors = {
            status: r for status, r in responses.items() if not status.startswith("2")
        }
        assert set(errors) == statuses
        for response in errors.values():
            assert response["content"]["application/json"]["schema"] == {
                "$ref": "#/components/schemas/ApiErrorResponse"
            }
    assert "HTTPValidationError" not in schema["components"]["schemas"]


# End to end.


class ScriptedLLMProvider:
    """Answers every interpretation with ``intent`` and every collection
    request with details; both carry ``values``. Raises ``error`` when set."""

    def __init__(self) -> None:
        self.intent = Intent.GET_BALANCE
        self.values: dict[str, Any] = {}
        self.error: Exception | None = None

    def generate_structured[T: BaseModel](
        self, *, instructions: str, input_text: str, output_type: type[T]
    ) -> T:
        if self.error is not None:
            raise self.error
        output: dict[str, Any] = dict.fromkeys(output_type.model_fields)
        if "kind" in output:
            output["kind"] = "DETAILS"
        else:
            output["intent"] = self.intent.value
        output.update(self.values)
        return output_type.model_validate(output)


@pytest.fixture
def scripted() -> ScriptedLLMProvider:
    return ScriptedLLMProvider()


@pytest.fixture
def llm_provider(scripted: ScriptedLLMProvider) -> LLMProvider:
    return scripted


@pytest.fixture
def seeded(migrated_engine: Engine, test_settings: Settings) -> None:
    customer = CustomerModel(
        id=test_settings.demo_customer_id, first_name="Ana", last_name="Ruiz"
    )
    with create_session_factory(migrated_engine).begin() as session:
        session.add_all(
            [
                customer,
                AccountModel(
                    id=SAVINGS.id,
                    customer=customer,
                    name=SAVINGS.name,
                    balance=Decimal("150000.50"),
                    currency=Currency.ARS,
                    status=AccountStatus.ACTIVE,
                ),
                BeneficiaryModel(
                    id=LAURA.id,
                    customer=customer,
                    name=LAURA.name,
                    account_reference=LAURA.account_reference,
                    bank_name=None,
                ),
            ]
        )


@pytest.mark.integration
@pytest.mark.usefixtures("seeded")
def test_transfer_round_trip_over_http(
    test_container: Container, scripted: ScriptedLLMProvider
) -> None:
    with TestClient(create_app(test_container)) as client:
        started = client.post("/conversations")
        assert started.status_code == 201
        conversation_id = started.json()["conversation_id"]

        scripted.intent = Intent.TRANSFER_MONEY
        scripted.values = {"amount": "25000", "beneficiary_reference": "Laura"}
        requested = client.post(
            "/chat",
            json={
                "conversation_id": conversation_id,
                "message": "Transferile 25000 a Laura",
            },
        ).json()
        assert requested["conversation_state"] == "WAITING_CONFIRMATION"
        assert requested["ui"]["type"] == "CONFIRMATION"
        operation_id = requested["ui"]["data"]["operation_id"]

        confirmed = client.post(
            "/chat",
            json={
                "conversation_id": conversation_id,
                "interaction": "CONFIRM",
                "payload": {"operation_id": operation_id},
            },
        )

    assert confirmed.status_code == 200
    body = confirmed.json()
    assert body["conversation_state"] == "READY"
    assert body["intent"] == "TRANSFER_MONEY"
    assert body["ui"]["type"] == "TRANSFER_SUMMARY"
    assert body["ui"]["data"]["beneficiary"] == "Laura"
    assert body["ui"]["data"]["amount"] == ars("25000.00")
    with Session(test_container.engine) as session:
        balance = session.get_one(AccountModel, SAVINGS.id).balance
    assert balance == Decimal("125000.50")


@pytest.mark.integration
@pytest.mark.usefixtures("migrated_engine")
def test_unknown_conversation_over_http(test_container: Container) -> None:
    with TestClient(create_app(test_container)) as client:
        response = client.post(
            "/chat", json={"conversation_id": str(uuid4()), "message": "Hola"}
        )

    assert_api_error(response, 404, "CONVERSATION_NOT_FOUND")


@pytest.mark.integration
@pytest.mark.usefixtures("seeded")
def test_unavailable_llm_over_http(
    test_container: Container, scripted: ScriptedLLMProvider
) -> None:
    scripted.error = LLMUnavailableError()
    with TestClient(create_app(test_container)) as client:
        conversation_id = client.post("/conversations").json()["conversation_id"]
        response = client.post(
            "/chat",
            json={"conversation_id": conversation_id, "message": "¿Cuánta plata?"},
        )

    assert_api_error(response, 503, "SERVICE_UNAVAILABLE")
