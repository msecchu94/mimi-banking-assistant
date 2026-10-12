import logging
from datetime import UTC, datetime
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


def internal_error_response(request: Request, exc: Exception) -> JSONResponse:
    request_id = new_request_id()
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
                return error_response(
                    status_code, exc.code, exc.message, new_request_id()
                )
    # An error outside every category is a programming error, not client-facing.
    return internal_error_response(request, exc)


async def handle_request_validation_error(
    request: Request, exc: Exception
) -> JSONResponse:
    return error_response(
        422, INVALID_REQUEST, INVALID_REQUEST_MESSAGE, new_request_id()
    )


async def handle_unexpected_error(request: Request, exc: Exception) -> JSONResponse:
    return internal_error_response(request, exc)


def register_error_handlers(app: FastAPI) -> None:
    app.add_exception_handler(ApplicationError, handle_application_error)
    app.add_exception_handler(RequestValidationError, handle_request_validation_error)
    app.add_exception_handler(Exception, handle_unexpected_error)
