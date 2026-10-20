"""unresolved transfer amount

A pending transfer may keep a stated amount whose currency is not yet
determined: ``pending_amount`` without ``pending_currency``, while ``amount``
is still a missing field.

Revision ID: 0002
Revises: 0001
Create Date: 2026-10-20 12:00:00.000000

"""

from collections.abc import Sequence

from alembic import op

# revision identifiers, used by Alembic.
revision: str = "0002"
down_revision: str | Sequence[str] | None = "0001"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None


def upgrade() -> None:
    """Upgrade schema."""
    op.drop_constraint(
        op.f("ck_conversations_pending_amount_has_currency"),
        "conversations",
        type_="check",
    )
    op.create_check_constraint(
        op.f("ck_conversations_pending_currency_has_amount"),
        "conversations",
        "pending_currency IS NULL OR pending_amount IS NOT NULL",
    )
    op.create_check_constraint(
        op.f("ck_conversations_unresolved_amount_is_missing"),
        "conversations",
        "pending_amount IS NULL OR pending_currency IS NOT NULL "
        "OR 'amount' = ANY(pending_missing_fields)",
    )


def downgrade() -> None:
    """Downgrade schema.

    The previous schema cannot hold an unresolved amount, so it is dropped;
    ``amount`` is already a missing field of those operations.
    """
    op.drop_constraint(
        op.f("ck_conversations_unresolved_amount_is_missing"),
        "conversations",
        type_="check",
    )
    op.drop_constraint(
        op.f("ck_conversations_pending_currency_has_amount"),
        "conversations",
        type_="check",
    )
    op.execute(
        "UPDATE conversations SET pending_amount = NULL "
        "WHERE pending_currency IS NULL AND pending_amount IS NOT NULL"
    )
    op.create_check_constraint(
        op.f("ck_conversations_pending_amount_has_currency"),
        "conversations",
        "(pending_amount IS NULL) = (pending_currency IS NULL)",
    )
