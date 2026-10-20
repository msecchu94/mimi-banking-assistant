"""Deterministic results of a conversation turn, before any verbalization."""

from collections.abc import Mapping
from dataclasses import dataclass, field
from enum import StrEnum

from mimi.application.errors import ApplicationError
from mimi.application.interpretation import Intent
from mimi.application.pending_operations import PendingField, PendingOperation
from mimi.application.use_cases.analyze_expenses import ExpenseAnalysis, Period
from mimi.application.use_cases.compare_expenses import ExpenseComparison
from mimi.domain.entities import Account, Beneficiary, Card, Money, Transaction
from mimi.domain.enums import Currency, PendingOperationType


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


class FieldIssue(StrEnum):
    """Why a value the user stated this turn did not become operation data."""

    AMBIGUOUS = "AMBIGUOUS"
    NOT_FOUND = "NOT_FOUND"
    INVALID = "INVALID"
    UNSUPPORTED = "UNSUPPORTED"


@dataclass(frozen=True)
class AmountCurrencyConflict:
    """The selected source account cannot take the previously resolved amount,
    which was cleared rather than converted to ``selected_currency``."""

    previous: Money
    selected_currency: Currency


@dataclass(frozen=True)
class CollectingDataResult:
    """The pending operation after collecting this turn's data.

    ``issues`` names the fields whose stated value was not resolved; they are
    missing. Candidates are the matches of an ambiguous reference, for the
    user to choose from. Nothing here is persisted except ``operation``.
    """

    operation: PendingOperation
    issues: Mapping[PendingField, FieldIssue] = field(default_factory=dict)
    beneficiary_candidates: tuple[Beneficiary, ...] = ()
    account_candidates: tuple[Account, ...] = ()
    card_candidates: tuple[Card, ...] = ()
    amount_conflict: AmountCurrencyConflict | None = None


@dataclass(frozen=True)
class AwaitingConfirmationResult:
    """A complete operation that passed pre-validation and now waits for an
    explicit decision. The referenced records are read from the database at
    pre-validation, for the user to review; a transfer sets ``source_account``
    and ``beneficiary``, a card operation sets ``card``."""

    operation: PendingOperation
    source_account: Account | None = None
    beneficiary: Beneficiary | None = None
    card: Card | None = None


@dataclass(frozen=True)
class PreValidationFailedResult:
    """A complete operation that cannot currently be executed; it was
    discarded without requesting confirmation."""

    operation: PendingOperation
    error: ApplicationError


@dataclass(frozen=True)
class PendingOperationConflictResult:
    """A state-changing request that was not started because another
    operation is pending; the pending operation is unchanged."""

    intent: Intent
    pending_type: PendingOperationType


type TurnResult = (
    BalancesResult
    | TransactionsResult
    | ExpenseAnalysisResult
    | ExpenseComparisonResult
    | CardsResult
    | BeneficiariesResult
    | IncompleteQueryResult
    | UnhandledIntentResult
    | CollectingDataResult
    | AwaitingConfirmationResult
    | PreValidationFailedResult
    | PendingOperationConflictResult
)
