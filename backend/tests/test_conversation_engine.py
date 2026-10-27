from collections.abc import Callable, Iterator
from contextlib import contextmanager
from dataclasses import dataclass, replace
from datetime import datetime, timedelta, timezone
from decimal import Decimal
from typing import Any, NoReturn
from uuid import UUID, uuid4
from zoneinfo import ZoneInfo

import pytest
from pydantic import BaseModel

from mimi.application.conversation_context import (
    EMPTY_CONTEXT,
    ConversationContext,
    TemporalContext,
)
from mimi.application.conversation_engine import ConversationEngine, Turn
from mimi.application.conversation_results import (
    AwaitingConfirmationResult,
    BalancesResult,
    CollectingDataResult,
    ExpenseAnalysisResult,
    FieldIssue,
    IncompleteQueryResult,
    NoPendingOperationResult,
    OperationCancelledResult,
    OperationCompletedResult,
    OperationFailedResult,
    PendingOperationConflictResult,
    PreValidationFailedResult,
    TransactionsResult,
    UnhandledIntentResult,
)
from mimi.application.errors import (
    ConversationClosedError,
    ConversationNotFoundError,
    ConversationStateCorruptedError,
    InsufficientFundsError,
    InvalidCardStateError,
    InvalidConversationStateError,
    InvalidInteractionError,
    LLMInvalidResponseError,
    LLMUnavailableError,
)
from mimi.application.interactions import Cancel, Confirm, Interaction, SelectCard
from mimi.application.interpretation import Intent, PeriodReference
from mimi.application.pending_operations import (
    FreezeCardOperationData,
    PendingField,
    PendingOperation,
    TransferOperationData,
    UnfreezeCardOperationData,
)
from mimi.application.read_only_queries import ReadOnlyQueryRouter
from mimi.application.repositories import ConversationRecord, TransactionQuery
from mimi.application.use_cases.analyze_expenses import Period
from mimi.application.use_cases.interpret_message import (
    InterpretCollectionInput,
    InterpretMessage,
)
from mimi.domain.entities import (
    Account,
    Beneficiary,
    Card,
    Conversation,
    Message,
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
    MessageRole,
    PendingOperationType,
    TransactionCategory,
)

BUENOS_AIRES = timezone(timedelta(hours=-3))
STARTED_AT = datetime(2026, 10, 9, 13, 0, tzinfo=BUENOS_AIRES)
NOW = datetime(2026, 10, 9, 13, 31, 4, tzinfo=BUENOS_AIRES)

CUSTOMER_ID = uuid4()
OTHER_CUSTOMER_ID = uuid4()

SAVINGS = Account(
    id=uuid4(),
    customer_id=CUSTOMER_ID,
    name="Caja de ahorro",
    balance=Money(Decimal("150000.50"), Currency.ARS),
    status=AccountStatus.ACTIVE,
)

PENDING_TRANSFER = PendingOperation(
    PendingOperationType.TRANSFER,
    TransferOperationData(
        source_account_id=SAVINGS.id,
        beneficiary_id=uuid4(),
        amount=Money(Decimal("25000.00"), Currency.ARS),
    ),
    operation_id=uuid4(),
)

EMPTY_OUTPUT: dict[str, Any] = {
    "intent": "UNKNOWN",
    "amount": None,
    "currency": None,
    "beneficiary_reference": None,
    "card_reference": None,
    "category": None,
    "transaction_type": None,
    "period": None,
    "comparison_period": None,
    "relative_period": None,
}


def model_output(**fields: Any) -> dict[str, Any]:
    return {**EMPTY_OUTPUT, **fields}


EMPTY_COLLECTION_OUTPUT: dict[str, Any] = {
    "kind": "DETAILS",
    "amount": None,
    "currency": None,
    "beneficiary_reference": None,
    "account_reference": None,
    "card_reference": None,
}


def collection_output(**fields: Any) -> dict[str, Any]:
    return {**EMPTY_COLLECTION_OUTPUT, **fields}


def refuse_write(*args: object) -> NoReturn:
    raise AssertionError("read-only routing must not write")


class FakeTransferRepository:
    def __init__(self) -> None:
        self.transfers: list[tuple[Transfer, Transaction | None]] = []
        self.writable = False

    def add(self, transfer: Transfer, transaction: Transaction | None) -> None:
        if not self.writable:
            refuse_write()
        self.transfers.append((transfer, transaction))


class FakeConversationRepository:
    def __init__(self) -> None:
        self.records: dict[UUID, ConversationRecord] = {}

    def add(self, record: ConversationRecord) -> None:
        self.records[record.conversation.id] = record

    def get_for_update(
        self, customer_id: UUID, conversation_id: UUID
    ) -> ConversationRecord | None:
        record = self.records.get(conversation_id)
        if record is None or record.conversation.customer_id != customer_id:
            return None
        return record

    def save_pending_operation(
        self,
        conversation_id: UUID,
        flow_state: ConversationFlowState,
        pending_operation: PendingOperation | None,
    ) -> None:
        self.records[conversation_id] = replace(
            self.records[conversation_id],
            flow_state=flow_state,
            pending_operation=pending_operation,
        )

    def mark_closed(self, conversation_id: UUID) -> None:
        record = self.records[conversation_id]
        self.records[conversation_id] = replace(
            record,
            conversation=replace(record.conversation, status=ConversationStatus.CLOSED),
        )

    def touch(self, conversation_id: UUID, updated_at: datetime) -> None:
        record = self.records[conversation_id]
        self.records[conversation_id] = replace(
            record, conversation=replace(record.conversation, updated_at=updated_at)
        )

    def save_context(self, conversation_id: UUID, context: ConversationContext) -> None:
        self.records[conversation_id] = replace(
            self.records[conversation_id], context=context
        )


class FakeMessageRepository:
    def __init__(self) -> None:
        self.messages: list[Message] = []

    def add(self, message: Message) -> None:
        self.messages.append(message)

    def list_by_conversation(self, conversation_id: UUID) -> list[Message]:
        return [m for m in self.messages if m.conversation_id == conversation_id]


class FakeAccountRepository:
    def __init__(self) -> None:
        self.accounts: list[Account] = []
        self.locked: list[UUID] = []
        self.writable = False

    def list_by_customer(self, customer_id: UUID) -> list[Account]:
        return [a for a in self.accounts if a.customer_id == customer_id]

    def get_for_update(self, customer_id: UUID, account_id: UUID) -> Account | None:
        self.locked.append(account_id)
        return next(
            (a for a in self.list_by_customer(customer_id) if a.id == account_id), None
        )

    def update_balance(self, account_id: UUID, balance: Money) -> None:
        if not self.writable:
            refuse_write()
        self.accounts = [
            replace(a, balance=balance) if a.id == account_id else a
            for a in self.accounts
        ]


class FakeCardRepository:
    """Cards of ``CUSTOMER_ID``."""

    def __init__(self) -> None:
        self.cards: list[Card] = []
        self.writable = False

    def list_by_customer(self, customer_id: UUID) -> list[Card]:
        return list(self.cards) if customer_id == CUSTOMER_ID else []

    def get(self, customer_id: UUID, card_id: UUID) -> Card | None:
        return next(
            (c for c in self.list_by_customer(customer_id) if c.id == card_id), None
        )

    def update_status(self, card_id: UUID, status: CardStatus) -> None:
        if not self.writable:
            refuse_write()
        self.cards = [
            replace(c, status=status) if c.id == card_id else c for c in self.cards
        ]


class FakeBeneficiaryRepository:
    def __init__(self) -> None:
        self.beneficiaries: list[Beneficiary] = []

    def list_by_customer(self, customer_id: UUID) -> list[Beneficiary]:
        return [b for b in self.beneficiaries if b.customer_id == customer_id]

    def get(self, customer_id: UUID, beneficiary_id: UUID) -> Beneficiary | None:
        return next(
            (b for b in self.list_by_customer(customer_id) if b.id == beneficiary_id),
            None,
        )


class FakeTransactionRepository:
    def __init__(self) -> None:
        self.queries: list[TransactionQuery] = []

    def list_by_customer(
        self, customer_id: UUID, query: TransactionQuery
    ) -> list[Transaction]:
        self.queries.append(query)
        return []


@dataclass(frozen=True)
class FakeRepositories:
    conversations: FakeConversationRepository
    messages: FakeMessageRepository
    accounts: FakeAccountRepository
    cards: FakeCardRepository
    beneficiaries: FakeBeneficiaryRepository
    transactions: FakeTransactionRepository
    transfers: FakeTransferRepository


class FakeTransactionScope:
    def __init__(self) -> None:
        self.repositories = FakeRepositories(
            FakeConversationRepository(),
            FakeMessageRepository(),
            FakeAccountRepository(),
            FakeCardRepository(),
            FakeBeneficiaryRepository(),
            FakeTransactionRepository(),
            FakeTransferRepository(),
        )
        self.in_transaction = False
        self.committed = 0

    @contextmanager
    def begin(self) -> Iterator[FakeRepositories]:
        assert not self.in_transaction, "transactions must not nest"
        self.in_transaction = True
        try:
            yield self.repositories
            self.committed += 1
        finally:
            self.in_transaction = False


class FakeLLMProvider:
    """Validates a canned payload against the requested schema and records
    whether a database transaction was open when it was called.

    ``output`` answers message interpretation and ``collection_output`` answers
    collection interpretation, which by default is not collection input.
    """

    def __init__(self, scope: FakeTransactionScope) -> None:
        self._scope = scope
        self.output = model_output(intent="GET_BALANCE")
        self.collection_output = collection_output(kind="OTHER")
        self.error: Exception | None = None
        self.on_call: Callable[[], None] | None = None
        self.calls: list[str] = []
        self.collection_calls: list[str] = []
        self.called_in_transaction: list[bool] = []

    def generate_structured[T: BaseModel](
        self, *, instructions: str, input_text: str, output_type: type[T]
    ) -> T:
        collecting = "kind" in output_type.model_fields
        (self.collection_calls if collecting else self.calls).append(input_text)
        self.called_in_transaction.append(self._scope.in_transaction)
        if self.on_call is not None:
            self.on_call()
        if self.error is not None:
            raise self.error
        return output_type.model_validate(
            self.collection_output if collecting else self.output
        )


@pytest.fixture
def scope() -> FakeTransactionScope:
    scope = FakeTransactionScope()
    scope.repositories.accounts.accounts.append(SAVINGS)
    return scope


@pytest.fixture
def llm(scope: FakeTransactionScope) -> FakeLLMProvider:
    return FakeLLMProvider(scope)


def make_engine(
    scope: FakeTransactionScope,
    llm: FakeLLMProvider,
    clock: Callable[[], datetime] = lambda: NOW,
) -> ConversationEngine:
    return ConversationEngine(
        scope,
        interpreter=InterpretMessage(llm),
        collection_interpreter=InterpretCollectionInput(llm),
        router=ReadOnlyQueryRouter(ZoneInfo("America/Argentina/Buenos_Aires")),
        clock=clock,
    )


@pytest.fixture
def engine(scope: FakeTransactionScope, llm: FakeLLMProvider) -> ConversationEngine:
    return make_engine(scope, llm)


def store_conversation(
    scope: FakeTransactionScope,
    *,
    status: ConversationStatus = ConversationStatus.ACTIVE,
    customer_id: UUID = CUSTOMER_ID,
) -> ConversationRecord:
    record = ConversationRecord(
        conversation=Conversation(
            id=uuid4(),
            customer_id=customer_id,
            status=status,
            created_at=STARTED_AT,
            updated_at=STARTED_AT,
        ),
        flow_state=ConversationFlowState.READY,
    )
    scope.repositories.conversations.add(record)
    return record


def replace_stored(
    scope: FakeTransactionScope, conversation_id: UUID, **changes: Any
) -> None:
    records = scope.repositories.conversations.records
    records[conversation_id] = replace(records[conversation_id], **changes)


def test_start_persists_active_ready_conversation(
    engine: ConversationEngine, scope: FakeTransactionScope
) -> None:
    record = engine.start(CUSTOMER_ID)

    assert record.conversation.customer_id == CUSTOMER_ID
    assert record.conversation.status is ConversationStatus.ACTIVE
    assert record.conversation.created_at == NOW
    assert record.conversation.updated_at == NOW
    assert record.flow_state is ConversationFlowState.READY
    assert scope.repositories.conversations.records == {record.conversation.id: record}
    assert scope.committed == 1


def test_start_creates_distinct_conversations(engine: ConversationEngine) -> None:
    first = engine.start(CUSTOMER_ID)
    second = engine.start(CUSTOMER_ID)

    assert first.conversation.id != second.conversation.id


def test_handle_message_persists_user_message_and_answers_query(
    engine: ConversationEngine, scope: FakeTransactionScope
) -> None:
    record = store_conversation(scope)

    turn = engine.handle_message(
        CUSTOMER_ID, record.conversation.id, "What's my balance?"
    )

    assert turn.message is not None
    expected_message = Message(
        id=turn.message.id,
        conversation_id=record.conversation.id,
        role=MessageRole.USER,
        content="What's my balance?",
        created_at=NOW,
    )
    assert turn == Turn(
        conversation_id=record.conversation.id,
        flow_state=ConversationFlowState.READY,
        message=expected_message,
        intent=Intent.GET_BALANCE,
        result=BalancesResult((SAVINGS,)),
    )
    assert scope.repositories.messages.list_by_conversation(record.conversation.id) == [
        expected_message
    ]


def test_handle_message_interprets_content_outside_any_transaction(
    engine: ConversationEngine, scope: FakeTransactionScope, llm: FakeLLMProvider
) -> None:
    record = store_conversation(scope)

    engine.handle_message(CUSTOMER_ID, record.conversation.id, "What's my balance?")

    assert llm.calls == ["What's my balance?"]
    assert llm.called_in_transaction == [False]
    assert scope.committed == 2


def test_handle_message_updates_conversation_activity(
    engine: ConversationEngine, scope: FakeTransactionScope
) -> None:
    record = store_conversation(scope)

    engine.handle_message(CUSTOMER_ID, record.conversation.id, "Hello Mimi.")

    stored = scope.repositories.conversations.records[record.conversation.id]
    assert stored.conversation.updated_at == NOW
    assert stored.conversation.created_at == STARTED_AT


def test_handle_message_does_not_change_flow_state(
    engine: ConversationEngine, scope: FakeTransactionScope
) -> None:
    record = store_conversation(scope)

    engine.handle_message(CUSTOMER_ID, record.conversation.id, "What's my balance?")

    stored = scope.repositories.conversations.records[record.conversation.id]
    assert stored.flow_state is ConversationFlowState.READY


def test_operation_started_during_interpretation_persists_nothing(
    engine: ConversationEngine, scope: FakeTransactionScope, llm: FakeLLMProvider
) -> None:
    # The message was interpreted without the operation that is now pending.
    record = store_conversation(scope)
    conversation_id = record.conversation.id
    llm.on_call = lambda: replace_stored(
        scope,
        conversation_id,
        flow_state=ConversationFlowState.WAITING_CONFIRMATION,
        pending_operation=PENDING_TRANSFER,
    )

    with pytest.raises(InvalidConversationStateError):
        engine.handle_message(CUSTOMER_ID, conversation_id, "What's my balance?")

    stored = scope.repositories.conversations.records[conversation_id]
    assert stored.flow_state is ConversationFlowState.WAITING_CONFIRMATION
    assert stored.pending_operation == PENDING_TRANSFER
    assert scope.repositories.messages.messages == []


@pytest.mark.parametrize("intent", ["GENERAL_CONVERSATION", "CANCEL", "UNKNOWN"])
def test_handle_message_leaves_other_intents_unhandled(
    engine: ConversationEngine,
    scope: FakeTransactionScope,
    llm: FakeLLMProvider,
    intent: str,
) -> None:
    record = store_conversation(scope)
    llm.output = model_output(
        intent=intent, amount="25000", beneficiary_reference="Laura"
    )

    turn = engine.handle_message(CUSTOMER_ID, record.conversation.id, "Do something.")

    assert turn.intent is Intent(intent)
    assert turn.result == UnhandledIntentResult(Intent(intent))
    assert scope.repositories.messages.messages == [turn.message]


def test_handle_message_reports_unsupported_query_values(
    engine: ConversationEngine, scope: FakeTransactionScope, llm: FakeLLMProvider
) -> None:
    record = store_conversation(scope)
    llm.output = model_output(intent="ANALYZE_EXPENSES", category="UNSUPPORTED")

    turn = engine.handle_message(
        CUSTOMER_ID, record.conversation.id, "How much did I spend on health?"
    )

    assert turn.result == IncompleteQueryResult(
        Intent.ANALYZE_EXPENSES, unsupported_fields=frozenset({"category"})
    )


@pytest.mark.parametrize(
    "error", [LLMUnavailableError(), LLMInvalidResponseError()], ids=type
)
def test_failed_interpretation_persists_nothing(
    engine: ConversationEngine,
    scope: FakeTransactionScope,
    llm: FakeLLMProvider,
    error: Exception,
) -> None:
    record = store_conversation(scope)
    llm.error = error

    with pytest.raises(type(error)):
        engine.handle_message(CUSTOMER_ID, record.conversation.id, "Hello Mimi.")

    assert scope.repositories.messages.messages == []
    assert scope.repositories.conversations.records[record.conversation.id] == record
    assert not scope.in_transaction


def test_conversation_closed_during_interpretation_persists_nothing(
    engine: ConversationEngine, scope: FakeTransactionScope, llm: FakeLLMProvider
) -> None:
    record = store_conversation(scope)
    conversation_id = record.conversation.id
    closed = replace(
        record,
        conversation=replace(record.conversation, status=ConversationStatus.CLOSED),
    )
    llm.on_call = lambda: scope.repositories.conversations.add(closed)

    with pytest.raises(ConversationClosedError):
        engine.handle_message(CUSTOMER_ID, conversation_id, "What's my balance?")

    assert scope.repositories.messages.messages == []
    assert scope.repositories.conversations.records[conversation_id] == closed


def test_conversation_removed_during_interpretation_is_not_found(
    engine: ConversationEngine, scope: FakeTransactionScope, llm: FakeLLMProvider
) -> None:
    record = store_conversation(scope)
    conversation_id = record.conversation.id
    llm.on_call = lambda: scope.repositories.conversations.records.clear()

    with pytest.raises(ConversationNotFoundError):
        engine.handle_message(CUSTOMER_ID, conversation_id, "What's my balance?")

    assert scope.repositories.messages.messages == []


def test_handle_message_rejects_unknown_conversation(
    engine: ConversationEngine, scope: FakeTransactionScope, llm: FakeLLMProvider
) -> None:
    with pytest.raises(ConversationNotFoundError):
        engine.handle_message(CUSTOMER_ID, uuid4(), "Hello Mimi.")

    assert scope.repositories.messages.messages == []
    assert llm.calls == []


def test_handle_message_rejects_other_customers_conversation(
    engine: ConversationEngine, scope: FakeTransactionScope, llm: FakeLLMProvider
) -> None:
    record = store_conversation(scope, customer_id=OTHER_CUSTOMER_ID)

    with pytest.raises(ConversationNotFoundError):
        engine.handle_message(CUSTOMER_ID, record.conversation.id, "Hello Mimi.")

    assert scope.repositories.messages.messages == []
    assert scope.repositories.conversations.records[record.conversation.id] == record
    assert llm.calls == []


def test_handle_message_rejects_closed_conversation(
    engine: ConversationEngine, scope: FakeTransactionScope, llm: FakeLLMProvider
) -> None:
    record = store_conversation(scope, status=ConversationStatus.CLOSED)

    with pytest.raises(ConversationClosedError):
        engine.handle_message(CUSTOMER_ID, record.conversation.id, "Hello Mimi.")

    assert scope.repositories.messages.messages == []
    assert scope.repositories.conversations.records[record.conversation.id] == record
    assert llm.calls == []


@pytest.mark.parametrize("content", ["", "   ", "\t\n"])
def test_handle_message_rejects_blank_content(
    engine: ConversationEngine,
    scope: FakeTransactionScope,
    llm: FakeLLMProvider,
    content: str,
) -> None:
    record = store_conversation(scope)

    with pytest.raises(ValueError, match="blank"):
        engine.handle_message(CUSTOMER_ID, record.conversation.id, content)

    assert scope.repositories.messages.messages == []
    assert llm.calls == []


def test_naive_clock_is_rejected(
    scope: FakeTransactionScope, llm: FakeLLMProvider
) -> None:
    engine = make_engine(scope, llm, clock=lambda: NOW.replace(tzinfo=None))
    record = store_conversation(scope)

    with pytest.raises(ValueError, match="timezone-aware"):
        engine.start(CUSTOMER_ID)
    with pytest.raises(ValueError, match="timezone-aware"):
        engine.handle_message(CUSTOMER_ID, record.conversation.id, "Hello Mimi.")

    assert list(scope.repositories.conversations.records) == [record.conversation.id]
    assert scope.repositories.messages.messages == []
    assert llm.calls == []


# NOW is Friday Oct 9th in Buenos Aires.
SEPTEMBER = Period(
    datetime(2026, 9, 1, tzinfo=BUENOS_AIRES),
    datetime(2026, 10, 1, tzinfo=BUENOS_AIRES),
)
PREVIOUS_WEEK = Period(
    datetime(2026, 9, 28, tzinfo=BUENOS_AIRES),
    datetime(2026, 10, 5, tzinfo=BUENOS_AIRES),
)
PREVIOUS_PERIOD = model_output(intent="FOLLOW_UP", relative_period="PREVIOUS")


def send(
    engine: ConversationEngine,
    llm: FakeLLMProvider,
    conversation_id: UUID,
    content: str,
    output: dict[str, Any],
) -> Turn:
    llm.output = output
    return engine.handle_message(CUSTOMER_ID, conversation_id, content)


def stored_context(
    scope: FakeTransactionScope, conversation_id: UUID
) -> ConversationContext:
    return scope.repositories.conversations.records[conversation_id].context


def test_previous_period_follow_up_continues_expense_analysis(
    engine: ConversationEngine, scope: FakeTransactionScope, llm: FakeLLMProvider
) -> None:
    conversation_id = store_conversation(scope).conversation.id
    send(
        engine,
        llm,
        conversation_id,
        "¿En qué gasté más este mes?",
        model_output(intent="ANALYZE_EXPENSES", period="CURRENT_MONTH"),
    )

    turn = send(engine, llm, conversation_id, "¿Y el anterior?", PREVIOUS_PERIOD)

    assert turn.intent is Intent.ANALYZE_EXPENSES
    assert isinstance(turn.result, ExpenseAnalysisResult)
    assert turn.result.analysis.period == SEPTEMBER
    assert stored_context(scope, conversation_id) == ConversationContext(
        last_intent=Intent.ANALYZE_EXPENSES,
        temporal=TemporalContext(PeriodReference.PREVIOUS_MONTH, None, NOW),
    )


def test_stated_period_follow_up_continues_transactions(
    engine: ConversationEngine, scope: FakeTransactionScope, llm: FakeLLMProvider
) -> None:
    conversation_id = store_conversation(scope).conversation.id
    send(
        engine,
        llm,
        conversation_id,
        "Mostrame mis movimientos de este mes en restaurantes.",
        model_output(
            intent="GET_TRANSACTIONS", period="CURRENT_MONTH", category="DINING"
        ),
    )

    turn = send(
        engine,
        llm,
        conversation_id,
        "¿Y la semana pasada?",
        model_output(intent="FOLLOW_UP", period="PREVIOUS_WEEK"),
    )

    assert turn.intent is Intent.GET_TRANSACTIONS
    assert turn.result == TransactionsResult((), PREVIOUS_WEEK)
    assert scope.repositories.transactions.queries[-1] == TransactionQuery(
        occurred_from=PREVIOUS_WEEK.start,
        occurred_to=PREVIOUS_WEEK.end,
        category=TransactionCategory.DINING,
    )


def test_default_period_of_executed_query_is_kept_in_context(
    engine: ConversationEngine, scope: FakeTransactionScope, llm: FakeLLMProvider
) -> None:
    conversation_id = store_conversation(scope).conversation.id
    send(
        engine,
        llm,
        conversation_id,
        "¿Cuánto gasté en el super?",
        model_output(intent="ANALYZE_EXPENSES", category="GROCERIES"),
    )

    assert stored_context(scope, conversation_id) == ConversationContext(
        last_intent=Intent.ANALYZE_EXPENSES,
        category=TransactionCategory.GROCERIES,
        temporal=TemporalContext(PeriodReference.CURRENT_MONTH, None, NOW),
    )


def test_follow_up_without_context_executes_no_query(
    engine: ConversationEngine, scope: FakeTransactionScope, llm: FakeLLMProvider
) -> None:
    conversation_id = store_conversation(scope).conversation.id

    turn = send(engine, llm, conversation_id, "¿Y el mes pasado?", PREVIOUS_PERIOD)

    assert turn.intent is Intent.UNKNOWN
    assert turn.result == IncompleteQueryResult(
        Intent.UNKNOWN, missing_fields=frozenset({"context"})
    )
    assert scope.repositories.transactions.queries == []
    assert scope.repositories.messages.messages == [turn.message]
    assert stored_context(scope, conversation_id) == EMPTY_CONTEXT


@pytest.mark.parametrize(
    "output",
    [
        model_output(intent="GENERAL_CONVERSATION"),
        model_output(intent="UNKNOWN"),
        model_output(intent="TRANSFER_MONEY", amount="25000"),
        model_output(intent="GET_TRANSACTIONS", category="UNSUPPORTED"),
        model_output(intent="COMPARE_EXPENSES"),
        model_output(intent="FOLLOW_UP", transaction_type="CREDIT"),
    ],
    ids=["conversation", "unknown", "mutation", "unsupported", "incomplete", "follow"],
)
def test_turns_executing_no_query_keep_the_context(
    engine: ConversationEngine,
    scope: FakeTransactionScope,
    llm: FakeLLMProvider,
    output: dict[str, Any],
) -> None:
    conversation_id = store_conversation(scope).conversation.id
    send(
        engine,
        llm,
        conversation_id,
        "¿Cuánto gasté este mes?",
        model_output(intent="ANALYZE_EXPENSES", period="CURRENT_MONTH"),
    )
    context = stored_context(scope, conversation_id)

    send(engine, llm, conversation_id, "Something else.", output)

    assert stored_context(scope, conversation_id) == context
    turn = send(engine, llm, conversation_id, "¿Y el anterior?", PREVIOUS_PERIOD)
    assert isinstance(turn.result, ExpenseAnalysisResult)
    assert turn.result.analysis.period == SEPTEMBER


def test_executed_query_replaces_the_context(
    engine: ConversationEngine, scope: FakeTransactionScope, llm: FakeLLMProvider
) -> None:
    conversation_id = store_conversation(scope).conversation.id
    send(
        engine,
        llm,
        conversation_id,
        "¿Cuánto gasté este mes en el super?",
        model_output(
            intent="ANALYZE_EXPENSES", period="CURRENT_MONTH", category="GROCERIES"
        ),
    )
    send(
        engine,
        llm,
        conversation_id,
        "¿Cuánta plata tengo?",
        model_output(intent="GET_BALANCE"),
    )

    turn = send(engine, llm, conversation_id, "¿Y el anterior?", PREVIOUS_PERIOD)

    assert stored_context(scope, conversation_id) == ConversationContext(
        last_intent=Intent.GET_BALANCE
    )
    assert turn.result == IncompleteQueryResult(
        Intent.GET_BALANCE, unsupported_fields=frozenset({"period"})
    )
    assert len(scope.repositories.transactions.queries) == 1  # the first query only


def test_follow_up_is_resolved_against_context_read_under_turn_lock(
    engine: ConversationEngine, scope: FakeTransactionScope, llm: FakeLLMProvider
) -> None:
    conversation_id = store_conversation(scope).conversation.id
    committed_meanwhile = ConversationContext(
        last_intent=Intent.ANALYZE_EXPENSES,
        category=TransactionCategory.DINING,
        temporal=TemporalContext(PeriodReference.CURRENT_MONTH, None, NOW),
    )
    llm.on_call = lambda: replace_stored(
        scope, conversation_id, context=committed_meanwhile
    )

    turn = send(engine, llm, conversation_id, "¿Y el anterior?", PREVIOUS_PERIOD)

    assert isinstance(turn.result, ExpenseAnalysisResult)
    assert turn.result.analysis.period == SEPTEMBER
    assert turn.result.analysis.category is TransactionCategory.DINING


def test_read_only_turns_keep_the_pending_operation(
    engine: ConversationEngine, scope: FakeTransactionScope, llm: FakeLLMProvider
) -> None:
    conversation_id = store_conversation(scope).conversation.id
    replace_stored(
        scope,
        conversation_id,
        flow_state=ConversationFlowState.WAITING_CONFIRMATION,
        pending_operation=PENDING_TRANSFER,
    )

    turns = [
        send(
            engine,
            llm,
            conversation_id,
            "¿Cuánto gasté este mes?",
            model_output(intent="ANALYZE_EXPENSES", period="CURRENT_MONTH"),
        ),
        send(engine, llm, conversation_id, "¿Y el anterior?", PREVIOUS_PERIOD),
    ]

    stored = scope.repositories.conversations.records[conversation_id]
    assert stored.flow_state is ConversationFlowState.WAITING_CONFIRMATION
    assert stored.pending_operation == PENDING_TRANSFER
    assert [turn.flow_state for turn in turns] == [
        ConversationFlowState.WAITING_CONFIRMATION
    ] * 2
    assert isinstance(turns[1].result, ExpenseAnalysisResult)
    assert turns[1].result.analysis.period == SEPTEMBER


def test_corrupted_conversation_state_fails_before_interpretation(
    engine: ConversationEngine,
    scope: FakeTransactionScope,
    llm: FakeLLMProvider,
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    conversation_id = store_conversation(scope).conversation.id

    def corrupted(customer_id: UUID, conversation_id: UUID) -> NoReturn:
        raise ConversationStateCorruptedError()

    monkeypatch.setattr(scope.repositories.conversations, "get_for_update", corrupted)

    with pytest.raises(ConversationStateCorruptedError):
        engine.handle_message(CUSTOMER_ID, conversation_id, "¿Cuánta plata tengo?")

    assert llm.calls == []
    assert scope.repositories.messages.messages == []


# Data collection for state-changing operations.

DOLLARS = Account(
    id=uuid4(),
    customer_id=CUSTOMER_ID,
    name="Caja de ahorro en dólares",
    balance=Money(Decimal("1200.00"), Currency.USD),
    status=AccountStatus.ACTIVE,
)


def beneficiary(name: str) -> Beneficiary:
    return Beneficiary(uuid4(), CUSTOMER_ID, name, "0000003100012345678901", None)


LAURA = beneficiary("Laura Gómez")
CARLOS = beneficiary("Carlos Díaz")
JUAN_PEREZ = beneficiary("Juan Pérez")
JUAN_GARCIA = beneficiary("Juan García")

VISA_DEBIT = Card(
    uuid4(), SAVINGS.id, CardType.DEBIT, CardBrand.VISA, "4821", CardStatus.ACTIVE
)
VISA_CREDIT = Card(
    uuid4(), SAVINGS.id, CardType.CREDIT, CardBrand.VISA, "9134", CardStatus.FROZEN
)

TRANSFER_TO_LAURA = PendingOperation(
    PendingOperationType.TRANSFER, TransferOperationData(SAVINGS.id, LAURA.id)
)


@pytest.fixture
def banking(scope: FakeTransactionScope) -> FakeRepositories:
    repositories = scope.repositories
    repositories.beneficiaries.beneficiaries.extend(
        [LAURA, CARLOS, JUAN_PEREZ, JUAN_GARCIA]
    )
    repositories.cards.cards.extend([VISA_DEBIT, VISA_CREDIT])
    return repositories


def collecting(
    scope: FakeTransactionScope, operation: PendingOperation = TRANSFER_TO_LAURA
) -> UUID:
    conversation_id = store_conversation(scope).conversation.id
    replace_stored(
        scope,
        conversation_id,
        flow_state=ConversationFlowState.COLLECTING_DATA,
        pending_operation=operation,
    )
    return conversation_id


def reply(
    engine: ConversationEngine,
    llm: FakeLLMProvider,
    conversation_id: UUID,
    content: str,
    output: dict[str, Any],
) -> Turn:
    llm.collection_output = output
    return engine.handle_message(CUSTOMER_ID, conversation_id, content)


def stored_state(
    scope: FakeTransactionScope, conversation_id: UUID
) -> tuple[ConversationFlowState, PendingOperation | None]:
    record = scope.repositories.conversations.records[conversation_id]
    return record.flow_state, record.pending_operation


def awaiting(turn: Turn, operation: PendingOperation) -> PendingOperation:
    """``operation`` under the new operation id of the turn's confirmation
    request."""
    assert isinstance(turn.result, AwaitingConfirmationResult)
    operation_id = turn.result.operation.operation_id
    assert operation_id is not None
    return replace(operation, operation_id=operation_id)


def test_incomplete_request_starts_collecting_resolved_data(
    engine: ConversationEngine,
    scope: FakeTransactionScope,
    llm: FakeLLMProvider,
    banking: FakeRepositories,
) -> None:
    conversation_id = store_conversation(scope).conversation.id

    turn = send(
        engine,
        llm,
        conversation_id,
        "Pasale plata a Laura",
        model_output(intent="TRANSFER_MONEY", beneficiary_reference="Laura"),
    )

    assert turn.intent is Intent.TRANSFER_MONEY
    assert turn.flow_state is ConversationFlowState.COLLECTING_DATA
    assert turn.result == CollectingDataResult(TRANSFER_TO_LAURA)
    assert stored_state(scope, conversation_id) == (
        ConversationFlowState.COLLECTING_DATA,
        TRANSFER_TO_LAURA,
    )
    assert stored_context(scope, conversation_id) == EMPTY_CONTEXT
    assert llm.collection_calls == []


def test_contextual_answer_completes_and_pre_validates_transfer(
    engine: ConversationEngine,
    scope: FakeTransactionScope,
    llm: FakeLLMProvider,
    banking: FakeRepositories,
) -> None:
    conversation_id = collecting(scope)

    turn = reply(
        engine, llm, conversation_id, "25000", collection_output(amount="25000")
    )

    complete = awaiting(
        turn,
        PendingOperation(
            PendingOperationType.TRANSFER,
            TransferOperationData(
                SAVINGS.id, LAURA.id, Money(Decimal("25000"), Currency.ARS)
            ),
        ),
    )
    assert turn.intent is Intent.TRANSFER_MONEY
    assert turn.flow_state is ConversationFlowState.WAITING_CONFIRMATION
    assert turn.result == AwaitingConfirmationResult(
        complete, source_account=SAVINGS, beneficiary=LAURA
    )
    assert stored_state(scope, conversation_id) == (
        ConversationFlowState.WAITING_CONFIRMATION,
        complete,
    )
    assert llm.collection_calls == ["25000"]
    assert llm.calls == []
    assert banking.accounts.locked == [SAVINGS.id]


def test_correction_replaces_resolved_field_and_keeps_the_rest(
    engine: ConversationEngine,
    scope: FakeTransactionScope,
    llm: FakeLLMProvider,
    banking: FakeRepositories,
) -> None:
    conversation_id = collecting(scope)

    turn = reply(
        engine,
        llm,
        conversation_id,
        "Mejor mandáselo a Carlos",
        collection_output(beneficiary_reference="Carlos"),
    )

    expected = PendingOperation(
        PendingOperationType.TRANSFER, TransferOperationData(SAVINGS.id, CARLOS.id)
    )
    assert turn.result == CollectingDataResult(expected)
    assert stored_state(scope, conversation_id) == (
        ConversationFlowState.COLLECTING_DATA,
        expected,
    )


def test_ambiguous_correction_clears_old_value_and_keeps_independent_data(
    engine: ConversationEngine,
    scope: FakeTransactionScope,
    llm: FakeLLMProvider,
    banking: FakeRepositories,
) -> None:
    conversation_id = collecting(scope)

    turn = reply(
        engine,
        llm,
        conversation_id,
        "25000, pero a Juan",
        collection_output(amount="25000", beneficiary_reference="Juan"),
    )

    expected = PendingOperation(
        PendingOperationType.TRANSFER,
        TransferOperationData(SAVINGS.id, None, Money(Decimal("25000"), Currency.ARS)),
    )
    assert turn.flow_state is ConversationFlowState.COLLECTING_DATA
    assert turn.result == CollectingDataResult(
        expected,
        {PendingField.BENEFICIARY_ID: FieldIssue.AMBIGUOUS},
        beneficiary_candidates=(JUAN_PEREZ, JUAN_GARCIA),
    )
    assert stored_state(scope, conversation_id) == (
        ConversationFlowState.COLLECTING_DATA,
        expected,
    )


def test_ambiguous_request_collects_until_the_reference_is_clarified(
    engine: ConversationEngine,
    scope: FakeTransactionScope,
    llm: FakeLLMProvider,
    banking: FakeRepositories,
) -> None:
    conversation_id = store_conversation(scope).conversation.id
    first = send(
        engine,
        llm,
        conversation_id,
        "Transferile 20000 a Juan",
        model_output(
            intent="TRANSFER_MONEY", amount="20000", beneficiary_reference="Juan"
        ),
    )
    assert first.flow_state is ConversationFlowState.COLLECTING_DATA
    _, pending = stored_state(scope, conversation_id)
    assert pending is not None
    assert pending.missing_fields == (PendingField.BENEFICIARY_ID,)

    second = reply(
        engine,
        llm,
        conversation_id,
        "Juan Pérez",
        collection_output(beneficiary_reference="Juan Pérez"),
    )

    assert second.flow_state is ConversationFlowState.WAITING_CONFIRMATION
    assert isinstance(second.result, AwaitingConfirmationResult)
    assert second.result.beneficiary == JUAN_PEREZ


def test_amount_waits_for_its_currency_until_an_account_is_selected(
    engine: ConversationEngine,
    scope: FakeTransactionScope,
    llm: FakeLLMProvider,
    banking: FakeRepositories,
) -> None:
    banking.accounts.accounts.append(DOLLARS)
    conversation_id = store_conversation(scope).conversation.id

    first = send(
        engine,
        llm,
        conversation_id,
        "Transfer 1000 to Laura",
        model_output(
            intent="TRANSFER_MONEY", amount="1000", beneficiary_reference="Laura"
        ),
    )

    unresolved = PendingOperation(
        PendingOperationType.TRANSFER,
        TransferOperationData(None, LAURA.id, unresolved_amount=Decimal("1000")),
    )
    assert first.result == CollectingDataResult(unresolved)
    assert unresolved.missing_fields == (
        PendingField.SOURCE_ACCOUNT_ID,
        PendingField.AMOUNT,
    )

    second = reply(
        engine,
        llm,
        conversation_id,
        "desde la cuenta en dólares",
        collection_output(account_reference="la cuenta en dólares"),
    )

    assert second.flow_state is ConversationFlowState.WAITING_CONFIRMATION
    _, pending = stored_state(scope, conversation_id)
    assert pending is not None
    assert pending.data == TransferOperationData(
        DOLLARS.id, LAURA.id, Money(Decimal("1000"), Currency.USD)
    )


def test_card_operation_collects_an_ambiguous_card_and_pre_validates(
    engine: ConversationEngine,
    scope: FakeTransactionScope,
    llm: FakeLLMProvider,
    banking: FakeRepositories,
) -> None:
    conversation_id = store_conversation(scope).conversation.id

    first = send(
        engine,
        llm,
        conversation_id,
        "Freeze my Visa",
        model_output(intent="FREEZE_CARD", card_reference="my Visa"),
    )

    assert first.flow_state is ConversationFlowState.COLLECTING_DATA
    assert first.result == CollectingDataResult(
        PendingOperation(PendingOperationType.FREEZE_CARD, FreezeCardOperationData()),
        {PendingField.CARD_ID: FieldIssue.AMBIGUOUS},
        card_candidates=(VISA_DEBIT, VISA_CREDIT),
    )

    second = reply(
        engine,
        llm,
        conversation_id,
        "la de débito",
        collection_output(card_reference="la de débito"),
    )

    complete = awaiting(
        second,
        PendingOperation(
            PendingOperationType.FREEZE_CARD, FreezeCardOperationData(VISA_DEBIT.id)
        ),
    )
    assert second.intent is Intent.FREEZE_CARD
    assert second.result == AwaitingConfirmationResult(complete, card=VISA_DEBIT)
    assert stored_state(scope, conversation_id) == (
        ConversationFlowState.WAITING_CONFIRMATION,
        complete,
    )


def test_request_resolving_one_card_awaits_confirmation(
    engine: ConversationEngine,
    scope: FakeTransactionScope,
    llm: FakeLLMProvider,
    banking: FakeRepositories,
) -> None:
    conversation_id = store_conversation(scope).conversation.id

    turn = send(
        engine,
        llm,
        conversation_id,
        "Desbloqueá la que termina en 9134",
        model_output(intent="UNFREEZE_CARD", card_reference="la que termina en 9134"),
    )

    complete = awaiting(
        turn,
        PendingOperation(
            PendingOperationType.UNFREEZE_CARD,
            UnfreezeCardOperationData(VISA_CREDIT.id),
        ),
    )
    assert turn.intent is Intent.UNFREEZE_CARD
    assert turn.flow_state is ConversationFlowState.WAITING_CONFIRMATION
    assert turn.result == AwaitingConfirmationResult(complete, card=VISA_CREDIT)
    assert stored_state(scope, conversation_id) == (
        ConversationFlowState.WAITING_CONFIRMATION,
        complete,
    )


@pytest.mark.parametrize(
    ("output", "error"),
    [
        (
            model_output(intent="FREEZE_CARD", card_reference="la que termina en 9134"),
            InvalidCardStateError,
        ),
        (
            model_output(
                intent="UNFREEZE_CARD", card_reference="la que termina en 4821"
            ),
            InvalidCardStateError,
        ),
        (
            model_output(
                intent="TRANSFER_MONEY",
                amount="500000",
                beneficiary_reference="Laura",
            ),
            InsufficientFundsError,
        ),
    ],
    ids=["frozen_card", "active_card", "insufficient_funds"],
)
def test_failed_pre_validation_discards_the_operation(
    engine: ConversationEngine,
    scope: FakeTransactionScope,
    llm: FakeLLMProvider,
    banking: FakeRepositories,
    output: dict[str, Any],
    error: type[Exception],
) -> None:
    conversation_id = store_conversation(scope).conversation.id

    turn = send(engine, llm, conversation_id, "Do it now", output)

    assert turn.flow_state is ConversationFlowState.READY
    assert isinstance(turn.result, PreValidationFailedResult)
    assert isinstance(turn.result.error, error)
    assert stored_state(scope, conversation_id) == (ConversationFlowState.READY, None)


def test_read_only_interruption_keeps_the_collected_operation(
    engine: ConversationEngine,
    scope: FakeTransactionScope,
    llm: FakeLLMProvider,
    banking: FakeRepositories,
) -> None:
    conversation_id = collecting(scope)

    turn = send(
        engine,
        llm,
        conversation_id,
        "¿Cuánta plata tengo?",
        model_output(intent="GET_BALANCE"),
    )

    assert turn.result == BalancesResult((SAVINGS,))
    assert turn.flow_state is ConversationFlowState.COLLECTING_DATA
    assert stored_state(scope, conversation_id) == (
        ConversationFlowState.COLLECTING_DATA,
        TRANSFER_TO_LAURA,
    )
    assert llm.collection_calls == ["¿Cuánta plata tengo?"]
    assert llm.calls == ["¿Cuánta plata tengo?"]


def test_restated_operation_is_merged_while_collecting(
    engine: ConversationEngine,
    scope: FakeTransactionScope,
    llm: FakeLLMProvider,
    banking: FakeRepositories,
) -> None:
    conversation_id = collecting(scope)

    turn = send(
        engine,
        llm,
        conversation_id,
        "Transfer 30000 to Carlos",
        model_output(
            intent="TRANSFER_MONEY", amount="30000", beneficiary_reference="Carlos"
        ),
    )

    assert turn.flow_state is ConversationFlowState.WAITING_CONFIRMATION
    assert isinstance(turn.result, AwaitingConfirmationResult)
    assert turn.result.beneficiary == CARLOS


@pytest.mark.parametrize(
    ("flow_state", "pending", "intent"),
    [
        (ConversationFlowState.COLLECTING_DATA, TRANSFER_TO_LAURA, "FREEZE_CARD"),
        (ConversationFlowState.WAITING_CONFIRMATION, PENDING_TRANSFER, "FREEZE_CARD"),
        (
            ConversationFlowState.WAITING_CONFIRMATION,
            PendingOperation(
                PendingOperationType.UNFREEZE_CARD,
                UnfreezeCardOperationData(VISA_CREDIT.id),
                uuid4(),
            ),
            "FREEZE_CARD",
        ),
    ],
    ids=["collecting", "waiting", "waiting_card"],
)
def test_second_operation_conflicts_with_the_pending_one(
    engine: ConversationEngine,
    scope: FakeTransactionScope,
    llm: FakeLLMProvider,
    banking: FakeRepositories,
    flow_state: ConversationFlowState,
    pending: PendingOperation,
    intent: str,
) -> None:
    conversation_id = store_conversation(scope).conversation.id
    replace_stored(
        scope, conversation_id, flow_state=flow_state, pending_operation=pending
    )

    turn = send(
        engine,
        llm,
        conversation_id,
        "Freeze my Visa",
        model_output(intent=intent, card_reference="my Visa"),
    )

    assert turn.result == PendingOperationConflictResult(Intent(intent), pending.type)
    assert turn.flow_state is flow_state
    assert stored_state(scope, conversation_id) == (flow_state, pending)


@pytest.mark.parametrize("intent", ["CANCEL", "UNKNOWN", "GENERAL_CONVERSATION"])
def test_other_messages_leave_the_collected_operation_unchanged(
    engine: ConversationEngine,
    scope: FakeTransactionScope,
    llm: FakeLLMProvider,
    banking: FakeRepositories,
    intent: str,
) -> None:
    conversation_id = collecting(scope)

    turn = send(engine, llm, conversation_id, "Dejá", model_output(intent=intent))

    assert turn.result == UnhandledIntentResult(Intent(intent))
    assert stored_state(scope, conversation_id) == (
        ConversationFlowState.COLLECTING_DATA,
        TRANSFER_TO_LAURA,
    )


def test_collection_interpretation_is_used_only_with_a_pending_operation(
    engine: ConversationEngine,
    scope: FakeTransactionScope,
    llm: FakeLLMProvider,
    banking: FakeRepositories,
) -> None:
    conversation_id = store_conversation(scope).conversation.id
    llm.collection_output = collection_output(amount="25000")

    turn = send(engine, llm, conversation_id, "25000", model_output(intent="UNKNOWN"))

    assert turn.result == UnhandledIntentResult(Intent.UNKNOWN)
    assert llm.collection_calls == []
    assert stored_state(scope, conversation_id) == (ConversationFlowState.READY, None)


def test_operation_changed_during_interpretation_persists_nothing(
    engine: ConversationEngine,
    scope: FakeTransactionScope,
    llm: FakeLLMProvider,
    banking: FakeRepositories,
) -> None:
    conversation_id = collecting(scope)
    changed = PendingOperation(
        PendingOperationType.TRANSFER, TransferOperationData(SAVINGS.id, CARLOS.id)
    )
    llm.on_call = lambda: replace_stored(
        scope, conversation_id, pending_operation=changed
    )

    with pytest.raises(InvalidConversationStateError):
        reply(engine, llm, conversation_id, "25000", collection_output(amount="25000"))

    assert stored_state(scope, conversation_id) == (
        ConversationFlowState.COLLECTING_DATA,
        changed,
    )
    assert scope.repositories.messages.messages == []


# Structured interactions.

LAURA_25000 = PendingOperation(
    PendingOperationType.TRANSFER,
    TransferOperationData(
        SAVINGS.id, LAURA.id, Money(Decimal("25000.00"), Currency.ARS)
    ),
    uuid4(),
)
FREEZE_VISA_DEBIT = PendingOperation(
    PendingOperationType.FREEZE_CARD, FreezeCardOperationData(VISA_DEBIT.id), uuid4()
)
UNFREEZE_VISA_CREDIT = PendingOperation(
    PendingOperationType.UNFREEZE_CARD,
    UnfreezeCardOperationData(VISA_CREDIT.id),
    uuid4(),
)
COLLECTING_FREEZE = PendingOperation(
    PendingOperationType.FREEZE_CARD, FreezeCardOperationData()
)


@pytest.fixture
def executable(banking: FakeRepositories) -> FakeRepositories:
    """Banking data whose Banking Core writes are allowed."""
    banking.accounts.writable = True
    banking.cards.writable = True
    banking.transfers.writable = True
    return banking


def in_state(
    scope: FakeTransactionScope,
    flow_state: ConversationFlowState,
    operation: PendingOperation | None,
) -> UUID:
    conversation_id = store_conversation(scope).conversation.id
    replace_stored(
        scope, conversation_id, flow_state=flow_state, pending_operation=operation
    )
    return conversation_id


def waiting(scope: FakeTransactionScope, operation: PendingOperation) -> UUID:
    return in_state(scope, ConversationFlowState.WAITING_CONFIRMATION, operation)


def interact(
    engine: ConversationEngine,
    llm: FakeLLMProvider,
    conversation_id: UUID,
    interaction: Interaction,
) -> Turn:
    """Handle ``interaction``, checking that it is never interpreted."""
    llm.error = AssertionError("interactions must not be interpreted")
    calls = len(llm.called_in_transaction)
    turn = engine.handle_interaction(CUSTOMER_ID, conversation_id, interaction)
    assert len(llm.called_in_transaction) == calls
    return turn


def confirm(operation: PendingOperation) -> Confirm:
    """The confirmation of ``operation``'s confirmation request."""
    assert operation.operation_id is not None
    return Confirm(operation.operation_id)


def balance(scope: FakeTransactionScope) -> Money:
    [account] = [a for a in scope.repositories.accounts.accounts if a.id == SAVINGS.id]
    return account.balance


def card_status(scope: FakeTransactionScope, card_id: UUID) -> CardStatus:
    [card] = [c for c in scope.repositories.cards.cards if c.id == card_id]
    return card.status


def test_confirm_executes_the_persisted_transfer(
    engine: ConversationEngine,
    scope: FakeTransactionScope,
    llm: FakeLLMProvider,
    executable: FakeRepositories,
) -> None:
    conversation_id = waiting(scope, LAURA_25000)
    send(engine, llm, conversation_id, "Saldo", model_output(intent="GET_BALANCE"))
    context = stored_context(scope, conversation_id)
    messages = list(scope.repositories.messages.messages)

    turn = interact(engine, llm, conversation_id, confirm(LAURA_25000))

    [(transfer, transaction)] = executable.transfers.transfers
    assert turn == Turn(
        conversation_id=conversation_id,
        flow_state=ConversationFlowState.READY,
        message=None,
        intent=Intent.TRANSFER_MONEY,
        result=OperationCompletedResult(LAURA_25000, transfer=transfer),
    )
    assert transfer.source_account_id == SAVINGS.id
    assert transfer.beneficiary_id == LAURA.id
    assert transfer.amount == Money(Decimal("25000.00"), Currency.ARS)
    assert transfer.executed_at == NOW
    assert transaction is not None and transaction.transfer_id == transfer.id
    assert balance(scope) == Money(Decimal("125000.50"), Currency.ARS)
    assert stored_state(scope, conversation_id) == (ConversationFlowState.READY, None)
    assert stored_context(scope, conversation_id) == context
    assert scope.repositories.messages.messages == messages
    record = scope.repositories.conversations.records[conversation_id]
    assert record.conversation.updated_at == NOW


@pytest.mark.parametrize(
    ("operation", "card", "status", "intent"),
    [
        (FREEZE_VISA_DEBIT, VISA_DEBIT, CardStatus.FROZEN, Intent.FREEZE_CARD),
        (UNFREEZE_VISA_CREDIT, VISA_CREDIT, CardStatus.ACTIVE, Intent.UNFREEZE_CARD),
    ],
    ids=["freeze", "unfreeze"],
)
def test_confirm_executes_the_persisted_card_operation(
    engine: ConversationEngine,
    scope: FakeTransactionScope,
    llm: FakeLLMProvider,
    executable: FakeRepositories,
    operation: PendingOperation,
    card: Card,
    status: CardStatus,
    intent: Intent,
) -> None:
    conversation_id = waiting(scope, operation)

    turn = interact(engine, llm, conversation_id, confirm(operation))

    assert turn.intent is intent
    assert turn.flow_state is ConversationFlowState.READY
    assert turn.result == OperationCompletedResult(
        operation, card=replace(card, status=status)
    )
    assert card_status(scope, card.id) is status
    assert stored_state(scope, conversation_id) == (ConversationFlowState.READY, None)


def test_confirm_discards_a_transfer_that_fails_revalidation(
    engine: ConversationEngine,
    scope: FakeTransactionScope,
    llm: FakeLLMProvider,
    executable: FakeRepositories,
) -> None:
    conversation_id = waiting(scope, LAURA_25000)
    # The balance dropped after pre-validation.
    low = Money(Decimal("100.00"), Currency.ARS)
    executable.accounts.accounts = [replace(SAVINGS, balance=low)]

    turn = interact(engine, llm, conversation_id, confirm(LAURA_25000))

    assert turn.flow_state is ConversationFlowState.READY
    assert isinstance(turn.result, OperationFailedResult)
    assert turn.result.operation == LAURA_25000
    assert isinstance(turn.result.error, InsufficientFundsError)
    assert balance(scope) == low
    assert executable.transfers.transfers == []
    assert stored_state(scope, conversation_id) == (ConversationFlowState.READY, None)


@pytest.mark.parametrize(
    ("operation", "card"),
    [
        (
            PendingOperation(
                PendingOperationType.FREEZE_CARD,
                FreezeCardOperationData(VISA_CREDIT.id),
                uuid4(),
            ),
            VISA_CREDIT,
        ),
        (
            PendingOperation(
                PendingOperationType.UNFREEZE_CARD,
                UnfreezeCardOperationData(VISA_DEBIT.id),
                uuid4(),
            ),
            VISA_DEBIT,
        ),
    ],
    ids=["freeze", "unfreeze"],
)
def test_confirm_discards_a_card_operation_that_fails_revalidation(
    engine: ConversationEngine,
    scope: FakeTransactionScope,
    llm: FakeLLMProvider,
    executable: FakeRepositories,
    operation: PendingOperation,
    card: Card,
) -> None:
    # The card's status changed elsewhere after pre-validation.
    conversation_id = waiting(scope, operation)

    turn = interact(engine, llm, conversation_id, confirm(operation))

    assert turn.flow_state is ConversationFlowState.READY
    assert isinstance(turn.result, OperationFailedResult)
    assert turn.result.operation == operation
    assert isinstance(turn.result.error, InvalidCardStateError)
    assert card_status(scope, card.id) is card.status
    assert stored_state(scope, conversation_id) == (ConversationFlowState.READY, None)


def test_repeated_confirm_does_not_repeat_the_operation(
    engine: ConversationEngine,
    scope: FakeTransactionScope,
    llm: FakeLLMProvider,
    executable: FakeRepositories,
) -> None:
    conversation_id = waiting(scope, LAURA_25000)
    interact(engine, llm, conversation_id, confirm(LAURA_25000))

    turn = interact(engine, llm, conversation_id, confirm(LAURA_25000))

    assert turn.result == NoPendingOperationResult(confirm(LAURA_25000))
    assert turn.flow_state is ConversationFlowState.READY
    assert len(executable.transfers.transfers) == 1
    assert balance(scope) == Money(Decimal("125000.50"), Currency.ARS)


@pytest.mark.parametrize(
    ("interaction", "intent"),
    [(Confirm(uuid4()), Intent.UNKNOWN), (Cancel(), Intent.CANCEL)],
    ids=["confirm", "cancel"],
)
def test_confirm_or_cancel_without_a_pending_operation_has_no_effect(
    engine: ConversationEngine,
    scope: FakeTransactionScope,
    llm: FakeLLMProvider,
    banking: FakeRepositories,
    interaction: Confirm | Cancel,
    intent: Intent,
) -> None:
    conversation_id = store_conversation(scope).conversation.id

    turn = interact(engine, llm, conversation_id, interaction)

    assert turn.result == NoPendingOperationResult(interaction)
    assert turn.intent is intent
    assert turn.flow_state is ConversationFlowState.READY
    assert stored_state(scope, conversation_id) == (ConversationFlowState.READY, None)


@pytest.mark.parametrize(
    ("flow_state", "operation"),
    [
        (ConversationFlowState.COLLECTING_DATA, TRANSFER_TO_LAURA),
        (ConversationFlowState.WAITING_CONFIRMATION, LAURA_25000),
        (ConversationFlowState.WAITING_CONFIRMATION, FREEZE_VISA_DEBIT),
    ],
    ids=["collecting", "waiting_transfer", "waiting_card"],
)
def test_cancel_discards_the_pending_operation_without_executing_it(
    engine: ConversationEngine,
    scope: FakeTransactionScope,
    llm: FakeLLMProvider,
    banking: FakeRepositories,
    flow_state: ConversationFlowState,
    operation: PendingOperation,
) -> None:
    # Banking Core writes are refused by the fakes.
    conversation_id = in_state(scope, flow_state, operation)

    turn = interact(engine, llm, conversation_id, Cancel())

    assert turn.intent is Intent.CANCEL
    assert turn.flow_state is ConversationFlowState.READY
    assert turn.result == OperationCancelledResult(operation)
    assert stored_state(scope, conversation_id) == (ConversationFlowState.READY, None)
    assert balance(scope) == SAVINGS.balance
    assert card_status(scope, VISA_DEBIT.id) is CardStatus.ACTIVE


@pytest.mark.parametrize(
    ("flow_state", "operation", "interaction"),
    [
        (ConversationFlowState.COLLECTING_DATA, TRANSFER_TO_LAURA, Confirm(uuid4())),
        (ConversationFlowState.COLLECTING_DATA, COLLECTING_FREEZE, Confirm(uuid4())),
        (ConversationFlowState.READY, None, SelectCard(VISA_DEBIT.id)),
        (
            ConversationFlowState.COLLECTING_DATA,
            TRANSFER_TO_LAURA,
            SelectCard(VISA_DEBIT.id),
        ),
        (
            ConversationFlowState.WAITING_CONFIRMATION,
            FREEZE_VISA_DEBIT,
            SelectCard(VISA_CREDIT.id),
        ),
    ],
    ids=[
        "confirm_collecting_transfer",
        "confirm_collecting_card",
        "select_ready",
        "select_transfer",
        "select_waiting",
    ],
)
def test_inapplicable_interaction_leaves_the_conversation_unchanged(
    engine: ConversationEngine,
    scope: FakeTransactionScope,
    llm: FakeLLMProvider,
    banking: FakeRepositories,
    flow_state: ConversationFlowState,
    operation: PendingOperation | None,
    interaction: Interaction,
) -> None:
    conversation_id = in_state(scope, flow_state, operation)
    before = scope.repositories.conversations.records[conversation_id]

    with pytest.raises(InvalidInteractionError):
        interact(engine, llm, conversation_id, interaction)

    assert scope.repositories.conversations.records[conversation_id] == before


@pytest.mark.parametrize(
    ("operation_type", "card", "intent"),
    [
        (PendingOperationType.FREEZE_CARD, VISA_DEBIT, Intent.FREEZE_CARD),
        (PendingOperationType.UNFREEZE_CARD, VISA_CREDIT, Intent.UNFREEZE_CARD),
    ],
    ids=["freeze", "unfreeze"],
)
def test_selected_card_is_pre_validated_and_awaits_confirmation(
    engine: ConversationEngine,
    scope: FakeTransactionScope,
    llm: FakeLLMProvider,
    banking: FakeRepositories,
    operation_type: PendingOperationType,
    card: Card,
    intent: Intent,
) -> None:
    data = (
        FreezeCardOperationData(card.id)
        if operation_type is PendingOperationType.FREEZE_CARD
        else UnfreezeCardOperationData(card.id)
    )
    conversation_id = collecting(
        scope, PendingOperation(operation_type, replace(data, card_id=None))
    )

    turn = interact(engine, llm, conversation_id, SelectCard(card.id))

    expected = awaiting(turn, PendingOperation(operation_type, data))
    assert turn.intent is intent
    assert turn.flow_state is ConversationFlowState.WAITING_CONFIRMATION
    assert turn.result == AwaitingConfirmationResult(expected, card=card)
    assert stored_state(scope, conversation_id) == (
        ConversationFlowState.WAITING_CONFIRMATION,
        expected,
    )


def test_unowned_selected_card_keeps_collecting(
    engine: ConversationEngine,
    scope: FakeTransactionScope,
    llm: FakeLLMProvider,
    banking: FakeRepositories,
) -> None:
    conversation_id = collecting(scope, COLLECTING_FREEZE)

    turn = interact(engine, llm, conversation_id, SelectCard(uuid4()))

    assert turn.flow_state is ConversationFlowState.COLLECTING_DATA
    assert turn.result == CollectingDataResult(
        COLLECTING_FREEZE, {PendingField.CARD_ID: FieldIssue.NOT_FOUND}
    )
    assert stored_state(scope, conversation_id) == (
        ConversationFlowState.COLLECTING_DATA,
        COLLECTING_FREEZE,
    )


def test_selected_card_that_fails_pre_validation_is_discarded(
    engine: ConversationEngine,
    scope: FakeTransactionScope,
    llm: FakeLLMProvider,
    banking: FakeRepositories,
) -> None:
    conversation_id = collecting(scope, COLLECTING_FREEZE)

    turn = interact(engine, llm, conversation_id, SelectCard(VISA_CREDIT.id))

    assert turn.flow_state is ConversationFlowState.READY
    assert isinstance(turn.result, PreValidationFailedResult)
    assert isinstance(turn.result.error, InvalidCardStateError)
    assert stored_state(scope, conversation_id) == (ConversationFlowState.READY, None)


@pytest.mark.parametrize(
    ("status", "customer_id", "error"),
    [
        (ConversationStatus.CLOSED, CUSTOMER_ID, ConversationClosedError),
        (ConversationStatus.ACTIVE, OTHER_CUSTOMER_ID, ConversationNotFoundError),
    ],
    ids=["closed", "not_owned"],
)
def test_interaction_requires_an_owned_active_conversation(
    engine: ConversationEngine,
    scope: FakeTransactionScope,
    banking: FakeRepositories,
    status: ConversationStatus,
    customer_id: UUID,
    error: type[Exception],
) -> None:
    record = store_conversation(scope, status=status, customer_id=customer_id)

    with pytest.raises(error):
        engine.handle_interaction(CUSTOMER_ID, record.conversation.id, Cancel())

    assert scope.repositories.conversations.records[record.conversation.id] == record


def test_cancel_during_interpretation_rejects_the_collected_data(
    engine: ConversationEngine,
    scope: FakeTransactionScope,
    llm: FakeLLMProvider,
    banking: FakeRepositories,
) -> None:
    conversation_id = collecting(scope)

    def cancel() -> None:
        engine.handle_interaction(CUSTOMER_ID, conversation_id, Cancel())

    llm.on_call = cancel

    with pytest.raises(InvalidConversationStateError):
        reply(engine, llm, conversation_id, "25000", collection_output(amount="25000"))

    assert stored_state(scope, conversation_id) == (ConversationFlowState.READY, None)
    assert scope.repositories.messages.messages == []


# Corrections while waiting for confirmation.


def test_confirm_of_another_confirmation_request_is_rejected(
    engine: ConversationEngine,
    scope: FakeTransactionScope,
    llm: FakeLLMProvider,
    executable: FakeRepositories,
) -> None:
    conversation_id = waiting(scope, LAURA_25000)
    before = scope.repositories.conversations.records[conversation_id]

    with pytest.raises(InvalidInteractionError):
        interact(engine, llm, conversation_id, Confirm(uuid4()))

    assert scope.repositories.conversations.records[conversation_id] == before
    assert executable.transfers.transfers == []
    assert balance(scope) == SAVINGS.balance


def test_complete_correction_requests_a_new_confirmation(
    engine: ConversationEngine,
    scope: FakeTransactionScope,
    llm: FakeLLMProvider,
    executable: FakeRepositories,
) -> None:
    conversation_id = waiting(scope, LAURA_25000)

    turn = reply(
        engine,
        llm,
        conversation_id,
        "No, mejor 20000",
        collection_output(amount="20000"),
    )

    corrected = awaiting(
        turn,
        PendingOperation(
            PendingOperationType.TRANSFER,
            TransferOperationData(
                SAVINGS.id, LAURA.id, Money(Decimal("20000"), Currency.ARS)
            ),
        ),
    )
    assert corrected.operation_id != LAURA_25000.operation_id
    assert turn.intent is Intent.TRANSFER_MONEY
    assert turn.flow_state is ConversationFlowState.WAITING_CONFIRMATION
    assert turn.result == AwaitingConfirmationResult(
        corrected, source_account=SAVINGS, beneficiary=LAURA
    )
    assert stored_state(scope, conversation_id) == (
        ConversationFlowState.WAITING_CONFIRMATION,
        corrected,
    )

    # The earlier confirmation request no longer authorizes anything.
    with pytest.raises(InvalidInteractionError):
        interact(engine, llm, conversation_id, confirm(LAURA_25000))
    assert stored_state(scope, conversation_id) == (
        ConversationFlowState.WAITING_CONFIRMATION,
        corrected,
    )
    assert executable.transfers.transfers == []

    confirmed = interact(engine, llm, conversation_id, confirm(corrected))

    [(transfer, _)] = executable.transfers.transfers
    assert confirmed.result == OperationCompletedResult(corrected, transfer=transfer)
    assert transfer.amount == Money(Decimal("20000"), Currency.ARS)
    assert balance(scope) == Money(Decimal("130000.50"), Currency.ARS)


def test_restated_request_corrects_the_waiting_operation(
    engine: ConversationEngine,
    scope: FakeTransactionScope,
    llm: FakeLLMProvider,
    banking: FakeRepositories,
) -> None:
    conversation_id = waiting(scope, LAURA_25000)

    turn = send(
        engine,
        llm,
        conversation_id,
        "Transfer 30000 to Carlos",
        model_output(
            intent="TRANSFER_MONEY", amount="30000", beneficiary_reference="Carlos"
        ),
    )

    corrected = awaiting(
        turn,
        PendingOperation(
            PendingOperationType.TRANSFER,
            TransferOperationData(
                SAVINGS.id, CARLOS.id, Money(Decimal("30000"), Currency.ARS)
            ),
        ),
    )
    assert corrected.operation_id != LAURA_25000.operation_id
    assert turn.result == AwaitingConfirmationResult(
        corrected, source_account=SAVINGS, beneficiary=CARLOS
    )
    assert stored_state(scope, conversation_id) == (
        ConversationFlowState.WAITING_CONFIRMATION,
        corrected,
    )


def test_incomplete_correction_returns_to_collecting(
    engine: ConversationEngine,
    scope: FakeTransactionScope,
    llm: FakeLLMProvider,
    executable: FakeRepositories,
) -> None:
    conversation_id = waiting(scope, LAURA_25000)

    turn = reply(
        engine,
        llm,
        conversation_id,
        "Mejor a Juan",
        collection_output(beneficiary_reference="Juan"),
    )

    collected = PendingOperation(
        PendingOperationType.TRANSFER,
        TransferOperationData(
            SAVINGS.id, None, Money(Decimal("25000.00"), Currency.ARS)
        ),
    )
    assert turn.flow_state is ConversationFlowState.COLLECTING_DATA
    assert turn.result == CollectingDataResult(
        collected,
        {PendingField.BENEFICIARY_ID: FieldIssue.AMBIGUOUS},
        beneficiary_candidates=(JUAN_PEREZ, JUAN_GARCIA),
    )
    assert stored_state(scope, conversation_id) == (
        ConversationFlowState.COLLECTING_DATA,
        collected,
    )

    with pytest.raises(InvalidInteractionError):
        interact(engine, llm, conversation_id, confirm(LAURA_25000))
    assert executable.transfers.transfers == []


def test_correction_failing_pre_validation_discards_the_operation(
    engine: ConversationEngine,
    scope: FakeTransactionScope,
    llm: FakeLLMProvider,
    executable: FakeRepositories,
) -> None:
    conversation_id = waiting(scope, LAURA_25000)

    turn = reply(
        engine, llm, conversation_id, "500000", collection_output(amount="500000")
    )

    assert turn.flow_state is ConversationFlowState.READY
    assert isinstance(turn.result, PreValidationFailedResult)
    assert isinstance(turn.result.error, InsufficientFundsError)
    assert stored_state(scope, conversation_id) == (ConversationFlowState.READY, None)

    stale = interact(engine, llm, conversation_id, confirm(LAURA_25000))

    assert stale.result == NoPendingOperationResult(confirm(LAURA_25000))
    assert executable.transfers.transfers == []
    assert balance(scope) == SAVINGS.balance


def test_reply_without_data_keeps_the_confirmation_request(
    engine: ConversationEngine,
    scope: FakeTransactionScope,
    llm: FakeLLMProvider,
    banking: FakeRepositories,
) -> None:
    conversation_id = waiting(scope, LAURA_25000)

    turn = reply(engine, llm, conversation_id, "ok", collection_output())

    assert turn.flow_state is ConversationFlowState.WAITING_CONFIRMATION
    assert stored_state(scope, conversation_id) == (
        ConversationFlowState.WAITING_CONFIRMATION,
        LAURA_25000,
    )
    # The reply was then interpreted on its own.
    assert llm.collection_calls == ["ok"]
    assert llm.calls == ["ok"]


def test_confirm_after_cancel_executes_nothing(
    engine: ConversationEngine,
    scope: FakeTransactionScope,
    llm: FakeLLMProvider,
    executable: FakeRepositories,
) -> None:
    conversation_id = waiting(scope, LAURA_25000)
    interact(engine, llm, conversation_id, Cancel())

    turn = interact(engine, llm, conversation_id, confirm(LAURA_25000))

    assert turn.result == NoPendingOperationResult(confirm(LAURA_25000))
    assert stored_state(scope, conversation_id) == (ConversationFlowState.READY, None)
    assert executable.transfers.transfers == []
    assert balance(scope) == SAVINGS.balance


def test_confirm_during_interpretation_rejects_the_correction(
    engine: ConversationEngine,
    scope: FakeTransactionScope,
    llm: FakeLLMProvider,
    executable: FakeRepositories,
) -> None:
    conversation_id = waiting(scope, LAURA_25000)

    def confirm_waiting() -> None:
        engine.handle_interaction(CUSTOMER_ID, conversation_id, confirm(LAURA_25000))

    llm.on_call = confirm_waiting

    with pytest.raises(InvalidConversationStateError):
        reply(engine, llm, conversation_id, "20000", collection_output(amount="20000"))

    [(transfer, _)] = executable.transfers.transfers
    assert transfer.amount == Money(Decimal("25000.00"), Currency.ARS)
    assert stored_state(scope, conversation_id) == (ConversationFlowState.READY, None)
    assert scope.repositories.messages.messages == []


# Safe-action edge cases.


@pytest.mark.parametrize("content", ["Sí", "Dale, hacelo", "Confirmo"])
@pytest.mark.parametrize("kind", ["OTHER", "DETAILS"])
@pytest.mark.parametrize("intent", ["UNKNOWN", "GENERAL_CONVERSATION"])
def test_free_text_while_waiting_never_executes(
    engine: ConversationEngine,
    scope: FakeTransactionScope,
    llm: FakeLLMProvider,
    executable: FakeRepositories,
    content: str,
    kind: str,
    intent: str,
) -> None:
    conversation_id = waiting(scope, LAURA_25000)
    llm.collection_output = collection_output(kind=kind)

    turn = send(engine, llm, conversation_id, content, model_output(intent=intent))

    assert turn.result == UnhandledIntentResult(Intent(intent))
    assert turn.flow_state is ConversationFlowState.WAITING_CONFIRMATION
    assert stored_state(scope, conversation_id) == (
        ConversationFlowState.WAITING_CONFIRMATION,
        LAURA_25000,
    )
    assert executable.transfers.transfers == []
    assert balance(scope) == SAVINGS.balance


def test_restated_identical_details_require_a_new_confirmation(
    engine: ConversationEngine,
    scope: FakeTransactionScope,
    llm: FakeLLMProvider,
    executable: FakeRepositories,
) -> None:
    conversation_id = waiting(scope, LAURA_25000)

    turn = reply(
        engine,
        llm,
        conversation_id,
        "Sí, mandale los 25000",
        collection_output(amount="25000.00"),
    )

    restated = awaiting(turn, LAURA_25000)
    assert restated.operation_id != LAURA_25000.operation_id
    assert turn.flow_state is ConversationFlowState.WAITING_CONFIRMATION
    assert stored_state(scope, conversation_id) == (
        ConversationFlowState.WAITING_CONFIRMATION,
        restated,
    )
    assert executable.transfers.transfers == []

    with pytest.raises(InvalidInteractionError):
        interact(engine, llm, conversation_id, confirm(LAURA_25000))
    assert stored_state(scope, conversation_id) == (
        ConversationFlowState.WAITING_CONFIRMATION,
        restated,
    )
    assert executable.transfers.transfers == []
    assert balance(scope) == SAVINGS.balance


def test_confirm_after_failed_revalidation_executes_nothing(
    engine: ConversationEngine,
    scope: FakeTransactionScope,
    llm: FakeLLMProvider,
    executable: FakeRepositories,
) -> None:
    conversation_id = waiting(scope, LAURA_25000)
    executable.accounts.accounts = [
        replace(SAVINGS, balance=Money(Decimal("100.00"), Currency.ARS))
    ]
    failed = interact(engine, llm, conversation_id, confirm(LAURA_25000))
    assert isinstance(failed.result, OperationFailedResult)
    # The funds are available again.
    executable.accounts.accounts = [SAVINGS]

    turn = interact(engine, llm, conversation_id, confirm(LAURA_25000))

    assert turn.result == NoPendingOperationResult(confirm(LAURA_25000))
    assert turn.flow_state is ConversationFlowState.READY
    assert stored_state(scope, conversation_id) == (ConversationFlowState.READY, None)
    assert executable.transfers.transfers == []
    assert balance(scope) == SAVINGS.balance


# Closing.


@pytest.mark.parametrize(
    ("flow_state", "operation"),
    [
        (ConversationFlowState.READY, None),
        (ConversationFlowState.COLLECTING_DATA, TRANSFER_TO_LAURA),
        (ConversationFlowState.WAITING_CONFIRMATION, LAURA_25000),
    ],
    ids=["ready", "collecting", "waiting"],
)
def test_close_discards_pending_state_and_context_and_keeps_messages(
    engine: ConversationEngine,
    scope: FakeTransactionScope,
    llm: FakeLLMProvider,
    banking: FakeRepositories,
    flow_state: ConversationFlowState,
    operation: PendingOperation | None,
) -> None:
    # Banking Core writes are refused by the fakes.
    conversation_id = in_state(scope, flow_state, operation)
    send(engine, llm, conversation_id, "Saldo", model_output(intent="GET_BALANCE"))
    assert stored_context(scope, conversation_id) != EMPTY_CONTEXT
    messages = list(scope.repositories.messages.messages)
    llm.error = AssertionError("closing must not interpret")

    closed = engine.close(CUSTOMER_ID, conversation_id)

    stored = scope.repositories.conversations.records[conversation_id]
    assert closed == stored
    assert stored.conversation.status is ConversationStatus.CLOSED
    assert stored.conversation.updated_at == NOW
    assert stored.flow_state is ConversationFlowState.READY
    assert stored.pending_operation is None
    assert stored.context == EMPTY_CONTEXT
    assert scope.repositories.messages.messages == messages


@pytest.mark.parametrize(
    ("status", "customer_id", "error"),
    [
        (ConversationStatus.CLOSED, CUSTOMER_ID, ConversationClosedError),
        (ConversationStatus.ACTIVE, OTHER_CUSTOMER_ID, ConversationNotFoundError),
    ],
    ids=["already_closed", "not_owned"],
)
def test_close_requires_an_owned_active_conversation(
    engine: ConversationEngine,
    scope: FakeTransactionScope,
    status: ConversationStatus,
    customer_id: UUID,
    error: type[Exception],
) -> None:
    record = store_conversation(scope, status=status, customer_id=customer_id)

    with pytest.raises(error):
        engine.close(CUSTOMER_ID, record.conversation.id)

    assert scope.repositories.conversations.records[record.conversation.id] == record
