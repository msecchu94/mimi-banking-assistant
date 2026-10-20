from dataclasses import replace
from datetime import datetime
from uuid import UUID
from zoneinfo import ZoneInfo

from mimi.application.conversation_context import (
    ConversationContext,
    TemporalContext,
)
from mimi.application.conversation_results import (
    BalancesResult,
    BeneficiariesResult,
    CardsResult,
    ExpenseAnalysisResult,
    ExpenseComparisonResult,
    IncompleteQueryResult,
    TransactionsResult,
    TurnResult,
    UnhandledIntentResult,
)
from mimi.application.interpretation import (
    FollowUp,
    Intent,
    Interpretation,
    PeriodReference,
)
from mimi.application.periods import (
    current_counterpart,
    previous_counterpart,
    resolve_period,
)
from mimi.application.repositories import Repositories, TransactionQuery
from mimi.application.use_cases.analyze_expenses import AnalyzeExpenses, Period
from mimi.application.use_cases.compare_expenses import CompareExpenses
from mimi.application.use_cases.get_account_balances import GetAccountBalances
from mimi.application.use_cases.get_beneficiaries import GetBeneficiaries
from mimi.application.use_cases.get_cards import GetCards
from mimi.application.use_cases.get_transactions import GetTransactions

_READ_ONLY_INTENTS = frozenset(
    {
        Intent.GET_BALANCE,
        Intent.GET_TRANSACTIONS,
        Intent.ANALYZE_EXPENSES,
        Intent.COMPARE_EXPENSES,
        Intent.GET_CARDS,
        Intent.GET_BENEFICIARIES,
    }
)

# Values a follow-up may state, and so inherit, for each query it can continue.
_INHERITABLE_FIELDS: dict[Intent, frozenset[str]] = {
    Intent.GET_TRANSACTIONS: frozenset({"category", "transaction_type", "period"}),
    Intent.ANALYZE_EXPENSES: frozenset({"category", "period"}),
    Intent.COMPARE_EXPENSES: frozenset({"category", "period"}),
}

type PreparedQuery = Interpretation | IncompleteQueryResult | UnhandledIntentResult


class ReadOnlyQueryRouter:
    """Route an interpretation to the matching read-only Banking Core use case.

    Use Cases run on the given repositories, so their reads belong to the
    caller's transaction. Nothing is written. A query whose interpretation
    carries unsupported or invalid values, or lacks a required period, is not
    executed. Every other intent is left unhandled and executes no use case.
    A follow-up is first resolved against the conversation's context into an
    ordinary interpretation; it is never executed as such.

    Period defaults: expense analysis covers the current month; an expense
    comparison with one side omitted uses its matching current or previous
    period at the same scale; transactions are not filtered by date.
    """

    def __init__(self, timezone: ZoneInfo) -> None:
        self._timezone = timezone

    def route(
        self,
        repositories: Repositories,
        customer_id: UUID,
        interpretation: Interpretation,
        now: datetime,
    ) -> TurnResult:
        """Prepare ``interpretation`` and execute it when it is complete."""
        query = self.prepare(interpretation)
        if not isinstance(query, Interpretation):
            return query
        return self.execute(repositories, customer_id, query, now)

    def prepare(self, interpretation: Interpretation) -> PreparedQuery:
        """Return the complete read-only query to execute, with period defaults
        applied, or the result explaining why nothing is executed."""
        intent = interpretation.intent
        if intent not in _READ_ONLY_INTENTS:
            return UnhandledIntentResult(intent)
        if interpretation.unsupported_fields or interpretation.invalid_fields:
            return IncompleteQueryResult(
                intent,
                unsupported_fields=interpretation.unsupported_fields,
                invalid_fields=interpretation.invalid_fields,
            )
        match intent:
            case Intent.ANALYZE_EXPENSES if interpretation.period is None:
                return replace(interpretation, period=PeriodReference.CURRENT_MONTH)
            case Intent.COMPARE_EXPENSES:
                return _prepare_comparison(interpretation)
        return interpretation

    def resolve_follow_up(
        self, follow_up: FollowUp, context: ConversationContext, now: datetime
    ) -> Interpretation | IncompleteQueryResult:
        """Resolve ``follow_up`` against the conversation's last query.

        Stated values replace inherited ones; everything else is inherited. A
        relative period shifts the period in context to the preceding one at
        the same scale. Inherited periods must still resolve to the same dates
        as when the last query ran. A follow-up without context, with values
        its last query does not take, or without a period to inherit or shift
        is not resolved and executes no query.
        """
        intent = context.last_intent
        if intent is None:
            return IncompleteQueryResult(
                Intent.UNKNOWN, missing_fields=frozenset({"context"})
            )
        if follow_up.unsupported_fields or follow_up.invalid_fields:
            return IncompleteQueryResult(
                intent,
                unsupported_fields=follow_up.unsupported_fields,
                invalid_fields=follow_up.invalid_fields,
            )
        stated = _stated_fields(follow_up)
        if not stated:
            return IncompleteQueryResult(intent, missing_fields=frozenset({"context"}))
        if incompatible := stated - _INHERITABLE_FIELDS.get(intent, frozenset()):
            return IncompleteQueryResult(intent, unsupported_fields=incompatible)

        temporal = context.temporal
        if temporal is not None and self._is_stale(temporal, now):
            temporal = None
        period = follow_up.period
        comparison_period = None
        if follow_up.relative_period is not None:
            if intent is Intent.COMPARE_EXPENSES:
                return IncompleteQueryResult(
                    intent, unsupported_fields=frozenset({"period"})
                )
            period = None if temporal is None else previous_counterpart(temporal.period)
            if period is None:
                return IncompleteQueryResult(
                    intent, missing_fields=frozenset({"period"})
                )
        elif period is None and context.temporal is not None:
            if temporal is None:
                return IncompleteQueryResult(
                    intent, missing_fields=frozenset({"period"})
                )
            period = temporal.period
            comparison_period = temporal.comparison_period

        return Interpretation(
            intent=intent,
            category=_stated_or(follow_up.category, context.category),
            transaction_type=_stated_or(
                follow_up.transaction_type, context.transaction_type
            ),
            period=period,
            comparison_period=comparison_period,
        )

    def execute(
        self,
        repositories: Repositories,
        customer_id: UUID,
        query: Interpretation,
        now: datetime,
    ) -> TurnResult:
        """Execute a query returned by ``prepare``."""
        intent = query.intent
        match intent:
            case Intent.GET_BALANCE:
                accounts = GetAccountBalances(repositories.accounts).execute(
                    customer_id
                )
                return BalancesResult(tuple(accounts))
            case Intent.GET_TRANSACTIONS:
                period = (
                    None if query.period is None else self._resolve(query.period, now)
                )
                transaction_query = TransactionQuery(
                    occurred_from=None if period is None else period.start,
                    occurred_to=None if period is None else period.end,
                    category=query.category,
                    type=query.transaction_type,
                )
                transactions = GetTransactions(repositories.transactions).execute(
                    customer_id, transaction_query
                )
                return TransactionsResult(tuple(transactions), period)
            case Intent.ANALYZE_EXPENSES:
                if query.period is None:
                    raise AssertionError("expense analysis is not prepared")
                analysis = AnalyzeExpenses(repositories.transactions).execute(
                    customer_id, self._resolve(query.period, now), query.category
                )
                return ExpenseAnalysisResult(analysis)
            case Intent.COMPARE_EXPENSES:
                if query.period is None or query.comparison_period is None:
                    raise AssertionError("expense comparison is not prepared")
                comparison = CompareExpenses(repositories.transactions).execute(
                    customer_id,
                    self._resolve(query.period, now),
                    self._resolve(query.comparison_period, now),
                    query.category,
                )
                return ExpenseComparisonResult(comparison)
            case Intent.GET_CARDS:
                cards = GetCards(repositories.cards).execute(customer_id)
                return CardsResult(tuple(cards))
            case Intent.GET_BENEFICIARIES:
                beneficiaries = GetBeneficiaries(repositories.beneficiaries).execute(
                    customer_id
                )
                return BeneficiariesResult(tuple(beneficiaries))
        raise AssertionError(f"unrouted read-only intent {intent}")

    def _resolve(self, reference: PeriodReference, now: datetime) -> Period:
        return resolve_period(reference, now, self._timezone)

    def _is_stale(self, temporal: TemporalContext, now: datetime) -> bool:
        """Whether a period in context now resolves to other dates than when
        its query ran, e.g. ``CURRENT_MONTH`` after the month rolled over."""
        return any(
            self._resolve(reference, temporal.anchored_at)
            != self._resolve(reference, now)
            for reference in (temporal.period, temporal.comparison_period)
            if reference is not None
        )


def _prepare_comparison(
    interpretation: Interpretation,
) -> Interpretation | IncompleteQueryResult:
    current = interpretation.period
    previous = interpretation.comparison_period
    if current is None and previous is not None:
        current = current_counterpart(previous)
    elif previous is None and current is not None:
        previous = previous_counterpart(current)
    if current is None or previous is None:
        missing = {
            name
            for name, value in (
                ("period", current),
                ("comparison_period", previous),
            )
            if value is None
        }
        return IncompleteQueryResult(
            Intent.COMPARE_EXPENSES, missing_fields=frozenset(missing)
        )
    return replace(interpretation, period=current, comparison_period=previous)


def _stated_fields(follow_up: FollowUp) -> frozenset[str]:
    stated = {
        name
        for name, value in (
            ("category", follow_up.category),
            ("transaction_type", follow_up.transaction_type),
            ("period", follow_up.period or follow_up.relative_period),
        )
        if value is not None
    }
    return frozenset(stated)


def _stated_or[V](stated: V | None, inherited: V | None) -> V | None:
    return inherited if stated is None else stated
