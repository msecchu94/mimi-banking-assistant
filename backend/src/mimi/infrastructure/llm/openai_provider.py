from openai import (
    APIConnectionError,
    APIResponseValidationError,
    APIStatusError,
    OpenAI,
)
from pydantic import BaseModel, ValidationError

from mimi.application.errors import LLMInvalidResponseError, LLMUnavailableError

# Statuses worth retrying later; any other rejection means the provider is
# misconfigured or the request is wrong, which is not a temporary outage.
_TRANSIENT_STATUS_CODES = frozenset({408, 409, 429})


def _is_transient(status_code: int) -> bool:
    return status_code in _TRANSIENT_STATUS_CODES or status_code >= 500


class OpenAILLMProvider:
    def __init__(self, client: OpenAI, model: str) -> None:
        self._client = client
        self._model = model

    def generate_structured[T: BaseModel](
        self, *, instructions: str, input_text: str, output_type: type[T]
    ) -> T:
        try:
            response = self._client.responses.parse(
                model=self._model,
                instructions=instructions,
                input=input_text,
                text_format=output_type,
            )
        except APIConnectionError as exc:  # includes timeouts
            raise LLMUnavailableError() from exc
        except APIStatusError as exc:
            if _is_transient(exc.status_code):
                raise LLMUnavailableError() from exc
            # Not an ApplicationError: surfaces as an unexpected failure.
            raise RuntimeError(
                f"LLM provider rejected the request with status {exc.status_code}"
            ) from exc
        except (APIResponseValidationError, ValidationError) as exc:
            raise LLMInvalidResponseError() from exc

        if response.status != "completed":
            raise LLMInvalidResponseError()
        parsed = response.output_parsed
        # A refusal carries no parsed output.
        if not isinstance(parsed, output_type):
            raise LLMInvalidResponseError()
        return parsed
