from collections.abc import Iterator
from contextlib import contextmanager
from dataclasses import dataclass, replace
from datetime import datetime, timedelta, timezone
from uuid import UUID, uuid4

import pytest

from mimi.application.conversation_engine import ConversationEngine, Turn
from mimi.application.errors import ConversationClosedError, ConversationNotFoundError
from mimi.application.repositories import ConversationRecord
from mimi.domain.entities import Conversation, Message
from mimi.domain.enums import ConversationFlowState, ConversationStatus, MessageRole

BUENOS_AIRES = timezone(timedelta(hours=-3))
STARTED_AT = datetime(2026, 10, 9, 13, 0, tzinfo=BUENOS_AIRES)
NOW = datetime(2026, 10, 9, 13, 31, 4, tzinfo=BUENOS_AIRES)

CUSTOMER_ID = uuid4()
OTHER_CUSTOMER_ID = uuid4()


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


@dataclass(frozen=True)
class FakeRepositories:
    conversations: FakeConversationRepository
    messages: FakeMessageRepository


class FakeTransactionScope:
    def __init__(self) -> None:
        self.repositories = FakeRepositories(
            FakeConversationRepository(), FakeMessageRepository()
        )
        self.committed = 0

    @contextmanager
    def begin(self) -> Iterator[FakeRepositories]:
        yield self.repositories
        self.committed += 1


@pytest.fixture
def scope() -> FakeTransactionScope:
    return FakeTransactionScope()


@pytest.fixture
def engine(scope: FakeTransactionScope) -> ConversationEngine:
    return ConversationEngine(scope, clock=lambda: NOW)


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


def test_handle_message_persists_user_message(
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
    )
    assert scope.repositories.messages.list_by_conversation(record.conversation.id) == [
        expected_message
    ]
    assert scope.committed == 1


def test_handle_message_updates_conversation_activity(
    engine: ConversationEngine, scope: FakeTransactionScope
) -> None:
    record = store_conversation(scope)

    engine.handle_message(CUSTOMER_ID, record.conversation.id, "Hello Mimi.")

    stored = scope.repositories.conversations.records[record.conversation.id]
    assert stored.conversation.updated_at == NOW
    assert stored.conversation.created_at == STARTED_AT


def test_handle_message_rejects_unknown_conversation(
    engine: ConversationEngine, scope: FakeTransactionScope
) -> None:
    with pytest.raises(ConversationNotFoundError):
        engine.handle_message(CUSTOMER_ID, uuid4(), "Hello Mimi.")

    assert scope.repositories.messages.messages == []


def test_handle_message_rejects_other_customers_conversation(
    engine: ConversationEngine, scope: FakeTransactionScope
) -> None:
    record = store_conversation(scope, customer_id=OTHER_CUSTOMER_ID)

    with pytest.raises(ConversationNotFoundError):
        engine.handle_message(CUSTOMER_ID, record.conversation.id, "Hello Mimi.")

    assert scope.repositories.messages.messages == []
    assert scope.repositories.conversations.records[record.conversation.id] == record


def test_handle_message_rejects_closed_conversation(
    engine: ConversationEngine, scope: FakeTransactionScope
) -> None:
    record = store_conversation(scope, status=ConversationStatus.CLOSED)

    with pytest.raises(ConversationClosedError):
        engine.handle_message(CUSTOMER_ID, record.conversation.id, "Hello Mimi.")

    assert scope.repositories.messages.messages == []
    assert scope.repositories.conversations.records[record.conversation.id] == record


@pytest.mark.parametrize("content", ["", "   ", "\t\n"])
def test_handle_message_rejects_blank_content(
    engine: ConversationEngine, scope: FakeTransactionScope, content: str
) -> None:
    record = store_conversation(scope)

    with pytest.raises(ValueError, match="blank"):
        engine.handle_message(CUSTOMER_ID, record.conversation.id, content)

    assert scope.repositories.messages.messages == []


def test_naive_clock_is_rejected(scope: FakeTransactionScope) -> None:
    engine = ConversationEngine(scope, clock=lambda: NOW.replace(tzinfo=None))
    record = store_conversation(scope)

    with pytest.raises(ValueError, match="timezone-aware"):
        engine.start(CUSTOMER_ID)
    with pytest.raises(ValueError, match="timezone-aware"):
        engine.handle_message(CUSTOMER_ID, record.conversation.id, "Hello Mimi.")

    assert list(scope.repositories.conversations.records) == [record.conversation.id]
    assert scope.repositories.messages.messages == []
