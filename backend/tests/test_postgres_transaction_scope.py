from dataclasses import dataclass
from datetime import UTC, datetime
from decimal import Decimal
from uuid import UUID, uuid4

import pytest
from sqlalchemy import Engine, select
from sqlalchemy.orm import Session, sessionmaker

from mimi.application.conversation_engine import ConversationEngine
from mimi.composition import Container
from mimi.domain.entities import Message, Money, Transaction, Transfer
from mimi.domain.enums import (
    AccountStatus,
    ConversationFlowState,
    ConversationStatus,
    Currency,
    MessageRole,
    TransactionCategory,
    TransactionType,
    TransferStatus,
)
from mimi.infrastructure.database.models import (
    AccountModel,
    BeneficiaryModel,
    ConversationModel,
    CustomerModel,
    MessageModel,
    TransactionModel,
    TransferModel,
)
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
    session_factory: sessionmaker[Session], seed: Seed
) -> None:
    engine = ConversationEngine(
        PostgresTransactionScope(session_factory), clock=lambda: EXECUTED_AT
    )
    record = engine.start(seed.customer_id)

    turn = engine.handle_message(
        seed.customer_id, record.conversation.id, "Hello Mimi."
    )

    assert turn.flow_state is ConversationFlowState.READY
    assert stored_conversation(session_factory, record.conversation.id) == (
        EXECUTED_AT,
        [turn.message.id],
    )


def test_conversation_writes_roll_back_together_on_exception(
    session_factory: sessionmaker[Session], seed: Seed
) -> None:
    engine = ConversationEngine(
        PostgresTransactionScope(session_factory), clock=lambda: EXECUTED_AT
    )
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

    with session_factory() as session:
        conversation = session.get_one(ConversationModel, record.conversation.id)
        message = session.get_one(MessageModel, turn.message.id)
        assert conversation.status is ConversationStatus.ACTIVE
        assert conversation.flow_state is ConversationFlowState.READY
        assert conversation.updated_at == turn.message.created_at
        assert message.content == "What's my balance?"
