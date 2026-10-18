import json
from collections.abc import Callable
from typing import Any

import httpx2
import pytest
from openai import OpenAI
from pydantic import BaseModel

from mimi.application.errors import (
    ApplicationError,
    LLMInvalidResponseError,
    LLMUnavailableError,
)
from mimi.infrastructure.llm.openai_provider import OpenAILLMProvider

API_KEY = "sk-test-not-a-real-key"
MODEL = "test-model"

Handler = Callable[[httpx2.Request], httpx2.Response]


class Greeting(BaseModel):
    text: str
    language: str


def output_text_content(text: str) -> dict[str, Any]:
    return {"type": "output_text", "text": text, "annotations": []}


def responses_body(
    content: list[dict[str, Any]], status: str = "completed"
) -> dict[str, Any]:
    return {
        "id": "resp_1",
        "object": "response",
        "created_at": 0,
        "model": MODEL,
        "status": status,
        "output": [
            {
                "type": "message",
                "id": "msg_1",
                "role": "assistant",
                "status": status,
                "content": content,
            }
        ],
        "parallel_tool_calls": False,
        "tool_choice": "auto",
        "tools": [],
    }


def json_handler(body: dict[str, Any], status_code: int = 200) -> Handler:
    def handler(request: httpx2.Request) -> httpx2.Response:
        return httpx2.Response(status_code, json=body)

    return handler


def build_provider(handler: Handler) -> OpenAILLMProvider:
    client = OpenAI(
        api_key=API_KEY,
        max_retries=0,
        http_client=httpx2.Client(transport=httpx2.MockTransport(handler)),
    )
    return OpenAILLMProvider(client, MODEL)


def generate(provider: OpenAILLMProvider) -> Greeting:
    return provider.generate_structured(
        instructions="Greet the user.",
        input_text="Hello there",
        output_type=Greeting,
    )


def test_returns_output_validated_as_requested_type() -> None:
    body = responses_body([output_text_content('{"text": "Hola", "language": "es"}')])
    provider = build_provider(json_handler(body))

    result = generate(provider)

    assert result == Greeting(text="Hola", language="es")


def test_sends_model_instructions_input_and_strict_output_schema() -> None:
    requests: list[httpx2.Request] = []
    body = responses_body([output_text_content('{"text": "Hola", "language": "es"}')])

    def handler(request: httpx2.Request) -> httpx2.Response:
        requests.append(request)
        return httpx2.Response(200, json=body)

    generate(build_provider(handler))

    [request] = requests
    sent = json.loads(request.content)
    assert sent["model"] == MODEL
    assert sent["instructions"] == "Greet the user."
    assert sent["input"] == "Hello there"
    text_format = sent["text"]["format"]
    assert text_format["type"] == "json_schema"
    assert text_format["strict"] is True
    assert set(text_format["schema"]["properties"]) == {"text", "language"}


@pytest.mark.parametrize(
    "exception",
    [
        httpx2.ReadTimeout("timed out"),
        httpx2.ConnectError("connection refused"),
    ],
)
def test_transport_failures_are_unavailable(exception: Exception) -> None:
    def handler(request: httpx2.Request) -> httpx2.Response:
        raise exception

    with pytest.raises(LLMUnavailableError):
        generate(build_provider(handler))


@pytest.mark.parametrize("status_code", [408, 409, 429, 500, 503])
def test_transient_statuses_are_unavailable(status_code: int) -> None:
    provider = build_provider(
        json_handler({"error": {"message": "try later"}}, status_code)
    )

    with pytest.raises(LLMUnavailableError):
        generate(provider)


@pytest.mark.parametrize("status_code", [400, 401, 403, 404, 422])
def test_non_transient_rejections_are_unexpected_failures(status_code: int) -> None:
    provider_message = f"Incorrect API key provided: {API_KEY}"
    provider = build_provider(
        json_handler({"error": {"message": provider_message}}, status_code)
    )

    with pytest.raises(RuntimeError) as exc_info:
        generate(provider)

    assert not isinstance(exc_info.value, ApplicationError)
    assert str(status_code) in str(exc_info.value)
    assert API_KEY not in str(exc_info.value)
    assert provider_message not in str(exc_info.value)


@pytest.mark.parametrize(
    "content",
    [
        [output_text_content("not json")],
        [output_text_content('{"text": "Hola"}')],
        [{"type": "refusal", "refusal": "I can't help with that."}],
        [],
    ],
    ids=["malformed-json", "schema-mismatch", "refusal", "no-output"],
)
def test_unusable_output_is_invalid_response(content: list[dict[str, Any]]) -> None:
    provider = build_provider(json_handler(responses_body(content)))

    with pytest.raises(LLMInvalidResponseError):
        generate(provider)


def test_incomplete_response_is_invalid_response() -> None:
    body = responses_body(
        [output_text_content('{"text": "Hola", "language": "es"}')],
        status="incomplete",
    )
    provider = build_provider(json_handler(body))

    with pytest.raises(LLMInvalidResponseError):
        generate(provider)
