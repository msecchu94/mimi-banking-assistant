"""Language model port required by Use Cases that interpret natural language."""

from typing import Protocol

from pydantic import BaseModel


class LLMProvider(Protocol):
    def generate_structured[T: BaseModel](
        self, *, instructions: str, input_text: str, output_type: type[T]
    ) -> T:
        """Return the model's output validated against ``output_type``.

        Schema validation does not make the output trustworthy: callers must
        still validate it as untrusted input.

        Raises ``LLMUnavailableError`` when the provider cannot be reached and
        ``LLMInvalidResponseError`` when it returns no valid output.
        """
        ...
