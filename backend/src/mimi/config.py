from enum import StrEnum
from functools import lru_cache
from pathlib import Path

from pydantic import (
    Field,
    PostgresDsn,
    SecretStr,
    TypeAdapter,
    ValidationError,
    field_validator,
)
from pydantic_settings import BaseSettings, SettingsConfigDict

ENV_FILE = Path(__file__).resolve().parents[2] / ".env"

DATABASE_URL_SCHEME = "postgresql+psycopg"

_postgres_dsn = TypeAdapter(PostgresDsn)


class AppEnvironment(StrEnum):
    DEVELOPMENT = "development"
    TEST = "test"
    PRODUCTION = "production"


class LLMProviderName(StrEnum):
    OPENAI = "openai"


class Settings(BaseSettings):
    model_config = SettingsConfigDict(
        env_prefix="MIMI_",
        env_file=ENV_FILE,
        env_file_encoding="utf-8",
        extra="forbid",
        # Validation errors must not echo values such as database credentials.
        hide_input_in_errors=True,
    )

    environment: AppEnvironment = AppEnvironment.DEVELOPMENT
    database_url: SecretStr

    # Model and API key are optional here and required only when the real
    # provider is built, so components that never call the LLM need neither.
    llm_provider: LLMProviderName = LLMProviderName.OPENAI
    llm_model: str | None = Field(default=None, min_length=1)
    llm_api_key: SecretStr | None = None
    llm_timeout_seconds: float = Field(default=10.0, gt=0)

    @field_validator("database_url")
    @classmethod
    def validate_database_url(cls, value: SecretStr) -> SecretStr:
        try:
            dsn = _postgres_dsn.validate_python(value.get_secret_value())
        except ValidationError:
            raise ValueError("must be a valid PostgreSQL URL") from None
        if dsn.scheme != DATABASE_URL_SCHEME:
            raise ValueError(f"scheme must be '{DATABASE_URL_SCHEME}'")
        return value


@lru_cache
def get_settings() -> Settings:
    return Settings()
