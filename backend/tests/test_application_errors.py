import pytest

from mimi.application.errors import (
    BusinessRuleViolationError,
    ConflictError,
    DependencyUnavailableError,
    LLMInvalidResponseError,
    LLMUnavailableError,
    NotFoundError,
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
