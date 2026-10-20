import json
from decimal import Decimal
from typing import Any

import httpx2
import pytest
from openai import OpenAI
from pydantic import BaseModel

from mimi.application.errors import LLMInvalidResponseError, LLMUnavailableError
from mimi.application.interpretation import CollectionInput
from mimi.application.pending_operations import PendingField
from mimi.application.use_cases.interpret_message import (
    MAX_REFERENCE_LENGTH,
    InterpretCollectionInput,
)
from mimi.domain.enums import Currency, PendingOperationType
from mimi.infrastructure.llm.openai_provider import OpenAILLMProvider

TRANSFER = PendingOperationType.TRANSFER
FREEZE_CARD = PendingOperationType.FREEZE_CARD
UNFREEZE_CARD = PendingOperationType.UNFREEZE_CARD

EMPTY_OUTPUT: dict[str, Any] = {
    "kind": "DETAILS",
    "amount": None,
    "currency": None,
    "beneficiary_reference": None,
    "account_reference": None,
    "card_reference": None,
}

ALL_FIELDS_OUTPUT: dict[str, Any] = {
    "kind": "DETAILS",
    "amount": "25000",
    "currency": "USD",
    "beneficiary_reference": "Carlos",
    "account_reference": "la cuenta en dólares",
    "card_reference": "la Visa",
}


def model_output(**fields: Any) -> dict[str, Any]:
    return {**EMPTY_OUTPUT, **fields}


class FakeLLMProvider:
    """Validates a canned payload against the requested schema, as a real
    provider would."""

    def __init__(
        self, output: dict[str, Any] | None = None, error: Exception | None = None
    ) -> None:
        self._output = output or EMPTY_OUTPUT
        self._error = error
        self.calls: list[dict[str, Any]] = []

    def generate_structured[T: BaseModel](
        self, *, instructions: str, input_text: str, output_type: type[T]
    ) -> T:
        self.calls.append({"instructions": instructions, "input_text": input_text})
        if self._error is not None:
            raise self._error
        return output_type.model_validate(self._output)


def interpret(
    output: dict[str, Any],
    operation_type: PendingOperationType = TRANSFER,
    missing: tuple[PendingField, ...] = (PendingField.AMOUNT,),
) -> CollectionInput | None:
    return InterpretCollectionInput(FakeLLMProvider(output)).execute(
        "a reply", operation_type, missing
    )


def test_transfer_details_keep_only_transfer_fields() -> None:
    assert interpret(ALL_FIELDS_OUTPUT) == CollectionInput(
        amount=Decimal("25000"),
        currency=Currency.USD,
        beneficiary_reference="Carlos",
        account_reference="la cuenta en dólares",
    )


@pytest.mark.parametrize("operation_type", [FREEZE_CARD, UNFREEZE_CARD])
def test_card_details_keep_only_the_card_reference(
    operation_type: PendingOperationType,
) -> None:
    result = interpret(ALL_FIELDS_OUTPUT, operation_type, (PendingField.CARD_ID,))

    assert result == CollectionInput(card_reference="la Visa")


def test_other_messages_are_not_collection_input() -> None:
    assert interpret(model_output(kind="OTHER", amount="25000")) is None


def test_details_without_values_are_empty_input() -> None:
    assert interpret(model_output()) == CollectionInput()


@pytest.mark.parametrize("amount", ["-50", "0", "25,000", "1e5", "25000.505"])
def test_malformed_amount_is_discarded_and_reported(amount: str) -> None:
    result = interpret(model_output(amount=amount))

    assert result == CollectionInput(invalid_fields=frozenset({"amount"}))


@pytest.mark.parametrize("field_name", ["amount", "currency"])
def test_unsupported_values_are_reported(field_name: str) -> None:
    result = interpret(model_output(**{field_name: "UNSUPPORTED"}))

    assert result == CollectionInput(unsupported_fields=frozenset({field_name}))


def test_references_are_stripped_and_overlong_ones_reported() -> None:
    result = interpret(
        model_output(
            beneficiary_reference="  Carlos ",
            account_reference="x" * (MAX_REFERENCE_LENGTH + 1),
        )
    )

    assert result == CollectionInput(
        beneficiary_reference="Carlos",
        invalid_fields=frozenset({"account_reference"}),
    )


def test_instructions_name_only_the_operation_and_its_missing_fields() -> None:
    llm = FakeLLMProvider()

    InterpretCollectionInput(llm).execute(
        "a Zoe", TRANSFER, (PendingField.BENEFICIARY_ID, PendingField.AMOUNT)
    )

    [call] = llm.calls
    assert call["input_text"] == "a Zoe"
    assert "Zoe" not in call["instructions"]
    assert "a money transfer" in call["instructions"]
    assert "Details still missing: the recipient, the amount." in call["instructions"]
    assert "card_reference" not in call["instructions"]


def test_card_instructions_describe_only_the_card() -> None:
    llm = FakeLLMProvider()

    InterpretCollectionInput(llm).execute(
        "la Visa", UNFREEZE_CARD, (PendingField.CARD_ID,)
    )

    [call] = llm.calls
    assert "unfreezing a card" in call["instructions"]
    assert "card_reference" in call["instructions"]
    assert "beneficiary_reference" not in call["instructions"]


@pytest.mark.parametrize("message", ["", "   "])
def test_blank_message_is_not_collection_input_without_calling_the_model(
    message: str,
) -> None:
    llm = FakeLLMProvider()

    assert (
        InterpretCollectionInput(llm).execute(message, TRANSFER, (PendingField.AMOUNT,))
        is None
    )
    assert llm.calls == []


@pytest.mark.parametrize(
    "error", [LLMUnavailableError(), LLMInvalidResponseError()], ids=type
)
def test_provider_errors_propagate(error: Exception) -> None:
    llm = FakeLLMProvider(error=error)

    with pytest.raises(type(error)):
        InterpretCollectionInput(llm).execute("25000", TRANSFER, (PendingField.AMOUNT,))


def test_interprets_through_the_openai_provider_with_a_strict_schema() -> None:
    requests: list[httpx2.Request] = []
    body = {
        "id": "resp_1",
        "object": "response",
        "created_at": 0,
        "model": "test-model",
        "status": "completed",
        "output": [
            {
                "type": "message",
                "id": "msg_1",
                "role": "assistant",
                "status": "completed",
                "content": [
                    {
                        "type": "output_text",
                        "text": json.dumps(model_output(amount="25000")),
                        "annotations": [],
                    }
                ],
            }
        ],
        "parallel_tool_calls": False,
        "tool_choice": "auto",
        "tools": [],
    }

    def handler(request: httpx2.Request) -> httpx2.Response:
        requests.append(request)
        return httpx2.Response(200, json=body)

    client = OpenAI(
        api_key="sk-test-not-a-real-key",
        max_retries=0,
        http_client=httpx2.Client(transport=httpx2.MockTransport(handler)),
    )
    provider = OpenAILLMProvider(client, "test-model")

    result = InterpretCollectionInput(provider).execute(
        "25000", TRANSFER, (PendingField.AMOUNT,)
    )

    assert result == CollectionInput(amount=Decimal("25000"))
    [request] = requests
    text_format = json.loads(request.content)["text"]["format"]
    assert text_format["strict"] is True
    schema = text_format["schema"]
    assert schema["additionalProperties"] is False
    assert set(schema["required"]) == set(EMPTY_OUTPUT)
