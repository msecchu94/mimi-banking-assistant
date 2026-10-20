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

    TODAY = "TODAY"
    YESTERDAY = "YESTERDAY"
    CURRENT_WEEK = "CURRENT_WEEK"
    PREVIOUS_WEEK = "PREVIOUS_WEEK"
    CURRENT_MONTH = "CURRENT_MONTH"
    PREVIOUS_MONTH = "PREVIOUS_MONTH"


@dataclass(frozen=True)
class Interpretation:
    """Validated candidate interpretation of a single message.

    Values are well-formed but not authoritative: references are unresolved
    text, and completeness, resolution and business rules are decided later.
    Only fields relevant to ``intent`` are set. ``invalid_fields`` names fields
    the model extracted with a malformed value, which were discarded.
    ``unsupported_fields`` names fields the user stated with a value V1 cannot
    represent (e.g. another currency, a named month or several categories);
    those fields are unset.

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
    unsupported_fields: frozenset[str] = field(default_factory=frozenset)


class RelativePeriod(StrEnum):
    """A period stated relative to the one the conversation is about."""

    PREVIOUS = "PREVIOUS"


@dataclass(frozen=True)
class FollowUp:
    """Validated candidate continuation of the conversation's last query.

    Carries only values stated in the message, e.g. "¿Y el anterior?" or "And
    on groceries?". The intent and every unstated value come from the
    conversation's context, so a ``FollowUp`` is never routed directly: it is
    first resolved into an ``Interpretation``. ``relative_period`` is the
    period relative to the one in context; it is never set together with
    ``period``.
    """

    category: TransactionCategory | None = None
    transaction_type: TransactionType | None = None
    period: PeriodReference | None = None
    relative_period: RelativePeriod | None = None
    invalid_fields: frozenset[str] = field(default_factory=frozenset)
    unsupported_fields: frozenset[str] = field(default_factory=frozenset)


@dataclass(frozen=True)
class CollectionInput:
    """Validated candidate data for the pending state-changing operation.

    Carries only values stated in the message, such as "25000", "a Carlos" or
    "la Visa", including corrections of values supplied earlier. Like an
    ``Interpretation`` it is not authoritative: references are unresolved text
    that the application resolves, validates and merges. ``invalid_fields`` and
    ``unsupported_fields`` name fields the user stated with a value that was
    discarded.
    """

    amount: Decimal | None = None
    currency: Currency | None = None
    beneficiary_reference: str | None = None
    account_reference: str | None = None
    card_reference: str | None = None
    invalid_fields: frozenset[str] = field(default_factory=frozenset)
    unsupported_fields: frozenset[str] = field(default_factory=frozenset)

    @classmethod
    def from_interpretation(cls, interpretation: Interpretation) -> "CollectionInput":
        """The operation data stated in a state-changing request."""
        return cls(
            amount=interpretation.amount,
            currency=interpretation.currency,
            beneficiary_reference=interpretation.beneficiary_reference,
            card_reference=interpretation.card_reference,
            invalid_fields=interpretation.invalid_fields,
            unsupported_fields=interpretation.unsupported_fields,
        )
