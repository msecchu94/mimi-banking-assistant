from datetime import datetime, timedelta, timezone
from decimal import Decimal
from uuid import UUID, uuid4

from mimi.application.repositories import TransactionQuery
from mimi.application.use_cases.analyze_expenses import ExpenseAnalysis, Period
from mimi.application.use_cases.compare_expenses import (
    CompareExpenses,
    CurrencyComparison,
    ExpenseChange,
)
from mimi.domain.entities import Money, Transaction
from mimi.domain.enums import Currency, TransactionCategory, TransactionType

CUSTOMER_ID = uuid4()
BUENOS_AIRES = timezone(timedelta(hours=-3))
SEPTEMBER = Period(
    datetime(2026, 9, 1, tzinfo=BUENOS_AIRES),
    datetime(2026, 10, 1, tzinfo=BUENOS_AIRES),
)
OCTOBER = Period(
    datetime(2026, 10, 1, tzinfo=BUENOS_AIRES),
    datetime(2026, 11, 1, tzinfo=BUENOS_AIRES),
)


class FakeTransactionRepository:
    """Honours the period, type and category filters."""

    def __init__(self, transactions: list[Transaction] | None = None) -> None:
        self._transactions = transactions or []
        self.calls: list[tuple[UUID, TransactionQuery]] = []

    def list_by_customer(
        self, customer_id: UUID, query: TransactionQuery
    ) -> list[Transaction]:
        self.calls.append((customer_id, query))
        assert query.occurred_from is not None and query.occurred_to is not None
        return [
            transaction
            for transaction in self._transactions
            if query.occurred_from <= transaction.occurred_at < query.occurred_to
            and (query.type is None or transaction.type is query.type)
            and (query.category is None or transaction.category is query.category)
        ]


def make_transaction(
    period: Period,
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
        occurred_at=period.start + timedelta(days=2),
        transfer_id=None,
    )


def ars(amount: str) -> Money:
    return Money(Decimal(amount), Currency.ARS)


def usd(amount: str) -> Money:
    return Money(Decimal(amount), Currency.USD)


def compare(
    transactions: list[Transaction],
    category: TransactionCategory | None = None,
) -> tuple[FakeTransactionRepository, list[CurrencyComparison]]:
    repository = FakeTransactionRepository(transactions)
    result = CompareExpenses(repository).execute(
        CUSTOMER_ID, OCTOBER, SEPTEMBER, category
    )
    return repository, list(result.currencies)


def test_increase_reports_non_negative_difference() -> None:
    _, currencies = compare(
        [
            make_transaction(OCTOBER, "185000.00"),
            make_transaction(SEPTEMBER, "160000.00"),
        ]
    )

    assert currencies == [
        CurrencyComparison(
            currency=Currency.ARS,
            current_total=ars("185000.00"),
            previous_total=ars("160000.00"),
            difference=ars("25000.00"),
            change=ExpenseChange.INCREASE,
        )
    ]


def test_decrease_reports_non_negative_difference() -> None:
    _, currencies = compare(
        [
            make_transaction(OCTOBER, "150000.50"),
            make_transaction(SEPTEMBER, "160000.75"),
        ]
    )

    assert currencies[0].difference == ars("10000.25")
    assert currencies[0].change is ExpenseChange.DECREASE


def test_equal_totals_are_unchanged() -> None:
    _, currencies = compare(
        [
            make_transaction(OCTOBER, "1000.00", TransactionCategory.DINING),
            make_transaction(SEPTEMBER, "1000.00", TransactionCategory.FUEL),
        ]
    )

    assert currencies[0].difference == ars("0.00")
    assert currencies[0].change is ExpenseChange.UNCHANGED


def test_result_includes_both_period_analyses() -> None:
    repository = FakeTransactionRepository(
        [
            make_transaction(OCTOBER, "185000.00"),
            make_transaction(SEPTEMBER, "160000.00"),
        ]
    )

    result = CompareExpenses(repository).execute(CUSTOMER_ID, OCTOBER, SEPTEMBER)

    assert result.current.period == OCTOBER
    assert result.current.currencies[0].total == ars("185000.00")
    assert result.previous.period == SEPTEMBER
    assert result.previous.currencies[0].total == ars("160000.00")


def test_empty_previous_period_counts_as_zero() -> None:
    _, currencies = compare([make_transaction(OCTOBER, "185000.00")])

    assert currencies == [
        CurrencyComparison(
            currency=Currency.ARS,
            current_total=ars("185000.00"),
            previous_total=ars("0.00"),
            difference=ars("185000.00"),
            change=ExpenseChange.INCREASE,
        )
    ]


def test_empty_current_period_counts_as_zero() -> None:
    _, currencies = compare([make_transaction(SEPTEMBER, "160000.00")])

    assert currencies == [
        CurrencyComparison(
            currency=Currency.ARS,
            current_total=ars("0.00"),
            previous_total=ars("160000.00"),
            difference=ars("160000.00"),
            change=ExpenseChange.DECREASE,
        )
    ]


def test_both_periods_empty_yields_no_comparisons() -> None:
    repository = FakeTransactionRepository(
        [make_transaction(OCTOBER, "45990.00", type=TransactionType.CREDIT)]
    )

    result = CompareExpenses(repository).execute(CUSTOMER_ID, OCTOBER, SEPTEMBER)

    assert result.current == ExpenseAnalysis(OCTOBER, None, ())
    assert result.previous == ExpenseAnalysis(SEPTEMBER, None, ())
    assert result.currencies == ()


def test_currencies_are_compared_separately() -> None:
    _, currencies = compare(
        [
            make_transaction(OCTOBER, "185000.00"),
            make_transaction(SEPTEMBER, "160000.00"),
            make_transaction(SEPTEMBER, "42.10", currency=Currency.USD),
        ]
    )

    assert currencies == [
        CurrencyComparison(
            currency=Currency.ARS,
            current_total=ars("185000.00"),
            previous_total=ars("160000.00"),
            difference=ars("25000.00"),
            change=ExpenseChange.INCREASE,
        ),
        CurrencyComparison(
            currency=Currency.USD,
            current_total=usd("0.00"),
            previous_total=usd("42.10"),
            difference=usd("42.10"),
            change=ExpenseChange.DECREASE,
        ),
    ]


def test_category_filter_applies_to_both_periods() -> None:
    repository, currencies = compare(
        [
            make_transaction(OCTOBER, "90000.00", TransactionCategory.GROCERIES),
            make_transaction(OCTOBER, "50000.00", TransactionCategory.DINING),
            make_transaction(SEPTEMBER, "80000.00", TransactionCategory.GROCERIES),
        ],
        TransactionCategory.GROCERIES,
    )

    assert [query.category for _, query in repository.calls] == [
        TransactionCategory.GROCERIES,
        TransactionCategory.GROCERIES,
    ]
    assert currencies[0].difference == ars("10000.00")
    assert currencies[0].change is ExpenseChange.INCREASE


def test_periods_are_not_required_to_be_chronological() -> None:
    repository = FakeTransactionRepository(
        [
            make_transaction(OCTOBER, "185000.00"),
            make_transaction(SEPTEMBER, "160000.00"),
        ]
    )

    result = CompareExpenses(repository).execute(CUSTOMER_ID, SEPTEMBER, OCTOBER)

    assert result.currencies[0].difference == ars("25000.00")
    assert result.currencies[0].change is ExpenseChange.DECREASE
