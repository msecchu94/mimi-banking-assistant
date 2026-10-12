from enum import StrEnum
from functools import lru_cache
from pathlib import Path

from pydantic_settings import BaseSettings, SettingsConfigDict

ENV_FILE = Path(__file__).resolve().parents[2] / ".env"


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
    )

    environment: AppEnvironment = AppEnvironment.DEVELOPMENT


@lru_cache
def get_settings() -> Settings:
    return Settings()
