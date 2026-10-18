"""Application-level result of interpreting a user's natural-language message."""

from dataclasses import dataclass, field
from decimal import Decimal
from enum import StrEnum

from mimi.domain.enums import Currency, TransactionCategory, TransactionType


class Intent(StrEnum):
    GET_BALANCE = "GET_BALANCE"
    GET_TRANSACTIONS = "GET_TRANSACTIONS"
    ANALYZE_EXPENSES = "ANALYZE_EXPENSES"
    COMPARE_EXPENSES = "COMPARE_EXPENSES"
    GET_CARDS = "GET_CARDS"
    FREEZE_CARD = "FREEZE_CARD"
    UNFREEZE_CARD = "UNFREEZE_CARD"
    GET_BENEFICIARIES = "GET_BENEFICIARIES"
    TRANSFER_MONEY = "TRANSFER_MONEY"
    GENERAL_CONVERSATION = "GENERAL_CONVERSATION"
    CANCEL = "CANCEL"
    UNKNOWN = "UNKNOWN"


class PeriodReference(StrEnum):
    """A period as the user referred to it, not yet resolved to dates."""

    CURRENT_MONTH = "CURRENT_MONTH"
    PREVIOUS_MONTH = "PREVIOUS_MONTH"


@dataclass(frozen=True)
class Interpretation:
    """Validated candidate interpretation of a single message.

    Values are well-formed but not authoritative: references are unresolved
    text, and completeness, resolution and business rules are decided later.
    Only fields relevant to ``intent`` are set. ``invalid_fields`` names fields
    the model extracted with a malformed value, which were discarded.

    For ``COMPARE_EXPENSES``, ``period`` is the period of interest and
    ``comparison_period`` the one it is compared against.
    """

    intent: Intent
    amount: Decimal | None = None
    currency: Currency | None = None
    beneficiary_reference: str | None = None
    card_reference: str | None = None
    category: TransactionCategory | None = None
    transaction_type: TransactionType | None = None
    period: PeriodReference | None = None
    comparison_period: PeriodReference | None = None
    invalid_fields: frozenset[str] = field(default_factory=frozenset)
