from dataclasses import dataclass, replace
from datetime import UTC, datetime
from decimal import Decimal
from typing import Any
from uuid import UUID, uuid4
from zoneinfo import ZoneInfo

import pytest
from pydantic import BaseModel
from sqlalchemy import Engine, func, select
from sqlalchemy.orm import Session, sessionmaker

from mimi.application.conversation_context import EMPTY_CONTEXT
from mimi.application.conversation_engine import ConversationEngine
from mimi.application.conversation_results import (
    AwaitingConfirmationResult,
    BalancesResult,
    CardsResult,
    CollectingDataResult,
    FieldIssue,
    NoPendingOperationResult,
    OperationCancelledResult,
    OperationCompletedResult,
    OperationFailedResult,
    TransactionsResult,
)
from mimi.application.errors import (
    ConversationClosedError,
    InsufficientFundsError,
    InvalidInteractionError,
    LLMUnavailableError,
)
from mimi.application.interactions import Cancel, Confirm, SelectCard
from mimi.application.interpretation import Intent
from mimi.application.llm import LLMProvider
from mimi.application.pending_operations import (
    FreezeCardOperationData,
    PendingField,
    PendingOperation,
    TransferOperationData,
    UnfreezeCardOperationData,
)
from mimi.application.read_only_queries import ReadOnlyQueryRouter
from mimi.application.use_cases.interpret_message import (
    InterpretCollectionInput,
    InterpretMessage,
)
from mimi.composition import Container
from mimi.domain.entities import (
    Account,
    Card,
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
    TransactionType,
    TransferStatus,
)
from mimi.infrastructure.database.models import (
    AccountModel,
    BeneficiaryModel,
    CardModel,
    ConversationModel,
    CustomerModel,
    MessageModel,
    TransactionModel,
    TransferModel,
)
from mimi.infrastructure.database.repositories import PostgresTransferRepository
from mimi.infrastructure.database.session import create_session_factory
from mimi.infrastructure.database.transaction import (
    PostgresRepositories,
    PostgresTransactionScope,
)

pytestmark = pytest.mark.integration

EXECUTED_AT = datetime(2026, 10, 9, 16, 31, 4, tzinfo=UTC)
TRANSFER_AMOUNT = Money(Decimal("25000.00"), Currency.ARS)
BALANCE_AFTER_TRANSFER = Money(Decimal("125000.50"), Currency.ARS)


class ExecutionInterrupted(Exception):
    pass


class ScriptedLLMProvider:
    """Answers every interpretation request with a canned intent, and every
    collection request with details; both carry the canned ``values``."""

    def __init__(self, intent: Intent = Intent.GET_BALANCE) -> None:
        self.intent = intent
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
def llm_provider() -> ScriptedLLMProvider:
    return ScriptedLLMProvider()


def make_engine(
    session_factory: sessionmaker[Session], llm_provider: LLMProvider
) -> ConversationEngine:
    return ConversationEngine(
        PostgresTransactionScope(session_factory),
        interpreter=InterpretMessage(llm_provider),
        collection_interpreter=InterpretCollectionInput(llm_provider),
        router=ReadOnlyQueryRouter(ZoneInfo("America/Argentina/Buenos_Aires")),
        clock=lambda: EXECUTED_AT,
    )


@pytest.fixture
def session_factory(migrated_engine: Engine) -> sessionmaker[Session]:
    return create_session_factory(migrated_engine)


@dataclass(frozen=True)
class Seed:
    customer_id: UUID
    account_id: UUID
    beneficiary_id: UUID


@pytest.fixture
def seed(session_factory: sessionmaker[Session]) -> Seed:
    customer = CustomerModel(id=uuid4(), first_name="Ana", last_name="García")
    account = AccountModel(
        id=uuid4(),
        customer=customer,
        name="Caja de ahorro",
        balance=Decimal("150000.50"),
        currency=Currency.ARS,
        status=AccountStatus.ACTIVE,
    )
    beneficiary = BeneficiaryModel(
        id=uuid4(),
        customer=customer,
        name="Laura",
        account_reference="0000003100012345678901",
        bank_name=None,
    )
    with session_factory.begin() as session:
        session.add_all([customer, account, beneficiary])
    return Seed(customer.id, account.id, beneficiary.id)


def record_transfer(repositories: PostgresRepositories, seed: Seed) -> UUID:
    """Perform the writes of a transfer execution through the given repositories."""
    account = repositories.accounts.get_for_update(seed.customer_id, seed.account_id)
    assert account is not None
    transfer = Transfer(
        id=uuid4(),
        source_account_id=seed.account_id,
        beneficiary_id=seed.beneficiary_id,
        amount=TRANSFER_AMOUNT,
        status=TransferStatus.COMPLETED,
        created_at=EXECUTED_AT,
        executed_at=EXECUTED_AT,
    )
    repositories.accounts.update_balance(seed.account_id, BALANCE_AFTER_TRANSFER)
    repositories.transfers.add(
        transfer,
        Transaction(
            id=uuid4(),
            account_id=seed.account_id,
            amount=TRANSFER_AMOUNT,
            type=TransactionType.DEBIT,
            category=TransactionCategory.TRANSFER,
            description="Transfer to Laura",
            occurred_at=EXECUTED_AT,
            transfer_id=transfer.id,
        ),
    )
    return transfer.id


def stored_state(
    session_factory: sessionmaker[Session], seed: Seed, transfer_id: UUID
) -> tuple[Decimal, bool, bool]:
    with session_factory() as session:
        balance = session.get_one(AccountModel, seed.account_id).balance
        transfer = session.get(TransferModel, transfer_id)
        transaction = session.scalars(
            select(TransactionModel).where(TransactionModel.transfer_id == transfer_id)
        ).one_or_none()
        return balance, transfer is not None, transaction is not None


def test_scope_commits_all_writes_on_success(
    session_factory: sessionmaker[Session], seed: Seed
) -> None:
    with PostgresTransactionScope(session_factory).begin() as repositories:
        transfer_id = record_transfer(repositories, seed)

    assert stored_state(session_factory, seed, transfer_id) == (
        Decimal("125000.50"),
        True,
        True,
    )


def test_scope_rolls_back_all_writes_on_exception(
    session_factory: sessionmaker[Session], seed: Seed
) -> None:
    transfer_ids: list[UUID] = []

    with pytest.raises(ExecutionInterrupted):
        with PostgresTransactionScope(session_factory).begin() as repositories:
            transfer_ids.append(record_transfer(repositories, seed))
            raise ExecutionInterrupted

    assert stored_state(session_factory, seed, transfer_ids[0]) == (
        Decimal("150000.50"),
        False,
        False,
    )


def test_container_scope_uses_container_database(
    session_factory: sessionmaker[Session], seed: Seed, test_container: Container
) -> None:
    with test_container.transaction_scope.begin() as repositories:
        transfer_id = record_transfer(repositories, seed)

    with test_container.session_factory() as session:
        assert session.get(TransferModel, transfer_id) is not None


def stored_conversation(
    session_factory: sessionmaker[Session], conversation_id: UUID
) -> tuple[datetime, list[UUID]]:
    with session_factory() as session:
        updated_at = session.get_one(ConversationModel, conversation_id).updated_at
        message_ids = list(
            session.scalars(
                select(MessageModel.id).where(
                    MessageModel.conversation_id == conversation_id
                )
            )
        )
        return updated_at, message_ids


def test_engine_turn_commits_message_and_activity_together(
    session_factory: sessionmaker[Session],
    seed: Seed,
    llm_provider: ScriptedLLMProvider,
) -> None:
    llm_provider.intent = Intent.GENERAL_CONVERSATION
    engine = make_engine(session_factory, llm_provider)
    record = engine.start(seed.customer_id)

    turn = engine.handle_message(
        seed.customer_id, record.conversation.id, "Hello Mimi."
    )

    assert turn.message is not None
    assert turn.flow_state is ConversationFlowState.READY
    assert stored_conversation(session_factory, record.conversation.id) == (
        EXECUTED_AT,
        [turn.message.id],
    )


def test_conversation_writes_roll_back_together_on_exception(
    session_factory: sessionmaker[Session],
    seed: Seed,
    llm_provider: ScriptedLLMProvider,
) -> None:
    engine = make_engine(session_factory, llm_provider)
    record = engine.start(seed.customer_id)
    later = datetime(2026, 10, 9, 17, 0, tzinfo=UTC)

    with pytest.raises(ExecutionInterrupted):
        with PostgresTransactionScope(session_factory).begin() as repositories:
            repositories.messages.add(
                Message(
                    id=uuid4(),
                    conversation_id=record.conversation.id,
                    role=MessageRole.USER,
                    content="Hello Mimi.",
                    created_at=later,
                )
            )
            repositories.conversations.touch(record.conversation.id, later)
            raise ExecutionInterrupted

    assert stored_conversation(session_factory, record.conversation.id) == (
        EXECUTED_AT,
        [],
    )


def test_container_engine_persists_conversation_turns(
    session_factory: sessionmaker[Session], seed: Seed, test_container: Container
) -> None:
    engine = test_container.conversation_engine
    record = engine.start(seed.customer_id)

    turn = engine.handle_message(
        seed.customer_id, record.conversation.id, "What's my balance?"
    )

    assert turn.message is not None
    with session_factory() as session:
        conversation = session.get_one(ConversationModel, record.conversation.id)
        message = session.get_one(MessageModel, turn.message.id)
        assert conversation.status is ConversationStatus.ACTIVE
        assert conversation.flow_state is ConversationFlowState.READY
        assert conversation.updated_at == turn.message.created_at
        assert message.content == "What's my balance?"


def test_engine_answers_balance_from_persisted_accounts(
    session_factory: sessionmaker[Session],
    seed: Seed,
    llm_provider: ScriptedLLMProvider,
) -> None:
    engine = make_engine(session_factory, llm_provider)
    record = engine.start(seed.customer_id)

    turn = engine.handle_message(
        seed.customer_id, record.conversation.id, "What's my balance?"
    )

    assert turn.message is not None
    assert turn.intent is Intent.GET_BALANCE
    assert turn.result == BalancesResult(
        (
            Account(
                id=seed.account_id,
                customer_id=seed.customer_id,
                name="Caja de ahorro",
                balance=Money(Decimal("150000.50"), Currency.ARS),
                status=AccountStatus.ACTIVE,
            ),
        )
    )
    assert stored_conversation(session_factory, record.conversation.id) == (
        EXECUTED_AT,
        [turn.message.id],
    )


def test_engine_failed_interpretation_persists_no_message(
    session_factory: sessionmaker[Session],
    seed: Seed,
    llm_provider: ScriptedLLMProvider,
) -> None:
    engine = make_engine(session_factory, llm_provider)
    record = engine.start(seed.customer_id)
    llm_provider.error = LLMUnavailableError()

    with pytest.raises(LLMUnavailableError):
        engine.handle_message(
            seed.customer_id, record.conversation.id, "What's my balance?"
        )

    assert stored_conversation(session_factory, record.conversation.id) == (
        record.conversation.updated_at,
        [],
    )


OPERATION_ID = uuid4()


def waiting_for_transfer(
    session_factory: sessionmaker[Session], seed: Seed, engine: ConversationEngine
) -> UUID:
    """Start a conversation whose transfer waits for confirmation under
    ``OPERATION_ID``."""
    conversation_id = engine.start(seed.customer_id).conversation.id
    with PostgresTransactionScope(session_factory).begin() as repositories:
        repositories.conversations.save_pending_operation(
            conversation_id,
            ConversationFlowState.WAITING_CONFIRMATION,
            PendingOperation(
                PendingOperationType.TRANSFER,
                TransferOperationData(
                    seed.account_id, seed.beneficiary_id, TRANSFER_AMOUNT
                ),
                OPERATION_ID,
            ),
        )
    return conversation_id


def stored_flow(
    session_factory: sessionmaker[Session], seed: Seed, conversation_id: UUID
) -> tuple[ConversationFlowState, PendingOperation | None]:
    with PostgresTransactionScope(session_factory).begin() as repositories:
        record = repositories.conversations.get_for_update(
            seed.customer_id, conversation_id
        )
        assert record is not None
        return record.flow_state, record.pending_operation


def test_engine_confirm_commits_the_transfer_and_clears_the_operation(
    session_factory: sessionmaker[Session],
    seed: Seed,
    llm_provider: ScriptedLLMProvider,
) -> None:
    llm_provider.error = AssertionError("interactions must not be interpreted")
    engine = make_engine(session_factory, llm_provider)
    conversation_id = waiting_for_transfer(session_factory, seed, engine)

    turn = engine.handle_interaction(
        seed.customer_id, conversation_id, Confirm(OPERATION_ID)
    )
    repeated = engine.handle_interaction(
        seed.customer_id, conversation_id, Confirm(OPERATION_ID)
    )

    assert isinstance(turn.result, OperationCompletedResult)
    assert turn.result.transfer is not None
    assert stored_state(session_factory, seed, turn.result.transfer.id) == (
        Decimal("125000.50"),
        True,
        True,
    )
    assert stored_flow(session_factory, seed, conversation_id) == (
        ConversationFlowState.READY,
        None,
    )
    assert repeated.result == NoPendingOperationResult(Confirm(OPERATION_ID))
    with session_factory() as session:
        assert session.scalar(select(func.count()).select_from(TransferModel)) == 1


def test_engine_cancel_clears_the_operation_without_financial_writes(
    session_factory: sessionmaker[Session],
    seed: Seed,
    llm_provider: ScriptedLLMProvider,
) -> None:
    engine = make_engine(session_factory, llm_provider)
    conversation_id = waiting_for_transfer(session_factory, seed, engine)

    turn = engine.handle_interaction(seed.customer_id, conversation_id, Cancel())
    confirmed = engine.handle_interaction(
        seed.customer_id, conversation_id, Confirm(OPERATION_ID)
    )

    assert isinstance(turn.result, OperationCancelledResult)
    assert confirmed.result == NoPendingOperationResult(Confirm(OPERATION_ID))
    assert stored_flow(session_factory, seed, conversation_id) == (
        ConversationFlowState.READY,
        None,
    )
    assert financial_state(session_factory, seed) == (Decimal("150000.50"), 0, 0)


def test_engine_close_discards_the_waiting_operation_without_executing_it(
    session_factory: sessionmaker[Session],
    seed: Seed,
    llm_provider: ScriptedLLMProvider,
) -> None:
    engine = make_engine(session_factory, llm_provider)
    conversation_id = waiting_for_transfer(session_factory, seed, engine)
    message = engine.handle_message(seed.customer_id, conversation_id, "Saldo").message
    assert message is not None

    closed = engine.close(seed.customer_id, conversation_id)

    with pytest.raises(ConversationClosedError):
        engine.handle_interaction(
            seed.customer_id, conversation_id, Confirm(OPERATION_ID)
        )
    with PostgresTransactionScope(session_factory).begin() as repositories:
        stored = repositories.conversations.get_for_update(
            seed.customer_id, conversation_id
        )
    assert stored == closed
    assert stored.conversation.status is ConversationStatus.CLOSED
    assert stored.pending_operation is None
    assert stored.context == EMPTY_CONTEXT
    assert stored_conversation(session_factory, conversation_id) == (
        EXECUTED_AT,
        [message.id],
    )
    with session_factory() as session:
        assert session.get_one(AccountModel, seed.account_id).balance == Decimal(
            "150000.50"
        )
        assert session.scalar(select(func.count()).select_from(TransferModel)) == 0


def financial_state(
    session_factory: sessionmaker[Session], seed: Seed
) -> tuple[Decimal, int | None, int | None]:
    """The source balance and the number of stored transfers and transactions."""
    with session_factory() as session:
        return (
            session.get_one(AccountModel, seed.account_id).balance,
            session.scalar(select(func.count()).select_from(TransferModel)),
            session.scalar(select(func.count()).select_from(TransactionModel)),
        )


def test_engine_transfer_round_trip_is_observed_by_balance_and_transactions(
    session_factory: sessionmaker[Session],
    seed: Seed,
    llm_provider: ScriptedLLMProvider,
) -> None:
    engine = make_engine(session_factory, llm_provider)
    conversation_id = engine.start(seed.customer_id).conversation.id

    # The request names no amount, so the amount is collected.
    llm_provider.intent = Intent.TRANSFER_MONEY
    llm_provider.values = {"beneficiary_reference": "Laura"}
    requested = engine.handle_message(
        seed.customer_id, conversation_id, "Transferile a Laura"
    )
    assert requested.flow_state is ConversationFlowState.COLLECTING_DATA
    assert stored_flow(session_factory, seed, conversation_id) == (
        ConversationFlowState.COLLECTING_DATA,
        PendingOperation(
            PendingOperationType.TRANSFER,
            TransferOperationData(seed.account_id, seed.beneficiary_id),
        ),
    )

    llm_provider.values = {"amount": "25000.00"}
    answered = engine.handle_message(seed.customer_id, conversation_id, "25000")
    assert isinstance(answered.result, AwaitingConfirmationResult)
    operation_id = answered.result.operation.operation_id
    assert operation_id is not None
    operation = PendingOperation(
        PendingOperationType.TRANSFER,
        TransferOperationData(seed.account_id, seed.beneficiary_id, TRANSFER_AMOUNT),
        operation_id,
    )
    assert answered.intent is Intent.TRANSFER_MONEY
    assert answered.flow_state is ConversationFlowState.WAITING_CONFIRMATION
    assert answered.result.operation == operation
    assert stored_flow(session_factory, seed, conversation_id) == (
        ConversationFlowState.WAITING_CONFIRMATION,
        operation,
    )
    assert financial_state(session_factory, seed) == (Decimal("150000.50"), 0, 0)

    llm_provider.error = AssertionError("interactions must not be interpreted")
    confirmed = engine.handle_interaction(
        seed.customer_id, conversation_id, Confirm(operation_id)
    )
    assert confirmed.intent is Intent.TRANSFER_MONEY
    assert confirmed.flow_state is ConversationFlowState.READY
    assert isinstance(confirmed.result, OperationCompletedResult)
    assert confirmed.result.operation == operation
    transfer = confirmed.result.transfer
    assert transfer is not None
    assert transfer == Transfer(
        id=transfer.id,
        source_account_id=seed.account_id,
        beneficiary_id=seed.beneficiary_id,
        amount=TRANSFER_AMOUNT,
        status=TransferStatus.COMPLETED,
        created_at=EXECUTED_AT,
        executed_at=EXECUTED_AT,
    )
    assert stored_state(session_factory, seed, transfer.id) == (
        Decimal("125000.50"),
        True,
        True,
    )
    assert financial_state(session_factory, seed) == (Decimal("125000.50"), 1, 1)
    assert stored_flow(session_factory, seed, conversation_id) == (
        ConversationFlowState.READY,
        None,
    )

    llm_provider.error = None
    llm_provider.values = {}
    llm_provider.intent = Intent.GET_BALANCE
    balances = engine.handle_message(seed.customer_id, conversation_id, "Saldo")
    assert isinstance(balances.result, BalancesResult)
    [account] = balances.result.accounts
    assert account.balance == BALANCE_AFTER_TRANSFER

    llm_provider.intent = Intent.GET_TRANSACTIONS
    movements = engine.handle_message(seed.customer_id, conversation_id, "Movimientos")
    assert isinstance(movements.result, TransactionsResult)
    [transaction] = movements.result.transactions
    assert transaction == Transaction(
        id=transaction.id,
        account_id=seed.account_id,
        amount=TRANSFER_AMOUNT,
        type=TransactionType.DEBIT,
        category=TransactionCategory.TRANSFER,
        description="Transfer to Laura",
        occurred_at=EXECUTED_AT,
        transfer_id=transfer.id,
    )


def test_engine_confirm_failing_revalidation_writes_nothing(
    session_factory: sessionmaker[Session],
    seed: Seed,
    llm_provider: ScriptedLLMProvider,
) -> None:
    engine = make_engine(session_factory, llm_provider)
    conversation_id = engine.start(seed.customer_id).conversation.id
    llm_provider.intent = Intent.TRANSFER_MONEY
    llm_provider.values = {"amount": "25000.00", "beneficiary_reference": "Laura"}
    requested = engine.handle_message(
        seed.customer_id, conversation_id, "Transferile 25000 a Laura"
    )
    assert requested.flow_state is ConversationFlowState.WAITING_CONFIRMATION
    assert isinstance(requested.result, AwaitingConfirmationResult)
    operation = requested.result.operation
    assert operation.operation_id is not None

    # The balance dropped elsewhere after pre-validation.
    with session_factory.begin() as session:
        session.get_one(AccountModel, seed.account_id).balance = Decimal("100.00")

    llm_provider.error = AssertionError("interactions must not be interpreted")
    turn = engine.handle_interaction(
        seed.customer_id, conversation_id, Confirm(operation.operation_id)
    )

    assert turn.flow_state is ConversationFlowState.READY
    assert isinstance(turn.result, OperationFailedResult)
    assert turn.result.operation == operation
    assert isinstance(turn.result.error, InsufficientFundsError)
    assert financial_state(session_factory, seed) == (Decimal("100.00"), 0, 0)
    assert stored_flow(session_factory, seed, conversation_id) == (
        ConversationFlowState.READY,
        None,
    )


def test_engine_confirm_interrupted_after_the_first_write_writes_nothing(
    session_factory: sessionmaker[Session],
    seed: Seed,
    llm_provider: ScriptedLLMProvider,
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    llm_provider.error = AssertionError("interactions must not be interpreted")
    engine = make_engine(session_factory, llm_provider)
    conversation_id = waiting_for_transfer(session_factory, seed, engine)
    waiting = stored_flow(session_factory, seed, conversation_id)

    # The transfer fails to be recorded after the balance was updated.
    def interrupt(*args: object) -> None:
        raise ExecutionInterrupted

    monkeypatch.setattr(PostgresTransferRepository, "add", interrupt)

    with pytest.raises(ExecutionInterrupted):
        engine.handle_interaction(
            seed.customer_id, conversation_id, Confirm(OPERATION_ID)
        )

    assert financial_state(session_factory, seed) == (Decimal("150000.50"), 0, 0)
    assert stored_flow(session_factory, seed, conversation_id) == waiting

    monkeypatch.undo()
    retried = engine.handle_interaction(
        seed.customer_id, conversation_id, Confirm(OPERATION_ID)
    )

    assert isinstance(retried.result, OperationCompletedResult)
    assert financial_state(session_factory, seed) == (Decimal("125000.50"), 1, 1)
    assert stored_flow(session_factory, seed, conversation_id) == (
        ConversationFlowState.READY,
        None,
    )


def test_engine_correction_invalidates_the_earlier_confirmation(
    session_factory: sessionmaker[Session],
    seed: Seed,
    llm_provider: ScriptedLLMProvider,
) -> None:
    engine = make_engine(session_factory, llm_provider)
    conversation_id = engine.start(seed.customer_id).conversation.id
    llm_provider.intent = Intent.TRANSFER_MONEY
    llm_provider.values = {"amount": "25000.00", "beneficiary_reference": "Laura"}
    requested = engine.handle_message(
        seed.customer_id, conversation_id, "Transferile 25000 a Laura"
    )
    assert isinstance(requested.result, AwaitingConfirmationResult)
    earlier = requested.result.operation.operation_id
    assert earlier is not None

    llm_provider.values = {"amount": "20000.00"}
    corrected = engine.handle_message(
        seed.customer_id, conversation_id, "No, mejor 20000"
    )

    assert corrected.flow_state is ConversationFlowState.WAITING_CONFIRMATION
    assert isinstance(corrected.result, AwaitingConfirmationResult)
    operation_id = corrected.result.operation.operation_id
    assert operation_id is not None
    assert operation_id != earlier
    operation = PendingOperation(
        PendingOperationType.TRANSFER,
        TransferOperationData(
            seed.account_id,
            seed.beneficiary_id,
            Money(Decimal("20000.00"), Currency.ARS),
        ),
        operation_id,
    )
    assert corrected.result.operation == operation
    assert stored_flow(session_factory, seed, conversation_id) == (
        ConversationFlowState.WAITING_CONFIRMATION,
        operation,
    )

    llm_provider.error = AssertionError("interactions must not be interpreted")
    with pytest.raises(InvalidInteractionError):
        engine.handle_interaction(seed.customer_id, conversation_id, Confirm(earlier))
    assert stored_flow(session_factory, seed, conversation_id) == (
        ConversationFlowState.WAITING_CONFIRMATION,
        operation,
    )
    assert financial_state(session_factory, seed) == (Decimal("150000.50"), 0, 0)

    confirmed = engine.handle_interaction(
        seed.customer_id, conversation_id, Confirm(operation_id)
    )

    assert isinstance(confirmed.result, OperationCompletedResult)
    assert confirmed.result.operation == operation
    assert confirmed.result.transfer is not None
    assert confirmed.result.transfer.amount == Money(Decimal("20000.00"), Currency.ARS)
    assert financial_state(session_factory, seed) == (Decimal("130000.50"), 1, 1)
    assert stored_flow(session_factory, seed, conversation_id) == (
        ConversationFlowState.READY,
        None,
    )


@dataclass(frozen=True)
class SeedCards:
    active: Card
    frozen: Card
    other_customers: Card


@pytest.fixture
def cards(session_factory: sessionmaker[Session], seed: Seed) -> SeedCards:
    other_customer = CustomerModel(id=uuid4(), first_name="Otro", last_name="Cliente")
    other_account = AccountModel(
        id=uuid4(),
        customer=other_customer,
        name="Caja de ahorro",
        balance=Decimal("1000.00"),
        currency=Currency.ARS,
        status=AccountStatus.ACTIVE,
    )
    seeded = SeedCards(
        active=Card(
            uuid4(),
            seed.account_id,
            CardType.DEBIT,
            CardBrand.VISA,
            "4821",
            CardStatus.ACTIVE,
        ),
        frozen=Card(
            uuid4(),
            seed.account_id,
            CardType.CREDIT,
            CardBrand.VISA,
            "9134",
            CardStatus.FROZEN,
        ),
        other_customers=Card(
            uuid4(),
            other_account.id,
            CardType.DEBIT,
            CardBrand.MASTERCARD,
            "7310",
            CardStatus.ACTIVE,
        ),
    )
    with session_factory.begin() as session:
        session.add_all([other_customer, other_account])
        session.flush()
        session.add_all(
            CardModel(
                id=card.id,
                account_id=card.account_id,
                type=card.type,
                brand=card.brand,
                last_four=card.last_four,
                status=card.status,
            )
            for card in (seeded.active, seeded.frozen, seeded.other_customers)
        )
    return seeded


def stored_card_status(
    session_factory: sessionmaker[Session], card_id: UUID
) -> CardStatus:
    with session_factory() as session:
        return session.get_one(CardModel, card_id).status


@pytest.mark.parametrize(
    ("intent", "operation_type", "frozen", "status"),
    [
        (
            Intent.FREEZE_CARD,
            PendingOperationType.FREEZE_CARD,
            False,
            CardStatus.FROZEN,
        ),
        (
            Intent.UNFREEZE_CARD,
            PendingOperationType.UNFREEZE_CARD,
            True,
            CardStatus.ACTIVE,
        ),
    ],
    ids=["freeze", "unfreeze"],
)
def test_engine_card_operation_round_trip_is_observed_by_card_query(
    session_factory: sessionmaker[Session],
    seed: Seed,
    cards: SeedCards,
    llm_provider: ScriptedLLMProvider,
    intent: Intent,
    operation_type: PendingOperationType,
    frozen: bool,
    status: CardStatus,
) -> None:
    card = cards.frozen if frozen else cards.active
    data = (
        FreezeCardOperationData
        if operation_type is PendingOperationType.FREEZE_CARD
        else UnfreezeCardOperationData
    )
    engine = make_engine(session_factory, llm_provider)
    conversation_id = engine.start(seed.customer_id).conversation.id

    # The request names no card, so the card is collected.
    llm_provider.intent = intent
    requested = engine.handle_message(seed.customer_id, conversation_id, "Mi tarjeta")
    assert requested.flow_state is ConversationFlowState.COLLECTING_DATA
    assert stored_flow(session_factory, seed, conversation_id) == (
        ConversationFlowState.COLLECTING_DATA,
        PendingOperation(operation_type, data()),
    )

    llm_provider.error = AssertionError("interactions must not be interpreted")
    selected = engine.handle_interaction(
        seed.customer_id, conversation_id, SelectCard(card.id)
    )
    assert isinstance(selected.result, AwaitingConfirmationResult)
    operation_id = selected.result.operation.operation_id
    assert operation_id is not None
    operation = PendingOperation(operation_type, data(card.id), operation_id)
    assert selected.result == AwaitingConfirmationResult(operation, card=card)
    assert stored_flow(session_factory, seed, conversation_id) == (
        ConversationFlowState.WAITING_CONFIRMATION,
        operation,
    )
    assert stored_card_status(session_factory, card.id) is card.status

    confirmed = engine.handle_interaction(
        seed.customer_id, conversation_id, Confirm(operation_id)
    )
    changed = replace(card, status=status)
    assert confirmed.intent is intent
    assert confirmed.result == OperationCompletedResult(operation, card=changed)
    assert stored_card_status(session_factory, card.id) is status
    assert stored_flow(session_factory, seed, conversation_id) == (
        ConversationFlowState.READY,
        None,
    )

    llm_provider.error = None
    llm_provider.intent = Intent.GET_CARDS
    queried = engine.handle_message(seed.customer_id, conversation_id, "Mis tarjetas")
    assert isinstance(queried.result, CardsResult)
    assert set(queried.result.cards) == {
        changed,
        cards.frozen if not frozen else cards.active,
    }


def test_engine_cancel_leaves_the_card_unchanged(
    session_factory: sessionmaker[Session],
    seed: Seed,
    cards: SeedCards,
    llm_provider: ScriptedLLMProvider,
) -> None:
    engine = make_engine(session_factory, llm_provider)
    conversation_id = engine.start(seed.customer_id).conversation.id
    operation = PendingOperation(
        PendingOperationType.FREEZE_CARD,
        FreezeCardOperationData(cards.active.id),
        uuid4(),
    )
    with PostgresTransactionScope(session_factory).begin() as repositories:
        repositories.conversations.save_pending_operation(
            conversation_id, ConversationFlowState.WAITING_CONFIRMATION, operation
        )

    turn = engine.handle_interaction(seed.customer_id, conversation_id, Cancel())

    assert turn.result == OperationCancelledResult(operation)
    assert stored_card_status(session_factory, cards.active.id) is CardStatus.ACTIVE
    assert stored_flow(session_factory, seed, conversation_id) == (
        ConversationFlowState.READY,
        None,
    )


def test_engine_rejects_selecting_another_customers_card(
    session_factory: sessionmaker[Session],
    seed: Seed,
    cards: SeedCards,
    llm_provider: ScriptedLLMProvider,
) -> None:
    engine = make_engine(session_factory, llm_provider)
    conversation_id = engine.start(seed.customer_id).conversation.id
    llm_provider.intent = Intent.FREEZE_CARD
    engine.handle_message(seed.customer_id, conversation_id, "Congelá mi tarjeta")

    turn = engine.handle_interaction(
        seed.customer_id, conversation_id, SelectCard(cards.other_customers.id)
    )

    collecting = PendingOperation(
        PendingOperationType.FREEZE_CARD, FreezeCardOperationData()
    )
    assert turn.flow_state is ConversationFlowState.COLLECTING_DATA
    assert turn.result == CollectingDataResult(
        collecting, {PendingField.CARD_ID: FieldIssue.NOT_FOUND}
    )
    assert stored_flow(session_factory, seed, conversation_id) == (
        ConversationFlowState.COLLECTING_DATA,
        collecting,
    )
    assert (
        stored_card_status(session_factory, cards.other_customers.id)
        is CardStatus.ACTIVE
    )
