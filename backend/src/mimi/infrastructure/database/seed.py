"""Deterministic synthetic dataset for the V1 demo.

Usage:
    python -m mimi.infrastructure.database.seed [--reference-date YYYY-MM-DD] [--reset]

The database must already be migrated. Transactions cover the three months
before the reference date; the same reference date always produces the same
data. Account balances are fixed, and the balance before the seeded window is
derived so that replaying the transactions reproduces them.
"""

import argparse
import calendar
import sys
from collections.abc import Sequence
from dataclasses import dataclass
from datetime import date, datetime, time, timedelta, timezone
from decimal import Decimal
from itertools import accumulate
from uuid import UUID, uuid5

from sqlalchemy import delete, select
from sqlalchemy.orm import Session, sessionmaker

from mimi.config import AppEnvironment, Settings, get_settings
from mimi.domain.enums import (
    AccountStatus,
    CardBrand,
    CardStatus,
    CardType,
    Currency,
    TransactionCategory,
    TransactionType,
)
from mimi.infrastructure.database.models import (
    AccountModel,
    BeneficiaryModel,
    CardModel,
    ConversationModel,
    CustomerModel,
    MessageModel,
    TransactionModel,
    TransferModel,
)
from mimi.infrastructure.database.session import (
    create_db_engine,
    create_session_factory,
)

SEED_NAMESPACE = UUID("6f1d3c0e-5b7a-4c1e-9a52-3d8e7f4b2a10")

# Argentina observes no daylight saving time, so a fixed offset is exact.
BUENOS_AIRES = timezone(timedelta(hours=-3))

HISTORY_MONTHS = 3

MAIN_ACCOUNT_BALANCE = Decimal("1236480.75")
USD_SAVINGS_BALANCE = Decimal("2450.00")


def seed_id(key: str) -> UUID:
    return uuid5(SEED_NAMESPACE, key)


CUSTOMER_ID = seed_id("customer:valentina-ruiz")
MAIN_ACCOUNT_ID = seed_id("account:main")
USD_SAVINGS_ID = seed_id("account:usd-savings")

_CREDIT = TransactionType.CREDIT
_DEBIT = TransactionType.DEBIT
_C = TransactionCategory


@dataclass(frozen=True)
class MonthlyEntry:
    """A transaction template; amounts are for months M-3, M-2, M-1 and M."""

    key: str
    day: int
    at: time
    category: TransactionCategory
    type: TransactionType
    description: str
    amounts: tuple[str | None, str | None, str | None, str | None]


# fmt: off
MAIN_ACCOUNT_ENTRIES: tuple[MonthlyEntry, ...] = (
    # Income
    MonthlyEntry("salary", 1, time(9, 0), _C.OTHER, _CREDIT,
                 "Sueldo — Estudio Contable Norte",
                 ("1000000.00", "1000000.00", "1000000.00", "1000000.00")),
    MonthlyEntry("freelance", 18, time(15, 30), _C.OTHER, _CREDIT,
                 "Pago freelance — Diseño web",
                 (None, "180000.00", None, "150000.00")),
    MonthlyEntry("appliance-refund", 22, time(11, 15), _C.SHOPPING, _CREDIT,
                 "Reintegro parcial — Electrohogar",
                 (None, None, "45990.00", None)),
    # Groceries
    MonthlyEntry("groceries-week-1", 3, time(18, 20), _C.GROCERIES, _DEBIT,
                 "Supermercado La Estancia",
                 ("78450.30", "82340.50", "91120.00", "86700.40")),
    MonthlyEntry("greengrocer", 7, time(10, 45), _C.GROCERIES, _DEBIT,
                 "Verdulería El Huerto",
                 ("12300.00", "14850.50", "16200.00", "13980.00")),
    MonthlyEntry("groceries-week-2", 10, time(19, 5), _C.GROCERIES, _DEBIT,
                 "Supermercado La Estancia",
                 ("51200.00", "54210.75", "48900.20", "61350.90")),
    MonthlyEntry("groceries-week-3", 17, time(17, 40), _C.GROCERIES, _DEBIT,
                 "Supermercado La Estancia",
                 ("73900.00", "76880.10", "88450.60", "69990.00")),
    MonthlyEntry("bakery", 21, time(8, 30), _C.GROCERIES, _DEBIT,
                 "Panadería La Espiga",
                 ("6450.00", "7120.00", "8900.00", "7480.00")),
    MonthlyEntry("groceries-week-4", 24, time(18, 50), _C.GROCERIES, _DEBIT,
                 "Supermercado La Estancia",
                 ("47350.80", "49600.00", "57230.45", "52410.70")),
    MonthlyEntry("corner-shop", 27, time(21, 10), _C.GROCERIES, _DEBIT,
                 "Almacén Don Tito",
                 (None, None, "12450.00", None)),
    # Dining
    MonthlyEntry("cafe", 4, time(9, 40), _C.DINING, _DEBIT,
                 "Café Plaza Norte",
                 ("16900.00", "18600.00", "21300.00", "19850.00")),
    MonthlyEntry("lunch", 8, time(13, 15), _C.DINING, _DEBIT,
                 "Almuerzo — Bar La Esquina",
                 ("11800.00", "12400.00", "13100.00", "12950.00")),
    MonthlyEntry("bodegon", 13, time(21, 30), _C.DINING, _DEBIT,
                 "Bodegón Los Tilos",
                 ("38500.00", "42800.00", None, "31200.00")),
    MonthlyEntry("birthday-dinner", 13, time(22, 0), _C.DINING, _DEBIT,
                 "Cena de cumpleaños — Restaurante Mar Austral",
                 (None, None, "67900.00", None)),
    MonthlyEntry("empanadas", 18, time(20, 45), _C.DINING, _DEBIT,
                 "Delivery — Empanadas La Tucumana",
                 ("14200.00", "15600.00", "16800.00", "15900.00")),
    MonthlyEntry("pizzeria", 21, time(21, 15), _C.DINING, _DEBIT,
                 "Pizzería Lunetta",
                 ("22100.00", "23450.00", "26750.00", "24300.00")),
    MonthlyEntry("cafe-late", 26, time(17, 0), _C.DINING, _DEBIT,
                 "Café Plaza Norte",
                 (None, None, "15400.00", "17650.00")),
    # Transport
    MonthlyEntry("transit-card-1", 2, time(8, 10), _C.TRANSPORT, _DEBIT,
                 "Carga tarjeta de transporte",
                 ("15000.00", "15000.00", "15000.00", "15000.00")),
    MonthlyEntry("rideshare-1", 11, time(23, 20), _C.TRANSPORT, _DEBIT,
                 "Viaje — ViajaYa",
                 (None, "7850.00", None, "8640.00")),
    MonthlyEntry("transit-card-2", 16, time(8, 5), _C.TRANSPORT, _DEBIT,
                 "Carga tarjeta de transporte",
                 ("15000.00", "15000.00", "15000.00", "15000.00")),
    MonthlyEntry("rideshare-2", 19, time(1, 40), _C.TRANSPORT, _DEBIT,
                 "Viaje — ViajaYa",
                 ("6900.00", None, "9430.00", None)),
    MonthlyEntry("parking", 23, time(10, 20), _C.TRANSPORT, _DEBIT,
                 "Estacionamiento Centro",
                 ("4800.00", "5200.00", "5600.00", "5900.00")),
    # Fuel
    MonthlyEntry("fuel-1", 6, time(13, 25), _C.FUEL, _DEBIT,
                 "Estación de servicio Ruta 9",
                 ("49800.00", "52000.00", "58500.00", "61000.00")),
    MonthlyEntry("fuel-2", 20, time(12, 55), _C.FUEL, _DEBIT,
                 "Estación de servicio Ruta 9",
                 ("45100.00", "47300.00", "55900.00", "58200.00")),
    # Utilities
    MonthlyEntry("electricity", 8, time(10, 0), _C.UTILITIES, _DEBIT,
                 "Luz — Energía Metropolitana",
                 ("35200.00", "38450.00", "41200.00", "36980.00")),
    MonthlyEntry("gas", 10, time(10, 0), _C.UTILITIES, _DEBIT,
                 "Gas — Gas Natural del Plata",
                 ("16400.00", "18900.00", "21350.00", "24100.00")),
    MonthlyEntry("internet", 12, time(10, 0), _C.UTILITIES, _DEBIT,
                 "Internet — FibraSur",
                 ("29999.00", "29999.00", "29999.00", "29999.00")),
    MonthlyEntry("mobile", 14, time(10, 0), _C.UTILITIES, _DEBIT,
                 "Telefonía móvil — Conecta",
                 ("17500.00", "17500.00", "17500.00", "17500.00")),
    # Subscriptions
    MonthlyEntry("streaming", 5, time(6, 0), _C.SUBSCRIPTIONS, _DEBIT,
                 "Streaming — CineMax Plus",
                 ("8999.00", "8999.00", "8999.00", "8999.00")),
    MonthlyEntry("music", 5, time(6, 5), _C.SUBSCRIPTIONS, _DEBIT,
                 "Música — Sonora Premium",
                 ("4499.00", "4499.00", "4499.00", "4499.00")),
    MonthlyEntry("gym", 9, time(7, 0), _C.SUBSCRIPTIONS, _DEBIT,
                 "Gimnasio Activa",
                 ("32000.00", "32000.00", "32000.00", "32000.00")),
    # Entertainment
    MonthlyEntry("cinema", 15, time(20, 0), _C.ENTERTAINMENT, _DEBIT,
                 "Cine Lumière",
                 ("12800.00", "14400.00", None, "16800.00")),
    MonthlyEntry("concert", 23, time(19, 30), _C.ENTERTAINMENT, _DEBIT,
                 "Entradas — Concierto en Estadio Austral",
                 (None, None, "85000.00", None)),
    # Shopping
    MonthlyEntry("bookshop", 9, time(16, 20), _C.SHOPPING, _DEBIT,
                 "Librería Papiro",
                 (None, None, "27500.00", None)),
    MonthlyEntry("clothing", 12, time(17, 45), _C.SHOPPING, _DEBIT,
                 "Moda Urbana Palermo",
                 ("54300.00", None, None, "64900.00")),
    MonthlyEntry("appliance", 21, time(12, 10), _C.SHOPPING, _DEBIT,
                 "Electrohogar — Microondas",
                 (None, "189990.00", None, None)),
    # Other
    MonthlyEntry("pharmacy", 15, time(11, 30), _C.OTHER, _DEBIT,
                 "Farmacia Central",
                 ("19800.00", "22340.00", "18760.00", "25120.00")),
)
# fmt: on


@dataclass(frozen=True)
class SeedDataset:
    customer: CustomerModel
    accounts: list[AccountModel]
    cards: list[CardModel]
    beneficiaries: list[BeneficiaryModel]
    transactions: list[TransactionModel]
    # Derived balance of the main account before the seeded window; not persisted.
    main_account_opening_balance: Decimal

    def models(self) -> list[object]:
        return [
            self.customer,
            *self.accounts,
            *self.cards,
            *self.beneficiaries,
            *self.transactions,
        ]


class AlreadySeededError(Exception):
    pass


class ProductionEnvironmentError(Exception):
    pass


def add_months(day: date, months: int) -> date:
    """Shift by whole months, clamping to the last day of shorter months."""
    month_index = day.year * 12 + day.month - 1 + months
    year, month = divmod(month_index, 12)
    last_day = calendar.monthrange(year, month + 1)[1]
    return date(year, month + 1, min(day.day, last_day))


def _build_transactions(reference_date: date) -> list[TransactionModel]:
    window_start = add_months(reference_date, -HISTORY_MONTHS)
    transactions = []
    for index, offset in enumerate(range(-HISTORY_MONTHS, 1)):
        month_start = add_months(reference_date.replace(day=1), offset)
        for entry in MAIN_ACCOUNT_ENTRIES:
            amount = entry.amounts[index]
            occurred_on = month_start.replace(day=entry.day)
            if amount is None or not window_start <= occurred_on < reference_date:
                continue
            transactions.append(
                TransactionModel(
                    id=seed_id(f"transaction:M{offset}:{entry.key}"),
                    account_id=MAIN_ACCOUNT_ID,
                    amount=Decimal(amount),
                    currency=Currency.ARS,
                    type=entry.type,
                    category=entry.category,
                    description=entry.description,
                    occurred_at=datetime.combine(
                        occurred_on, entry.at, tzinfo=BUENOS_AIRES
                    ),
                    transfer_id=None,
                )
            )
    transactions.sort(key=lambda t: (t.occurred_at, str(t.id)))
    return transactions


def signed_amount(transaction: TransactionModel) -> Decimal:
    if transaction.type is TransactionType.CREDIT:
        return transaction.amount
    return -transaction.amount


def _opening_balance(
    final_balance: Decimal, transactions: Sequence[TransactionModel]
) -> Decimal:
    opening = final_balance - sum(
        (signed_amount(t) for t in transactions), Decimal("0")
    )
    balances = accumulate((signed_amount(t) for t in transactions), initial=opening)
    if any(balance < 0 for balance in balances):
        raise ValueError("Seeded history would make the balance negative")
    return opening


def build_dataset(reference_date: date) -> SeedDataset:
    customer = CustomerModel(id=CUSTOMER_ID, first_name="Valentina", last_name="Ruiz")
    accounts = [
        AccountModel(
            id=MAIN_ACCOUNT_ID,
            customer_id=CUSTOMER_ID,
            name="Cuenta principal",
            balance=MAIN_ACCOUNT_BALANCE,
            currency=Currency.ARS,
            status=AccountStatus.ACTIVE,
        ),
        AccountModel(
            id=USD_SAVINGS_ID,
            customer_id=CUSTOMER_ID,
            name="Caja de ahorro en dólares",
            balance=USD_SAVINGS_BALANCE,
            currency=Currency.USD,
            status=AccountStatus.ACTIVE,
        ),
    ]
    cards = [
        CardModel(
            id=seed_id(f"card:{key}"),
            account_id=MAIN_ACCOUNT_ID,
            type=card_type,
            brand=brand,
            last_four=last_four,
            status=status,
        )
        for key, card_type, brand, last_four, status in (
            ("visa-debit", CardType.DEBIT, CardBrand.VISA, "4821", CardStatus.ACTIVE),
            (
                "mastercard-credit",
                CardType.CREDIT,
                CardBrand.MASTERCARD,
                "5307",
                CardStatus.ACTIVE,
            ),
            ("visa-credit", CardType.CREDIT, CardBrand.VISA, "9134", CardStatus.FROZEN),
        )
    ]
    beneficiaries = [
        BeneficiaryModel(
            id=seed_id(f"beneficiary:{key}"),
            customer_id=CUSTOMER_ID,
            name=name,
            account_reference=account_reference,
            bank_name=bank_name,
        )
        for key, name, account_reference, bank_name in (
            ("laura-gomez", "Laura Gómez", "0000001100000000000011", "Banco Austral"),
            (
                "martin-perez",
                "Martín Pérez",
                "0000002200000000000022",
                "Banco Río Claro",
            ),
            ("lucia-fernandez", "Lucía Fernández", "0000003300000000000033", None),
            ("diego-romero", "Diego Romero", "0000001100000000000044", "Banco Austral"),
            (
                "sofia-benitez",
                "Sofía Benítez",
                "0000004400000000000055",
                "Banco Meridiano",
            ),
        )
    ]
    transactions = _build_transactions(reference_date)
    return SeedDataset(
        customer=customer,
        accounts=accounts,
        cards=cards,
        beneficiaries=beneficiaries,
        transactions=transactions,
        main_account_opening_balance=_opening_balance(
            MAIN_ACCOUNT_BALANCE, transactions
        ),
    )


def _delete_customer_data(session: Session, customer_id: UUID) -> None:
    accounts = select(AccountModel.id).where(AccountModel.customer_id == customer_id)
    beneficiaries = select(BeneficiaryModel.id).where(
        BeneficiaryModel.customer_id == customer_id
    )
    conversations = select(ConversationModel.id).where(
        ConversationModel.customer_id == customer_id
    )
    # Children before parents; the schema defines no cascades.
    for statement in (
        delete(MessageModel).where(MessageModel.conversation_id.in_(conversations)),
        delete(ConversationModel).where(ConversationModel.customer_id == customer_id),
        delete(TransactionModel).where(TransactionModel.account_id.in_(accounts)),
        delete(TransferModel).where(
            TransferModel.source_account_id.in_(accounts)
            | TransferModel.beneficiary_id.in_(beneficiaries)
        ),
        delete(CardModel).where(CardModel.account_id.in_(accounts)),
        delete(BeneficiaryModel).where(BeneficiaryModel.customer_id == customer_id),
        delete(AccountModel).where(AccountModel.customer_id == customer_id),
        delete(CustomerModel).where(CustomerModel.id == customer_id),
    ):
        session.execute(statement)


def seed(
    session_factory: sessionmaker[Session], reference_date: date, reset: bool
) -> SeedDataset:
    """Insert the dataset in one transaction; nothing persists on failure."""
    dataset = build_dataset(reference_date)
    with session_factory.begin() as session:
        if session.get(CustomerModel, CUSTOMER_ID) is not None:
            if not reset:
                raise AlreadySeededError(
                    "The database is already seeded; use --reset to replace it"
                )
            _delete_customer_data(session, CUSTOMER_ID)
        session.add_all(dataset.models())
    return dataset


def run(settings: Settings, reference_date: date, reset: bool) -> SeedDataset:
    if settings.environment is AppEnvironment.PRODUCTION:
        raise ProductionEnvironmentError("Seeding is not allowed in production")
    engine = create_db_engine(settings.database_url.get_secret_value())
    try:
        return seed(create_session_factory(engine), reference_date, reset)
    finally:
        engine.dispose()


def main(argv: Sequence[str] | None = None) -> int:
    parser = argparse.ArgumentParser(
        description="Seed the deterministic V1 synthetic dataset."
    )
    parser.add_argument(
        "--reference-date",
        type=date.fromisoformat,
        default=datetime.now(BUENOS_AIRES).date(),
        help="Transactions cover the three months before this date "
        "(default: today in Buenos Aires).",
    )
    parser.add_argument(
        "--reset",
        action="store_true",
        help="Delete the seeded customer's data, including conversations, "
        "before seeding again.",
    )
    args = parser.parse_args(argv)
    try:
        dataset = run(get_settings(), args.reference_date, args.reset)
    except (AlreadySeededError, ProductionEnvironmentError) as error:
        print(f"Seed aborted: {error}", file=sys.stderr)
        return 1
    print(
        f"Seeded 1 customer, {len(dataset.accounts)} accounts, "
        f"{len(dataset.cards)} cards, {len(dataset.beneficiaries)} beneficiaries "
        f"and {len(dataset.transactions)} transactions "
        f"(reference date {args.reference_date.isoformat()})."
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
