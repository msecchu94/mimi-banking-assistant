from datetime import datetime, timedelta, timezone
from decimal import Decimal
from uuid import UUID, uuid4

import pytest

from mimi.application.repositories import TransactionQuery
from mimi.application.use_cases.analyze_expenses import (
    AnalyzeExpenses,
    CategoryExpense,
    CurrencyExpenses,
    ExpenseAnalysis,
    Period,
)
from mimi.domain.entities import Money, Transaction
from mimi.domain.enums import Currency, TransactionCategory, TransactionType

CUSTOMER_ID = uuid4()
BUENOS_AIRES = timezone(timedelta(hours=-3))
OCTOBER = Period(
    datetime(2026, 10, 1, tzinfo=BUENOS_AIRES),
    datetime(2026, 11, 1, tzinfo=BUENOS_AIRES),
)


class FakeTransactionRepository:
    """Honours the type and category filters; period filtering is the adapter's."""

    def __init__(self, transactions: list[Transaction] | None = None) -> None:
        self._transactions = transactions or []
        self.calls: list[tuple[UUID, TransactionQuery]] = []

    def list_by_customer(
        self, customer_id: UUID, query: TransactionQuery
    ) -> list[Transaction]:
        self.calls.append((customer_id, query))
        return [
            transaction
            for transaction in self._transactions
            if (query.type is None or transaction.type is query.type)
            and (query.category is None or transaction.category is query.category)
        ]


def make_transaction(
    amount: str,
    category: TransactionCategory = TransactionCategory.GROCERIES,
    currency: Currency = Currency.ARS,
    type: TransactionType = TransactionType.DEBIT,
) -> Transaction:
    return Transaction(
        id=uuid4(),
        account_id=uuid4(),
        amount=Money(Decimal(amount), currency),
        type=type,
        category=category,
        description="Movimiento",
        occurred_at=OCTOBER.start,
        transfer_id=None,
    )


def ars(amount: str) -> Money:
    return Money(Decimal(amount), Currency.ARS)


@pytest.mark.parametrize(
    ("start", "end"),
    [
        (datetime(2026, 10, 1), datetime(2026, 11, 1, tzinfo=BUENOS_AIRES)),
        (datetime(2026, 10, 1, tzinfo=BUENOS_AIRES), datetime(2026, 11, 1)),
        (OCTOBER.start, OCTOBER.start),
        (OCTOBER.end, OCTOBER.start),
    ],
)
def test_invalid_period_is_rejected(start: datetime, end: datetime) -> None:
    with pytest.raises(ValueError):
        Period(start, end)


def test_queries_debits_within_period() -> None:
    repository = FakeTransactionRepository()

    AnalyzeExpenses(repository).execute(CUSTOMER_ID, OCTOBER)

    assert repository.calls == [
        (
            CUSTOMER_ID,
            TransactionQuery(
                occurred_from=OCTOBER.start,
                occurred_to=OCTOBER.end,
                type=TransactionType.DEBIT,
            ),
        )
    ]


def test_totals_by_category_sorted_by_amount() -> None:
    repository = FakeTransactionRepository(
        [
            make_transaction("78450.30", TransactionCategory.GROCERIES),
            make_transaction("16900.00", TransactionCategory.DINING),
            make_transaction("12300.25", TransactionCategory.GROCERIES),
            make_transaction("95000.00", TransactionCategory.TRANSFER),
        ]
    )

    result = AnalyzeExpenses(repository).execute(CUSTOMER_ID, OCTOBER)

    assert result == ExpenseAnalysis(
        period=OCTOBER,
        category=None,
        currencies=(
            CurrencyExpenses(
                currency=Currency.ARS,
                total=ars("202650.55"),
                categories=(
                    CategoryExpense(TransactionCategory.TRANSFER, ars("95000.00")),
                    CategoryExpense(TransactionCategory.GROCERIES, ars("90750.55")),
                    CategoryExpense(TransactionCategory.DINING, ars("16900.00")),
                ),
            ),
        ),
    )


def test_equal_category_totals_are_ordered_by_category() -> None:
    repository = FakeTransactionRepository(
        [
            make_transaction("100.00", TransactionCategory.SHOPPING),
            make_transaction("100.00", TransactionCategory.DINING),
        ]
    )

    result = AnalyzeExpenses(repository).execute(CUSTOMER_ID, OCTOBER)

    assert [entry.category for entry in result.currencies[0].categories] == [
        TransactionCategory.DINING,
        TransactionCategory.SHOPPING,
    ]


def test_credits_do_not_reduce_spending() -> None:
    repository = FakeTransactionRepository(
        [
            make_transaction("120000.00", TransactionCategory.SHOPPING),
            make_transaction(
                "45990.00", TransactionCategory.SHOPPING, type=TransactionType.CREDIT
            ),
        ]
    )

    result = AnalyzeExpenses(repository).execute(CUSTOMER_ID, OCTOBER)

    assert result.currencies[0].total == ars("120000.00")
    assert result.currencies[0].categories == (
        CategoryExpense(TransactionCategory.SHOPPING, ars("120000.00")),
    )


def test_currencies_are_kept_separate() -> None:
    repository = FakeTransactionRepository(
        [
            make_transaction("42.10", TransactionCategory.SUBSCRIPTIONS, Currency.USD),
            make_transaction("1500.00", TransactionCategory.DINING, Currency.ARS),
            make_transaction("7.90", TransactionCategory.SUBSCRIPTIONS, Currency.USD),
        ]
    )

    result = AnalyzeExpenses(repository).execute(CUSTOMER_ID, OCTOBER)

    assert [entry.currency for entry in result.currencies] == [
        Currency.ARS,
        Currency.USD,
    ]
    assert result.currencies[0].total == ars("1500.00")
    assert result.currencies[1].total == Money(Decimal("50.00"), Currency.USD)
    assert result.currencies[1].categories == (
        CategoryExpense(
            TransactionCategory.SUBSCRIPTIONS, Money(Decimal("50.00"), Currency.USD)
        ),
    )


def test_category_filter_is_applied() -> None:
    repository = FakeTransactionRepository(
        [
            make_transaction("78450.30", TransactionCategory.GROCERIES),
            make_transaction("16900.00", TransactionCategory.DINING),
        ]
    )

    result = AnalyzeExpenses(repository).execute(
        CUSTOMER_ID, OCTOBER, TransactionCategory.GROCERIES
    )

    assert repository.calls[0][1].category is TransactionCategory.GROCERIES
    assert result.category is TransactionCategory.GROCERIES
    assert result.currencies == (
        CurrencyExpenses(
            currency=Currency.ARS,
            total=ars("78450.30"),
            categories=(
                CategoryExpense(TransactionCategory.GROCERIES, ars("78450.30")),
            ),
        ),
    )


def test_period_without_expenses_yields_empty_analysis() -> None:
    repository = FakeTransactionRepository(
        [
            make_transaction(
                "1000000.00", TransactionCategory.OTHER, type=TransactionType.CREDIT
            )
        ]
    )

    result = AnalyzeExpenses(repository).execute(CUSTOMER_ID, OCTOBER)

    assert result == ExpenseAnalysis(period=OCTOBER, category=None, currencies=())
