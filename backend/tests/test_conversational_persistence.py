from collections.abc import Callable
from dataclasses import dataclass
from datetime import datetime, timedelta, timezone
from decimal import Decimal
from typing import Any
from uuid import UUID, uuid4

import pytest
from sqlalchemy import Engine, select, text
from sqlalchemy.exc import IntegrityError, InvalidRequestError
from sqlalchemy.orm import Session, selectinload, sessionmaker

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
)
from mimi.infrastructure.database.models import (
    AccountModel,
    BeneficiaryModel,
    CardModel,
    ConversationModel,
    CustomerModel,
    MessageModel,
)
from mimi.infrastructure.database.session import create_session_factory

pytestmark = pytest.mark.integration

NOW = datetime(2026, 10, 9, 13, 31, 4, tzinfo=timezone(timedelta(hours=-3)))

READY = ConversationFlowState.READY
COLLECTING_DATA = ConversationFlowState.COLLECTING_DATA
WAITING_CONFIRMATION = ConversationFlowState.WAITING_CONFIRMATION
TRANSFER = PendingOperationType.TRANSFER
FREEZE_CARD = PendingOperationType.FREEZE_CARD
UNFREEZE_CARD = PendingOperationType.UNFREEZE_CARD


@dataclass(frozen=True)
class FinancialRefs:
    customer_id: UUID
    account_id: UUID
    beneficiary_id: UUID
    card_id: UUID
    conversation_id: UUID


Overrides = Callable[[FinancialRefs], dict[str, Any]]


@pytest.fixture
def session_factory(migrated_engine: Engine) -> sessionmaker[Session]:
    return create_session_factory(migrated_engine)


def conversation(refs: FinancialRefs, **overrides: Any) -> ConversationModel:
    values: dict[str, Any] = {
        "id": uuid4(),
        "customer_id": refs.customer_id,
        "status": ConversationStatus.ACTIVE,
        "created_at": NOW,
        "updated_at": NOW,
        "flow_state": READY,
        "context": {},
        "pending_operation_type": None,
        "pending_operation_id": None,
        "pending_source_account_id": None,
        "pending_beneficiary_id": None,
        "pending_amount": None,
        "pending_currency": None,
        "pending_card_id": None,
        "pending_missing_fields": None,
    }
    values.update(overrides)
    return ConversationModel(**values)


@pytest.fixture
def refs(session_factory: sessionmaker[Session]) -> FinancialRefs:
    customer = CustomerModel(id=uuid4(), first_name="Ana", last_name="García")
    account = AccountModel(
        id=uuid4(),
        customer=customer,
        name="Caja de ahorro",
        balance=Decimal("150000.00"),
        currency=Currency.ARS,
        status=AccountStatus.ACTIVE,
    )
    card = CardModel(
        id=uuid4(),
        account=account,
        type=CardType.DEBIT,
        brand=CardBrand.VISA,
        last_four="4821",
        status=CardStatus.ACTIVE,
    )
    beneficiary = BeneficiaryModel(
        id=uuid4(),
        customer=customer,
        name="Laura",
        account_reference="0000003100012345678901",
        bank_name=None,
    )
    refs = FinancialRefs(
        customer_id=customer.id,
        account_id=account.id,
        beneficiary_id=beneficiary.id,
        card_id=card.id,
        conversation_id=uuid4(),
    )
    with session_factory.begin() as session:
        session.add_all([customer, account, card, beneficiary])
        session.add(conversation(refs, id=refs.conversation_id))
    return refs


VALID_STATES: dict[str, Overrides] = {
    "ready_empty_context": lambda refs: {},
    "ready_with_context": lambda refs: {
        "context": {
            "last_intent": "ANALYZE_EXPENSES",
            "relevant_references": {"account_id": str(refs.account_id)},
            "temporal_context": {"period": "2026-09"},
        }
    },
    "collecting_transfer_data": lambda refs: {
        "flow_state": COLLECTING_DATA,
        "pending_operation_type": TRANSFER,
        "pending_beneficiary_id": refs.beneficiary_id,
        "pending_missing_fields": ["source_account_id", "amount"],
    },
    "collecting_correction_of_resolved_field": lambda refs: {
        "flow_state": COLLECTING_DATA,
        "pending_operation_type": TRANSFER,
        "pending_beneficiary_id": refs.beneficiary_id,
        "pending_missing_fields": ["beneficiary_id"],
    },
    "waiting_transfer_confirmation": lambda refs: {
        "flow_state": WAITING_CONFIRMATION,
        "pending_operation_id": uuid4(),
        "pending_operation_type": TRANSFER,
        "pending_source_account_id": refs.account_id,
        "pending_beneficiary_id": refs.beneficiary_id,
        "pending_amount": Decimal("25000.00"),
        "pending_currency": Currency.ARS,
        "pending_missing_fields": [],
    },
    "waiting_freeze_confirmation": lambda refs: {
        "flow_state": WAITING_CONFIRMATION,
        "pending_operation_id": uuid4(),
        "pending_operation_type": FREEZE_CARD,
        "pending_card_id": refs.card_id,
        "pending_missing_fields": [],
    },
    "collecting_unfreeze_card": lambda refs: {
        "flow_state": COLLECTING_DATA,
        "pending_operation_type": UNFREEZE_CARD,
        "pending_missing_fields": ["card_id"],
    },
    "closed": lambda refs: {"status": ConversationStatus.CLOSED},
}


@pytest.mark.parametrize("overrides", VALID_STATES.values(), ids=VALID_STATES.keys())
def test_valid_conversation_state_round_trips(
    session_factory: sessionmaker[Session], refs: FinancialRefs, overrides: Overrides
) -> None:
    original = conversation(refs, **overrides(refs))
    expected = {
        column.key: getattr(original, column.key)
        for column in ConversationModel.__table__.columns
    }
    with session_factory.begin() as session:
        session.add(original)

    with session_factory() as session:
        loaded = session.get_one(ConversationModel, original.id)
        actual = {key: getattr(loaded, key) for key in expected}

    assert actual == expected
    assert loaded.created_at.tzinfo is not None
    assert loaded.updated_at.tzinfo is not None
    if loaded.pending_amount is not None:
        assert isinstance(loaded.pending_amount, Decimal)


def test_messages_load_explicitly_in_deterministic_order(
    session_factory: sessionmaker[Session], refs: FinancialRefs
) -> None:
    tied_at = NOW + timedelta(seconds=1)
    messages = [
        MessageModel(
            id=uuid4(),
            conversation_id=refs.conversation_id,
            role=MessageRole.USER,
            content="Transfer 25,000 to Laura.",
            created_at=NOW,
        ),
        *(
            MessageModel(
                id=uuid4(),
                conversation_id=refs.conversation_id,
                role=role,
                content=content,
                created_at=tied_at,
            )
            for role, content in [
                (MessageRole.ASSISTANT, "Confirm transferring 25,000 to Laura?"),
                (MessageRole.USER, "Yes."),
            ]
        ),
    ]
    with session_factory.begin() as session:
        session.add_all(messages)
    expected_order = [
        message.id
        for message in sorted(messages, key=lambda m: (m.created_at, str(m.id)))
    ]

    with session_factory() as session:
        loaded = session.get_one(ConversationModel, refs.conversation_id)
        with pytest.raises(InvalidRequestError):
            _ = loaded.messages

    for _ in range(2):
        with session_factory() as session:
            loaded = session.scalars(
                select(ConversationModel)
                .where(ConversationModel.id == refs.conversation_id)
                .options(selectinload(ConversationModel.messages))
            ).one()
            assert [message.id for message in loaded.messages] == expected_order
            assert all(m.created_at.tzinfo is not None for m in loaded.messages)


INVALID_STATES: dict[str, Overrides] = {
    "ready_with_pending_operation": lambda refs: {
        "pending_operation_type": TRANSFER,
        "pending_missing_fields": ["amount"],
    },
    "ready_with_pending_data": lambda refs: {"pending_card_id": refs.card_id},
    "collecting_without_pending_operation": lambda refs: {
        "flow_state": COLLECTING_DATA
    },
    "collecting_with_empty_missing_fields": lambda refs: {
        "flow_state": COLLECTING_DATA,
        "pending_operation_type": TRANSFER,
        "pending_missing_fields": [],
    },
    "waiting_without_pending_operation": lambda refs: {
        "flow_state": WAITING_CONFIRMATION,
        "pending_operation_id": uuid4(),
    },
    "waiting_without_operation_id": lambda refs: {
        "flow_state": WAITING_CONFIRMATION,
        "pending_operation_type": FREEZE_CARD,
        "pending_card_id": refs.card_id,
        "pending_missing_fields": [],
    },
    "collecting_with_operation_id": lambda refs: {
        "flow_state": COLLECTING_DATA,
        "pending_operation_type": UNFREEZE_CARD,
        "pending_operation_id": uuid4(),
        "pending_missing_fields": ["card_id"],
    },
    "ready_with_operation_id": lambda refs: {"pending_operation_id": uuid4()},
    "waiting_with_missing_fields": lambda refs: {
        "flow_state": WAITING_CONFIRMATION,
        "pending_operation_id": uuid4(),
        "pending_operation_type": FREEZE_CARD,
        "pending_card_id": refs.card_id,
        "pending_missing_fields": ["card_id"],
    },
    "waiting_with_incomplete_transfer": lambda refs: {
        "flow_state": WAITING_CONFIRMATION,
        "pending_operation_id": uuid4(),
        "pending_operation_type": TRANSFER,
        "pending_beneficiary_id": refs.beneficiary_id,
        "pending_missing_fields": [],
    },
    "waiting_card_operation_without_card": lambda refs: {
        "flow_state": WAITING_CONFIRMATION,
        "pending_operation_id": uuid4(),
        "pending_operation_type": UNFREEZE_CARD,
        "pending_missing_fields": [],
    },
    "closed_with_pending_operation": lambda refs: {
        "status": ConversationStatus.CLOSED,
        "flow_state": COLLECTING_DATA,
        "pending_operation_type": TRANSFER,
        "pending_missing_fields": ["amount"],
    },
    "pending_type_without_missing_fields": lambda refs: {
        "flow_state": WAITING_CONFIRMATION,
        "pending_operation_id": uuid4(),
        "pending_operation_type": FREEZE_CARD,
        "pending_card_id": refs.card_id,
    },
    "missing_fields_without_pending_type": lambda refs: {
        "pending_missing_fields": [],
    },
    "transfer_with_card": lambda refs: {
        "flow_state": COLLECTING_DATA,
        "pending_operation_type": TRANSFER,
        "pending_card_id": refs.card_id,
        "pending_missing_fields": ["amount"],
    },
    "card_operation_with_transfer_data": lambda refs: {
        "flow_state": COLLECTING_DATA,
        "pending_operation_type": FREEZE_CARD,
        "pending_beneficiary_id": refs.beneficiary_id,
        "pending_missing_fields": ["card_id"],
    },
    "unresolved_amount_not_missing": lambda refs: {
        "flow_state": COLLECTING_DATA,
        "pending_operation_type": TRANSFER,
        "pending_amount": Decimal("100.00"),
        "pending_missing_fields": ["beneficiary_id"],
    },
    "unresolved_amount_awaiting_confirmation": lambda refs: {
        "flow_state": WAITING_CONFIRMATION,
        "pending_operation_id": uuid4(),
        "pending_operation_type": TRANSFER,
        "pending_source_account_id": refs.account_id,
        "pending_beneficiary_id": refs.beneficiary_id,
        "pending_amount": Decimal("100.00"),
        "pending_missing_fields": [],
    },
    "currency_without_amount": lambda refs: {
        "flow_state": COLLECTING_DATA,
        "pending_operation_type": TRANSFER,
        "pending_currency": Currency.ARS,
        "pending_missing_fields": ["amount"],
    },
    "zero_amount": lambda refs: {
        "flow_state": COLLECTING_DATA,
        "pending_operation_type": TRANSFER,
        "pending_amount": Decimal("0.00"),
        "pending_currency": Currency.ARS,
        "pending_missing_fields": ["beneficiary_id"],
    },
    "negative_amount": lambda refs: {
        "flow_state": COLLECTING_DATA,
        "pending_operation_type": TRANSFER,
        "pending_amount": Decimal("-50.00"),
        "pending_currency": Currency.ARS,
        "pending_missing_fields": ["beneficiary_id"],
    },
    "card_field_missing_for_transfer": lambda refs: {
        "flow_state": COLLECTING_DATA,
        "pending_operation_type": TRANSFER,
        "pending_missing_fields": ["card_id"],
    },
    "transfer_field_missing_for_card_operation": lambda refs: {
        "flow_state": COLLECTING_DATA,
        "pending_operation_type": FREEZE_CARD,
        "pending_missing_fields": ["amount"],
    },
    "unknown_missing_field": lambda refs: {
        "flow_state": COLLECTING_DATA,
        "pending_operation_type": TRANSFER,
        "pending_missing_fields": ["pin"],
    },
    "null_missing_field": lambda refs: {
        "flow_state": COLLECTING_DATA,
        "pending_operation_type": TRANSFER,
        "pending_missing_fields": ["amount", None],
    },
    "context_not_object": lambda refs: {"context": ["GET_BALANCE"]},
    "dangling_customer": lambda refs: {"customer_id": uuid4()},
    "dangling_source_account": lambda refs: {
        "flow_state": COLLECTING_DATA,
        "pending_operation_type": TRANSFER,
        "pending_source_account_id": uuid4(),
        "pending_missing_fields": ["amount"],
    },
    "dangling_beneficiary": lambda refs: {
        "flow_state": COLLECTING_DATA,
        "pending_operation_type": TRANSFER,
        "pending_beneficiary_id": uuid4(),
        "pending_missing_fields": ["amount"],
    },
    "dangling_card": lambda refs: {
        "flow_state": WAITING_CONFIRMATION,
        "pending_operation_id": uuid4(),
        "pending_operation_type": FREEZE_CARD,
        "pending_card_id": uuid4(),
        "pending_missing_fields": [],
    },
}


REJECTING_CONSTRAINT = {
    "ready_with_pending_operation": "ck_conversations_ready_has_no_pending_operation",
    "ready_with_pending_data": "ck_conversations_pending_data_matches_type",
    "collecting_without_pending_operation": (
        "ck_conversations_collecting_data_has_missing_fields"
    ),
    "collecting_with_empty_missing_fields": (
        "ck_conversations_collecting_data_has_missing_fields"
    ),
    "waiting_without_pending_operation": (
        "ck_conversations_waiting_confirmation_is_complete"
    ),
    "waiting_without_operation_id": (
        "ck_conversations_waiting_confirmation_has_operation_id"
    ),
    "collecting_with_operation_id": (
        "ck_conversations_waiting_confirmation_has_operation_id"
    ),
    "ready_with_operation_id": "ck_conversations_waiting_confirmation_has_operation_id",
    "waiting_with_missing_fields": "ck_conversations_waiting_confirmation_is_complete",
    "waiting_with_incomplete_transfer": (
        "ck_conversations_waiting_confirmation_is_complete"
    ),
    "waiting_card_operation_without_card": (
        "ck_conversations_waiting_confirmation_is_complete"
    ),
    "closed_with_pending_operation": "ck_conversations_closed_has_no_pending_operation",
    "pending_type_without_missing_fields": (
        "ck_conversations_pending_type_and_missing_fields"
    ),
    "missing_fields_without_pending_type": (
        "ck_conversations_pending_type_and_missing_fields"
    ),
    "transfer_with_card": "ck_conversations_pending_data_matches_type",
    "card_operation_with_transfer_data": "ck_conversations_pending_data_matches_type",
    "unresolved_amount_not_missing": "ck_conversations_unresolved_amount_is_missing",
    "unresolved_amount_awaiting_confirmation": (
        "ck_conversations_unresolved_amount_is_missing"
    ),
    "currency_without_amount": "ck_conversations_pending_currency_has_amount",
    "zero_amount": "ck_conversations_pending_amount_positive",
    "negative_amount": "ck_conversations_pending_amount_positive",
    "card_field_missing_for_transfer": "ck_conversations_pending_missing_fields_valid",
    "transfer_field_missing_for_card_operation": (
        "ck_conversations_pending_missing_fields_valid"
    ),
    "unknown_missing_field": "ck_conversations_pending_missing_fields_valid",
    "null_missing_field": "ck_conversations_pending_missing_fields_valid",
    "context_not_object": "ck_conversations_context_is_object",
    "dangling_customer": "fk_conversations_customer_id_customers",
    "dangling_source_account": "fk_conversations_pending_source_account_id_accounts",
    "dangling_beneficiary": "fk_conversations_pending_beneficiary_id_beneficiaries",
    "dangling_card": "fk_conversations_pending_card_id_cards",
}


def constraint_name(error: IntegrityError) -> str | None:
    return getattr(getattr(error.orig, "diag", None), "constraint_name", None)


@pytest.mark.parametrize("case", INVALID_STATES)
def test_database_rejects_invalid_conversation_state(
    session_factory: sessionmaker[Session], refs: FinancialRefs, case: str
) -> None:
    with pytest.raises(IntegrityError) as exc_info:
        with session_factory.begin() as session:
            session.add(conversation(refs, **INVALID_STATES[case](refs)))

    assert constraint_name(exc_info.value) == REJECTING_CONSTRAINT[case]


@pytest.mark.parametrize(
    "statement",
    [
        "UPDATE conversations SET status = 'PAUSED'",
        "UPDATE conversations SET flow_state = 'COMPLETED'",
        "UPDATE conversations SET flow_state = 'COLLECTING_DATA', "
        "pending_operation_type = 'PAY_BILL', pending_missing_fields = '{amount}'",
        "UPDATE conversations SET status = NULL",
        "UPDATE conversations SET flow_state = NULL",
        "UPDATE conversations SET context = NULL",
        "UPDATE conversations SET updated_at = NULL",
    ],
)
def test_database_rejects_invalid_conversation_columns(
    test_engine: Engine, refs: FinancialRefs, statement: str
) -> None:
    with pytest.raises(IntegrityError), test_engine.begin() as connection:
        connection.execute(text(statement))


def test_database_rejects_unsupported_pending_currency(
    test_engine: Engine, refs: FinancialRefs
) -> None:
    statement = text(
        "UPDATE conversations SET flow_state = 'COLLECTING_DATA', "
        "pending_operation_type = 'TRANSFER', pending_amount = 100, "
        "pending_currency = 'EUR', pending_missing_fields = '{beneficiary_id}'"
    )
    with pytest.raises(IntegrityError), test_engine.begin() as connection:
        connection.execute(statement)


INVALID_MESSAGES: dict[str, Callable[[FinancialRefs], dict[str, Any]]] = {
    "null_content": lambda refs: {"content": None},
    "null_role": lambda refs: {"role": None},
    "null_created_at": lambda refs: {"created_at": None},
    "dangling_conversation": lambda refs: {"conversation_id": uuid4()},
}


@pytest.mark.parametrize(
    "overrides", INVALID_MESSAGES.values(), ids=INVALID_MESSAGES.keys()
)
def test_database_rejects_invalid_message(
    session_factory: sessionmaker[Session], refs: FinancialRefs, overrides: Overrides
) -> None:
    values: dict[str, Any] = {
        "id": uuid4(),
        "conversation_id": refs.conversation_id,
        "role": MessageRole.USER,
        "content": "Hello Mimi.",
        "created_at": NOW,
    }
    values.update(overrides(refs))

    with pytest.raises(IntegrityError), session_factory.begin() as session:
        session.add(MessageModel(**values))


def message(refs: FinancialRefs, content: str) -> MessageModel:
    return MessageModel(
        id=uuid4(),
        conversation_id=refs.conversation_id,
        role=MessageRole.USER,
        content=content,
        created_at=NOW,
    )


@pytest.mark.parametrize(
    "content",
    ["", "   ", "\t\t", "\n\n", " \t\r\n "],
    ids=["empty", "spaces", "tabs", "newlines", "mixed_whitespace"],
)
def test_database_rejects_blank_message_content(
    session_factory: sessionmaker[Session], refs: FinancialRefs, content: str
) -> None:
    with pytest.raises(IntegrityError) as exc_info:
        with session_factory.begin() as session:
            session.add(message(refs, content))

    assert constraint_name(exc_info.value) == "ck_messages_content_not_blank"


@pytest.mark.parametrize(
    "content",
    ["Hello Mimi.", "  What's my balance?\n"],
    ids=["text", "text_with_surrounding_whitespace"],
)
def test_database_accepts_message_content_with_text(
    session_factory: sessionmaker[Session], refs: FinancialRefs, content: str
) -> None:
    original = message(refs, content)
    with session_factory.begin() as session:
        session.add(original)

    with session_factory() as session:
        assert session.get_one(MessageModel, original.id).content == content


def test_database_rejects_invalid_message_role(
    test_engine: Engine, refs: FinancialRefs
) -> None:
    statement = text(
        "INSERT INTO messages (id, conversation_id, role, content, created_at) "
        "VALUES (gen_random_uuid(), :conversation_id, 'SYSTEM', 'Hi', now())"
    )
    with pytest.raises(IntegrityError), test_engine.begin() as connection:
        connection.execute(statement, {"conversation_id": refs.conversation_id})
