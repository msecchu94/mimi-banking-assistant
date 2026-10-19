"""Deterministic results of a conversation turn, before any verbalization."""

from dataclasses import dataclass

from mimi.application.interpretation import Intent
from mimi.application.use_cases.analyze_expenses import ExpenseAnalysis, Period
from mimi.application.use_cases.compare_expenses import ExpenseComparison
from mimi.domain.entities import Account, Beneficiary, Card, Transaction


@dataclass(frozen=True)
class BalancesResult:
    accounts: tuple[Account, ...]


@dataclass(frozen=True)
class TransactionsResult:
    """Matching transactions, newest first; ``period`` is ``None`` when unfiltered
    by date."""

    transactions: tuple[Transaction, ...]
    period: Period | None


@dataclass(frozen=True)
class ExpenseAnalysisResult:
    analysis: ExpenseAnalysis


@dataclass(frozen=True)
class ExpenseComparisonResult:
    comparison: ExpenseComparison


@dataclass(frozen=True)
class CardsResult:
    cards: tuple[Card, ...]


@dataclass(frozen=True)
class BeneficiariesResult:
    beneficiaries: tuple[Beneficiary, ...]


@dataclass(frozen=True)
class IncompleteQueryResult:
    """A read-only query that was not executed because required data is
    missing, or because the user stated values that are unsupported or invalid.
    """

    intent: Intent
    missing_fields: frozenset[str] = frozenset()
    unsupported_fields: frozenset[str] = frozenset()
    invalid_fields: frozenset[str] = frozenset()


@dataclass(frozen=True)
class UnhandledIntentResult:
    """An intent this turn does not route; no Banking Core use case was executed."""

    intent: Intent


type TurnResult = (
    BalancesResult
    | TransactionsResult
    | ExpenseAnalysisResult
    | ExpenseComparisonResult
    | CardsResult
    | BeneficiariesResult
    | IncompleteQueryResult
    | UnhandledIntentResult
)
