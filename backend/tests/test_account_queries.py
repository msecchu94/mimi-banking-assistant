from collections.abc import Iterator
from contextlib import contextmanager
from dataclasses import dataclass
from datetime import UTC, datetime
from decimal import Decimal
from uuid import UUID, uuid4

import pytest

from mimi.application.account_queries import AccountQueries
from mimi.application.repositories import TransactionQuery
from mimi.domain.entities import Account, Money, Transaction
from mimi.domain.enums import (
    AccountStatus,
    Currency,
    TransactionCategory,
    TransactionType,
)

CUSTOMER_ID = uuid4()
SAVINGS = Account(
    uuid4(),
    CUSTOMER_ID,
    "Cuenta principal",
    Money(Decimal("150000.50"), Currency.ARS),
    AccountStatus.ACTIVE,
)
GROCERIES = Transaction(
    id=uuid4(),
    account_id=SAVINGS.id,
    amount=Money(Decimal("1200.10"), Currency.ARS),
    type=TransactionType.DEBIT,
    category=TransactionCategory.GROCERIES,
    description="Supermercado",
    occurred_at=datetime(2026, 10, 9, 12, tzinfo=UTC),
    transfer_id=None,
)


class FakeAccountRepository:
    def __init__(self, accounts: list[Account]) -> None:
        self._accounts = accounts
        self.customers: list[UUID] = []

    def list_by_customer(self, customer_id: UUID) -> list[Account]:
        self.customers.append(customer_id)
        return list(self._accounts)


class FakeTransactionRepository:
    def __init__(self, transactions: list[Transaction]) -> None:
        self._transactions = transactions
        self.calls: list[tuple[UUID, TransactionQuery]] = []

    def list_by_customer(
        self, customer_id: UUID, query: TransactionQuery
    ) -> list[Transaction]:
        self.calls.append((customer_id, query))
        return list(self._transactions)


@dataclass
class FakeRepositories:
    accounts: FakeAccountRepository
    transactions: FakeTransactionRepository


class FakeTransactionScope:
    def __init__(self, repositories: FakeRepositories) -> None:
        self.repositories = repositories
        self.committed = 0

    @contextmanager
    def begin(self) -> Iterator[FakeRepositories]:
        yield self.repositories
        self.committed += 1


def make_queries() -> tuple[AccountQueries, FakeTransactionScope]:
    scope = FakeTransactionScope(
        FakeRepositories(
            FakeAccountRepository([SAVINGS]), FakeTransactionRepository([GROCERIES])
        )
    )
    return AccountQueries(scope), scope  # type: ignore[arg-type]


def test_lists_the_customers_accounts_in_one_transaction() -> None:
    queries, scope = make_queries()

    assert queries.list_accounts(CUSTOMER_ID) == [SAVINGS]
    assert scope.repositories.accounts.customers == [CUSTOMER_ID]
    assert scope.committed == 1


def test_lists_recent_transactions_of_one_account() -> None:
    queries, scope = make_queries()

    result = queries.list_recent_transactions(CUSTOMER_ID, SAVINGS.id, 3)

    assert result == [GROCERIES]
    assert scope.repositories.transactions.calls == [
        (CUSTOMER_ID, TransactionQuery(account_id=SAVINGS.id, limit=3))
    ]
    assert scope.committed == 1


def test_lists_recent_transactions_of_every_account_without_filter() -> None:
    queries, scope = make_queries()

    queries.list_recent_transactions(CUSTOMER_ID, None, 5)

    assert scope.repositories.transactions.calls == [
        (CUSTOMER_ID, TransactionQuery(limit=5))
    ]


def test_rejects_a_non_positive_limit() -> None:
    queries, _ = make_queries()

    with pytest.raises(ValueError):
        queries.list_recent_transactions(CUSTOMER_ID, None, 0)
