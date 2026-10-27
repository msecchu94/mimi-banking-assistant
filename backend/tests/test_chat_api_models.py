from decimal import Decimal
from typing import Any
from uuid import UUID

import pytest
from pydantic import TypeAdapter, ValidationError

from mimi.api.chat_models import (
    CancelRequest,
    CardConfirmationSummary,
    ChatRequest,
    ChatResponse,
    ConfirmationUi,
    ConfirmPayload,
    ConfirmRequest,
    IntentType,
    MessageRequest,
    Money,
    SelectCardPayload,
    SelectCardRequest,
    TransferConfirmationSummary,
    UiResponse,
    UiType,
)
from mimi.domain.enums import ConversationFlowState, Currency

CONVERSATION_ID = "9e47b4c1-4a8c-4a3c-98d2-a31c9c87e641"
OPERATION_ID = "5b0c7d2e-3f41-4a6b-9c8d-1e2f3a4b5c6d"
CARD_ID = "16e39f21-93b5-48b5-a8dc-90ad03ea5dd1"

REQUESTS = TypeAdapter[Any](ChatRequest)
UI = TypeAdapter[Any](UiResponse)


def request(**fields: Any) -> dict[str, Any]:
    return {"conversation_id": CONVERSATION_ID, **fields}


# Requests.


@pytest.mark.parametrize(
    ("body", "expected"),
    [
        (
            request(message="What's my balance?"),
            MessageRequest(
                conversation_id=UUID(CONVERSATION_ID), message="What's my balance?"
            ),
        ),
        (
            request(interaction="CONFIRM", payload={"operation_id": OPERATION_ID}),
            ConfirmRequest(
                conversation_id=UUID(CONVERSATION_ID),
                interaction="CONFIRM",
                payload=ConfirmPayload(operation_id=UUID(OPERATION_ID)),
            ),
        ),
        (
            request(interaction="CANCEL"),
            CancelRequest(conversation_id=UUID(CONVERSATION_ID), interaction="CANCEL"),
        ),
        (
            request(interaction="CANCEL", payload=None),
            CancelRequest(conversation_id=UUID(CONVERSATION_ID), interaction="CANCEL"),
        ),
        (
            request(interaction="SELECT_CARD", payload={"card_id": CARD_ID}),
            SelectCardRequest(
                conversation_id=UUID(CONVERSATION_ID),
                interaction="SELECT_CARD",
                payload=SelectCardPayload(card_id=UUID(CARD_ID)),
            ),
        ),
    ],
    ids=["message", "confirm", "cancel", "cancel_null_payload", "select_card"],
)
def test_contract_requests_are_accepted(body: dict[str, Any], expected: Any) -> None:
    assert REQUESTS.validate_python(body) == expected
    assert REQUESTS.validate_json(REQUESTS.dump_json(expected)) == expected


@pytest.mark.parametrize(
    "body",
    [
        request(
            message="Yes.",
            interaction="CONFIRM",
            payload={"operation_id": OPERATION_ID},
        ),
        request(),
        request(message="Yes.", payload={"operation_id": OPERATION_ID}),
        request(message=""),
        request(message=" \n\t"),
        request(message=None),
        request(interaction="CONFIRM"),
        request(interaction="CONFIRM", payload={}),
        request(interaction="CONFIRM", payload={"operation_id": "not-a-uuid"}),
        request(interaction="CONFIRM", payload={"card_id": CARD_ID}),
        request(
            interaction="CONFIRM",
            payload={"operation_id": OPERATION_ID, "card_id": CARD_ID},
        ),
        request(interaction="CANCEL", payload={}),
        request(interaction="CANCEL", payload={"operation_id": OPERATION_ID}),
        request(interaction="SELECT_CARD"),
        request(interaction="SELECT_CARD", payload={"operation_id": OPERATION_ID}),
        request(interaction="APPROVE", payload={"operation_id": OPERATION_ID}),
        request(message="Hi", customer_id=CARD_ID),
        {"message": "Hi"},
        request(message="Hi", conversation_id="not-a-uuid"),
    ],
    ids=[
        "message_and_interaction",
        "neither",
        "message_with_payload",
        "empty_message",
        "blank_message",
        "null_message",
        "confirm_without_payload",
        "confirm_empty_payload",
        "confirm_malformed_operation_id",
        "confirm_card_payload",
        "confirm_extra_payload_field",
        "cancel_object_payload",
        "cancel_confirm_payload",
        "select_card_without_payload",
        "select_card_confirm_payload",
        "unknown_interaction",
        "unknown_field",
        "missing_conversation_id",
        "malformed_conversation_id",
    ],
)
def test_invalid_requests_are_rejected(body: dict[str, Any]) -> None:
    with pytest.raises(ValidationError):
        REQUESTS.validate_python(body)


def test_request_schema_lists_one_variant_per_request_kind() -> None:
    schema = REQUESTS.json_schema()

    variants = {ref["$ref"].rsplit("/", 1)[1] for ref in schema["oneOf"]}
    assert variants == {
        "MessageRequest",
        "ConfirmRequest",
        "CancelRequest",
        "SelectCardRequest",
    }
    confirm = schema["$defs"]["ConfirmRequest"]
    assert confirm["required"] == ["conversation_id", "interaction", "payload"]
    assert confirm["additionalProperties"] is False
    assert schema["$defs"]["CancelRequest"]["properties"]["payload"]["type"] == "null"


# Responses.

METADATA = {"request_id": "req-50dc23a1", "timestamp": "2026-10-09T16:30:00Z"}
MONEY = {"amount": "25000.00", "currency": "ARS"}
CARD = {
    "id": CARD_ID,
    "brand": "VISA",
    "type": "DEBIT",
    "last_four": "4821",
    "status": "ACTIVE",
}

# The contract's example of each UI type.
UI_EXAMPLES: dict[str, dict[str, Any]] = {
    "TEXT": {},
    "CARD_LIST": {
        "cards": [
            CARD,
            {
                "id": "738b6767-11ef-45a9-8147-f67c9d37b411",
                "brand": "MASTERCARD",
                "type": "CREDIT",
                "last_four": "9314",
                "status": "ACTIVE",
            },
        ]
    },
    "CARD_SELECTOR": {"cards": [CARD]},
    "BENEFICIARY_LIST": {
        "beneficiaries": [
            {
                "id": "b43b2bd2-ef66-46a7-93b5-b617ee28c40e",
                "name": "Laura",
                "account_reference": "****4582",
                "bank_name": "Example Bank",
            },
            {
                "id": "c1c5b1f2-0f0e-4d3c-9a0b-2d6f1e7a8b9c",
                "name": "Carlos",
                "account_reference": "****1234",
                "bank_name": None,
            },
        ]
    },
    "CONFIRMATION": {
        "operation_id": OPERATION_ID,
        "title": "Confirm transfer",
        "summary": {"type": "TRANSFER", "amount": MONEY, "beneficiary": "Laura"},
        "actions": [
            {"type": "CONFIRM", "label": "Confirm"},
            {"type": "CANCEL", "label": "Cancel"},
        ],
    },
    "EXPENSE_SUMMARY": {
        "period": {"from": "2026-10-01", "to": "2026-10-31"},
        "currencies": [
            {
                "total": {"amount": "185000.00", "currency": "ARS"},
                "categories": [
                    {
                        "category": "DINING",
                        "amount": {"amount": "85000.00", "currency": "ARS"},
                    },
                    {
                        "category": "GROCERIES",
                        "amount": {"amount": "60000.00", "currency": "ARS"},
                    },
                ],
            },
            {
                "total": {"amount": "120.00", "currency": "USD"},
                "categories": [
                    {
                        "category": "SUBSCRIPTIONS",
                        "amount": {"amount": "120.00", "currency": "USD"},
                    }
                ],
            },
        ],
    },
    "EXPENSE_COMPARISON": {
        "current_period": {"from": "2026-10-01", "to": "2026-10-31"},
        "previous_period": {"from": "2026-09-01", "to": "2026-09-30"},
        "currencies": [
            {
                "current_total": {"amount": "185000.00", "currency": "ARS"},
                "previous_total": {"amount": "160000.00", "currency": "ARS"},
                "difference": MONEY,
                "change": "INCREASE",
            },
            {
                "current_total": {"amount": "80.00", "currency": "USD"},
                "previous_total": {"amount": "120.00", "currency": "USD"},
                "difference": {"amount": "40.00", "currency": "USD"},
                "change": "DECREASE",
            },
        ],
    },
    "TRANSACTION_LIST": {
        "transactions": [
            {
                "id": "9eab44a2-c710-4a0c-beb7-c24de95a9820",
                "description": "Supermarket",
                "amount": {"amount": "24500.00", "currency": "ARS"},
                "type": "DEBIT",
                "category": "GROCERIES",
                "occurred_at": "2026-10-08T18:30:00Z",
            }
        ]
    },
    "TRANSFER_SUMMARY": {
        "transfer_id": "c919db94-a92f-4bc5-9355-32e90a10c632",
        "beneficiary": "Laura",
        "amount": MONEY,
        "status": "COMPLETED",
        "executed_at": "2026-10-09T16:30:00Z",
    },
}


def response(ui_type: str, data: dict[str, Any]) -> dict[str, Any]:
    return {
        "conversation_id": CONVERSATION_ID,
        "message": "Done.",
        "intent": "GENERAL_CONVERSATION",
        "conversation_state": "READY",
        "ui": {"type": ui_type, "data": data},
        "metadata": METADATA,
    }


def test_every_ui_type_has_a_contract_example() -> None:
    assert set(UI_EXAMPLES) == set(UiType)


@pytest.mark.parametrize("ui_type", list(UI_EXAMPLES))
def test_contract_responses_round_trip_unchanged(ui_type: str) -> None:
    body = response(ui_type, UI_EXAMPLES[ui_type])

    parsed = ChatResponse.model_validate_json(
        ChatResponse.model_validate(body).model_dump_json()
    )

    assert parsed.ui.type == ui_type
    assert parsed.model_dump(mode="json") == body


def test_card_confirmation_summary_carries_the_card() -> None:
    data = {
        **UI_EXAMPLES["CONFIRMATION"],
        "title": "Confirm card freeze",
        "summary": {"type": "CARD", "card": CARD},
    }
    body = response("CONFIRMATION", data)

    parsed = ChatResponse.model_validate(body)

    assert isinstance(parsed.ui, ConfirmationUi)
    assert isinstance(parsed.ui.data.summary, CardConfirmationSummary)
    assert parsed.model_dump(mode="json") == body


@pytest.mark.parametrize(
    "summary",
    [
        {"amount": MONEY, "beneficiary": "Laura"},
        {"type": "CARD", "amount": MONEY, "beneficiary": "Laura"},
        {"type": "TRANSFER", "card": CARD},
        {"type": "FREEZE_CARD", "card": CARD},
    ],
    ids=["untyped", "card_with_transfer_data", "transfer_with_card", "unknown_type"],
)
def test_confirmation_summary_must_match_its_type(summary: dict[str, Any]) -> None:
    data = {**UI_EXAMPLES["CONFIRMATION"], "summary": summary}

    with pytest.raises(ValidationError):
        UI.validate_python({"type": "CONFIRMATION", "data": data})


@pytest.mark.parametrize(
    ("ui_type", "data"),
    [
        ("TEXT", UI_EXAMPLES["CARD_LIST"]),
        ("CARD_LIST", UI_EXAMPLES["BENEFICIARY_LIST"]),
        ("CONFIRMATION", {**UI_EXAMPLES["CONFIRMATION"], "operation_id": None}),
        ("ERROR", {}),
        (
            "EXPENSE_SUMMARY",
            {
                "period": {"from": "2026-10-01", "to": "2026-10-31"},
                "total": MONEY,
                "categories": [],
            },
        ),
        (
            "EXPENSE_COMPARISON",
            {
                **UI_EXAMPLES["EXPENSE_COMPARISON"],
                "currencies": [
                    {
                        "current_total": MONEY,
                        "previous_total": MONEY,
                        "difference": {"amount": "-1.00", "currency": "ARS"},
                        "change": "DECREASE",
                    }
                ],
            },
        ),
        (
            "EXPENSE_COMPARISON",
            {
                **UI_EXAMPLES["EXPENSE_COMPARISON"],
                "currencies": [
                    {
                        "current_total": MONEY,
                        "previous_total": MONEY,
                        "difference": MONEY,
                        "change": "UP",
                    }
                ],
            },
        ),
    ],
    ids=[
        "text_with_cards",
        "cards_with_beneficiaries",
        "no_operation_id",
        "error",
        "combined_expense_total",
        "negative_difference",
        "unknown_change",
    ],
)
def test_ui_data_must_match_its_type(ui_type: str, data: dict[str, Any]) -> None:
    with pytest.raises(ValidationError):
        UI.validate_python({"type": ui_type, "data": data})


@pytest.mark.parametrize(
    ("amount", "serialized"),
    [
        (Decimal("25000"), "25000.00"),
        (Decimal("25000.5"), "25000.50"),
        (Decimal("25000.00"), "25000.00"),
        (Decimal("0.010"), "0.01"),
        (Decimal("-25000.00"), "-25000.00"),
        (Decimal("1E+3"), "1000.00"),
    ],
)
def test_money_amount_serializes_as_a_two_decimal_string(
    amount: Decimal, serialized: str
) -> None:
    money = Money(amount=amount, currency=Currency.ARS)

    assert money.model_dump(mode="json") == {"amount": serialized, "currency": "ARS"}
    assert money.model_dump_json() == f'{{"amount":"{serialized}","currency":"ARS"}}'


@pytest.mark.parametrize(
    "amount", [Decimal("25000.001"), Decimal("0.005"), Decimal("NaN"), "Infinity"]
)
def test_money_amount_with_unsupported_precision_is_rejected(
    amount: Decimal | str,
) -> None:
    with pytest.raises(ValidationError):
        Money(amount=amount, currency=Currency.ARS)


def test_confirmation_summary_variants_default_their_type() -> None:
    money = Money(amount=Decimal("25000"), currency=Currency.ARS)

    summary = TransferConfirmationSummary(amount=money, beneficiary="Laura")

    assert summary.model_dump(mode="json") == {
        "type": "TRANSFER",
        "amount": MONEY,
        "beneficiary": "Laura",
    }


def test_response_rejects_naive_datetimes() -> None:
    body = response("TEXT", {})
    body["metadata"] = {**METADATA, "timestamp": "2026-10-09T16:30:00"}

    with pytest.raises(ValidationError):
        ChatResponse.model_validate(body)


def test_intent_and_conversation_state_vocabularies_match_the_contract() -> None:
    assert [intent.value for intent in IntentType] == [
        "GET_BALANCE",
        "GET_TRANSACTIONS",
        "ANALYZE_EXPENSES",
        "COMPARE_EXPENSES",
        "GET_CARDS",
        "FREEZE_CARD",
        "UNFREEZE_CARD",
        "GET_BENEFICIARIES",
        "TRANSFER_MONEY",
        "GENERAL_CONVERSATION",
        "CANCEL",
        "UNKNOWN",
    ]
    assert [state.value for state in ConversationFlowState] == [
        "READY",
        "COLLECTING_DATA",
        "WAITING_CONFIRMATION",
    ]


def test_response_schema_discriminates_ui_types_and_carries_money_as_strings() -> None:
    schema = ChatResponse.model_json_schema(mode="serialization")
    defs = schema["$defs"]

    ui = schema["properties"]["ui"]
    assert set(ui["discriminator"]["mapping"]) == set(UiType)
    assert ui["discriminator"]["propertyName"] == "type"
    summary = defs["ConfirmationUiData"]["properties"]["summary"]
    assert set(summary["discriminator"]["mapping"]) == {"TRANSFER", "CARD"}
    assert defs["Money"]["properties"]["amount"] == {
        "type": "string",
        "pattern": r"^-?\d+\.\d{2}$",
        "title": "Amount",
    }
    assert set(defs["ExpensePeriod"]["properties"]) == {"from", "to"}
    assert "type" in defs["TextUi"]["required"]
    assert "type" in defs["TransferConfirmationSummary"]["required"]
    assert defs["BeneficiaryItem"]["properties"]["bank_name"]["anyOf"] == [
        {"type": "string"},
        {"type": "null"},
    ]
