import logging
from collections.abc import Mapping
from datetime import UTC, datetime
from typing import Any
from uuid import uuid4

from fastapi import FastAPI, Request
from fastapi.exceptions import RequestValidationError
from fastapi.responses import JSONResponse
from pydantic import AwareDatetime, BaseModel

from mimi.application.errors import (
    ApplicationError,
    BusinessRuleViolationError,
    ConflictError,
    DependencyUnavailableError,
    NotFoundError,
)

logger = logging.getLogger(__name__)

INVALID_REQUEST = "INVALID_REQUEST"
INTERNAL_ERROR = "INTERNAL_ERROR"

INVALID_REQUEST_MESSAGE = "The request is invalid."
INTERNAL_ERROR_MESSAGE = "An unexpected error occurred."

STATUS_BY_CATEGORY: tuple[tuple[type[ApplicationError], int], ...] = (
    (NotFoundError, 404),
    (ConflictError, 409),
    (BusinessRuleViolationError, 422),
    (DependencyUnavailableError, 503),
)


class ApiErrorResponse(BaseModel):
    code: str
    message: str
    request_id: str
    timestamp: AwareDatetime


def new_request_id() -> str:
    return str(uuid4())


def get_request_id(request: Request) -> str:
    """The ID of this HTTP request, created on first use.

    It is kept in the request state, which every layer handling the request
    shares, so its response and logs carry the same ID.
    """
    request_id: str | None = getattr(request.state, "request_id", None)
    if request_id is None:
        request_id = new_request_id()
        request.state.request_id = request_id
    return request_id


def error_responses(descriptions: Mapping[int, str]) -> dict[int | str, Any]:
    """OpenAPI documentation of the error statuses a route can return."""
    return {
        status_code: {"model": ApiErrorResponse, "description": description}
        for status_code, description in descriptions.items()
    }


def error_response(
    status_code: int, code: str, message: str, request_id: str
) -> JSONResponse:
    body = ApiErrorResponse(
        code=code,
        message=message,
        request_id=request_id,
        timestamp=datetime.now(UTC),
    )
    return JSONResponse(status_code=status_code, content=body.model_dump(mode="json"))


def handled_error_response(
    request: Request,
    status_code: int,
    code: str,
    message: str,
    exc: Exception | None = None,
) -> JSONResponse:
    """An error response for a failure the API maps by design.

    Client errors are logged at info level; an unavailable dependency is
    logged as a warning with its cause.
    """
    request_id = get_request_id(request)
    unavailable = status_code >= 500
    logger.log(
        logging.WARNING if unavailable else logging.INFO,
        "Request failed on %s %s with %s %s [request_id=%s]",
        request.method,
        request.url.path,
        status_code,
        code,
        request_id,
        exc_info=exc if unavailable else None,
    )
    return error_response(status_code, code, message, request_id)


def internal_error_response(request: Request, exc: Exception) -> JSONResponse:
    request_id = get_request_id(request)
    logger.error(
        "Unhandled error on %s %s [request_id=%s]",
        request.method,
        request.url.path,
        request_id,
        exc_info=exc,
    )
    return error_response(500, INTERNAL_ERROR, INTERNAL_ERROR_MESSAGE, request_id)


async def handle_application_error(request: Request, exc: Exception) -> JSONResponse:
    if isinstance(exc, ApplicationError):
        for category, status_code in STATUS_BY_CATEGORY:
            if isinstance(exc, category):
                return handled_error_response(
                    request, status_code, exc.code, exc.message, exc
                )
    # An error outside every category is a programming error, not client-facing.
    return internal_error_response(request, exc)


async def handle_request_validation_error(
    request: Request, exc: Exception
) -> JSONResponse:
    return handled_error_response(
        request, 422, INVALID_REQUEST, INVALID_REQUEST_MESSAGE
    )


async def handle_unexpected_error(request: Request, exc: Exception) -> JSONResponse:
    return internal_error_response(request, exc)


def register_error_handlers(app: FastAPI) -> None:
    app.add_exception_handler(ApplicationError, handle_application_error)
    app.add_exception_handler(RequestValidationError, handle_request_validation_error)
    app.add_exception_handler(Exception, handle_unexpected_error)
