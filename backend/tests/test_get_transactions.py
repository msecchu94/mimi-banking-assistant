from datetime import UTC, datetime, timedelta, timezone
from decimal import Decimal
from uuid import UUID, uuid4

import pytest

from mimi.application.repositories import TransactionQuery
from mimi.application.use_cases.get_transactions import GetTransactions
from mimi.domain.entities import Money, Transaction
from mimi.domain.enums import Currency, TransactionCategory, TransactionType

CUSTOMER_ID = uuid4()
BUENOS_AIRES = timezone(timedelta(hours=-3))
OCTOBER_1 = datetime(2026, 10, 1, tzinfo=BUENOS_AIRES)


class FakeTransactionRepository:
    def __init__(self, transactions: list[Transaction] | None = None) -> None:
        self._transactions = transactions or []
        self.calls: list[tuple[UUID, TransactionQuery]] = []

    def list_by_customer(
        self, customer_id: UUID, query: TransactionQuery
    ) -> list[Transaction]:
        self.calls.append((customer_id, query))
        return list(self._transactions)


def make_transaction(amount: Money, occurred_at: datetime) -> Transaction:
    return Transaction(
        id=uuid4(),
        account_id=uuid4(),
        amount=amount,
        type=TransactionType.DEBIT,
        category=TransactionCategory.GROCERIES,
        description="Supermercado",
        occurred_at=occurred_at,
        transfer_id=None,
    )


def test_without_filters_returns_repository_results_in_order() -> None:
    newer = make_transaction(
        Money(Decimal("15300.25"), Currency.ARS), OCTOBER_1 + timedelta(days=2)
    )
    older = make_transaction(Money(Decimal("42.10"), Currency.USD), OCTOBER_1)
    repository = FakeTransactionRepository([newer, older])

    result = GetTransactions(repository).execute(CUSTOMER_ID, TransactionQuery())

    assert result == [newer, older]
    assert result[0].amount == Money(Decimal("15300.25"), Currency.ARS)
    assert result[0].occurred_at == OCTOBER_1 + timedelta(days=2)
    assert repository.calls == [(CUSTOMER_ID, TransactionQuery())]


@pytest.mark.parametrize(
    "query",
    [
        TransactionQuery(occurred_from=OCTOBER_1),
        TransactionQuery(occurred_to=OCTOBER_1),
        TransactionQuery(category=TransactionCategory.FUEL),
        TransactionQuery(type=TransactionType.CREDIT),
        TransactionQuery(limit=1),
        TransactionQuery(
            occurred_from=OCTOBER_1,
            occurred_to=OCTOBER_1 + timedelta(days=31),
            category=TransactionCategory.DINING,
            type=TransactionType.DEBIT,
            limit=5,
        ),
        TransactionQuery(occurred_from=OCTOBER_1, occurred_to=OCTOBER_1),
        TransactionQuery(
            occurred_from=OCTOBER_1, occurred_to=OCTOBER_1.astimezone(UTC)
        ),
    ],
)
def test_valid_query_is_passed_to_repository_unchanged(
    query: TransactionQuery,
) -> None:
    repository = FakeTransactionRepository()

    GetTransactions(repository).execute(CUSTOMER_ID, query)

    assert repository.calls == [(CUSTOMER_ID, query)]


def test_returns_empty_list_when_nothing_matches() -> None:
    repository = FakeTransactionRepository([])

    result = GetTransactions(repository).execute(
        CUSTOMER_ID, TransactionQuery(category=TransactionCategory.FUEL)
    )

    assert result == []


@pytest.mark.parametrize(
    "query",
    [
        TransactionQuery(occurred_from=datetime(2026, 10, 1)),
        TransactionQuery(occurred_to=datetime(2026, 10, 1)),
        TransactionQuery(
            occurred_from=OCTOBER_1 + timedelta(seconds=1), occurred_to=OCTOBER_1
        ),
        TransactionQuery(limit=0),
        TransactionQuery(limit=-1),
    ],
)
def test_invalid_query_is_rejected_before_reaching_repository(
    query: TransactionQuery,
) -> None:
    repository = FakeTransactionRepository()

    with pytest.raises(ValueError):
        GetTransactions(repository).execute(CUSTOMER_ID, query)

    assert repository.calls == []
