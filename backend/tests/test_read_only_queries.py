from dataclasses import dataclass, field
from datetime import UTC, datetime, timedelta
from decimal import Decimal
from typing import Any, NoReturn
from uuid import UUID, uuid4
from zoneinfo import ZoneInfo

import pytest

from mimi.application.conversation_context import (
    EMPTY_CONTEXT,
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
    UnhandledIntentResult,
)
from mimi.application.interpretation import (
    CalendarMonth,
    FollowUp,
    Intent,
    Interpretation,
    PeriodReference,
    RelativePeriod,
)
from mimi.application.pending_operations import PendingOperation
from mimi.application.read_only_queries import ReadOnlyQueryRouter
from mimi.application.repositories import ConversationRecord, TransactionQuery
from mimi.application.use_cases.analyze_expenses import Period
from mimi.application.use_cases.compare_expenses import ExpenseChange
from mimi.domain.entities import (
    Account,
    Beneficiary,
    Card,
    Message,
    Money,
    Transaction,
)
from mimi.domain.enums import (
    AccountStatus,
    CardBrand,
    CardStatus,
    CardType,
    ConversationFlowState,
    Currency,
    TransactionCategory,
    TransactionType,
)

BUENOS_AIRES = ZoneInfo("America/Argentina/Buenos_Aires")
# 01:30 UTC on Nov 1st is Oct 31st, 22:30 in Buenos Aires.
NOW = datetime(2026, 11, 1, 1, 30, tzinfo=UTC)

OCTOBER = Period(
    datetime(2026, 10, 1, tzinfo=BUENOS_AIRES),
    datetime(2026, 11, 1, tzinfo=BUENOS_AIRES),
)
SEPTEMBER = Period(
    datetime(2026, 9, 1, tzinfo=BUENOS_AIRES),
    datetime(2026, 10, 1, tzinfo=BUENOS_AIRES),
)
CURRENT_WEEK = Period(
    datetime(2026, 10, 26, tzinfo=BUENOS_AIRES),
    datetime(2026, 11, 2, tzinfo=BUENOS_AIRES),
)
PREVIOUS_WEEK = Period(
    datetime(2026, 10, 19, tzinfo=BUENOS_AIRES),
    datetime(2026, 10, 26, tzinfo=BUENOS_AIRES),
)

CUSTOMER_ID = uuid4()
OTHER_CUSTOMER_ID = uuid4()

READ_ONLY_INTENTS = [
    Intent.GET_BALANCE,
    Intent.GET_TRANSACTIONS,
    Intent.ANALYZE_EXPENSES,
    Intent.COMPARE_EXPENSES,
    Intent.GET_CARDS,
    Intent.GET_BENEFICIARIES,
]
UNROUTED_INTENTS = [intent for intent in Intent if intent not in READ_ONLY_INTENTS]


def refuse_write(*args: object) -> NoReturn:
    raise AssertionError("read-only routing must not write")


class FakeAccountRepository:
    def __init__(self, reads: list[str], accounts: dict[UUID, list[Account]]) -> None:
        self._reads = reads
        self._accounts = accounts

    def list_by_customer(self, customer_id: UUID) -> list[Account]:
        self._reads.append("accounts")
        return self._accounts.get(customer_id, [])

    def get_for_update(self, customer_id: UUID, account_id: UUID) -> Account | None:
        refuse_write()

    def update_balance(self, account_id: UUID, balance: Money) -> None:
        refuse_write()


class FakeCardRepository:
    def __init__(self, reads: list[str], cards: dict[UUID, list[Card]]) -> None:
        self._reads = reads
        self._cards = cards

    def list_by_customer(self, customer_id: UUID) -> list[Card]:
        self._reads.append("cards")
        return self._cards.get(customer_id, [])

    def get(self, customer_id: UUID, card_id: UUID) -> Card | None:
        raise AssertionError("unexpected single card read")

    def update_status(self, card_id: UUID, status: CardStatus) -> None:
        refuse_write()


class FakeBeneficiaryRepository:
    def __init__(
        self, reads: list[str], beneficiaries: dict[UUID, list[Beneficiary]]
    ) -> None:
        self._reads = reads
        self._beneficiaries = beneficiaries

    def list_by_customer(self, customer_id: UUID) -> list[Beneficiary]:
        self._reads.append("beneficiaries")
        return self._beneficiaries.get(customer_id, [])

    def get(self, customer_id: UUID, beneficiary_id: UUID) -> Beneficiary | None:
        raise AssertionError("unexpected single beneficiary read")


class FakeTransactionRepository:
    """Honours every query filter, as the PostgreSQL adapter does."""

    def __init__(
        self, reads: list[str], transactions: dict[UUID, list[Transaction]]
    ) -> None:
        self._reads = reads
        self._transactions = transactions
        self.queries: list[TransactionQuery] = []

    def list_by_customer(
        self, customer_id: UUID, query: TransactionQuery
    ) -> list[Transaction]:
        self._reads.append("transactions")
        self.queries.append(query)
        matching = [
            t
            for t in self._transactions.get(customer_id, [])
            if (query.occurred_from is None or t.occurred_at >= query.occurred_from)
            and (query.occurred_to is None or t.occurred_at < query.occurred_to)
            and (query.category is None or t.category is query.category)
            and (query.type is None or t.type is query.type)
        ]
        matching.sort(key=lambda t: t.occurred_at, reverse=True)
        return matching[: query.limit]


class FakeConversationRepository:
    def add(self, record: ConversationRecord) -> None:
        refuse_write()

    def get_for_update(
        self, customer_id: UUID, conversation_id: UUID
    ) -> ConversationRecord | None:
        raise AssertionError("routing must not read conversations")

    def save_pending_operation(
        self,
        conversation_id: UUID,
        flow_state: ConversationFlowState,
        pending_operation: PendingOperation | None,
    ) -> None:
        refuse_write()

    def mark_closed(self, conversation_id: UUID) -> None:
        refuse_write()

    def touch(self, conversation_id: UUID, updated_at: datetime) -> None:
        refuse_write()

    def save_context(self, conversation_id: UUID, context: ConversationContext) -> None:
        refuse_write()


class FakeMessageRepository:
    def add(self, message: Message) -> None:
        refuse_write()

    def list_by_conversation(self, conversation_id: UUID) -> list[Message]:
        raise AssertionError("routing must not read messages")


@dataclass
class BankData:
    accounts: dict[UUID, list[Account]] = field(default_factory=dict)
    cards: dict[UUID, list[Card]] = field(default_factory=dict)
    beneficiaries: dict[UUID, list[Beneficiary]] = field(default_factory=dict)
    transactions: dict[UUID, list[Transaction]] = field(default_factory=dict)


class FakeRepositories:
    def __init__(self, data: BankData | None = None) -> None:
        data = data or BankData()
        self.reads: list[str] = []
        self.accounts = FakeAccountRepository(self.reads, data.accounts)
        self.cards = FakeCardRepository(self.reads, data.cards)
        self.beneficiaries = FakeBeneficiaryRepository(self.reads, data.beneficiaries)
        self.transactions = FakeTransactionRepository(self.reads, data.transactions)
        self.transfers: Any = None
        self.conversations = FakeConversationRepository()
        self.messages = FakeMessageRepository()


def make_account(name: str, amount: str, currency: Currency) -> Account:
    return Account(
        id=uuid4(),
        customer_id=CUSTOMER_ID,
        name=name,
        balance=Money(Decimal(amount), currency),
        status=AccountStatus.ACTIVE,
    )


def make_card(status: CardStatus) -> Card:
    return Card(
        id=uuid4(),
        account_id=uuid4(),
        type=CardType.DEBIT,
        brand=CardBrand.VISA,
        last_four="4821",
        status=status,
    )


def make_beneficiary(name: str) -> Beneficiary:
    return Beneficiary(
        id=uuid4(),
        customer_id=CUSTOMER_ID,
        name=name,
        account_reference="0000003100012345678901",
        bank_name=None,
    )


def make_transaction(
    amount: str,
    occurred_at: datetime,
    category: TransactionCategory = TransactionCategory.GROCERIES,
    type: TransactionType = TransactionType.DEBIT,
) -> Transaction:
    return Transaction(
        id=uuid4(),
        account_id=uuid4(),
        amount=Money(Decimal(amount), Currency.ARS),
        type=type,
        category=category,
        description="Movimiento",
        occurred_at=occurred_at,
        transfer_id=None,
    )


def ars(amount: str) -> Money:
    return Money(Decimal(amount), Currency.ARS)


def local(month: int, day: int) -> datetime:
    return datetime(2026, month, day, 12, 0, tzinfo=BUENOS_AIRES)


# Expenses of the customer: two in October, one in September, one credit.
OCTOBER_GROCERIES = make_transaction("30000.00", local(10, 20))
OCTOBER_DINING = make_transaction(
    "15000.00", local(10, 28), category=TransactionCategory.DINING
)
SEPTEMBER_GROCERIES = make_transaction("20000.00", local(9, 10))
OCTOBER_SALARY = make_transaction(
    "500000.00",
    local(10, 5),
    category=TransactionCategory.OTHER,
    type=TransactionType.CREDIT,
)
CUSTOMER_TRANSACTIONS = [
    SEPTEMBER_GROCERIES,
    OCTOBER_SALARY,
    OCTOBER_GROCERIES,
    OCTOBER_DINING,
]


@pytest.fixture
def router() -> ReadOnlyQueryRouter:
    return ReadOnlyQueryRouter(BUENOS_AIRES)


@pytest.fixture
def repositories() -> FakeRepositories:
    return FakeRepositories(
        BankData(
            transactions={
                CUSTOMER_ID: list(CUSTOMER_TRANSACTIONS),
                OTHER_CUSTOMER_ID: [make_transaction("99999.00", local(10, 20))],
            }
        )
    )


def route(
    router: ReadOnlyQueryRouter,
    repositories: FakeRepositories,
    interpretation: Interpretation,
) -> object:
    return router.route(repositories, CUSTOMER_ID, interpretation, NOW)


def test_balance_returns_customer_accounts_as_stored(
    router: ReadOnlyQueryRouter,
) -> None:
    savings = make_account("Caja de ahorro", "150000.50", Currency.ARS)
    dollars = make_account("Cuenta en dólares", "320.00", Currency.USD)
    other = make_account("Ajena", "1.00", Currency.ARS)
    repositories = FakeRepositories(
        BankData(accounts={CUSTOMER_ID: [savings, dollars], OTHER_CUSTOMER_ID: [other]})
    )

    result = route(router, repositories, Interpretation(intent=Intent.GET_BALANCE))

    assert result == BalancesResult((savings, dollars))
    assert repositories.reads == ["accounts"]


def test_cards_return_customer_cards_including_frozen(
    router: ReadOnlyQueryRouter,
) -> None:
    active = make_card(CardStatus.ACTIVE)
    frozen = make_card(CardStatus.FROZEN)
    repositories = FakeRepositories(
        BankData(
            cards={
                CUSTOMER_ID: [active, frozen],
                OTHER_CUSTOMER_ID: [make_card(CardStatus.ACTIVE)],
            }
        )
    )

    result = route(router, repositories, Interpretation(intent=Intent.GET_CARDS))

    assert result == CardsResult((active, frozen))
    assert repositories.reads == ["cards"]


def test_beneficiaries_return_customer_beneficiaries(
    router: ReadOnlyQueryRouter,
) -> None:
    laura = make_beneficiary("Laura")
    repositories = FakeRepositories(
        BankData(
            beneficiaries={
                CUSTOMER_ID: [laura],
                OTHER_CUSTOMER_ID: [make_beneficiary("Juan")],
            }
        )
    )

    result = route(
        router, repositories, Interpretation(intent=Intent.GET_BENEFICIARIES)
    )

    assert result == BeneficiariesResult((laura,))
    assert repositories.reads == ["beneficiaries"]


@pytest.mark.parametrize(
    ("intent", "expected"),
    [
        (Intent.GET_BALANCE, BalancesResult(())),
        (Intent.GET_CARDS, CardsResult(())),
        (Intent.GET_BENEFICIARIES, BeneficiariesResult(())),
        (Intent.GET_TRANSACTIONS, TransactionsResult((), None)),
    ],
)
def test_customer_without_data_gets_empty_result(
    router: ReadOnlyQueryRouter, intent: Intent, expected: object
) -> None:
    result = route(router, FakeRepositories(), Interpretation(intent=intent))

    assert result == expected


def test_transactions_without_period_are_unfiltered_and_unlimited(
    router: ReadOnlyQueryRouter, repositories: FakeRepositories
) -> None:
    result = route(router, repositories, Interpretation(intent=Intent.GET_TRANSACTIONS))

    assert result == TransactionsResult(
        (OCTOBER_DINING, OCTOBER_GROCERIES, OCTOBER_SALARY, SEPTEMBER_GROCERIES),
        period=None,
    )
    assert repositories.transactions.queries == [TransactionQuery()]


def test_transactions_apply_resolved_period_category_and_type(
    router: ReadOnlyQueryRouter, repositories: FakeRepositories
) -> None:
    interpretation = Interpretation(
        intent=Intent.GET_TRANSACTIONS,
        category=TransactionCategory.GROCERIES,
        transaction_type=TransactionType.DEBIT,
        period=PeriodReference.CURRENT_MONTH,
    )

    result = route(router, repositories, interpretation)

    assert result == TransactionsResult((OCTOBER_GROCERIES,), period=OCTOBER)
    assert repositories.transactions.queries == [
        TransactionQuery(
            occurred_from=OCTOBER.start,
            occurred_to=OCTOBER.end,
            category=TransactionCategory.GROCERIES,
            type=TransactionType.DEBIT,
        )
    ]


def test_transactions_filter_by_type_only(
    router: ReadOnlyQueryRouter, repositories: FakeRepositories
) -> None:
    interpretation = Interpretation(
        intent=Intent.GET_TRANSACTIONS, transaction_type=TransactionType.CREDIT
    )

    result = route(router, repositories, interpretation)

    assert result == TransactionsResult((OCTOBER_SALARY,), period=None)


def test_expense_analysis_defaults_to_current_month(
    router: ReadOnlyQueryRouter, repositories: FakeRepositories
) -> None:
    result = route(router, repositories, Interpretation(intent=Intent.ANALYZE_EXPENSES))

    assert isinstance(result, ExpenseAnalysisResult)
    analysis = result.analysis
    assert analysis.period == OCTOBER
    assert analysis.category is None
    [ars_expenses] = analysis.currencies
    assert ars_expenses.total == ars("45000.00")
    assert [entry.category for entry in ars_expenses.categories] == [
        TransactionCategory.GROCERIES,
        TransactionCategory.DINING,
    ]


def test_expense_analysis_uses_stated_period_and_category(
    router: ReadOnlyQueryRouter, repositories: FakeRepositories
) -> None:
    interpretation = Interpretation(
        intent=Intent.ANALYZE_EXPENSES,
        category=TransactionCategory.GROCERIES,
        period=PeriodReference.PREVIOUS_MONTH,
    )

    result = route(router, repositories, interpretation)

    assert isinstance(result, ExpenseAnalysisResult)
    assert result.analysis.period == SEPTEMBER
    assert result.analysis.category is TransactionCategory.GROCERIES
    [ars_expenses] = result.analysis.currencies
    assert ars_expenses.total == ars("20000.00")


def test_expense_comparison_uses_both_stated_periods(
    router: ReadOnlyQueryRouter, repositories: FakeRepositories
) -> None:
    interpretation = Interpretation(
        intent=Intent.COMPARE_EXPENSES,
        period=PeriodReference.CURRENT_MONTH,
        comparison_period=PeriodReference.PREVIOUS_MONTH,
    )

    result = route(router, repositories, interpretation)

    assert isinstance(result, ExpenseComparisonResult)
    comparison = result.comparison
    assert comparison.current.period == OCTOBER
    assert comparison.previous.period == SEPTEMBER
    [ars_comparison] = comparison.currencies
    assert ars_comparison.current_total == ars("45000.00")
    assert ars_comparison.previous_total == ars("20000.00")
    assert ars_comparison.difference == ars("25000.00")
    assert ars_comparison.change is ExpenseChange.INCREASE


def test_expense_comparison_passes_category(
    router: ReadOnlyQueryRouter, repositories: FakeRepositories
) -> None:
    interpretation = Interpretation(
        intent=Intent.COMPARE_EXPENSES,
        category=TransactionCategory.DINING,
        period=PeriodReference.CURRENT_MONTH,
        comparison_period=PeriodReference.PREVIOUS_MONTH,
    )

    result = route(router, repositories, interpretation)

    assert isinstance(result, ExpenseComparisonResult)
    assert result.comparison.current.category is TransactionCategory.DINING
    [ars_comparison] = result.comparison.currencies
    assert ars_comparison.current_total == ars("15000.00")
    assert ars_comparison.previous_total == ars("0.00")


@pytest.mark.parametrize(
    ("period", "comparison_period", "expected_current", "expected_previous"),
    [
        (None, PeriodReference.PREVIOUS_MONTH, OCTOBER, SEPTEMBER),
        (PeriodReference.CURRENT_MONTH, None, OCTOBER, SEPTEMBER),
        (None, PeriodReference.PREVIOUS_WEEK, CURRENT_WEEK, PREVIOUS_WEEK),
        (PeriodReference.CURRENT_WEEK, None, CURRENT_WEEK, PREVIOUS_WEEK),
    ],
)
def test_expense_comparison_derives_omitted_side_at_same_scale(
    router: ReadOnlyQueryRouter,
    repositories: FakeRepositories,
    period: PeriodReference | None,
    comparison_period: PeriodReference | None,
    expected_current: Period,
    expected_previous: Period,
) -> None:
    interpretation = Interpretation(
        intent=Intent.COMPARE_EXPENSES,
        period=period,
        comparison_period=comparison_period,
    )

    result = route(router, repositories, interpretation)

    assert isinstance(result, ExpenseComparisonResult)
    assert result.comparison.current.period == expected_current
    assert result.comparison.previous.period == expected_previous


def test_expense_comparison_derives_yesterday_from_today(
    router: ReadOnlyQueryRouter, repositories: FakeRepositories
) -> None:
    interpretation = Interpretation(
        intent=Intent.COMPARE_EXPENSES, period=PeriodReference.TODAY
    )

    result = route(router, repositories, interpretation)

    assert isinstance(result, ExpenseComparisonResult)
    assert result.comparison.current.period == Period(
        datetime(2026, 10, 31, tzinfo=BUENOS_AIRES),
        datetime(2026, 11, 1, tzinfo=BUENOS_AIRES),
    )
    assert result.comparison.previous.period == Period(
        datetime(2026, 10, 30, tzinfo=BUENOS_AIRES),
        datetime(2026, 10, 31, tzinfo=BUENOS_AIRES),
    )


@pytest.mark.parametrize(
    ("period", "comparison_period", "missing"),
    [
        (None, None, {"period", "comparison_period"}),
        (PeriodReference.PREVIOUS_MONTH, None, {"comparison_period"}),
        (PeriodReference.YESTERDAY, None, {"comparison_period"}),
        (None, PeriodReference.CURRENT_MONTH, {"period"}),
        (None, PeriodReference.TODAY, {"period"}),
    ],
)
def test_expense_comparison_without_derivable_periods_is_incomplete(
    router: ReadOnlyQueryRouter,
    repositories: FakeRepositories,
    period: PeriodReference | None,
    comparison_period: PeriodReference | None,
    missing: set[str],
) -> None:
    interpretation = Interpretation(
        intent=Intent.COMPARE_EXPENSES,
        period=period,
        comparison_period=comparison_period,
    )

    result = route(router, repositories, interpretation)

    assert result == IncompleteQueryResult(
        Intent.COMPARE_EXPENSES, missing_fields=frozenset(missing)
    )
    assert repositories.reads == []


@pytest.mark.parametrize("intent", READ_ONLY_INTENTS)
def test_unsupported_fields_execute_no_query(
    router: ReadOnlyQueryRouter, repositories: FakeRepositories, intent: Intent
) -> None:
    interpretation = Interpretation(
        intent=intent, unsupported_fields=frozenset({"category", "period"})
    )

    result = route(router, repositories, interpretation)

    assert result == IncompleteQueryResult(
        intent, unsupported_fields=frozenset({"category", "period"})
    )
    assert repositories.reads == []


@pytest.mark.parametrize("intent", READ_ONLY_INTENTS)
def test_invalid_fields_execute_no_query(
    router: ReadOnlyQueryRouter, repositories: FakeRepositories, intent: Intent
) -> None:
    interpretation = Interpretation(intent=intent, invalid_fields=frozenset({"amount"}))

    result = route(router, repositories, interpretation)

    assert result == IncompleteQueryResult(intent, invalid_fields=frozenset({"amount"}))
    assert repositories.reads == []


def test_expense_analysis_of_a_calendar_month(
    router: ReadOnlyQueryRouter, repositories: FakeRepositories
) -> None:
    interpretation = Interpretation(
        intent=Intent.ANALYZE_EXPENSES, period=CalendarMonth(9, 2026)
    )

    result = route(router, repositories, interpretation)

    assert isinstance(result, ExpenseAnalysisResult)
    assert result.analysis.period == SEPTEMBER
    [ars_expenses] = result.analysis.currencies
    assert ars_expenses.total == ars("20000.00")


@pytest.mark.parametrize(
    ("period", "comparison_period", "expected_current", "expected_previous"),
    [
        (CalendarMonth(10), CalendarMonth(9), OCTOBER, SEPTEMBER),
        (CalendarMonth(9), CalendarMonth(10), SEPTEMBER, OCTOBER),
        (None, CalendarMonth(9), OCTOBER, SEPTEMBER),
        (CalendarMonth(10), None, OCTOBER, SEPTEMBER),
        (PeriodReference.CURRENT_MONTH, CalendarMonth(9, 2026), OCTOBER, SEPTEMBER),
    ],
)
def test_expense_comparison_of_calendar_months(
    router: ReadOnlyQueryRouter,
    repositories: FakeRepositories,
    period: PeriodReference | CalendarMonth | None,
    comparison_period: PeriodReference | CalendarMonth | None,
    expected_current: Period,
    expected_previous: Period,
) -> None:
    interpretation = Interpretation(
        intent=Intent.COMPARE_EXPENSES,
        period=period,
        comparison_period=comparison_period,
    )

    result = route(router, repositories, interpretation)

    assert isinstance(result, ExpenseComparisonResult)
    assert result.comparison.current.period == expected_current
    assert result.comparison.previous.period == expected_previous


@pytest.mark.parametrize(
    ("interpretation", "future"),
    [
        (
            Interpretation(
                intent=Intent.ANALYZE_EXPENSES, period=CalendarMonth(11, 2026)
            ),
            {"period"},
        ),
        (
            Interpretation(
                intent=Intent.GET_TRANSACTIONS, period=CalendarMonth(1, 2027)
            ),
            {"period"},
        ),
        (
            Interpretation(
                intent=Intent.COMPARE_EXPENSES,
                period=CalendarMonth(12, 2026),
                comparison_period=CalendarMonth(11, 2026),
            ),
            {"period", "comparison_period"},
        ),
    ],
)
def test_future_calendar_month_executes_no_query(
    router: ReadOnlyQueryRouter,
    repositories: FakeRepositories,
    interpretation: Interpretation,
    future: set[str],
) -> None:
    result = route(router, repositories, interpretation)

    assert result == IncompleteQueryResult(
        interpretation.intent, unsupported_fields=frozenset(future)
    )
    assert repositories.reads == []


def test_unsupported_side_of_comparison_is_not_derived(
    router: ReadOnlyQueryRouter, repositories: FakeRepositories
) -> None:
    interpretation = Interpretation(
        intent=Intent.COMPARE_EXPENSES,
        comparison_period=PeriodReference.PREVIOUS_MONTH,
        unsupported_fields=frozenset({"period"}),
    )

    result = route(router, repositories, interpretation)

    assert result == IncompleteQueryResult(
        Intent.COMPARE_EXPENSES, unsupported_fields=frozenset({"period"})
    )
    assert repositories.reads == []


@pytest.mark.parametrize("intent", UNROUTED_INTENTS)
def test_other_intents_are_unhandled_and_execute_no_use_case(
    router: ReadOnlyQueryRouter, repositories: FakeRepositories, intent: Intent
) -> None:
    interpretation = Interpretation(
        intent=intent,
        amount=Decimal("25000"),
        currency=Currency.ARS,
        beneficiary_reference="Laura",
        card_reference="my Visa",
    )

    result = route(router, repositories, interpretation)

    assert result == UnhandledIntentResult(intent)
    assert repositories.reads == []


def test_unrouted_intents_cover_mutations_and_conversation() -> None:
    assert set(UNROUTED_INTENTS) == {
        Intent.FREEZE_CARD,
        Intent.UNFREEZE_CARD,
        Intent.TRANSFER_MONEY,
        Intent.GENERAL_CONVERSATION,
        Intent.CANCEL,
        Intent.UNKNOWN,
    }


def test_prepare_applies_expense_analysis_default_period(
    router: ReadOnlyQueryRouter,
) -> None:
    query = router.prepare(
        Interpretation(
            intent=Intent.ANALYZE_EXPENSES, category=TransactionCategory.DINING
        ),
        NOW,
    )

    assert query == Interpretation(
        intent=Intent.ANALYZE_EXPENSES,
        category=TransactionCategory.DINING,
        period=PeriodReference.CURRENT_MONTH,
    )


def test_prepare_derives_omitted_comparison_side(router: ReadOnlyQueryRouter) -> None:
    query = router.prepare(
        Interpretation(
            intent=Intent.COMPARE_EXPENSES,
            comparison_period=PeriodReference.PREVIOUS_WEEK,
        ),
        NOW,
    )

    assert query == Interpretation(
        intent=Intent.COMPARE_EXPENSES,
        period=PeriodReference.CURRENT_WEEK,
        comparison_period=PeriodReference.PREVIOUS_WEEK,
    )


@pytest.mark.parametrize(
    ("period", "anchored"),
    [
        (CalendarMonth(10), CalendarMonth(10, 2026)),
        (CalendarMonth(11), CalendarMonth(11, 2025)),
        (CalendarMonth(11, 2024), CalendarMonth(11, 2024)),
    ],
)
def test_prepare_anchors_calendar_months_to_a_year(
    router: ReadOnlyQueryRouter, period: CalendarMonth, anchored: CalendarMonth
) -> None:
    query = router.prepare(
        Interpretation(
            intent=Intent.COMPARE_EXPENSES,
            period=period,
            comparison_period=CalendarMonth(1),
        ),
        NOW,
    )

    assert query == Interpretation(
        intent=Intent.COMPARE_EXPENSES,
        period=anchored,
        comparison_period=CalendarMonth(1, 2026),
    )


def test_prepare_derives_previous_month_after_anchoring(
    router: ReadOnlyQueryRouter,
) -> None:
    query = router.prepare(
        Interpretation(intent=Intent.COMPARE_EXPENSES, period=CalendarMonth(1)), NOW
    )

    assert query == Interpretation(
        intent=Intent.COMPARE_EXPENSES,
        period=CalendarMonth(1, 2026),
        comparison_period=CalendarMonth(12, 2025),
    )


def test_prepare_keeps_transactions_unfiltered_by_date(
    router: ReadOnlyQueryRouter,
) -> None:
    interpretation = Interpretation(
        intent=Intent.GET_TRANSACTIONS, transaction_type=TransactionType.CREDIT
    )

    assert router.prepare(interpretation, NOW) == interpretation


# Follow-ups. NOW is Oct 31st, 22:30 in Buenos Aires.
EARLIER_TODAY = NOW - timedelta(minutes=10)
# Sep 30th in Buenos Aires: CURRENT_MONTH was September.
LAST_MONTH = datetime(2026, 9, 30, 12, 0, tzinfo=BUENOS_AIRES)
# Sunday Oct 25th: CURRENT_WEEK was the previous ISO week.
LAST_WEEK = datetime(2026, 10, 25, 12, 0, tzinfo=BUENOS_AIRES)


def context(
    intent: Intent,
    period: PeriodReference | CalendarMonth | None = None,
    *,
    comparison_period: PeriodReference | CalendarMonth | None = None,
    category: TransactionCategory | None = None,
    transaction_type: TransactionType | None = None,
    anchored_at: datetime = EARLIER_TODAY,
) -> ConversationContext:
    return ConversationContext(
        last_intent=intent,
        category=category,
        transaction_type=transaction_type,
        temporal=(
            None
            if period is None
            else TemporalContext(period, comparison_period, anchored_at)
        ),
    )


PREVIOUS = FollowUp(relative_period=RelativePeriod.PREVIOUS)


def test_previous_period_follow_up_shifts_analysis_and_keeps_category(
    router: ReadOnlyQueryRouter,
) -> None:
    last = context(
        Intent.ANALYZE_EXPENSES,
        PeriodReference.CURRENT_MONTH,
        category=TransactionCategory.GROCERIES,
    )

    resolved = router.resolve_follow_up(PREVIOUS, last, NOW)

    assert resolved == Interpretation(
        intent=Intent.ANALYZE_EXPENSES,
        category=TransactionCategory.GROCERIES,
        period=PeriodReference.PREVIOUS_MONTH,
    )


def test_stated_period_replaces_inherited_one(router: ReadOnlyQueryRouter) -> None:
    last = context(
        Intent.GET_TRANSACTIONS,
        PeriodReference.CURRENT_MONTH,
        category=TransactionCategory.DINING,
        transaction_type=TransactionType.DEBIT,
    )
    follow_up = FollowUp(period=PeriodReference.PREVIOUS_WEEK)

    resolved = router.resolve_follow_up(follow_up, last, NOW)

    assert resolved == Interpretation(
        intent=Intent.GET_TRANSACTIONS,
        category=TransactionCategory.DINING,
        transaction_type=TransactionType.DEBIT,
        period=PeriodReference.PREVIOUS_WEEK,
    )


def test_stated_values_replace_inherited_ones_and_keep_the_period(
    router: ReadOnlyQueryRouter,
) -> None:
    last = context(
        Intent.GET_TRANSACTIONS,
        PeriodReference.CURRENT_WEEK,
        category=TransactionCategory.DINING,
        transaction_type=TransactionType.DEBIT,
    )
    follow_up = FollowUp(
        category=TransactionCategory.GROCERIES,
        transaction_type=TransactionType.CREDIT,
    )

    resolved = router.resolve_follow_up(follow_up, last, NOW)

    assert resolved == Interpretation(
        intent=Intent.GET_TRANSACTIONS,
        category=TransactionCategory.GROCERIES,
        transaction_type=TransactionType.CREDIT,
        period=PeriodReference.CURRENT_WEEK,
    )


def test_follow_up_of_unfiltered_transactions_inherits_no_period(
    router: ReadOnlyQueryRouter,
) -> None:
    follow_up = FollowUp(category=TransactionCategory.FUEL)

    resolved = router.resolve_follow_up(
        follow_up, context(Intent.GET_TRANSACTIONS), NOW
    )

    assert resolved == Interpretation(
        intent=Intent.GET_TRANSACTIONS, category=TransactionCategory.FUEL
    )


def test_follow_up_without_context_is_unresolved(router: ReadOnlyQueryRouter) -> None:
    resolved = router.resolve_follow_up(PREVIOUS, EMPTY_CONTEXT, NOW)

    assert resolved == IncompleteQueryResult(
        Intent.UNKNOWN, missing_fields=frozenset({"context"})
    )


def test_follow_up_stating_nothing_is_unresolved_without_blaming_context(
    router: ReadOnlyQueryRouter,
) -> None:
    last = context(Intent.ANALYZE_EXPENSES, PeriodReference.CURRENT_MONTH)

    resolved = router.resolve_follow_up(FollowUp(), last, NOW)

    assert resolved == IncompleteQueryResult(Intent.ANALYZE_EXPENSES)


@pytest.mark.parametrize(
    ("last", "follow_up", "incompatible"),
    [
        (
            context(Intent.ANALYZE_EXPENSES, PeriodReference.CURRENT_MONTH),
            FollowUp(transaction_type=TransactionType.CREDIT),
            {"transaction_type"},
        ),
        (
            context(Intent.GET_BALANCE),
            FollowUp(period=PeriodReference.PREVIOUS_MONTH),
            {"period"},
        ),
        (context(Intent.GET_CARDS), PREVIOUS, {"period"}),
        (
            context(Intent.GET_BENEFICIARIES),
            FollowUp(category=TransactionCategory.DINING),
            {"category"},
        ),
        (
            context(Intent.GET_TRANSACTIONS, PeriodReference.CURRENT_MONTH),
            FollowUp(comparison_period=PeriodReference.PREVIOUS_MONTH),
            {"comparison_period"},
        ),
    ],
)
def test_follow_up_values_the_last_query_does_not_take_are_unresolved(
    router: ReadOnlyQueryRouter,
    last: ConversationContext,
    follow_up: FollowUp,
    incompatible: set[str],
) -> None:
    resolved = router.resolve_follow_up(follow_up, last, NOW)

    assert last.last_intent is not None
    assert resolved == IncompleteQueryResult(
        last.last_intent, unsupported_fields=frozenset(incompatible)
    )


def test_follow_up_with_unsupported_values_is_unresolved(
    router: ReadOnlyQueryRouter,
) -> None:
    last = context(Intent.ANALYZE_EXPENSES, PeriodReference.CURRENT_MONTH)
    follow_up = FollowUp(unsupported_fields=frozenset({"period"}))

    resolved = router.resolve_follow_up(follow_up, last, NOW)

    assert resolved == IncompleteQueryResult(
        Intent.ANALYZE_EXPENSES, unsupported_fields=frozenset({"period"})
    )


@pytest.mark.parametrize(
    "last",
    [
        context(Intent.GET_TRANSACTIONS),
        context(Intent.ANALYZE_EXPENSES, PeriodReference.PREVIOUS_MONTH),
        context(Intent.GET_TRANSACTIONS, PeriodReference.YESTERDAY),
    ],
)
def test_previous_period_without_a_shiftable_period_is_unresolved(
    router: ReadOnlyQueryRouter, last: ConversationContext
) -> None:
    resolved = router.resolve_follow_up(PREVIOUS, last, NOW)

    assert last.last_intent is not None
    assert resolved == IncompleteQueryResult(
        last.last_intent, missing_fields=frozenset({"period"})
    )


@pytest.mark.parametrize(
    ("period", "anchored_at"),
    [
        (PeriodReference.CURRENT_MONTH, LAST_MONTH),
        (PeriodReference.CURRENT_WEEK, LAST_WEEK),
        (PeriodReference.TODAY, NOW - timedelta(days=1)),
    ],
)
@pytest.mark.parametrize(
    "follow_up", [PREVIOUS, FollowUp(category=TransactionCategory.DINING)]
)
def test_period_from_before_a_calendar_rollover_is_not_inherited(
    router: ReadOnlyQueryRouter,
    period: PeriodReference,
    anchored_at: datetime,
    follow_up: FollowUp,
) -> None:
    last = context(Intent.ANALYZE_EXPENSES, period, anchored_at=anchored_at)

    resolved = router.resolve_follow_up(follow_up, last, NOW)

    assert resolved == IncompleteQueryResult(
        Intent.ANALYZE_EXPENSES, missing_fields=frozenset({"period"})
    )


def test_stated_period_resolves_after_a_calendar_rollover(
    router: ReadOnlyQueryRouter,
) -> None:
    last = context(
        Intent.ANALYZE_EXPENSES,
        PeriodReference.CURRENT_MONTH,
        category=TransactionCategory.GROCERIES,
        anchored_at=LAST_MONTH,
    )
    follow_up = FollowUp(period=PeriodReference.PREVIOUS_MONTH)

    resolved = router.resolve_follow_up(follow_up, last, NOW)

    assert resolved == Interpretation(
        intent=Intent.ANALYZE_EXPENSES,
        category=TransactionCategory.GROCERIES,
        period=PeriodReference.PREVIOUS_MONTH,
    )


def test_period_resolving_to_the_same_dates_is_inherited(
    router: ReadOnlyQueryRouter,
) -> None:
    # PREVIOUS_MONTH anchored on Oct 1st still means September on Oct 31st.
    anchored_at = datetime(2026, 10, 1, 0, 5, tzinfo=BUENOS_AIRES)
    last = context(
        Intent.ANALYZE_EXPENSES, PeriodReference.PREVIOUS_MONTH, anchored_at=anchored_at
    )
    follow_up = FollowUp(category=TransactionCategory.DINING)

    resolved = router.resolve_follow_up(follow_up, last, NOW)

    assert resolved == Interpretation(
        intent=Intent.ANALYZE_EXPENSES,
        category=TransactionCategory.DINING,
        period=PeriodReference.PREVIOUS_MONTH,
    )


COMPARISON = context(
    Intent.COMPARE_EXPENSES,
    PeriodReference.CURRENT_MONTH,
    comparison_period=PeriodReference.PREVIOUS_MONTH,
    category=TransactionCategory.DINING,
)


def test_comparison_follow_up_keeps_both_periods(router: ReadOnlyQueryRouter) -> None:
    follow_up = FollowUp(category=TransactionCategory.GROCERIES)

    resolved = router.resolve_follow_up(follow_up, COMPARISON, NOW)

    assert resolved == Interpretation(
        intent=Intent.COMPARE_EXPENSES,
        category=TransactionCategory.GROCERIES,
        period=PeriodReference.CURRENT_MONTH,
        comparison_period=PeriodReference.PREVIOUS_MONTH,
    )


def test_comparison_follow_up_period_rederives_the_compared_side(
    router: ReadOnlyQueryRouter,
) -> None:
    follow_up = FollowUp(period=PeriodReference.CURRENT_WEEK)

    resolved = router.resolve_follow_up(follow_up, COMPARISON, NOW)

    assert isinstance(resolved, Interpretation)
    assert router.prepare(resolved, NOW) == Interpretation(
        intent=Intent.COMPARE_EXPENSES,
        category=TransactionCategory.DINING,
        period=PeriodReference.CURRENT_WEEK,
        comparison_period=PeriodReference.PREVIOUS_WEEK,
    )


def test_comparison_follow_up_period_without_a_pair_is_incomplete(
    router: ReadOnlyQueryRouter,
) -> None:
    follow_up = FollowUp(period=PeriodReference.PREVIOUS_WEEK)

    resolved = router.resolve_follow_up(follow_up, COMPARISON, NOW)

    assert isinstance(resolved, Interpretation)
    assert router.prepare(resolved, NOW) == IncompleteQueryResult(
        Intent.COMPARE_EXPENSES, missing_fields=frozenset({"comparison_period"})
    )


def test_comparison_follow_up_with_previous_period_is_unresolved(
    router: ReadOnlyQueryRouter,
) -> None:
    resolved = router.resolve_follow_up(PREVIOUS, COMPARISON, NOW)

    assert resolved == IncompleteQueryResult(
        Intent.COMPARE_EXPENSES, unsupported_fields=frozenset({"period"})
    )


# Follow-ups that turn an expense query into a comparison.


@pytest.mark.parametrize(
    ("period", "comparison_period"),
    [
        (PeriodReference.CURRENT_MONTH, PeriodReference.PREVIOUS_MONTH),
        (CalendarMonth(9, 2026), CalendarMonth(8)),
    ],
)
def test_comparison_follow_up_compares_the_analysis_in_context(
    router: ReadOnlyQueryRouter,
    period: PeriodReference | CalendarMonth,
    comparison_period: PeriodReference | CalendarMonth,
) -> None:
    last = context(
        Intent.ANALYZE_EXPENSES, period, category=TransactionCategory.GROCERIES
    )
    follow_up = FollowUp(comparison_period=comparison_period)

    resolved = router.resolve_follow_up(follow_up, last, NOW)

    assert resolved == Interpretation(
        intent=Intent.COMPARE_EXPENSES,
        category=TransactionCategory.GROCERIES,
        period=period,
        comparison_period=comparison_period,
    )


def test_comparison_follow_up_of_an_analysis_executes_the_comparison(
    router: ReadOnlyQueryRouter, repositories: FakeRepositories
) -> None:
    last = context(
        Intent.ANALYZE_EXPENSES,
        PeriodReference.CURRENT_MONTH,
        category=TransactionCategory.GROCERIES,
    )
    follow_up = FollowUp(comparison_period=PeriodReference.PREVIOUS_MONTH)

    resolved = router.resolve_follow_up(follow_up, last, NOW)
    assert isinstance(resolved, Interpretation)
    result = route(router, repositories, resolved)

    assert isinstance(result, ExpenseComparisonResult)
    assert result.comparison.current.period == OCTOBER
    assert result.comparison.previous.period == SEPTEMBER
    assert result.comparison.current.category is TransactionCategory.GROCERIES
    [ars_comparison] = result.comparison.currencies
    assert ars_comparison.current_total == ars("30000.00")
    assert ars_comparison.previous_total == ars("20000.00")


def test_comparison_follow_up_replaces_the_compared_period(
    router: ReadOnlyQueryRouter,
) -> None:
    follow_up = FollowUp(comparison_period=CalendarMonth(8, 2026))

    resolved = router.resolve_follow_up(follow_up, COMPARISON, NOW)

    assert resolved == Interpretation(
        intent=Intent.COMPARE_EXPENSES,
        category=TransactionCategory.DINING,
        period=PeriodReference.CURRENT_MONTH,
        comparison_period=CalendarMonth(8, 2026),
    )


def test_comparison_follow_up_with_both_periods_inherits_only_the_category(
    router: ReadOnlyQueryRouter,
) -> None:
    last = context(
        Intent.ANALYZE_EXPENSES,
        PeriodReference.CURRENT_WEEK,
        category=TransactionCategory.FUEL,
    )
    follow_up = FollowUp(period=CalendarMonth(10), comparison_period=CalendarMonth(9))

    resolved = router.resolve_follow_up(follow_up, last, NOW)

    assert resolved == Interpretation(
        intent=Intent.COMPARE_EXPENSES,
        category=TransactionCategory.FUEL,
        period=CalendarMonth(10),
        comparison_period=CalendarMonth(9),
    )


def test_comparison_follow_up_does_not_inherit_a_stale_period(
    router: ReadOnlyQueryRouter,
) -> None:
    last = context(
        Intent.ANALYZE_EXPENSES, PeriodReference.CURRENT_MONTH, anchored_at=LAST_MONTH
    )
    follow_up = FollowUp(comparison_period=PeriodReference.PREVIOUS_MONTH)

    resolved = router.resolve_follow_up(follow_up, last, NOW)

    assert resolved == IncompleteQueryResult(
        Intent.COMPARE_EXPENSES, missing_fields=frozenset({"period"})
    )


def test_previous_period_follow_up_shifts_a_calendar_month(
    router: ReadOnlyQueryRouter,
) -> None:
    last = context(Intent.ANALYZE_EXPENSES, CalendarMonth(1, 2026))

    resolved = router.resolve_follow_up(PREVIOUS, last, NOW)

    assert resolved == Interpretation(
        intent=Intent.ANALYZE_EXPENSES, period=CalendarMonth(12, 2025)
    )


def test_calendar_month_in_context_is_never_stale(
    router: ReadOnlyQueryRouter,
) -> None:
    last = context(
        Intent.ANALYZE_EXPENSES, CalendarMonth(9, 2026), anchored_at=LAST_MONTH
    )
    follow_up = FollowUp(category=TransactionCategory.DINING)

    resolved = router.resolve_follow_up(follow_up, last, NOW)

    assert resolved == Interpretation(
        intent=Intent.ANALYZE_EXPENSES,
        category=TransactionCategory.DINING,
        period=CalendarMonth(9, 2026),
    )
