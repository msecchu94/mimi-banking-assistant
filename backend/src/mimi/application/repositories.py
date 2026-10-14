"""Persistence ports required by V1 Use Cases.

Single reads return ``None`` when the record does not exist or is not owned by
the given customer. List reads return an empty list when nothing matches.

Updates expect the caller to have read the record earlier in the same
transaction.
"""

from dataclasses import dataclass
from datetime import datetime
from typing import Protocol
from uuid import UUID

from mimi.domain.entities import (
    Account,
    Beneficiary,
    Card,
    Money,
    Transaction,
    Transfer,
)
from mimi.domain.enums import CardStatus, TransactionCategory, TransactionType


class AccountRepository(Protocol):
    def list_by_customer(self, customer_id: UUID) -> list[Account]: ...

    def get_for_update(self, customer_id: UUID, account_id: UUID) -> Account | None:
        """Return the owned account, locked until the current transaction ends."""
        ...

    def update_balance(self, account_id: UUID, balance: Money) -> None: ...


class CardRepository(Protocol):
    def list_by_customer(self, customer_id: UUID) -> list[Card]: ...

    def get(self, customer_id: UUID, card_id: UUID) -> Card | None: ...

    def update_status(self, card_id: UUID, status: CardStatus) -> None: ...


class BeneficiaryRepository(Protocol):
    def list_by_customer(self, customer_id: UUID) -> list[Beneficiary]: ...

    def get(self, customer_id: UUID, beneficiary_id: UUID) -> Beneficiary | None: ...


@dataclass(frozen=True)
class TransactionQuery:
    """Filters for a customer's transactions; unset fields do not filter.

    The period is half-open: ``occurred_from`` inclusive, ``occurred_to``
    exclusive. Both must be timezone-aware.
    """

    occurred_from: datetime | None = None
    occurred_to: datetime | None = None
    category: TransactionCategory | None = None
    type: TransactionType | None = None
    limit: int | None = None


class TransactionRepository(Protocol):
    def list_by_customer(
        self, customer_id: UUID, query: TransactionQuery
    ) -> list[Transaction]:
        """Return matching transactions, newest first."""
        ...


class TransferRepository(Protocol):
    def add(self, transfer: Transfer, transaction: Transaction | None) -> None:
        """Persist a transfer together with its resulting transaction, if any."""
        ...
