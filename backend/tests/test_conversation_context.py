from datetime import UTC, datetime

import pytest

from mimi.application.conversation_context import (
    EMPTY_CONTEXT,
    ConversationContext,
    TemporalContext,
)
from mimi.application.interpretation import Intent, Interpretation, PeriodReference
from mimi.domain.enums import TransactionCategory, TransactionType

NOW = datetime(2026, 10, 9, 16, 31, 4, tzinfo=UTC)


def test_context_after_query_keeps_its_effective_values() -> None:
    query = Interpretation(
        intent=Intent.COMPARE_EXPENSES,
        category=TransactionCategory.DINING,
        period=PeriodReference.CURRENT_MONTH,
        comparison_period=PeriodReference.PREVIOUS_MONTH,
    )

    assert ConversationContext.after_query(query, NOW) == ConversationContext(
        last_intent=Intent.COMPARE_EXPENSES,
        category=TransactionCategory.DINING,
        temporal=TemporalContext(
            PeriodReference.CURRENT_MONTH, PeriodReference.PREVIOUS_MONTH, NOW
        ),
    )


def test_context_after_query_without_period_has_no_temporal_context() -> None:
    query = Interpretation(
        intent=Intent.GET_TRANSACTIONS, transaction_type=TransactionType.CREDIT
    )

    assert ConversationContext.after_query(query, NOW) == ConversationContext(
        last_intent=Intent.GET_TRANSACTIONS, transaction_type=TransactionType.CREDIT
    )


def test_empty_context_has_no_last_query() -> None:
    assert EMPTY_CONTEXT == ConversationContext()
    assert EMPTY_CONTEXT.last_intent is None


@pytest.mark.parametrize(
    "values",
    [
        {"category": TransactionCategory.DINING},
        {"transaction_type": TransactionType.DEBIT},
        {"temporal": TemporalContext(PeriodReference.TODAY, None, NOW)},
    ],
)
def test_context_values_require_a_last_intent(values: dict[str, object]) -> None:
    with pytest.raises(ValueError, match="must be empty"):
        ConversationContext(**values)  # type: ignore[arg-type]


def test_temporal_context_requires_aware_anchor() -> None:
    with pytest.raises(ValueError, match="timezone-aware"):
        TemporalContext(PeriodReference.TODAY, None, datetime(2026, 10, 9, 13, 0))
