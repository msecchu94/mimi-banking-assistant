from dataclasses import dataclass
from datetime import datetime, timedelta, timezone
from decimal import Decimal
from uuid import uuid4

import pytest
from sqlalchemy import Engine, select, text
from sqlalchemy.exc import IntegrityError, InvalidRequestError
from sqlalchemy.orm import Session, selectinload, sessionmaker

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
from mimi.infrastructure.database.models import (
    AccountModel,
    BeneficiaryModel,
    CardModel,
    CustomerModel,
    TransactionModel,
    TransferModel,
)
from mimi.infrastructure.database.session import create_session_factory

pytestmark = pytest.mark.integration


@pytest.fixture
def session_factory(migrated_engine: Engine) -> sessionmaker[Session]:
    return create_session_factory(migrated_engine)


@dataclass(frozen=True)
class FinancialRecords:
    customer: CustomerModel
    account: AccountModel
    card: CardModel
    beneficiary: BeneficiaryModel
    transfer: TransferModel
    transfer_transaction: TransactionModel
    purchase: TransactionModel


EXECUTED_AT = datetime(2026, 10, 9, 13, 31, 4, tzinfo=timezone(timedelta(hours=-3)))


def build_records() -> FinancialRecords:
    customer = CustomerModel(id=uuid4(), first_name="Ana", last_name="García")
    account = AccountModel(
        id=uuid4(),
        customer=customer,
        name="Caja de ahorro",
        balance=Decimal("150000.50"),
        currency=Currency.ARS,
        status=AccountStatus.ACTIVE,
    )
    card = CardModel(
        id=uuid4(),
        account=account,
        type=CardType.DEBIT,
        brand=CardBrand.VISA,
        last_four="4821",
        status=CardStatus.ACTIVE,
    )
    beneficiary = BeneficiaryModel(
        id=uuid4(),
        customer=customer,
        name="Laura",
        account_reference="0000003100012345678901",
        bank_name=None,
    )
    transfer = TransferModel(
        id=uuid4(),
        source_account=account,
        beneficiary=beneficiary,
        amount=Decimal("25000.00"),
        currency=Currency.ARS,
        status=TransferStatus.COMPLETED,
        created_at=EXECUTED_AT,
        executed_at=EXECUTED_AT,
    )
    transfer_transaction = TransactionModel(
        id=uuid4(),
        account=account,
        transfer=transfer,
        amount=Decimal("25000.00"),
        currency=Currency.ARS,
        type=TransactionType.DEBIT,
        category=TransactionCategory.TRANSFER,
        description="Transfer to Laura",
        occurred_at=EXECUTED_AT,
    )
    purchase = TransactionModel(
        id=uuid4(),
        account=account,
        amount=Decimal("0.01"),
        currency=Currency.ARS,
        type=TransactionType.CREDIT,
        category=TransactionCategory.OTHER,
        description="Refund",
        occurred_at=EXECUTED_AT - timedelta(days=1),
    )
    return FinancialRecords(
        customer, account, card, beneficiary, transfer, transfer_transaction, purchase
    )


@pytest.fixture
def records(session_factory: sessionmaker[Session]) -> FinancialRecords:
    records = build_records()
    with session_factory.begin() as session:
        session.add(records.customer)
    return records


def test_financial_records_round_trip(
    session_factory: sessionmaker[Session], records: FinancialRecords
) -> None:
    with session_factory() as session:
        account = session.get_one(AccountModel, records.account.id)
        card = session.get_one(CardModel, records.card.id)
        beneficiary = session.get_one(BeneficiaryModel, records.beneficiary.id)
        transfer = session.get_one(TransferModel, records.transfer.id)
        transaction = session.get_one(TransactionModel, records.transfer_transaction.id)

        assert account.customer_id == records.customer.id
        assert account.balance == Decimal("150000.50")
        assert isinstance(account.balance, Decimal)
        assert account.currency is Currency.ARS
        assert account.status is AccountStatus.ACTIVE
        assert (card.type, card.brand, card.status) == (
            CardType.DEBIT,
            CardBrand.VISA,
            CardStatus.ACTIVE,
        )
        assert card.last_four == "4821"
        assert beneficiary.bank_name is None
        assert transfer.status is TransferStatus.COMPLETED
        assert transfer.amount == Decimal("25000.00")
        assert transfer.executed_at == EXECUTED_AT
        assert transfer.executed_at is not None
        assert transfer.executed_at.tzinfo is not None
        assert transaction.transfer_id == records.transfer.id
        assert transaction.occurred_at == EXECUTED_AT
        assert transaction.occurred_at.tzinfo is not None


def test_relationships_require_explicit_loading(
    session_factory: sessionmaker[Session], records: FinancialRecords
) -> None:
    with session_factory() as session:
        customer = session.get_one(CustomerModel, records.customer.id)
        with pytest.raises(InvalidRequestError):
            _ = customer.accounts

    with session_factory() as session:
        customer = session.scalars(
            select(CustomerModel)
            .where(CustomerModel.id == records.customer.id)
            .options(selectinload(CustomerModel.accounts))
        ).one()

        assert [account.id for account in customer.accounts] == [records.account.id]


@pytest.mark.parametrize(
    "statement",
    [
        "UPDATE accounts SET balance = -0.01",
        "UPDATE transactions SET amount = 0",
        "UPDATE transfers SET amount = 0",
        "UPDATE accounts SET currency = 'EUR'",
        "UPDATE transfers SET currency = 'EUR'",
        "UPDATE transactions SET currency = 'EUR'",
        "UPDATE accounts SET status = 'CLOSED'",
        "UPDATE cards SET brand = 'AMEX'",
        "UPDATE cards SET status = 'CLOSED'",
        "UPDATE cards SET type = 'CHARGE'",
        "UPDATE transactions SET category = 'TRAVEL'",
        "UPDATE transfers SET status = 'PENDING'",
        "UPDATE cards SET last_four = '12a4'",
        "UPDATE cards SET last_four = '123'",
        "UPDATE transactions SET category = 'DINING' WHERE transfer_id IS NOT NULL",
        "UPDATE transactions SET type = 'CREDIT' WHERE transfer_id IS NOT NULL",
        "UPDATE transactions SET transfer_id = (SELECT id FROM transfers)",
        "UPDATE cards SET account_id = gen_random_uuid()",
        "UPDATE transfers SET beneficiary_id = gen_random_uuid()",
        "UPDATE customers SET first_name = NULL",
        "UPDATE transactions SET occurred_at = NULL",
    ],
)
def test_database_rejects_invalid_financial_state(
    test_engine: Engine, records: FinancialRecords, statement: str
) -> None:
    with pytest.raises(IntegrityError), test_engine.begin() as connection:
        connection.execute(text(statement))


def test_transaction_without_transfer_may_have_any_category_and_type(
    session_factory: sessionmaker[Session], records: FinancialRecords
) -> None:
    with session_factory() as session:
        purchase = session.get_one(TransactionModel, records.purchase.id)

        assert purchase.transfer_id is None
        assert purchase.type is TransactionType.CREDIT
        assert purchase.category is TransactionCategory.OTHER
