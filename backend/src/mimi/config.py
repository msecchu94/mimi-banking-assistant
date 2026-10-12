from enum import StrEnum
from functools import lru_cache
from pathlib import Path

from pydantic import (
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
