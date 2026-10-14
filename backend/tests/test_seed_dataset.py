from collections import defaultdict
from datetime import date
from decimal import Decimal
from uuid import UUID

import pytest
from pydantic import SecretStr

from mimi.config import AppEnvironment, Settings
from mimi.domain.enums import (
    AccountStatus,
    CardBrand,
    CardStatus,
    CardType,
    Currency,
    TransactionCategory,
    TransactionType,
)
from mimi.infrastructure.database import seed as seed_module
from mimi.infrastructure.database.models import TransactionModel
from mimi.infrastructure.database.seed import (
    BUENOS_AIRES,
    MAIN_ACCOUNT_BALANCE,
    MAIN_ACCOUNT_ID,
    ProductionEnvironmentError,
    SeedDataset,
    add_months,
    build_dataset,
    run,
    seed_id,
)

REFERENCE_DATE = date(2026, 10, 13)

# Mid-month, month start, 31-day month end, year boundary, a window starting
# in February of a common and of a leap year, and a leap day.
REPRESENTATIVE_DATES = [
    date(2026, 10, 13),
    date(2026, 11, 1),
    date(2026, 12, 31),
    date(2027, 1, 15),
    date(2027, 5, 31),
    date(2028, 2, 29),
    date(2028, 5, 31),
]


@pytest.fixture
def dataset() -> SeedDataset:
    return build_dataset(REFERENCE_DATE)


def local_date(transaction: TransactionModel) -> date:
    return transaction.occurred_at.astimezone(BUENOS_AIRES).date()


def debit_totals_by_category(
    dataset: SeedDataset, month: tuple[int, int]
) -> dict[TransactionCategory, Decimal]:
    totals: dict[TransactionCategory, Decimal] = defaultdict(Decimal)
    for transaction in dataset.transactions:
        on = local_date(transaction)
        if (on.year, on.month) == month and transaction.type is TransactionType.DEBIT:
            totals[transaction.category] += transaction.amount
    return totals


def test_dataset_contents(dataset: SeedDataset) -> None:
    assert (dataset.customer.first_name, dataset.customer.last_name) == (
        "Valentina",
        "Ruiz",
    )
    assert [
        (account.name, account.currency, account.balance, account.status)
        for account in dataset.accounts
    ] == [
        ("Cuenta principal", Currency.ARS, Decimal("1236480.75"), AccountStatus.ACTIVE),
        (
            "Caja de ahorro en dólares",
            Currency.USD,
            Decimal("2450.00"),
            AccountStatus.ACTIVE,
        ),
    ]
    assert [
        (card.type, card.brand, card.last_four, card.status, card.account_id)
        for card in dataset.cards
    ] == [
        (CardType.DEBIT, CardBrand.VISA, "4821", CardStatus.ACTIVE, MAIN_ACCOUNT_ID),
        (
            CardType.CREDIT,
            CardBrand.MASTERCARD,
            "5307",
            CardStatus.ACTIVE,
            MAIN_ACCOUNT_ID,
        ),
        (CardType.CREDIT, CardBrand.VISA, "9134", CardStatus.FROZEN, MAIN_ACCOUNT_ID),
    ]
    assert len(dataset.transactions) == 89


def test_beneficiaries_are_five_with_distinct_first_names(
    dataset: SeedDataset,
) -> None:
    names = [beneficiary.name for beneficiary in dataset.beneficiaries]

    assert len(names) == 5
    assert "Laura Gómez" in names
    assert len({name.split()[0] for name in names}) == 5
    assert [b.bank_name for b in dataset.beneficiaries].count(None) == 1


def test_transactions_cover_the_three_months_before_reference_date(
    dataset: SeedDataset,
) -> None:
    dates = [local_date(transaction) for transaction in dataset.transactions]

    assert min(dates) >= date(2026, 7, 13)
    assert max(dates) < REFERENCE_DATE
    assert all(t.occurred_at.tzinfo is not None for t in dataset.transactions)
    assert dataset.transactions == sorted(
        dataset.transactions, key=lambda t: (t.occurred_at, str(t.id))
    )


def test_transactions_are_well_formed(dataset: SeedDataset) -> None:
    for transaction in dataset.transactions:
        assert transaction.account_id == MAIN_ACCOUNT_ID
        assert transaction.currency is Currency.ARS
        assert transaction.amount > 0
        assert transaction.amount.as_tuple().exponent == -2
        assert transaction.transfer_id is None
        assert transaction.description.strip()


def test_transactions_support_filtering_and_analysis(dataset: SeedDataset) -> None:
    categories = {transaction.category for transaction in dataset.transactions}
    assert categories == set(TransactionCategory) - {TransactionCategory.TRANSFER}

    for month in [(2026, 8), (2026, 9)]:
        types = {
            t.type
            for t in dataset.transactions
            if (local_date(t).year, local_date(t).month) == month
        }
        assert types == {TransactionType.DEBIT, TransactionType.CREDIT}

    refunds = [
        t
        for t in dataset.transactions
        if t.type is TransactionType.CREDIT
        and t.category is TransactionCategory.SHOPPING
    ]
    assert len(refunds) == 1

    last_month = debit_totals_by_category(dataset, (2026, 9))
    month_before = debit_totals_by_category(dataset, (2026, 8))
    assert last_month != month_before
    assert sum(last_month.values()) != sum(month_before.values())
    assert max(last_month, key=last_month.__getitem__) is not TransactionCategory.OTHER


def test_dataset_is_deterministic(dataset: SeedDataset) -> None:
    def snapshot(data: SeedDataset) -> list[tuple[object, ...]]:
        return [
            (t.id, t.amount, t.type, t.category, t.description, t.occurred_at)
            for t in data.transactions
        ]

    assert snapshot(build_dataset(REFERENCE_DATE)) == snapshot(dataset)
    assert dataset.customer.id == UUID("0e275bc8-90cc-5472-a99f-ad4a4bdb416f")
    assert MAIN_ACCOUNT_ID == UUID("8a8af4c0-4b88-5fd2-bc99-fa08e17c211b")
    assert seed_id("card:visa-debit") == UUID("11b9a0ca-0913-52a9-b051-cbcb757e09f6")


def test_identifiers_are_unique(dataset: SeedDataset) -> None:
    ids = [
        dataset.customer.id,
        *(account.id for account in dataset.accounts),
        *(card.id for card in dataset.cards),
        *(beneficiary.id for beneficiary in dataset.beneficiaries),
        *(transaction.id for transaction in dataset.transactions),
    ]

    assert len(ids) == len(set(ids))


@pytest.mark.parametrize(
    ("day", "months", "expected"),
    [
        (date(2026, 10, 13), -3, date(2026, 7, 13)),
        (date(2027, 1, 15), -3, date(2026, 10, 15)),
        (date(2027, 5, 31), -3, date(2027, 2, 28)),
        (date(2028, 5, 31), -3, date(2028, 2, 29)),
        (date(2026, 12, 31), -1, date(2026, 11, 30)),
    ],
)
def test_add_months_clamps_to_shorter_months(
    day: date, months: int, expected: date
) -> None:
    assert add_months(day, months) == expected


@pytest.mark.parametrize("reference_date", REPRESENTATIVE_DATES)
def test_history_reconciles_with_persisted_balance(reference_date: date) -> None:
    dataset = build_dataset(reference_date)
    window_start = add_months(reference_date, -3)

    assert dataset.main_account_opening_balance >= 0
    running = dataset.main_account_opening_balance
    for transaction in dataset.transactions:
        assert window_start <= local_date(transaction) < reference_date
        if transaction.type is TransactionType.CREDIT:
            running += transaction.amount
        else:
            running -= transaction.amount
        assert running >= 0
    assert running == MAIN_ACCOUNT_BALANCE
    assert 85 <= len(dataset.transactions) <= 95


def test_history_that_would_overdraw_is_rejected(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    monkeypatch.setattr(seed_module, "MAIN_ACCOUNT_BALANCE", Decimal("0.00"))

    with pytest.raises(ValueError):
        build_dataset(REFERENCE_DATE)


def test_seeding_is_refused_in_production() -> None:
    settings = Settings(
        _env_file=None,
        environment=AppEnvironment.PRODUCTION,
        database_url=SecretStr("postgresql+psycopg://mimi:mimi@localhost:5432/mimi"),
    )

    with pytest.raises(ProductionEnvironmentError):
        run(settings, REFERENCE_DATE, reset=False)
