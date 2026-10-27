from datetime import UTC, datetime
from typing import Annotated, assert_never
from uuid import UUID
from zoneinfo import ZoneInfo

from fastapi import APIRouter, Body, Depends, Request

from mimi.api.chat_mapping import present_turn
from mimi.api.chat_models import (
    CancelRequest,
    ChatRequest,
    ChatResponse,
    ConfirmRequest,
    ConversationResponse,
    MessageRequest,
    ResponseMetadata,
    SelectCardRequest,
)
from mimi.api.errors import error_responses, get_request_id
from mimi.application.conversation_engine import ConversationEngine
from mimi.application.interactions import Cancel, Confirm, SelectCard
from mimi.composition import Container
from mimi.config import Settings

router = APIRouter()


def require_demo_customer_id(settings: Settings) -> UUID:
    """The customer every Chat API request acts for; V1 serves one demo
    customer and has no authentication."""
    if settings.demo_customer_id is None:
        raise ValueError("MIMI_DEMO_CUSTOMER_ID is required to serve the Chat API")
    return settings.demo_customer_id


def get_container(request: Request) -> Container:
    container: Container = request.app.state.container
    return container


def get_conversation_engine(
    container: Annotated[Container, Depends(get_container)],
) -> ConversationEngine:
    return container.conversation_engine


def get_customer_id(container: Annotated[Container, Depends(get_container)]) -> UUID:
    return require_demo_customer_id(container.settings)


def get_timezone(container: Annotated[Container, Depends(get_container)]) -> ZoneInfo:
    return container.settings.timezone


def new_metadata(request_id: str) -> ResponseMetadata:
    return ResponseMetadata(request_id=request_id, timestamp=datetime.now(UTC))


INTERNAL_ERROR_DESCRIPTION = "Unexpected backend failure: INTERNAL_ERROR."

CONVERSATION_ERRORS = error_responses({500: INTERNAL_ERROR_DESCRIPTION})

CHAT_ERRORS = error_responses(
    {
        404: (
            "The conversation or a financial resource was not found: "
            "CONVERSATION_NOT_FOUND, ACCOUNT_NOT_FOUND, CARD_NOT_FOUND, "
            "BENEFICIARY_NOT_FOUND."
        ),
        409: (
            "The request conflicts with the conversation or resource state: "
            "CONVERSATION_CLOSED, INVALID_CONVERSATION_STATE, INVALID_INTERACTION, "
            "PENDING_OPERATION_CONFLICT, INVALID_ACCOUNT_STATE, INVALID_CARD_STATE."
        ),
        422: (
            "The request is invalid (INVALID_REQUEST) or violates a business "
            "rule: INVALID_AMOUNT, INSUFFICIENT_FUNDS."
        ),
        500: INTERNAL_ERROR_DESCRIPTION,
        503: ("A required dependency is temporarily unavailable: SERVICE_UNAVAILABLE."),
    }
)


@router.post("/conversations", status_code=201, responses=CONVERSATION_ERRORS)
def start_conversation(
    engine: Annotated[ConversationEngine, Depends(get_conversation_engine)],
    customer_id: Annotated[UUID, Depends(get_customer_id)],
    request_id: Annotated[str, Depends(get_request_id)],
) -> ConversationResponse:
    record = engine.start(customer_id)
    return ConversationResponse(
        conversation_id=record.conversation.id,
        conversation_state=record.flow_state,
        metadata=new_metadata(request_id),
    )


@router.post("/chat", responses=CHAT_ERRORS)
def chat(
    body: Annotated[ChatRequest, Body()],
    engine: Annotated[ConversationEngine, Depends(get_conversation_engine)],
    customer_id: Annotated[UUID, Depends(get_customer_id)],
    timezone: Annotated[ZoneInfo, Depends(get_timezone)],
    request_id: Annotated[str, Depends(get_request_id)],
) -> ChatResponse:
    """Handle one free-text message or structured interaction."""
    match body:
        case MessageRequest():
            turn = engine.handle_message(
                customer_id, body.conversation_id, body.message
            )
        case ConfirmRequest():
            turn = engine.handle_interaction(
                customer_id,
                body.conversation_id,
                Confirm(body.payload.operation_id),
            )
        case CancelRequest():
            turn = engine.handle_interaction(
                customer_id, body.conversation_id, Cancel()
            )
        case SelectCardRequest():
            turn = engine.handle_interaction(
                customer_id, body.conversation_id, SelectCard(body.payload.card_id)
            )
        case _:
            assert_never(body)
    return present_turn(turn, timezone, new_metadata(request_id))
