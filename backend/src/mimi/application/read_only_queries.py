from datetime import datetime
from uuid import UUID
from zoneinfo import ZoneInfo

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
from mimi.application.interpretation import Intent, Interpretation, PeriodReference
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


class ReadOnlyQueryRouter:
    """Route an interpretation to the matching read-only Banking Core use case.

    Use Cases run on the given repositories, so their reads belong to the
    caller's transaction. Nothing is written. A query whose interpretation
    carries unsupported or invalid values, or lacks a required period, is not
    executed. Every other intent is left unhandled and executes no use case.

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
            case Intent.GET_BALANCE:
                accounts = GetAccountBalances(repositories.accounts).execute(
                    customer_id
                )
                return BalancesResult(tuple(accounts))
            case Intent.GET_TRANSACTIONS:
                period = (
                    None
                    if interpretation.period is None
                    else self._resolve(interpretation.period, now)
                )
                query = TransactionQuery(
                    occurred_from=None if period is None else period.start,
                    occurred_to=None if period is None else period.end,
                    category=interpretation.category,
                    type=interpretation.transaction_type,
                )
                transactions = GetTransactions(repositories.transactions).execute(
                    customer_id, query
                )
                return TransactionsResult(tuple(transactions), period)
            case Intent.ANALYZE_EXPENSES:
                reference = interpretation.period or PeriodReference.CURRENT_MONTH
                analysis = AnalyzeExpenses(repositories.transactions).execute(
                    customer_id, self._resolve(reference, now), interpretation.category
                )
                return ExpenseAnalysisResult(analysis)
            case Intent.COMPARE_EXPENSES:
                return self._compare(repositories, customer_id, interpretation, now)
            case Intent.GET_CARDS:
                cards = GetCards(repositories.cards).execute(customer_id)
                return CardsResult(tuple(cards))
            case Intent.GET_BENEFICIARIES:
                beneficiaries = GetBeneficiaries(repositories.beneficiaries).execute(
                    customer_id
                )
                return BeneficiariesResult(tuple(beneficiaries))
        raise AssertionError(f"unrouted read-only intent {intent}")

    def _compare(
        self,
        repositories: Repositories,
        customer_id: UUID,
        interpretation: Interpretation,
        now: datetime,
    ) -> TurnResult:
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

        comparison = CompareExpenses(repositories.transactions).execute(
            customer_id,
            self._resolve(current, now),
            self._resolve(previous, now),
            interpretation.category,
        )
        return ExpenseComparisonResult(comparison)

    def _resolve(self, reference: PeriodReference, now: datetime) -> Period:
        return resolve_period(reference, now, self._timezone)
