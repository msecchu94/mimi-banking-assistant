from dataclasses import dataclass
from decimal import Decimal
from enum import StrEnum
from uuid import UUID

from mimi.application.repositories import TransactionRepository
from mimi.application.use_cases.analyze_expenses import (
    AnalyzeExpenses,
    ExpenseAnalysis,
    Period,
)
from mimi.domain.entities import Money
from mimi.domain.enums import Currency, TransactionCategory


class ExpenseChange(StrEnum):
    INCREASE = "INCREASE"
    DECREASE = "DECREASE"
    UNCHANGED = "UNCHANGED"


@dataclass(frozen=True)
class CurrencyComparison:
    """Totals of both periods in one currency.

    ``difference`` is the non-negative magnitude of current minus previous;
    ``change`` carries its direction.
    """

    currency: Currency
    current_total: Money
    previous_total: Money
    difference: Money
    change: ExpenseChange


@dataclass(frozen=True)
class ExpenseComparison:
    """Comparison per currency present in either period, ordered by currency code.

    A currency without expenses in one of the periods counts as zero there.
    """

    current: ExpenseAnalysis
    previous: ExpenseAnalysis
    currencies: tuple[CurrencyComparison, ...]


class CompareExpenses:
    """Compare the customer's expenses between two resolved periods.

    Periods are not required to be chronological or disjoint.
    """

    def __init__(self, transactions: TransactionRepository) -> None:
        self._analyze = AnalyzeExpenses(transactions)

    def execute(
        self,
        customer_id: UUID,
        current: Period,
        previous: Period,
        category: TransactionCategory | None = None,
    ) -> ExpenseComparison:
        current_analysis = self._analyze.execute(customer_id, current, category)
        previous_analysis = self._analyze.execute(customer_id, previous, category)
        current_totals = _totals(current_analysis)
        previous_totals = _totals(previous_analysis)
        currencies = sorted(current_totals.keys() | previous_totals.keys())
        return ExpenseComparison(
            current=current_analysis,
            previous=previous_analysis,
            currencies=tuple(
                _compare(
                    currency,
                    current_totals.get(currency, Decimal("0.00")),
                    previous_totals.get(currency, Decimal("0.00")),
                )
                for currency in currencies
            ),
        )


def _totals(analysis: ExpenseAnalysis) -> dict[Currency, Decimal]:
    return {entry.currency: entry.total.amount for entry in analysis.currencies}


def _compare(
    currency: Currency, current: Decimal, previous: Decimal
) -> CurrencyComparison:
    delta = current - previous
    if delta > 0:
        change = ExpenseChange.INCREASE
    elif delta < 0:
        change = ExpenseChange.DECREASE
    else:
        change = ExpenseChange.UNCHANGED
    return CurrencyComparison(
        currency=currency,
        current_total=Money(current, currency),
        previous_total=Money(previous, currency),
        difference=Money(abs(delta), currency),
        change=change,
    )
