"""Conversational context preserved within one active Conversation."""

from dataclasses import dataclass
from datetime import datetime

from mimi.application.interpretation import Intent, Interpretation, PeriodReference
from mimi.domain.enums import TransactionCategory, TransactionType


@dataclass(frozen=True)
class TemporalContext:
    """The periods of the last query, as the user referred to them.

    ``anchored_at`` is when the query ran, so a follow-up can detect that a
    symbolic period such as ``CURRENT_MONTH`` now resolves to other dates.
    """

    period: PeriodReference
    comparison_period: PeriodReference | None
    anchored_at: datetime

    def __post_init__(self) -> None:
        if self.anchored_at.utcoffset() is None:
            raise ValueError("anchored_at must be timezone-aware")


@dataclass(frozen=True)
class ConversationContext:
    """What a follow-up may inherit: the last executed read-only query.

    Built only from validated queries the application executed, never from
    raw model output. It holds one query at a time, replaced after every
    executed read-only query.
    """

    last_intent: Intent | None = None
    category: TransactionCategory | None = None
    transaction_type: TransactionType | None = None
    temporal: TemporalContext | None = None

    def __post_init__(self) -> None:
        if self.last_intent is None and (
            self.category is not None
            or self.transaction_type is not None
            or self.temporal is not None
        ):
            raise ValueError("context without a last intent must be empty")

    @classmethod
    def after_query(cls, query: Interpretation, now: datetime) -> "ConversationContext":
        """Context after executing ``query``, a prepared read-only query whose
        defaults are already applied."""
        return cls(
            last_intent=query.intent,
            category=query.category,
            transaction_type=query.transaction_type,
            temporal=(
                None
                if query.period is None
                else TemporalContext(query.period, query.comparison_period, now)
            ),
        )


EMPTY_CONTEXT = ConversationContext()
