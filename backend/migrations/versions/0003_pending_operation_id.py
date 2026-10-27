"""pending operation id

An operation waiting for confirmation is identified by ``pending_operation_id``,
the confirmation request a ``CONFIRM`` must name; no other state has one.

Operations already waiting for confirmation were offered without an
identifier, so no confirmation can name them: they are discarded and their
conversations return to READY. Nothing was executed, and messages and context
are kept.

Revision ID: 0003
Revises: 0002
Create Date: 2026-10-27 12:00:00.000000

"""

from collections.abc import Sequence

import sqlalchemy as sa
from alembic import op

# revision identifiers, used by Alembic.
revision: str = "0003"
down_revision: str | Sequence[str] | None = "0002"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None


def upgrade() -> None:
    """Upgrade schema."""
    op.add_column(
        "conversations", sa.Column("pending_operation_id", sa.Uuid(), nullable=True)
    )
    op.execute(
        "UPDATE conversations SET flow_state = 'READY', "
        "pending_operation_type = NULL, pending_source_account_id = NULL, "
        "pending_beneficiary_id = NULL, pending_amount = NULL, "
        "pending_currency = NULL, pending_card_id = NULL, "
        "pending_missing_fields = NULL "
        "WHERE flow_state = 'WAITING_CONFIRMATION'"
    )
    op.create_check_constraint(
        op.f("ck_conversations_waiting_confirmation_has_operation_id"),
        "conversations",
        "(pending_operation_id IS NOT NULL) = (flow_state = 'WAITING_CONFIRMATION')",
    )


def downgrade() -> None:
    """Downgrade schema.

    Operations waiting for confirmation remain valid without an identifier.
    """
    op.drop_constraint(
        op.f("ck_conversations_waiting_confirmation_has_operation_id"),
        "conversations",
        type_="check",
    )
    op.drop_column("conversations", "pending_operation_id")
