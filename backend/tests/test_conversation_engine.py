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

from mimi.application.conversation_engine import ConversationEngine, Turn
from mimi.application.conversation_results import (
    BalancesResult,
    IncompleteQueryResult,
    UnhandledIntentResult,
)
from mimi.application.errors import (
    ConversationClosedError,
    ConversationNotFoundError,
    LLMInvalidResponseError,
    LLMUnavailableError,
)
from mimi.application.interpretation import Intent
from mimi.application.read_only_queries import ReadOnlyQueryRouter
from mimi.application.repositories import ConversationRecord, TransactionQuery
from mimi.application.use_cases.interpret_message import InterpretMessage
from mimi.domain.entities import (
    Account,
    Beneficiary,
    Card,
    Conversation,
    Message,
    Money,
    Transaction,
)
from mimi.domain.enums import (
    AccountStatus,
    CardStatus,
    ConversationFlowState,
    ConversationStatus,
    Currency,
    MessageRole,
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
}


def model_output(**fields: Any) -> dict[str, Any]:
    return {**EMPTY_OUTPUT, **fields}


def refuse_write(*args: object) -> NoReturn:
    raise AssertionError("read-only routing must not write")


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

    def touch(self, conversation_id: UUID, updated_at: datetime) -> None:
        record = self.records[conversation_id]
        self.records[conversation_id] = replace(
            record, conversation=replace(record.conversation, updated_at=updated_at)
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

    def list_by_customer(self, customer_id: UUID) -> list[Account]:
        return [a for a in self.accounts if a.customer_id == customer_id]

    def get_for_update(self, customer_id: UUID, account_id: UUID) -> Account | None:
        refuse_write()

    def update_balance(self, account_id: UUID, balance: Money) -> None:
        refuse_write()


class FakeCardRepository:
    def list_by_customer(self, customer_id: UUID) -> list[Card]:
        return []

    def get(self, customer_id: UUID, card_id: UUID) -> Card | None:
        return None

    def update_status(self, card_id: UUID, status: CardStatus) -> None:
        refuse_write()


class FakeBeneficiaryRepository:
    def list_by_customer(self, customer_id: UUID) -> list[Beneficiary]:
        return []

    def get(self, customer_id: UUID, beneficiary_id: UUID) -> Beneficiary | None:
        return None


class FakeTransactionRepository:
    def list_by_customer(
        self, customer_id: UUID, query: TransactionQuery
    ) -> list[Transaction]:
        return []


@dataclass(frozen=True)
class FakeRepositories:
    conversations: FakeConversationRepository
    messages: FakeMessageRepository
    accounts: FakeAccountRepository
    cards: FakeCardRepository
    beneficiaries: FakeBeneficiaryRepository
    transactions: FakeTransactionRepository


class FakeTransactionScope:
    def __init__(self) -> None:
        self.repositories = FakeRepositories(
            FakeConversationRepository(),
            FakeMessageRepository(),
            FakeAccountRepository(),
            FakeCardRepository(),
            FakeBeneficiaryRepository(),
            FakeTransactionRepository(),
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
    whether a database transaction was open when it was called."""

    def __init__(self, scope: FakeTransactionScope) -> None:
        self._scope = scope
        self.output = model_output(intent="GET_BALANCE")
        self.error: Exception | None = None
        self.on_call: Callable[[], None] | None = None
        self.calls: list[str] = []
        self.called_in_transaction: list[bool] = []

    def generate_structured[T: BaseModel](
        self, *, instructions: str, input_text: str, output_type: type[T]
    ) -> T:
        self.calls.append(input_text)
        self.called_in_transaction.append(self._scope.in_transaction)
        if self.on_call is not None:
            self.on_call()
        if self.error is not None:
            raise self.error
        return output_type.model_validate(self.output)


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


def test_handle_message_reports_flow_state_read_under_turn_lock(
    engine: ConversationEngine, scope: FakeTransactionScope, llm: FakeLLMProvider
) -> None:
    record = store_conversation(scope)
    conversation_id = record.conversation.id
    llm.on_call = lambda: replace_stored(
        scope, conversation_id, flow_state=ConversationFlowState.WAITING_CONFIRMATION
    )

    turn = engine.handle_message(CUSTOMER_ID, conversation_id, "What's my balance?")

    assert turn.flow_state is ConversationFlowState.WAITING_CONFIRMATION
    assert turn.result == BalancesResult((SAVINGS,))
    stored = scope.repositories.conversations.records[conversation_id]
    assert stored.flow_state is ConversationFlowState.WAITING_CONFIRMATION


@pytest.mark.parametrize(
    "intent",
    ["FREEZE_CARD", "UNFREEZE_CARD", "TRANSFER_MONEY", "GENERAL_CONVERSATION"],
)
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
