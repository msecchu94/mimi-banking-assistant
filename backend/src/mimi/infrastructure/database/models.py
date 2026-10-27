from datetime import datetime
from decimal import Decimal
from enum import StrEnum
from typing import Any
from uuid import UUID

from sqlalchemy import CHAR, CheckConstraint, Enum, ForeignKey, Index, String, Text
from sqlalchemy.dialects.postgresql import ARRAY, JSONB
from sqlalchemy.orm import Mapped, mapped_column, relationship

from mimi.application.pending_operations import PendingField
from mimi.domain.enums import (
    AccountStatus,
    CardBrand,
    CardStatus,
    CardType,
    ConversationFlowState,
    ConversationStatus,
    Currency,
    MessageRole,
    PendingOperationType,
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
    conversations: Mapped[list["ConversationModel"]] = relationship(
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


# Required data per pending operation type, as named in CONVERSATION.md.
TRANSFER_OPERATION_FIELDS = (
    PendingField.SOURCE_ACCOUNT_ID.value,
    PendingField.BENEFICIARY_ID.value,
    PendingField.AMOUNT.value,
)
CARD_OPERATION_FIELDS = (PendingField.CARD_ID.value,)


def sql_values(values: tuple[str, ...]) -> str:
    return ", ".join(f"'{value}'" for value in values)


def sql_varchar_array(values: tuple[str, ...]) -> str:
    return f"ARRAY[{sql_values(values)}]::varchar[]"


_READY = ConversationFlowState.READY.value
_COLLECTING_DATA = ConversationFlowState.COLLECTING_DATA.value
_WAITING_CONFIRMATION = ConversationFlowState.WAITING_CONFIRMATION.value
_CLOSED = ConversationStatus.CLOSED.value
_TRANSFER = PendingOperationType.TRANSFER.value
_CARD_OPERATIONS = sql_values(
    (PendingOperationType.FREEZE_CARD.value, PendingOperationType.UNFREEZE_CARD.value)
)

_NO_TRANSFER_DATA = (
    "pending_source_account_id IS NULL AND pending_beneficiary_id IS NULL "
    "AND pending_amount IS NULL AND pending_currency IS NULL"
)
_COMPLETE_TRANSFER_DATA = (
    "pending_source_account_id IS NOT NULL AND pending_beneficiary_id IS NOT NULL "
    "AND pending_amount IS NOT NULL AND pending_currency IS NOT NULL"
)


class ConversationModel(Base):
    __tablename__ = "conversations"
    __table_args__ = (
        CheckConstraint(
            f"flow_state <> '{_READY}' OR pending_operation_type IS NULL",
            name="ready_has_no_pending_operation",
        ),
        CheckConstraint(
            f"flow_state <> '{_COLLECTING_DATA}' OR ("
            "pending_operation_type IS NOT NULL "
            "AND coalesce(cardinality(pending_missing_fields), 0) > 0)",
            name="collecting_data_has_missing_fields",
        ),
        CheckConstraint(
            f"flow_state <> '{_WAITING_CONFIRMATION}' OR ("
            "pending_operation_type IS NOT NULL "
            "AND coalesce(cardinality(pending_missing_fields), -1) = 0 "
            f"AND ((pending_operation_type = '{_TRANSFER}' "
            f"AND {_COMPLETE_TRANSFER_DATA}) "
            f"OR (pending_operation_type IN ({_CARD_OPERATIONS}) "
            "AND pending_card_id IS NOT NULL)))",
            name="waiting_confirmation_is_complete",
        ),
        CheckConstraint(
            "(pending_operation_id IS NOT NULL) = "
            f"(flow_state = '{_WAITING_CONFIRMATION}')",
            name="waiting_confirmation_has_operation_id",
        ),
        CheckConstraint(
            f"status <> '{_CLOSED}' OR pending_operation_type IS NULL",
            name="closed_has_no_pending_operation",
        ),
        CheckConstraint(
            "(pending_operation_type IS NULL) = (pending_missing_fields IS NULL)",
            name="pending_type_and_missing_fields",
        ),
        CheckConstraint(
            "CASE "
            f"WHEN pending_operation_type = '{_TRANSFER}' "
            "THEN pending_card_id IS NULL "
            f"WHEN pending_operation_type IN ({_CARD_OPERATIONS}) "
            f"THEN {_NO_TRANSFER_DATA} "
            f"ELSE {_NO_TRANSFER_DATA} AND pending_card_id IS NULL END",
            name="pending_data_matches_type",
        ),
        CheckConstraint(
            "pending_currency IS NULL OR pending_amount IS NOT NULL",
            name="pending_currency_has_amount",
        ),
        # An amount without currency is an unresolved candidate, so the amount
        # is still missing.
        CheckConstraint(
            "pending_amount IS NULL OR pending_currency IS NOT NULL "
            f"OR '{PendingField.AMOUNT.value}' = ANY(pending_missing_fields)",
            name="unresolved_amount_is_missing",
        ),
        CheckConstraint(
            "pending_amount IS NULL OR pending_amount > 0",
            name="pending_amount_positive",
        ),
        CheckConstraint(
            "CASE "
            f"WHEN pending_operation_type = '{_TRANSFER}' "
            "THEN pending_missing_fields "
            f"<@ {sql_varchar_array(TRANSFER_OPERATION_FIELDS)} "
            f"WHEN pending_operation_type IN ({_CARD_OPERATIONS}) "
            "THEN pending_missing_fields "
            f"<@ {sql_varchar_array(CARD_OPERATION_FIELDS)} "
            "ELSE TRUE END",
            name="pending_missing_fields_valid",
        ),
        CheckConstraint("jsonb_typeof(context) = 'object'", name="context_is_object"),
    )

    id: Mapped[UUID] = mapped_column(primary_key=True)
    customer_id: Mapped[UUID] = mapped_column(ForeignKey("customers.id"))
    status: Mapped[ConversationStatus] = mapped_column(
        enum_type(ConversationStatus, "status")
    )
    created_at: Mapped[datetime]
    updated_at: Mapped[datetime]
    flow_state: Mapped[ConversationFlowState] = mapped_column(
        enum_type(ConversationFlowState, "flow_state")
    )
    context: Mapped[dict[str, Any]] = mapped_column(JSONB)
    pending_operation_type: Mapped[PendingOperationType | None] = mapped_column(
        enum_type(PendingOperationType, "pending_operation_type")
    )
    pending_operation_id: Mapped[UUID | None]
    pending_source_account_id: Mapped[UUID | None] = mapped_column(
        ForeignKey("accounts.id")
    )
    pending_beneficiary_id: Mapped[UUID | None] = mapped_column(
        ForeignKey("beneficiaries.id")
    )
    pending_amount: Mapped[Decimal | None]
    pending_currency: Mapped[Currency | None] = mapped_column(
        enum_type(Currency, "pending_currency")
    )
    pending_card_id: Mapped[UUID | None] = mapped_column(ForeignKey("cards.id"))
    pending_missing_fields: Mapped[list[str] | None] = mapped_column(ARRAY(String))

    customer: Mapped[CustomerModel] = relationship(
        back_populates="conversations", lazy="raise"
    )
    messages: Mapped[list["MessageModel"]] = relationship(
        back_populates="conversation",
        lazy="raise",
        order_by=lambda: (MessageModel.created_at, MessageModel.id),
    )


class MessageModel(Base):
    __tablename__ = "messages"
    __table_args__ = (
        # Requires a non-whitespace character; tabs and newlines count as blank.
        CheckConstraint(r"content ~ '\S'", name="content_not_blank"),
        Index(
            "ix_messages_conversation_id_created_at_id",
            "conversation_id",
            "created_at",
            "id",
        ),
    )

    id: Mapped[UUID] = mapped_column(primary_key=True)
    conversation_id: Mapped[UUID] = mapped_column(ForeignKey("conversations.id"))
    role: Mapped[MessageRole] = mapped_column(enum_type(MessageRole, "role"))
    content: Mapped[str] = mapped_column(Text)
    created_at: Mapped[datetime]

    conversation: Mapped[ConversationModel] = relationship(
        back_populates="messages", lazy="raise"
    )
