from collections.abc import Iterator
from dataclasses import dataclass
from datetime import UTC, datetime, timedelta, timezone
from decimal import Decimal
from uuid import UUID, uuid4

import pytest
from sqlalchemy import Engine, select
from sqlalchemy.exc import OperationalError
from sqlalchemy.orm import Session, sessionmaker

from mimi.application.repositories import TransactionQuery
from mimi.domain.entities import Account, Money, Transaction, Transfer
from mimi.domain.enums import (
    AccountStatus,
    CardBrand,
    CardStatus,
    CardType,
    Currency,
    TransactionCategory,
    TransactionType,
    TransferStatus,
)
from mimi.infrastructure.database.base import Base
from mimi.infrastructure.database.models import (
    AccountModel,
    BeneficiaryModel,
    CardModel,
    CustomerModel,
    TransactionModel,
    TransferModel,
)
from mimi.infrastructure.database.repositories import (
    PostgresAccountRepository,
    PostgresBeneficiaryRepository,
    PostgresCardRepository,
    PostgresTransactionRepository,
    PostgresTransferRepository,
)
from mimi.infrastructure.database.session import create_session_factory

pytestmark = pytest.mark.integration

# DB-04 replaces create_all with the initial Alembic migration.

BUENOS_AIRES = timezone(timedelta(hours=-3))
OCTOBER_1 = datetime(2026, 10, 1, tzinfo=BUENOS_AIRES)


@pytest.fixture
def session_factory(test_engine: Engine) -> Iterator[sessionmaker[Session]]:
    Base.metadata.create_all(test_engine)
    try:
        yield create_session_factory(test_engine)
    finally:
        Base.metadata.drop_all(test_engine)


@dataclass(frozen=True)
class Dataset:
    customer_id: UUID
    other_customer_id: UUID
    savings_id: UUID
    dollars_id: UUID
    other_account_id: UUID
    visa_id: UUID
    mastercard_id: UUID
    other_card_id: UUID
    laura_id: UUID
    bruno_id: UUID
    other_beneficiary_id: UUID
    groceries_id: UUID
    dining_id: UUID
    salary_id: UUID
    september_groceries_id: UUID


def _transaction(
    account: AccountModel,
    amount: str,
    type: TransactionType,
    category: TransactionCategory,
    occurred_at: datetime,
) -> TransactionModel:
    return TransactionModel(
        id=uuid4(),
        account=account,
        amount=Decimal(amount),
        currency=account.currency,
        type=type,
        category=category,
        description=category.value.title(),
        occurred_at=occurred_at,
    )


@pytest.fixture
def dataset(session_factory: sessionmaker[Session]) -> Dataset:
    customer = CustomerModel(id=uuid4(), first_name="Ana", last_name="García")
    other_customer = CustomerModel(id=uuid4(), first_name="Otro", last_name="Cliente")
    savings = AccountModel(
        id=uuid4(),
        customer=customer,
        name="Caja de ahorro",
        balance=Decimal("150000.50"),
        currency=Currency.ARS,
        status=AccountStatus.ACTIVE,
    )
    dollars = AccountModel(
        id=uuid4(),
        customer=customer,
        name="Cuenta en dólares",
        balance=Decimal("10.00"),
        currency=Currency.USD,
        status=AccountStatus.INACTIVE,
    )
    other_account = AccountModel(
        id=uuid4(),
        customer=other_customer,
        name="Another account",
        balance=Decimal("1.00"),
        currency=Currency.ARS,
        status=AccountStatus.ACTIVE,
    )
    visa = CardModel(
        id=uuid4(),
        account=savings,
        type=CardType.DEBIT,
        brand=CardBrand.VISA,
        last_four="4821",
        status=CardStatus.ACTIVE,
    )
    mastercard = CardModel(
        id=uuid4(),
        account=dollars,
        type=CardType.CREDIT,
        brand=CardBrand.MASTERCARD,
        last_four="1234",
        status=CardStatus.FROZEN,
    )
    other_card = CardModel(
        id=uuid4(),
        account=other_account,
        type=CardType.DEBIT,
        brand=CardBrand.VISA,
        last_four="9999",
        status=CardStatus.ACTIVE,
    )
    laura = BeneficiaryModel(
        id=uuid4(),
        customer=customer,
        name="Laura",
        account_reference="0000003100012345678901",
        bank_name=None,
    )
    bruno = BeneficiaryModel(
        id=uuid4(),
        customer=customer,
        name="Bruno",
        account_reference="0000003100098765432109",
        bank_name="Banco Sintético",
    )
    other_beneficiary = BeneficiaryModel(
        id=uuid4(),
        customer=other_customer,
        name="Zoe",
        account_reference="0000003100011111111111",
        bank_name=None,
    )
    groceries = _transaction(
        savings,
        "1200.10",
        TransactionType.DEBIT,
        TransactionCategory.GROCERIES,
        OCTOBER_1 + timedelta(days=5),
    )
    dining = _transaction(
        savings,
        "8500.00",
        TransactionType.DEBIT,
        TransactionCategory.DINING,
        OCTOBER_1 + timedelta(days=3),
    )
    salary = _transaction(
        savings,
        "900000.00",
        TransactionType.CREDIT,
        TransactionCategory.OTHER,
        OCTOBER_1,
    )
    september_groceries = _transaction(
        savings,
        "3000.00",
        TransactionType.DEBIT,
        TransactionCategory.GROCERIES,
        OCTOBER_1 - timedelta(microseconds=1),
    )
    other_transaction = _transaction(
        other_account,
        "5.00",
        TransactionType.DEBIT,
        TransactionCategory.GROCERIES,
        OCTOBER_1 + timedelta(days=1),
    )
    with session_factory.begin() as session:
        session.add_all(
            [
                customer,
                other_customer,
                groceries,
                dining,
                salary,
                september_groceries,
                other_transaction,
                visa,
                mastercard,
                other_card,
                laura,
                bruno,
                other_beneficiary,
            ]
        )
    return Dataset(
        customer_id=customer.id,
        other_customer_id=other_customer.id,
        savings_id=savings.id,
        dollars_id=dollars.id,
        other_account_id=other_account.id,
        visa_id=visa.id,
        mastercard_id=mastercard.id,
        other_card_id=other_card.id,
        laura_id=laura.id,
        bruno_id=bruno.id,
        other_beneficiary_id=other_beneficiary.id,
        groceries_id=groceries.id,
        dining_id=dining.id,
        salary_id=salary.id,
        september_groceries_id=september_groceries.id,
    )


# Accounts


def test_accounts_are_listed_for_customer_only(
    session_factory: sessionmaker[Session], dataset: Dataset
) -> None:
    with session_factory() as session:
        accounts = PostgresAccountRepository(session).list_by_customer(
            dataset.customer_id
        )

    assert accounts == [
        Account(
            id=dataset.savings_id,
            customer_id=dataset.customer_id,
            name="Caja de ahorro",
            balance=Money(Decimal("150000.50"), Currency.ARS),
            status=AccountStatus.ACTIVE,
        ),
        Account(
            id=dataset.dollars_id,
            customer_id=dataset.customer_id,
            name="Cuenta en dólares",
            balance=Money(Decimal("10.00"), Currency.USD),
            status=AccountStatus.INACTIVE,
        ),
    ]
    assert isinstance(accounts[0].balance.amount, Decimal)


def test_accounts_of_unknown_customer_are_empty(
    session_factory: sessionmaker[Session], dataset: Dataset
) -> None:
    with session_factory() as session:
        assert PostgresAccountRepository(session).list_by_customer(uuid4()) == []


def test_get_for_update_returns_owned_account_only(
    session_factory: sessionmaker[Session], dataset: Dataset
) -> None:
    with session_factory() as session:
        repository = PostgresAccountRepository(session)

        account = repository.get_for_update(dataset.customer_id, dataset.savings_id)
        assert account is not None
        assert account.balance == Money(Decimal("150000.50"), Currency.ARS)
        assert (
            repository.get_for_update(dataset.customer_id, dataset.other_account_id)
            is None
        )
        assert repository.get_for_update(dataset.customer_id, uuid4()) is None


def test_get_for_update_locks_account_until_transaction_ends(
    session_factory: sessionmaker[Session], dataset: Dataset
) -> None:
    locked_row = (
        select(AccountModel)
        .where(AccountModel.id == dataset.savings_id)
        .with_for_update(nowait=True)
    )

    with session_factory() as holder, session_factory() as contender:
        PostgresAccountRepository(holder).get_for_update(
            dataset.customer_id, dataset.savings_id
        )
        with pytest.raises(OperationalError):
            contender.execute(locked_row)
        contender.rollback()

        holder.rollback()
        assert contender.scalars(locked_row).one().id == dataset.savings_id


def test_update_balance_persists(
    session_factory: sessionmaker[Session], dataset: Dataset
) -> None:
    with session_factory.begin() as session:
        PostgresAccountRepository(session).update_balance(
            dataset.savings_id, Money(Decimal("125000.49"), Currency.ARS)
        )

    with session_factory() as session:
        account = PostgresAccountRepository(session).get_for_update(
            dataset.customer_id, dataset.savings_id
        )

    assert account is not None
    assert account.balance == Money(Decimal("125000.49"), Currency.ARS)


# Cards


def test_cards_are_listed_for_customer_only(
    session_factory: sessionmaker[Session], dataset: Dataset
) -> None:
    with session_factory() as session:
        cards = PostgresCardRepository(session).list_by_customer(dataset.customer_id)

    assert [card.id for card in cards] == [dataset.mastercard_id, dataset.visa_id]
    assert (cards[1].account_id, cards[1].type, cards[1].last_four) == (
        dataset.savings_id,
        CardType.DEBIT,
        "4821",
    )


def test_cards_of_unknown_customer_are_empty(
    session_factory: sessionmaker[Session], dataset: Dataset
) -> None:
    with session_factory() as session:
        assert PostgresCardRepository(session).list_by_customer(uuid4()) == []


def test_get_card_returns_owned_card_only(
    session_factory: sessionmaker[Session], dataset: Dataset
) -> None:
    with session_factory() as session:
        repository = PostgresCardRepository(session)

        card = repository.get(dataset.customer_id, dataset.visa_id)
        assert card is not None
        assert (card.brand, card.status) == (CardBrand.VISA, CardStatus.ACTIVE)
        assert repository.get(dataset.customer_id, dataset.other_card_id) is None
        assert repository.get(dataset.customer_id, uuid4()) is None


def test_card_status_changes_are_persisted(
    session_factory: sessionmaker[Session], dataset: Dataset
) -> None:
    for status in (CardStatus.FROZEN, CardStatus.ACTIVE):
        with session_factory.begin() as session:
            PostgresCardRepository(session).update_status(dataset.visa_id, status)

        with session_factory() as session:
            card = PostgresCardRepository(session).get(
                dataset.customer_id, dataset.visa_id
            )

        assert card is not None
        assert card.status is status


# Beneficiaries


def test_beneficiaries_are_listed_for_customer_only(
    session_factory: sessionmaker[Session], dataset: Dataset
) -> None:
    with session_factory() as session:
        beneficiaries = PostgresBeneficiaryRepository(session).list_by_customer(
            dataset.customer_id
        )

    assert [(b.id, b.name, b.bank_name) for b in beneficiaries] == [
        (dataset.bruno_id, "Bruno", "Banco Sintético"),
        (dataset.laura_id, "Laura", None),
    ]


def test_beneficiaries_of_unknown_customer_are_empty(
    session_factory: sessionmaker[Session], dataset: Dataset
) -> None:
    with session_factory() as session:
        assert PostgresBeneficiaryRepository(session).list_by_customer(uuid4()) == []


def test_get_beneficiary_returns_owned_beneficiary_only(
    session_factory: sessionmaker[Session], dataset: Dataset
) -> None:
    with session_factory() as session:
        repository = PostgresBeneficiaryRepository(session)

        beneficiary = repository.get(dataset.customer_id, dataset.laura_id)
        assert beneficiary is not None
        assert beneficiary.account_reference == "0000003100012345678901"
        assert repository.get(dataset.customer_id, dataset.other_beneficiary_id) is None
        assert repository.get(dataset.customer_id, uuid4()) is None


# Transactions


def _list_transaction_ids(
    session_factory: sessionmaker[Session], customer_id: UUID, query: TransactionQuery
) -> list[UUID]:
    with session_factory() as session:
        transactions = PostgresTransactionRepository(session).list_by_customer(
            customer_id, query
        )
    return [transaction.id for transaction in transactions]


def test_transactions_are_listed_newest_first_for_customer_only(
    session_factory: sessionmaker[Session], dataset: Dataset
) -> None:
    assert _list_transaction_ids(
        session_factory, dataset.customer_id, TransactionQuery()
    ) == [
        dataset.groceries_id,
        dataset.dining_id,
        dataset.salary_id,
        dataset.september_groceries_id,
    ]


def test_transactions_are_mapped_with_exact_amounts_and_aware_datetimes(
    session_factory: sessionmaker[Session], dataset: Dataset
) -> None:
    with session_factory() as session:
        transactions = PostgresTransactionRepository(session).list_by_customer(
            dataset.customer_id, TransactionQuery(limit=1)
        )

    assert transactions == [
        Transaction(
            id=dataset.groceries_id,
            account_id=dataset.savings_id,
            amount=Money(Decimal("1200.10"), Currency.ARS),
            type=TransactionType.DEBIT,
            category=TransactionCategory.GROCERIES,
            description="Groceries",
            occurred_at=OCTOBER_1 + timedelta(days=5),
            transfer_id=None,
        )
    ]
    assert transactions[0].occurred_at.tzinfo is not None


def test_transaction_period_is_half_open(
    session_factory: sessionmaker[Session], dataset: Dataset
) -> None:
    # The same instants expressed in UTC select the same Buenos Aires records.
    query = TransactionQuery(
        occurred_from=OCTOBER_1.astimezone(UTC),
        occurred_to=(OCTOBER_1 + timedelta(days=5)).astimezone(UTC),
    )

    assert _list_transaction_ids(session_factory, dataset.customer_id, query) == [
        dataset.dining_id,
        dataset.salary_id,
    ]


def test_transactions_are_filtered_by_category(
    session_factory: sessionmaker[Session], dataset: Dataset
) -> None:
    query = TransactionQuery(category=TransactionCategory.GROCERIES)

    assert _list_transaction_ids(session_factory, dataset.customer_id, query) == [
        dataset.groceries_id,
        dataset.september_groceries_id,
    ]


def test_transactions_are_filtered_by_type(
    session_factory: sessionmaker[Session], dataset: Dataset
) -> None:
    query = TransactionQuery(type=TransactionType.CREDIT)

    assert _list_transaction_ids(session_factory, dataset.customer_id, query) == [
        dataset.salary_id
    ]


def test_transaction_limit_keeps_newest(
    session_factory: sessionmaker[Session], dataset: Dataset
) -> None:
    query = TransactionQuery(limit=2)

    assert _list_transaction_ids(session_factory, dataset.customer_id, query) == [
        dataset.groceries_id,
        dataset.dining_id,
    ]


def test_transaction_filters_combine(
    session_factory: sessionmaker[Session], dataset: Dataset
) -> None:
    query = TransactionQuery(
        occurred_from=OCTOBER_1,
        category=TransactionCategory.GROCERIES,
        type=TransactionType.DEBIT,
    )

    assert _list_transaction_ids(session_factory, dataset.customer_id, query) == [
        dataset.groceries_id
    ]


def test_transactions_without_matches_are_empty(
    session_factory: sessionmaker[Session], dataset: Dataset
) -> None:
    query = TransactionQuery(category=TransactionCategory.FUEL)

    assert _list_transaction_ids(session_factory, dataset.customer_id, query) == []
    assert _list_transaction_ids(session_factory, uuid4(), TransactionQuery()) == []


# Transfers


def test_completed_transfer_is_persisted_with_its_transaction(
    session_factory: sessionmaker[Session], dataset: Dataset
) -> None:
    executed_at = OCTOBER_1 + timedelta(days=6)
    amount = Money(Decimal("25000.00"), Currency.ARS)
    transfer = Transfer(
        id=uuid4(),
        source_account_id=dataset.savings_id,
        beneficiary_id=dataset.laura_id,
        amount=amount,
        status=TransferStatus.COMPLETED,
        created_at=executed_at,
        executed_at=executed_at,
    )
    transaction = Transaction(
        id=uuid4(),
        account_id=dataset.savings_id,
        amount=amount,
        type=TransactionType.DEBIT,
        category=TransactionCategory.TRANSFER,
        description="Transfer to Laura",
        occurred_at=executed_at,
        transfer_id=transfer.id,
    )

    with session_factory.begin() as session:
        PostgresTransferRepository(session).add(transfer, transaction)

    with session_factory() as session:
        stored = session.get_one(TransferModel, transfer.id)
        transactions = PostgresTransactionRepository(session).list_by_customer(
            dataset.customer_id, TransactionQuery(limit=1)
        )

        assert (stored.amount, stored.currency, stored.status) == (
            Decimal("25000.00"),
            Currency.ARS,
            TransferStatus.COMPLETED,
        )
        assert stored.executed_at == executed_at
    assert transactions == [transaction]


def test_failed_transfer_is_persisted_without_transaction(
    session_factory: sessionmaker[Session], dataset: Dataset
) -> None:
    transfer = Transfer(
        id=uuid4(),
        source_account_id=dataset.savings_id,
        beneficiary_id=dataset.laura_id,
        amount=Money(Decimal("25000.00"), Currency.ARS),
        status=TransferStatus.FAILED,
        created_at=OCTOBER_1,
        executed_at=None,
    )

    with session_factory.begin() as session:
        PostgresTransferRepository(session).add(transfer, None)

    with session_factory() as session:
        stored = session.get_one(TransferModel, transfer.id)
        linked = session.scalars(
            select(TransactionModel).where(TransactionModel.transfer_id == transfer.id)
        ).all()

        assert stored.status is TransferStatus.FAILED
        assert stored.executed_at is None
        assert linked == []
