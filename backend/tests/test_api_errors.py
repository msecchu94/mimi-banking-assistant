from collections.abc import Iterator
from datetime import datetime
from uuid import UUID

import pytest
from fastapi import FastAPI
from fastapi.testclient import TestClient

from mimi.application.errors import (
    ApplicationError,
    BusinessRuleViolationError,
    ConflictError,
    DependencyUnavailableError,
    NotFoundError,
)


class WidgetNotFoundError(NotFoundError):
    code = "WIDGET_NOT_FOUND"
    default_message = "The requested widget was not found."


class WidgetConflictError(ConflictError):
    code = "WIDGET_CONFLICT"
    default_message = "The widget is in a conflicting state."


class WidgetRuleViolationError(BusinessRuleViolationError):
    code = "INVALID_WIDGET"
    default_message = "The widget violates a business rule."


class WidgetStoreUnavailableError(DependencyUnavailableError):
    code = "SERVICE_UNAVAILABLE"
    default_message = "The service is temporarily unavailable."


class UncategorizedError(ApplicationError):
    code = "UNCATEGORIZED"
    default_message = "Uncategorized internal detail."


@pytest.fixture
def error_client(app: FastAPI) -> Iterator[TestClient]:
    @app.get("/test/raise/{name}")
    def raise_error(name: str) -> None:
        errors: dict[str, Exception] = {
            "not-found": WidgetNotFoundError(),
            "conflict": WidgetConflictError(),
            "rule": WidgetRuleViolationError(),
            "unavailable": WidgetStoreUnavailableError(),
            "custom-message": WidgetNotFoundError("Widget 42 was not found."),
            "uncategorized": UncategorizedError(),
            "unexpected": RuntimeError("database password is s3cret"),
        }
        raise errors[name]

    @app.get("/test/items/{item_id}")
    def get_item(item_id: int) -> dict[str, int]:
        return {"item_id": item_id}

    with TestClient(app, raise_server_exceptions=False) as client:
        yield client


def assert_error_response(
    body: dict[str, str], expected_code: str, expected_message: str
) -> None:
    assert set(body) == {"code", "message", "request_id", "timestamp"}
    assert body["code"] == expected_code
    assert body["message"] == expected_message
    UUID(body["request_id"])
    assert datetime.fromisoformat(body["timestamp"]).tzinfo is not None


@pytest.mark.parametrize(
    ("name", "status_code", "error"),
    [
        ("not-found", 404, WidgetNotFoundError),
        ("conflict", 409, WidgetConflictError),
        ("rule", 422, WidgetRuleViolationError),
        ("unavailable", 503, WidgetStoreUnavailableError),
    ],
)
def test_application_error_categories_map_to_http_status(
    error_client: TestClient,
    name: str,
    status_code: int,
    error: type[ApplicationError],
) -> None:
    response = error_client.get(f"/test/raise/{name}")

    assert response.status_code == status_code
    assert_error_response(response.json(), error.code, error.default_message)


def test_application_error_message_override_is_returned(
    error_client: TestClient,
) -> None:
    response = error_client.get("/test/raise/custom-message")

    assert response.status_code == 404
    assert_error_response(
        response.json(), "WIDGET_NOT_FOUND", "Widget 42 was not found."
    )


def test_request_validation_error_maps_to_invalid_request(
    error_client: TestClient,
) -> None:
    response = error_client.get("/test/items/not-a-number")

    assert response.status_code == 422
    assert_error_response(response.json(), "INVALID_REQUEST", "The request is invalid.")


def test_unexpected_error_maps_to_internal_error_without_leaking_details(
    error_client: TestClient, caplog: pytest.LogCaptureFixture
) -> None:
    response = error_client.get("/test/raise/unexpected")

    assert response.status_code == 500
    body = response.json()
    assert_error_response(body, "INTERNAL_ERROR", "An unexpected error occurred.")
    assert "s3cret" not in response.text
    assert "RuntimeError" not in response.text
    assert body["request_id"] in caplog.text


def test_uncategorized_application_error_maps_to_internal_error(
    error_client: TestClient,
) -> None:
    response = error_client.get("/test/raise/uncategorized")

    assert response.status_code == 500
    assert_error_response(
        response.json(), "INTERNAL_ERROR", "An unexpected error occurred."
    )
