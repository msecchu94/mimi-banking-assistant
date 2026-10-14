from collections.abc import Iterator
from dataclasses import dataclass
from datetime import UTC, datetime
from decimal import Decimal
from uuid import UUID, uuid4

import pytest
from sqlalchemy import Engine, select
from sqlalchemy.orm import Session, sessionmaker

from mimi.composition import Container
from mimi.domain.entities import Money, Transaction, Transfer
from mimi.domain.enums import (
    AccountStatus,
    Currency,
    TransactionCategory,
    TransactionType,
    TransferStatus,
)
from mimi.infrastructure.database.base import Base
from mimi.infrastructure.database.models import (
    AccountModel,
    BeneficiaryModel,
    CustomerModel,
    TransactionModel,
    TransferModel,
)
from mimi.infrastructure.database.session import create_session_factory
from mimi.infrastructure.database.transaction import (
    PostgresRepositories,
    PostgresTransactionScope,
)

pytestmark = pytest.mark.integration

# DB-04 replaces create_all with the initial Alembic migration.

EXECUTED_AT = datetime(2026, 10, 9, 16, 31, 4, tzinfo=UTC)
TRANSFER_AMOUNT = Money(Decimal("25000.00"), Currency.ARS)
BALANCE_AFTER_TRANSFER = Money(Decimal("125000.50"), Currency.ARS)


class ExecutionInterrupted(Exception):
    pass


@pytest.fixture
def session_factory(test_engine: Engine) -> Iterator[sessionmaker[Session]]:
    Base.metadata.create_all(test_engine)
    try:
        yield create_session_factory(test_engine)
    finally:
        Base.metadata.drop_all(test_engine)


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
