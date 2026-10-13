from datetime import datetime
from decimal import Decimal
from enum import StrEnum
from uuid import UUID

from sqlalchemy import CHAR, CheckConstraint, Enum, ForeignKey, Index
from sqlalchemy.orm import Mapped, mapped_column, relationship

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


def enum_type(enum_class: type[StrEnum], name: str) -> Enum:
    """Store an enum as VARCHAR with a CHECK constraint on its values."""
    return Enum(
        enum_class,
        name=name,
        native_enum=False,
        create_constraint=True,
        values_callable=lambda members: [member.value for member in members],
    )


class CustomerModel(Base):
    __tablename__ = "customers"

    id: Mapped[UUID] = mapped_column(primary_key=True)
    first_name: Mapped[str]
    last_name: Mapped[str]

    accounts: Mapped[list["AccountModel"]] = relationship(
        back_populates="customer", lazy="raise"
    )
    beneficiaries: Mapped[list["BeneficiaryModel"]] = relationship(
        back_populates="customer", lazy="raise"
    )


class AccountModel(Base):
    __tablename__ = "accounts"
    __table_args__ = (CheckConstraint("balance >= 0", name="balance_non_negative"),)

    id: Mapped[UUID] = mapped_column(primary_key=True)
    customer_id: Mapped[UUID] = mapped_column(ForeignKey("customers.id"))
    name: Mapped[str]
    balance: Mapped[Decimal]
    currency: Mapped[Currency] = mapped_column(enum_type(Currency, "currency"))
    status: Mapped[AccountStatus] = mapped_column(enum_type(AccountStatus, "status"))

    customer: Mapped[CustomerModel] = relationship(
        back_populates="accounts", lazy="raise"
    )
    cards: Mapped[list["CardModel"]] = relationship(
        back_populates="account", lazy="raise"
    )
    transactions: Mapped[list["TransactionModel"]] = relationship(
        back_populates="account", lazy="raise"
    )
    outgoing_transfers: Mapped[list["TransferModel"]] = relationship(
        back_populates="source_account", lazy="raise"
    )


class CardModel(Base):
    __tablename__ = "cards"
    __table_args__ = (
        CheckConstraint("last_four ~ '^[0-9]{4}$'", name="last_four_digits"),
    )

    id: Mapped[UUID] = mapped_column(primary_key=True)
    account_id: Mapped[UUID] = mapped_column(ForeignKey("accounts.id"))
    type: Mapped[CardType] = mapped_column(enum_type(CardType, "type"))
    brand: Mapped[CardBrand] = mapped_column(enum_type(CardBrand, "brand"))
    last_four: Mapped[str] = mapped_column(CHAR(4))
    status: Mapped[CardStatus] = mapped_column(enum_type(CardStatus, "status"))

    account: Mapped[AccountModel] = relationship(back_populates="cards", lazy="raise")


class BeneficiaryModel(Base):
    __tablename__ = "beneficiaries"

    id: Mapped[UUID] = mapped_column(primary_key=True)
    customer_id: Mapped[UUID] = mapped_column(ForeignKey("customers.id"))
    name: Mapped[str]
    account_reference: Mapped[str]
    bank_name: Mapped[str | None]

    customer: Mapped[CustomerModel] = relationship(
        back_populates="beneficiaries", lazy="raise"
    )
    transfers: Mapped[list["TransferModel"]] = relationship(
        back_populates="beneficiary", lazy="raise"
    )


class TransferModel(Base):
    __tablename__ = "transfers"
    __table_args__ = (CheckConstraint("amount > 0", name="amount_positive"),)

    id: Mapped[UUID] = mapped_column(primary_key=True)
    source_account_id: Mapped[UUID] = mapped_column(ForeignKey("accounts.id"))
    beneficiary_id: Mapped[UUID] = mapped_column(ForeignKey("beneficiaries.id"))
    amount: Mapped[Decimal]
    currency: Mapped[Currency] = mapped_column(enum_type(Currency, "currency"))
    status: Mapped[TransferStatus] = mapped_column(enum_type(TransferStatus, "status"))
    created_at: Mapped[datetime]
    executed_at: Mapped[datetime | None]

    source_account: Mapped[AccountModel] = relationship(
        back_populates="outgoing_transfers", lazy="raise"
    )
    beneficiary: Mapped[BeneficiaryModel] = relationship(
        back_populates="transfers", lazy="raise"
    )
    transaction: Mapped["TransactionModel | None"] = relationship(
        back_populates="transfer", lazy="raise"
    )


class TransactionModel(Base):
    __tablename__ = "transactions"
    __table_args__ = (
        CheckConstraint("amount > 0", name="amount_positive"),
        CheckConstraint(
            "transfer_id IS NULL OR ("
            f"category = '{TransactionCategory.TRANSFER.value}' "
            f"AND type = '{TransactionType.DEBIT.value}')",
            name="transfer_is_debit_transfer",
        ),
        Index("ix_transactions_account_id_occurred_at", "account_id", "occurred_at"),
    )

    id: Mapped[UUID] = mapped_column(primary_key=True)
    account_id: Mapped[UUID] = mapped_column(ForeignKey("accounts.id"))
    amount: Mapped[Decimal]
    currency: Mapped[Currency] = mapped_column(enum_type(Currency, "currency"))
    type: Mapped[TransactionType] = mapped_column(enum_type(TransactionType, "type"))
    category: Mapped[TransactionCategory] = mapped_column(
        enum_type(TransactionCategory, "category")
    )
    description: Mapped[str]
    occurred_at: Mapped[datetime]
    transfer_id: Mapped[UUID | None] = mapped_column(
        ForeignKey("transfers.id"), unique=True
    )

    account: Mapped[AccountModel] = relationship(
        back_populates="transactions", lazy="raise"
    )
    transfer: Mapped[TransferModel | None] = relationship(
        back_populates="transaction", lazy="raise"
    )
