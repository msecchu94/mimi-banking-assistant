from dataclasses import dataclass
from datetime import UTC, datetime
from decimal import Decimal
from typing import Any
from uuid import UUID, uuid4
from zoneinfo import ZoneInfo

import pytest
from pydantic import BaseModel
from sqlalchemy import Engine, select
from sqlalchemy.orm import Session, sessionmaker

from mimi.application.conversation_engine import ConversationEngine
from mimi.application.conversation_results import BalancesResult
from mimi.application.errors import LLMUnavailableError
from mimi.application.interpretation import Intent
from mimi.application.llm import LLMProvider
from mimi.application.read_only_queries import ReadOnlyQueryRouter
from mimi.application.use_cases.interpret_message import InterpretMessage
from mimi.composition import Container
from mimi.domain.entities import Account, Message, Money, Transaction, Transfer
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


class ScriptedLLMProvider:
    """Answers every interpretation request with a canned intent."""

    def __init__(self, intent: Intent = Intent.GET_BALANCE) -> None:
        self.intent = intent
        self.error: Exception | None = None

    def generate_structured[T: BaseModel](
        self, *, instructions: str, input_text: str, output_type: type[T]
    ) -> T:
        if self.error is not None:
            raise self.error
        output: dict[str, Any] = dict.fromkeys(
            [
                "amount",
                "currency",
                "beneficiary_reference",
                "card_reference",
                "category",
                "transaction_type",
                "period",
                "comparison_period",
                "relative_period",
            ]
        )
        return output_type.model_validate({"intent": self.intent.value, **output})


@pytest.fixture
def llm_provider() -> ScriptedLLMProvider:
    return ScriptedLLMProvider()


def make_engine(
    session_factory: sessionmaker[Session], llm_provider: LLMProvider
) -> ConversationEngine:
    return ConversationEngine(
        PostgresTransactionScope(session_factory),
        interpreter=InterpretMessage(llm_provider),
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
