import pytest

from mimi.application.errors import (
    ApplicationError,
    BusinessRuleViolationError,
    ConflictError,
    ConversationClosedError,
    ConversationNotFoundError,
    DependencyUnavailableError,
    InvalidConversationStateError,
    LLMInvalidResponseError,
    LLMUnavailableError,
    NotFoundError,
    PendingOperationConflictError,
)


class WidgetNotFoundError(NotFoundError):
    code = "WIDGET_NOT_FOUND"
    default_message = "The requested widget was not found."


def test_concrete_error_uses_default_message() -> None:
    error = WidgetNotFoundError()

    assert error.code == "WIDGET_NOT_FOUND"
    assert error.message == "The requested widget was not found."


def test_concrete_error_accepts_message_override() -> None:
    error = WidgetNotFoundError("Widget 42 was not found.")

    assert error.message == "Widget 42 was not found."


@pytest.mark.parametrize(
    "category",
    [
        NotFoundError,
        ConflictError,
        BusinessRuleViolationError,
        DependencyUnavailableError,
    ],
)
def test_error_categories_cannot_be_raised_directly(
    category: type[Exception],
) -> None:
    with pytest.raises(TypeError, match="error category"):
        category()


@pytest.mark.parametrize("error_type", [LLMUnavailableError, LLMInvalidResponseError])
def test_llm_errors_are_dependency_unavailable_with_public_code(
    error_type: type[DependencyUnavailableError],
) -> None:
    error = error_type()

    assert isinstance(error, DependencyUnavailableError)
    assert error.code == "SERVICE_UNAVAILABLE"
    assert error.message == "The service is temporarily unavailable."


@pytest.mark.parametrize(
    ("error_type", "category", "code"),
    [
        (ConversationNotFoundError, NotFoundError, "CONVERSATION_NOT_FOUND"),
        (ConversationClosedError, ConflictError, "CONVERSATION_CLOSED"),
        (
            InvalidConversationStateError,
            ConflictError,
            "INVALID_CONVERSATION_STATE",
        ),
        (
            PendingOperationConflictError,
            ConflictError,
            "PENDING_OPERATION_CONFLICT",
        ),
    ],
)
def test_conversation_errors_use_public_codes(
    error_type: type[ApplicationError], category: type[ApplicationError], code: str
) -> None:
    error = error_type()

    assert isinstance(error, category)
    assert error.code == code
