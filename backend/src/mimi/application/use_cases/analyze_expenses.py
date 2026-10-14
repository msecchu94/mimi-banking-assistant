from collections import defaultdict
from dataclasses import dataclass
from datetime import datetime
from decimal import Decimal
from uuid import UUID

from mimi.application.repositories import TransactionQuery, TransactionRepository
from mimi.domain.entities import Money, Transaction
from mimi.domain.enums import Currency, TransactionCategory, TransactionType


@dataclass(frozen=True)
class Period:
    """A resolved, half-open period: ``start`` inclusive, ``end`` exclusive.

    Both bounds must be timezone-aware and ``start`` must precede ``end``;
    otherwise construction raises ``ValueError``.
    """

    start: datetime
    end: datetime

    def __post_init__(self) -> None:
        if self.start.utcoffset() is None or self.end.utcoffset() is None:
            raise ValueError("period bounds must be timezone-aware")
        if self.start >= self.end:
            raise ValueError("period start must be before its end")


@dataclass(frozen=True)
class CategoryExpense:
    category: TransactionCategory
    total: Money


@dataclass(frozen=True)
class CurrencyExpenses:
    """Expenses in a single currency; categories are sorted by total, largest first."""

    currency: Currency
    total: Money
    categories: tuple[CategoryExpense, ...]


@dataclass(frozen=True)
class ExpenseAnalysis:
    """Expenses for a period, one entry per currency ordered by currency code.

    A period without expenses has no currency entries.
    """

    period: Period
    category: TransactionCategory | None
    currencies: tuple[CurrencyExpenses, ...]


class AnalyzeExpenses:
    """Aggregate the customer's expenses for a resolved period.

    Expenses are DEBIT transactions at their full amount; CREDITs, including
    refunds, do not reduce spending. Currencies are never converted or combined.
    """

    def __init__(self, transactions: TransactionRepository) -> None:
        self._transactions = transactions

    def execute(
        self,
        customer_id: UUID,
        period: Period,
        category: TransactionCategory | None = None,
    ) -> ExpenseAnalysis:
        query = TransactionQuery(
            occurred_from=period.start,
            occurred_to=period.end,
            category=category,
            type=TransactionType.DEBIT,
        )
        expenses = self._transactions.list_by_customer(customer_id, query)
        return ExpenseAnalysis(
            period=period, category=category, currencies=_aggregate(expenses)
        )


def _aggregate(expenses: list[Transaction]) -> tuple[CurrencyExpenses, ...]:
    totals: defaultdict[Currency, defaultdict[TransactionCategory, Decimal]] = (
        defaultdict(lambda: defaultdict(Decimal))
    )
    for expense in expenses:
        totals[expense.amount.currency][expense.category] += expense.amount.amount

    return tuple(
        _currency_expenses(currency, totals[currency]) for currency in sorted(totals)
    )


def _currency_expenses(
    currency: Currency, by_category: dict[TransactionCategory, Decimal]
) -> CurrencyExpenses:
    ranked = sorted(by_category.items(), key=lambda item: (-item[1], item[0]))
    return CurrencyExpenses(
        currency=currency,
        total=Money(sum(by_category.values(), Decimal("0.00")), currency),
        categories=tuple(
            CategoryExpense(category, Money(amount, currency))
            for category, amount in ranked
        ),
    )
