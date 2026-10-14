"""initial schema

Revision ID: 0001
Revises:
Create Date: 2026-10-13 21:27:17.206020

"""

from collections.abc import Sequence

import sqlalchemy as sa
from alembic import op
from sqlalchemy.dialects import postgresql

# revision identifiers, used by Alembic.
revision: str = "0001"
down_revision: str | Sequence[str] | None = None
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None

# Enums are stored as VARCHAR with a named CHECK on their values. Values are
# literal so this revision does not change when the application enums do.
CURRENCY_VALUES = "('ARS', 'USD')"


def upgrade() -> None:
    """Upgrade schema."""
    op.create_table(
        "customers",
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.Column("first_name", sa.String(), nullable=False),
        sa.Column("last_name", sa.String(), nullable=False),
        sa.PrimaryKeyConstraint("id", name=op.f("pk_customers")),
    )
    op.create_table(
        "accounts",
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.Column("customer_id", sa.Uuid(), nullable=False),
        sa.Column("name", sa.String(), nullable=False),
        sa.Column("balance", sa.Numeric(precision=18, scale=2), nullable=False),
        sa.Column("currency", sa.String(length=3), nullable=False),
        sa.Column("status", sa.String(length=8), nullable=False),
        sa.CheckConstraint(
            f"currency IN {CURRENCY_VALUES}", name=op.f("ck_accounts_currency")
        ),
        sa.CheckConstraint(
            "status IN ('ACTIVE', 'INACTIVE')", name=op.f("ck_accounts_status")
        ),
        sa.CheckConstraint(
            "balance >= 0", name=op.f("ck_accounts_balance_non_negative")
        ),
        sa.ForeignKeyConstraint(
            ["customer_id"],
            ["customers.id"],
            name=op.f("fk_accounts_customer_id_customers"),
        ),
        sa.PrimaryKeyConstraint("id", name=op.f("pk_accounts")),
    )
    op.create_table(
        "beneficiaries",
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.Column("customer_id", sa.Uuid(), nullable=False),
        sa.Column("name", sa.String(), nullable=False),
        sa.Column("account_reference", sa.String(), nullable=False),
        sa.Column("bank_name", sa.String(), nullable=True),
        sa.ForeignKeyConstraint(
            ["customer_id"],
            ["customers.id"],
            name=op.f("fk_beneficiaries_customer_id_customers"),
        ),
        sa.PrimaryKeyConstraint("id", name=op.f("pk_beneficiaries")),
    )
    op.create_table(
        "cards",
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.Column("account_id", sa.Uuid(), nullable=False),
        sa.Column("type", sa.String(length=6), nullable=False),
        sa.Column("brand", sa.String(length=10), nullable=False),
        sa.Column("last_four", sa.CHAR(length=4), nullable=False),
        sa.Column("status", sa.String(length=6), nullable=False),
        sa.CheckConstraint("type IN ('DEBIT', 'CREDIT')", name=op.f("ck_cards_type")),
        sa.CheckConstraint(
            "brand IN ('VISA', 'MASTERCARD')", name=op.f("ck_cards_brand")
        ),
        sa.CheckConstraint(
            "status IN ('ACTIVE', 'FROZEN')", name=op.f("ck_cards_status")
        ),
        sa.CheckConstraint(
            "last_four ~ '^[0-9]{4}$'", name=op.f("ck_cards_last_four_digits")
        ),
        sa.ForeignKeyConstraint(
            ["account_id"],
            ["accounts.id"],
            name=op.f("fk_cards_account_id_accounts"),
        ),
        sa.PrimaryKeyConstraint("id", name=op.f("pk_cards")),
    )
    op.create_table(
        "transfers",
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.Column("source_account_id", sa.Uuid(), nullable=False),
        sa.Column("beneficiary_id", sa.Uuid(), nullable=False),
        sa.Column("amount", sa.Numeric(precision=18, scale=2), nullable=False),
        sa.Column("currency", sa.String(length=3), nullable=False),
        sa.Column("status", sa.String(length=9), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("executed_at", sa.DateTime(timezone=True), nullable=True),
        sa.CheckConstraint(
            f"currency IN {CURRENCY_VALUES}", name=op.f("ck_transfers_currency")
        ),
        sa.CheckConstraint(
            "status IN ('COMPLETED', 'FAILED')", name=op.f("ck_transfers_status")
        ),
        sa.CheckConstraint("amount > 0", name=op.f("ck_transfers_amount_positive")),
        sa.ForeignKeyConstraint(
            ["beneficiary_id"],
            ["beneficiaries.id"],
            name=op.f("fk_transfers_beneficiary_id_beneficiaries"),
        ),
        sa.ForeignKeyConstraint(
            ["source_account_id"],
            ["accounts.id"],
            name=op.f("fk_transfers_source_account_id_accounts"),
        ),
        sa.PrimaryKeyConstraint("id", name=op.f("pk_transfers")),
    )
    op.create_table(
        "transactions",
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.Column("account_id", sa.Uuid(), nullable=False),
        sa.Column("amount", sa.Numeric(precision=18, scale=2), nullable=False),
        sa.Column("currency", sa.String(length=3), nullable=False),
        sa.Column("type", sa.String(length=6), nullable=False),
        sa.Column("category", sa.String(length=13), nullable=False),
        sa.Column("description", sa.String(), nullable=False),
        sa.Column("occurred_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("transfer_id", sa.Uuid(), nullable=True),
        sa.CheckConstraint(
            f"currency IN {CURRENCY_VALUES}", name=op.f("ck_transactions_currency")
        ),
        sa.CheckConstraint(
            "type IN ('DEBIT', 'CREDIT')", name=op.f("ck_transactions_type")
        ),
        sa.CheckConstraint(
            "category IN ('GROCERIES', 'DINING', 'TRANSPORT', 'FUEL', 'UTILITIES', "
            "'SUBSCRIPTIONS', 'ENTERTAINMENT', 'SHOPPING', 'TRANSFER', 'OTHER')",
            name=op.f("ck_transactions_category"),
        ),
        sa.CheckConstraint("amount > 0", name=op.f("ck_transactions_amount_positive")),
        sa.CheckConstraint(
            "transfer_id IS NULL OR (category = 'TRANSFER' AND type = 'DEBIT')",
            name=op.f("ck_transactions_transfer_is_debit_transfer"),
        ),
        sa.ForeignKeyConstraint(
            ["account_id"],
            ["accounts.id"],
            name=op.f("fk_transactions_account_id_accounts"),
        ),
        sa.ForeignKeyConstraint(
            ["transfer_id"],
            ["transfers.id"],
            name=op.f("fk_transactions_transfer_id_transfers"),
        ),
        sa.PrimaryKeyConstraint("id", name=op.f("pk_transactions")),
        sa.UniqueConstraint("transfer_id", name=op.f("uq_transactions_transfer_id")),
    )
    op.create_index(
        "ix_transactions_account_id_occurred_at",
        "transactions",
        ["account_id", "occurred_at"],
        unique=False,
    )
    op.create_table(
        "conversations",
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.Column("customer_id", sa.Uuid(), nullable=False),
        sa.Column("status", sa.String(length=6), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("flow_state", sa.String(length=20), nullable=False),
        sa.Column("context", postgresql.JSONB(astext_type=sa.Text()), nullable=False),
        sa.Column("pending_operation_type", sa.String(length=13), nullable=True),
        sa.Column("pending_source_account_id", sa.Uuid(), nullable=True),
        sa.Column("pending_beneficiary_id", sa.Uuid(), nullable=True),
        sa.Column("pending_amount", sa.Numeric(precision=18, scale=2), nullable=True),
        sa.Column("pending_currency", sa.String(length=3), nullable=True),
        sa.Column("pending_card_id", sa.Uuid(), nullable=True),
        sa.Column(
            "pending_missing_fields", postgresql.ARRAY(sa.String()), nullable=True
        ),
        sa.CheckConstraint(
            "status IN ('ACTIVE', 'CLOSED')", name=op.f("ck_conversations_status")
        ),
        sa.CheckConstraint(
            "flow_state IN ('READY', 'COLLECTING_DATA', 'WAITING_CONFIRMATION')",
            name=op.f("ck_conversations_flow_state"),
        ),
        sa.CheckConstraint(
            "pending_operation_type IN ('TRANSFER', 'FREEZE_CARD', 'UNFREEZE_CARD')",
            name=op.f("ck_conversations_pending_operation_type"),
        ),
        sa.CheckConstraint(
            f"pending_currency IN {CURRENCY_VALUES}",
            name=op.f("ck_conversations_pending_currency"),
        ),
        sa.CheckConstraint(
            "flow_state <> 'READY' OR pending_operation_type IS NULL",
            name=op.f("ck_conversations_ready_has_no_pending_operation"),
        ),
        sa.CheckConstraint(
            "flow_state <> 'COLLECTING_DATA' OR (pending_operation_type IS NOT NULL "
            "AND coalesce(cardinality(pending_missing_fields), 0) > 0)",
            name=op.f("ck_conversations_collecting_data_has_missing_fields"),
        ),
        sa.CheckConstraint(
            "flow_state <> 'WAITING_CONFIRMATION' OR (pending_operation_type IS NOT "
            "NULL AND coalesce(cardinality(pending_missing_fields), -1) = 0 AND "
            "((pending_operation_type = 'TRANSFER' AND pending_source_account_id IS "
            "NOT NULL AND pending_beneficiary_id IS NOT NULL AND pending_amount IS "
            "NOT NULL AND pending_currency IS NOT NULL) OR (pending_operation_type "
            "IN ('FREEZE_CARD', 'UNFREEZE_CARD') AND pending_card_id IS NOT NULL)))",
            name=op.f("ck_conversations_waiting_confirmation_is_complete"),
        ),
        sa.CheckConstraint(
            "status <> 'CLOSED' OR pending_operation_type IS NULL",
            name=op.f("ck_conversations_closed_has_no_pending_operation"),
        ),
        sa.CheckConstraint(
            "(pending_operation_type IS NULL) = (pending_missing_fields IS NULL)",
            name=op.f("ck_conversations_pending_type_and_missing_fields"),
        ),
        sa.CheckConstraint(
            "CASE WHEN pending_operation_type = 'TRANSFER' THEN pending_card_id IS "
            "NULL WHEN pending_operation_type IN ('FREEZE_CARD', 'UNFREEZE_CARD') "
            "THEN pending_source_account_id IS NULL AND pending_beneficiary_id IS "
            "NULL AND pending_amount IS NULL AND pending_currency IS NULL ELSE "
            "pending_source_account_id IS NULL AND pending_beneficiary_id IS NULL "
            "AND pending_amount IS NULL AND pending_currency IS NULL AND "
            "pending_card_id IS NULL END",
            name=op.f("ck_conversations_pending_data_matches_type"),
        ),
        sa.CheckConstraint(
            "(pending_amount IS NULL) = (pending_currency IS NULL)",
            name=op.f("ck_conversations_pending_amount_has_currency"),
        ),
        sa.CheckConstraint(
            "pending_amount IS NULL OR pending_amount > 0",
            name=op.f("ck_conversations_pending_amount_positive"),
        ),
        sa.CheckConstraint(
            "CASE WHEN pending_operation_type = 'TRANSFER' THEN "
            "pending_missing_fields <@ ARRAY['source_account_id', 'beneficiary_id', "
            "'amount']::varchar[] WHEN pending_operation_type IN ('FREEZE_CARD', "
            "'UNFREEZE_CARD') THEN pending_missing_fields <@ "
            "ARRAY['card_id']::varchar[] ELSE TRUE END",
            name=op.f("ck_conversations_pending_missing_fields_valid"),
        ),
        sa.CheckConstraint(
            "jsonb_typeof(context) = 'object'",
            name=op.f("ck_conversations_context_is_object"),
        ),
        sa.ForeignKeyConstraint(
            ["customer_id"],
            ["customers.id"],
            name=op.f("fk_conversations_customer_id_customers"),
        ),
        sa.ForeignKeyConstraint(
            ["pending_beneficiary_id"],
            ["beneficiaries.id"],
            name=op.f("fk_conversations_pending_beneficiary_id_beneficiaries"),
        ),
        sa.ForeignKeyConstraint(
            ["pending_card_id"],
            ["cards.id"],
            name=op.f("fk_conversations_pending_card_id_cards"),
        ),
        sa.ForeignKeyConstraint(
            ["pending_source_account_id"],
            ["accounts.id"],
            name=op.f("fk_conversations_pending_source_account_id_accounts"),
        ),
        sa.PrimaryKeyConstraint("id", name=op.f("pk_conversations")),
    )
    op.create_table(
        "messages",
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.Column("conversation_id", sa.Uuid(), nullable=False),
        sa.Column("role", sa.String(length=9), nullable=False),
        sa.Column("content", sa.Text(), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.CheckConstraint(
            "role IN ('USER', 'ASSISTANT')", name=op.f("ck_messages_role")
        ),
        sa.CheckConstraint(
            r"content ~ '\S'", name=op.f("ck_messages_content_not_blank")
        ),
        sa.ForeignKeyConstraint(
            ["conversation_id"],
            ["conversations.id"],
            name=op.f("fk_messages_conversation_id_conversations"),
        ),
        sa.PrimaryKeyConstraint("id", name=op.f("pk_messages")),
    )
    op.create_index(
        "ix_messages_conversation_id_created_at_id",
        "messages",
        ["conversation_id", "created_at", "id"],
        unique=False,
    )


def downgrade() -> None:
    """Downgrade schema."""
    op.drop_index("ix_messages_conversation_id_created_at_id", table_name="messages")
    op.drop_table("messages")
    op.drop_table("conversations")
    op.drop_index("ix_transactions_account_id_occurred_at", table_name="transactions")
    op.drop_table("transactions")
    op.drop_table("transfers")
    op.drop_table("cards")
    op.drop_table("beneficiaries")
    op.drop_table("accounts")
    op.drop_table("customers")
