import os
import subprocess
import sys
from datetime import UTC, date, datetime
from decimal import Decimal
from pathlib import Path
from uuid import uuid4

import pytest
from sqlalchemy import Engine, func, select, update
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session, sessionmaker

from mimi.application.repositories import TransactionQuery
from mimi.domain.entities import Money
from mimi.domain.enums import (
    CardStatus,
    ConversationFlowState,
    ConversationStatus,
    Currency,
    MessageRole,
    TransactionCategory,
    TransactionType,
    TransferStatus,
)
from mimi.infrastructure.database import seed as seed_module
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
from mimi.infrastructure.database.repositories import (
    PostgresAccountRepository,
    PostgresBeneficiaryRepository,
    PostgresCardRepository,
    PostgresTransactionRepository,
)
from mimi.infrastructure.database.seed import (
    BUENOS_AIRES,
    CUSTOMER_ID,
    MAIN_ACCOUNT_ID,
    AlreadySeededError,
    SeedDataset,
    build_dataset,
    seed,
    seed_id,
)
from mimi.infrastructure.database.session import create_session_factory

pytestmark = pytest.mark.integration

BACKEND_DIR = Path(__file__).resolve().parents[1]
REFERENCE_DATE = date(2026, 10, 13)
VISA_DEBIT_ID = seed_id("card:visa-debit")
LAURA_ID = seed_id("beneficiary:laura-gomez")

PERSISTED_MODELS = (
    CustomerModel,
    AccountModel,
    CardModel,
    BeneficiaryModel,
    TransactionModel,
    TransferModel,
    ConversationModel,
    MessageModel,
)


@pytest.fixture
def session_factory(migrated_engine: Engine) -> sessionmaker[Session]:
    return create_session_factory(migrated_engine)


def row_counts(session_factory: sessionmaker[Session]) -> dict[str, int]:
    with session_factory() as session:
        return {
            model.__tablename__: session.scalar(select(func.count()).select_from(model))
            or 0
            for model in PERSISTED_MODELS
        }


SEEDED_COUNTS = {
    "customers": 1,
    "accounts": 2,
    "cards": 3,
    "beneficiaries": 5,
    "transactions": 89,
    "transfers": 0,
    "conversations": 0,
    "messages": 0,
}
EMPTY_COUNTS = dict.fromkeys(SEEDED_COUNTS, 0)


def simulate_demo_activity(session_factory: sessionmaker[Session]) -> None:
    """Change seeded state the way a demo would, including a conversation."""
    now = datetime(2026, 10, 13, 15, 0, tzinfo=UTC)
    transfer_id = uuid4()
    conversation_id = uuid4()
    with session_factory.begin() as session:
        session.execute(
            update(CardModel)
            .where(CardModel.id == VISA_DEBIT_ID)
            .values(status=CardStatus.FROZEN)
        )
        session.execute(
            update(AccountModel)
            .where(AccountModel.id == MAIN_ACCOUNT_ID)
            .values(balance=Decimal("1211480.75"))
        )
        session.add(
            TransferModel(
                id=transfer_id,
                source_account_id=MAIN_ACCOUNT_ID,
                beneficiary_id=LAURA_ID,
                amount=Decimal("25000.00"),
                currency=Currency.ARS,
                status=TransferStatus.COMPLETED,
                created_at=now,
                executed_at=now,
            )
        )
        session.flush()
        session.add(
            TransactionModel(
                id=uuid4(),
                account_id=MAIN_ACCOUNT_ID,
                amount=Decimal("25000.00"),
                currency=Currency.ARS,
                type=TransactionType.DEBIT,
                category=TransactionCategory.TRANSFER,
                description="Transferencia a Laura Gómez",
                occurred_at=now,
                transfer_id=transfer_id,
            )
        )
        session.add(
            ConversationModel(
                id=conversation_id,
                customer_id=CUSTOMER_ID,
                status=ConversationStatus.ACTIVE,
                created_at=now,
                updated_at=now,
                flow_state=ConversationFlowState.READY,
                context={},
            )
        )
        session.flush()
        session.add(
            MessageModel(
                id=uuid4(),
                conversation_id=conversation_id,
                role=MessageRole.USER,
                content="Transferí 25.000 a Laura",
                created_at=now,
            )
        )


def broken_dataset() -> SeedDataset:
    dataset = build_dataset(REFERENCE_DATE)
    dataset.transactions[-1].amount = Decimal("0.00")
    return dataset


def test_seed_persists_dataset_readable_by_repositories(
    session_factory: sessionmaker[Session],
) -> None:
    seed(session_factory, REFERENCE_DATE, reset=False)

    assert row_counts(session_factory) == SEEDED_COUNTS
    with session_factory() as session:
        accounts = PostgresAccountRepository(session).list_by_customer(CUSTOMER_ID)
        cards = PostgresCardRepository(session).list_by_customer(CUSTOMER_ID)
        beneficiaries = PostgresBeneficiaryRepository(session).list_by_customer(
            CUSTOMER_ID
        )
        september_groceries = PostgresTransactionRepository(session).list_by_customer(
            CUSTOMER_ID,
            TransactionQuery(
                occurred_from=datetime(2026, 9, 1, tzinfo=BUENOS_AIRES),
                occurred_to=datetime(2026, 10, 1, tzinfo=BUENOS_AIRES),
                category=TransactionCategory.GROCERIES,
            ),
        )

    assert {account.balance for account in accounts} == {
        Money(Decimal("1236480.75"), Currency.ARS),
        Money(Decimal("2450.00"), Currency.USD),
    }
    assert sorted(card.status for card in cards) == [
        CardStatus.ACTIVE,
        CardStatus.ACTIVE,
        CardStatus.FROZEN,
    ]
    assert len(beneficiaries) == 5
    assert len(september_groceries) == 7


def test_rerun_without_reset_refuses_and_keeps_data(
    session_factory: sessionmaker[Session],
) -> None:
    seed(session_factory, REFERENCE_DATE, reset=False)
    simulate_demo_activity(session_factory)
    counts_before = row_counts(session_factory)

    with pytest.raises(AlreadySeededError):
        seed(session_factory, REFERENCE_DATE, reset=False)

    assert row_counts(session_factory) == counts_before
    with session_factory() as session:
        card = session.get_one(CardModel, VISA_DEBIT_ID)
        assert card.status is CardStatus.FROZEN


def test_reset_restores_original_dataset(
    session_factory: sessionmaker[Session],
) -> None:
    seed(session_factory, REFERENCE_DATE, reset=False)
    simulate_demo_activity(session_factory)

    seed(session_factory, REFERENCE_DATE, reset=True)

    assert row_counts(session_factory) == SEEDED_COUNTS
    with session_factory() as session:
        assert session.get_one(CardModel, VISA_DEBIT_ID).status is CardStatus.ACTIVE
        assert session.get_one(AccountModel, MAIN_ACCOUNT_ID).balance == Decimal(
            "1236480.75"
        )


def test_failed_seed_leaves_database_empty(
    session_factory: sessionmaker[Session], monkeypatch: pytest.MonkeyPatch
) -> None:
    monkeypatch.setattr(seed_module, "build_dataset", lambda _: broken_dataset())

    with pytest.raises(IntegrityError):
        seed(session_factory, REFERENCE_DATE, reset=False)

    assert row_counts(session_factory) == EMPTY_COUNTS


def test_failed_reset_keeps_existing_data(
    session_factory: sessionmaker[Session], monkeypatch: pytest.MonkeyPatch
) -> None:
    seed(session_factory, REFERENCE_DATE, reset=False)
    simulate_demo_activity(session_factory)
    counts_before = row_counts(session_factory)
    monkeypatch.setattr(seed_module, "build_dataset", lambda _: broken_dataset())

    with pytest.raises(IntegrityError):
        seed(session_factory, REFERENCE_DATE, reset=True)

    assert row_counts(session_factory) == counts_before


def test_command_line_seeds_once(migrated_engine: Engine) -> None:
    env = {
        **os.environ,
        "MIMI_DATABASE_URL": migrated_engine.url.render_as_string(hide_password=False),
        "MIMI_ENVIRONMENT": "test",
    }
    command = [
        sys.executable,
        "-m",
        "mimi.infrastructure.database.seed",
        "--reference-date",
        REFERENCE_DATE.isoformat(),
    ]

    first = subprocess.run(
        command, cwd=BACKEND_DIR, env=env, capture_output=True, text=True
    )
    second = subprocess.run(
        command, cwd=BACKEND_DIR, env=env, capture_output=True, text=True
    )

    assert first.returncode == 0, first.stderr
    assert "89 transactions" in first.stdout
    assert second.returncode == 1
    assert "already seeded" in second.stderr
