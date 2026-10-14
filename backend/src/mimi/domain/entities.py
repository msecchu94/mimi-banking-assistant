from dataclasses import dataclass
from datetime import datetime
from decimal import Decimal
from uuid import UUID

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


@dataclass(frozen=True)
class Money:
    amount: Decimal
    currency: Currency


@dataclass(frozen=True)
class Account:
    id: UUID
    customer_id: UUID
    name: str
    balance: Money
    status: AccountStatus


@dataclass(frozen=True)
class Card:
    id: UUID
    account_id: UUID
    type: CardType
    brand: CardBrand
    last_four: str
    status: CardStatus


@dataclass(frozen=True)
class Beneficiary:
    id: UUID
    customer_id: UUID
    name: str
    account_reference: str
    bank_name: str | None


@dataclass(frozen=True)
class Transaction:
    id: UUID
    account_id: UUID
    amount: Money
    type: TransactionType
    category: TransactionCategory
    description: str
    occurred_at: datetime
    transfer_id: UUID | None


@dataclass(frozen=True)
class Transfer:
    id: UUID
    source_account_id: UUID
    beneficiary_id: UUID
    amount: Money
    status: TransferStatus
    created_at: datetime
    executed_at: datetime | None
