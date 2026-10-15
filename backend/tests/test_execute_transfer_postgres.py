from dataclasses import dataclass
from datetime import UTC, datetime
from decimal import Decimal
from uuid import UUID, uuid4

import pytest
from sqlalchemy import Engine, func, select
from sqlalchemy.orm import Session, sessionmaker

from mimi.application.errors import InsufficientFundsError
from mimi.application.repositories import TransactionQuery
from mimi.application.use_cases.execute_transfer import ExecuteTransfer
from mimi.domain.entities import Money, Transaction, Transfer
from mimi.domain.enums import (
    AccountStatus,
    Currency,
    TransactionCategory,
    TransactionType,
    TransferStatus,
)
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

NOW = datetime(2026, 10, 9, 16, 30, tzinfo=UTC)


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


def execute(repositories: PostgresRepositories, seed: Seed, amount: str) -> Transfer:
    use_case = ExecuteTransfer(
        repositories.accounts,
        repositories.beneficiaries,
        repositories.transfers,
        lambda: NOW,
    )
    return use_case.execute(
        customer_id=seed.customer_id,
        source_account_id=seed.account_id,
        beneficiary_id=seed.beneficiary_id,
        amount=Money(Decimal(amount), Currency.ARS),
    )


def assert_untouched(session_factory: sessionmaker[Session], seed: Seed) -> None:
    with session_factory() as session:
        assert session.get_one(AccountModel, seed.account_id).balance == Decimal(
            "150000.50"
        )
        assert session.scalar(select(func.count()).select_from(TransferModel)) == 0
        assert session.scalar(select(func.count()).select_from(TransactionModel)) == 0


def test_committed_transfer_is_observable_by_later_reads(
    session_factory: sessionmaker[Session], seed: Seed
) -> None:
    scope = PostgresTransactionScope(session_factory)

    with scope.begin() as repositories:
        transfer = execute(repositories, seed, "25000.00")

    with scope.begin() as repositories:
        [account] = repositories.accounts.list_by_customer(seed.customer_id)
        transactions = repositories.transactions.list_by_customer(
            seed.customer_id, TransactionQuery()
        )
    with session_factory() as session:
        stored_transfer = session.get_one(TransferModel, transfer.id)

    assert account.balance == Money(Decimal("125000.50"), Currency.ARS)
    assert stored_transfer.status is TransferStatus.COMPLETED
    assert stored_transfer.amount == Decimal("25000.00")
    assert stored_transfer.executed_at == NOW
    assert transactions == [
        Transaction(
            id=transactions[0].id,
            account_id=seed.account_id,
            amount=Money(Decimal("25000.00"), Currency.ARS),
            type=TransactionType.DEBIT,
            category=TransactionCategory.TRANSFER,
            description="Transfer to Laura",
            occurred_at=NOW,
            transfer_id=transfer.id,
        )
    ]


def test_validation_failure_leaves_database_untouched(
    session_factory: sessionmaker[Session], seed: Seed
) -> None:
    with pytest.raises(InsufficientFundsError):
        with PostgresTransactionScope(session_factory).begin() as repositories:
            execute(repositories, seed, "150000.51")

    assert_untouched(session_factory, seed)


def test_failure_after_execution_rolls_back_every_write(
    session_factory: sessionmaker[Session], seed: Seed
) -> None:
    with pytest.raises(ExecutionInterrupted):
        with PostgresTransactionScope(session_factory).begin() as repositories:
            execute(repositories, seed, "25000.00")
            raise ExecutionInterrupted

    assert_untouched(session_factory, seed)
