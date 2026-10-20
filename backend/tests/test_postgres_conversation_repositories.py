from dataclasses import dataclass
from datetime import UTC, datetime, timedelta, timezone
from uuid import UUID, uuid4

import pytest
from sqlalchemy import Engine
from sqlalchemy.orm import Session, sessionmaker

from mimi.application.conversation_context import (
    EMPTY_CONTEXT,
    ConversationContext,
    TemporalContext,
)
from mimi.application.interpretation import Intent, PeriodReference
from mimi.application.repositories import ConversationRecord
from mimi.domain.entities import Conversation, Message
from mimi.domain.enums import (
    ConversationFlowState,
    ConversationStatus,
    MessageRole,
    TransactionCategory,
    TransactionType,
)
from mimi.infrastructure.database.models import ConversationModel, CustomerModel
from mimi.infrastructure.database.repositories import (
    PostgresConversationRepository,
    PostgresMessageRepository,
)
from mimi.infrastructure.database.session import create_session_factory

pytestmark = pytest.mark.integration

BUENOS_AIRES = timezone(timedelta(hours=-3))
STARTED_AT = datetime(2026, 10, 9, 13, 0, tzinfo=BUENOS_AIRES)


@pytest.fixture
def session_factory(migrated_engine: Engine) -> sessionmaker[Session]:
    return create_session_factory(migrated_engine)


@dataclass(frozen=True)
class Customers:
    customer_id: UUID
    other_customer_id: UUID


@pytest.fixture
def customers(session_factory: sessionmaker[Session]) -> Customers:
    customer = CustomerModel(id=uuid4(), first_name="Ana", last_name="García")
    other = CustomerModel(id=uuid4(), first_name="Bruno", last_name="Díaz")
    with session_factory.begin() as session:
        session.add_all([customer, other])
    return Customers(customer.id, other.id)


def make_record(
    customer_id: UUID, status: ConversationStatus = ConversationStatus.ACTIVE
) -> ConversationRecord:
    return ConversationRecord(
        conversation=Conversation(
            id=uuid4(),
            customer_id=customer_id,
            status=status,
            created_at=STARTED_AT,
            updated_at=STARTED_AT,
        ),
        flow_state=ConversationFlowState.READY,
    )


def add_record(
    session_factory: sessionmaker[Session], record: ConversationRecord
) -> None:
    with session_factory.begin() as session:
        PostgresConversationRepository(session).add(record)


def make_message(
    conversation_id: UUID,
    created_at: datetime,
    *,
    id: UUID | None = None,
    role: MessageRole = MessageRole.USER,
    content: str = "Hello Mimi.",
) -> Message:
    return Message(
        id=id or uuid4(),
        conversation_id=conversation_id,
        role=role,
        content=content,
        created_at=created_at,
    )


def test_added_conversation_round_trips(
    session_factory: sessionmaker[Session], customers: Customers
) -> None:
    record = make_record(customers.customer_id)
    add_record(session_factory, record)

    with session_factory.begin() as session:
        loaded = PostgresConversationRepository(session).get_for_update(
            customers.customer_id, record.conversation.id
        )

    assert loaded == record
    assert loaded.conversation.created_at.utcoffset() is not None


def test_added_conversation_has_empty_context_and_no_pending_operation(
    session_factory: sessionmaker[Session], customers: Customers
) -> None:
    record = make_record(customers.customer_id)
    add_record(session_factory, record)

    with session_factory() as session:
        model = session.get_one(ConversationModel, record.conversation.id)
        assert model.context == {}
        assert model.pending_operation_type is None
        assert model.pending_missing_fields is None


def test_closed_conversation_is_loaded_with_its_status(
    session_factory: sessionmaker[Session], customers: Customers
) -> None:
    record = make_record(customers.customer_id, ConversationStatus.CLOSED)
    add_record(session_factory, record)

    with session_factory.begin() as session:
        loaded = PostgresConversationRepository(session).get_for_update(
            customers.customer_id, record.conversation.id
        )

    assert loaded == record


def test_get_for_update_is_scoped_to_owner(
    session_factory: sessionmaker[Session], customers: Customers
) -> None:
    record = make_record(customers.customer_id)
    add_record(session_factory, record)

    with session_factory.begin() as session:
        repository = PostgresConversationRepository(session)
        assert (
            repository.get_for_update(
                customers.other_customer_id, record.conversation.id
            )
            is None
        )
        assert repository.get_for_update(customers.customer_id, uuid4()) is None


def test_touch_updates_only_updated_at(
    session_factory: sessionmaker[Session], customers: Customers
) -> None:
    record = make_record(customers.customer_id)
    untouched = make_record(customers.customer_id)
    add_record(session_factory, record)
    add_record(session_factory, untouched)
    later = datetime(2026, 10, 9, 16, 31, 4, tzinfo=UTC)

    with session_factory.begin() as session:
        PostgresConversationRepository(session).touch(record.conversation.id, later)

    with session_factory.begin() as session:
        repository = PostgresConversationRepository(session)
        touched = repository.get_for_update(
            customers.customer_id, record.conversation.id
        )
        other = repository.get_for_update(
            customers.customer_id, untouched.conversation.id
        )

    assert touched is not None
    assert touched.conversation.updated_at == later
    assert touched.conversation.created_at == STARTED_AT
    assert other == untouched


CONTEXT = ConversationContext(
    last_intent=Intent.COMPARE_EXPENSES,
    category=TransactionCategory.DINING,
    temporal=TemporalContext(
        PeriodReference.CURRENT_MONTH,
        PeriodReference.PREVIOUS_MONTH,
        datetime(2026, 10, 9, 16, 31, 4, tzinfo=UTC),
    ),
)


def load(
    session_factory: sessionmaker[Session], customer_id: UUID, conversation_id: UUID
) -> ConversationRecord | None:
    with session_factory.begin() as session:
        return PostgresConversationRepository(session).get_for_update(
            customer_id, conversation_id
        )


def store_raw_context(
    session_factory: sessionmaker[Session], conversation_id: UUID, raw: object
) -> None:
    with session_factory.begin() as session:
        session.get_one(ConversationModel, conversation_id).context = raw  # type: ignore[assignment]


@pytest.mark.parametrize(
    "context",
    [
        CONTEXT,
        ConversationContext(
            last_intent=Intent.GET_TRANSACTIONS,
            transaction_type=TransactionType.CREDIT,
        ),
        ConversationContext(last_intent=Intent.GET_BALANCE),
    ],
)
def test_saved_context_round_trips(
    session_factory: sessionmaker[Session],
    customers: Customers,
    context: ConversationContext,
) -> None:
    record = make_record(customers.customer_id)
    add_record(session_factory, record)

    with session_factory.begin() as session:
        PostgresConversationRepository(session).save_context(
            record.conversation.id, context
        )

    loaded = load(session_factory, customers.customer_id, record.conversation.id)
    assert loaded is not None
    assert loaded.context == context
    assert loaded.conversation == record.conversation
    assert loaded.flow_state is record.flow_state


def test_save_context_affects_only_its_conversation(
    session_factory: sessionmaker[Session], customers: Customers
) -> None:
    record = make_record(customers.customer_id)
    other = make_record(customers.customer_id)
    add_record(session_factory, record)
    add_record(session_factory, other)

    with session_factory.begin() as session:
        PostgresConversationRepository(session).save_context(
            record.conversation.id, CONTEXT
        )

    assert load(session_factory, customers.customer_id, other.conversation.id) == other


def test_saving_empty_context_stores_an_empty_object(
    session_factory: sessionmaker[Session], customers: Customers
) -> None:
    record = make_record(customers.customer_id)
    add_record(session_factory, record)

    with session_factory.begin() as session:
        repository = PostgresConversationRepository(session)
        repository.save_context(record.conversation.id, CONTEXT)
        repository.save_context(record.conversation.id, EMPTY_CONTEXT)

    with session_factory() as session:
        assert session.get_one(ConversationModel, record.conversation.id).context == {}


@pytest.mark.parametrize(
    "raw",
    [
        {"version": 2, "last_intent": "GET_BALANCE"},
        {"last_intent": "NOT_AN_INTENT"},
        {"version": 1, "last_intent": "GET_BALANCE", "unexpected": True},
        {
            "version": 1,
            "last_intent": "ANALYZE_EXPENSES",
            "category": None,
            "transaction_type": None,
            "temporal": {
                "period": "CURRENT_MONTH",
                "comparison_period": None,
                "anchored_at": "2026-10-09T13:00:00",
            },
        },
    ],
    ids=["version", "intent", "extra", "naive"],
)
def test_malformed_context_loads_as_empty(
    session_factory: sessionmaker[Session], customers: Customers, raw: object
) -> None:
    record = make_record(customers.customer_id)
    add_record(session_factory, record)
    store_raw_context(session_factory, record.conversation.id, raw)

    loaded = load(session_factory, customers.customer_id, record.conversation.id)

    assert loaded is not None
    assert loaded.context == EMPTY_CONTEXT


def test_save_context_of_missing_conversation_fails(
    session_factory: sessionmaker[Session],
) -> None:
    with pytest.raises(RuntimeError, match="Expected to update one row"):
        with session_factory.begin() as session:
            PostgresConversationRepository(session).save_context(uuid4(), CONTEXT)


def test_touch_of_missing_conversation_fails(
    session_factory: sessionmaker[Session],
) -> None:
    with pytest.raises(RuntimeError, match="Expected to update one row"):
        with session_factory.begin() as session:
            PostgresConversationRepository(session).touch(uuid4(), STARTED_AT)


def test_messages_are_listed_oldest_first(
    session_factory: sessionmaker[Session], customers: Customers
) -> None:
    record = make_record(customers.customer_id)
    add_record(session_factory, record)
    conversation_id = record.conversation.id
    later = make_message(conversation_id, STARTED_AT + timedelta(seconds=2))
    earlier = make_message(
        conversation_id,
        STARTED_AT + timedelta(seconds=1),
        role=MessageRole.ASSISTANT,
        content="Hi! How can I help?",
    )
    # Equal timestamps are ordered by id.
    tie_high = make_message(
        conversation_id, STARTED_AT, id=UUID("ffffffff-ffff-4fff-bfff-ffffffffffff")
    )
    tie_low = make_message(
        conversation_id, STARTED_AT, id=UUID("00000000-0000-4000-8000-000000000000")
    )

    with session_factory.begin() as session:
        repository = PostgresMessageRepository(session)
        for message in (later, tie_high, earlier, tie_low):
            repository.add(message)

    with session_factory() as session:
        listed = PostgresMessageRepository(session).list_by_conversation(
            conversation_id
        )

    assert listed == [tie_low, tie_high, earlier, later]
    assert all(message.created_at.utcoffset() is not None for message in listed)


def test_messages_are_scoped_to_conversation(
    session_factory: sessionmaker[Session], customers: Customers
) -> None:
    record = make_record(customers.customer_id)
    other = make_record(customers.customer_id)
    add_record(session_factory, record)
    add_record(session_factory, other)
    message = make_message(record.conversation.id, STARTED_AT)

    with session_factory.begin() as session:
        repository = PostgresMessageRepository(session)
        repository.add(message)
        repository.add(make_message(other.conversation.id, STARTED_AT))

    with session_factory() as session:
        repository = PostgresMessageRepository(session)
        assert repository.list_by_conversation(record.conversation.id) == [message]
        assert repository.list_by_conversation(uuid4()) == []
