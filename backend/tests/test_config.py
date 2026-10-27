import os
from pathlib import Path
from uuid import UUID
from zoneinfo import ZoneInfo

import pytest
from pydantic import ValidationError

from mimi.config import AppEnvironment, LLMProviderName, Settings

VALID_DATABASE_URL = "postgresql+psycopg://mimi:s3cret@localhost:5432/mimi"


@pytest.fixture(autouse=True)
def isolate_mimi_env(monkeypatch: pytest.MonkeyPatch) -> None:
    for name in list(os.environ):
        if name.startswith("MIMI_"):
            monkeypatch.delenv(name)
    monkeypatch.setenv("MIMI_DATABASE_URL", VALID_DATABASE_URL)


def write_env_file(tmp_path: Path, content: str) -> Path:
    env_file = tmp_path / ".env"
    env_file.write_text(content)
    return env_file


def test_environment_defaults_to_development() -> None:
    settings = Settings(_env_file=None)

    assert settings.environment is AppEnvironment.DEVELOPMENT


@pytest.mark.parametrize("environment", list(AppEnvironment))
def test_environment_is_read_from_env_var(
    monkeypatch: pytest.MonkeyPatch, environment: AppEnvironment
) -> None:
    monkeypatch.setenv("MIMI_ENVIRONMENT", environment.value)

    settings = Settings(_env_file=None)

    assert settings.environment is environment


@pytest.mark.parametrize("value", ["staging", "Production", ""])
def test_invalid_environment_is_rejected(
    monkeypatch: pytest.MonkeyPatch, value: str
) -> None:
    monkeypatch.setenv("MIMI_ENVIRONMENT", value)

    with pytest.raises(ValidationError, match="environment"):
        Settings(_env_file=None)


def test_environment_is_read_from_env_file(tmp_path: Path) -> None:
    env_file = write_env_file(tmp_path, "MIMI_ENVIRONMENT=test\n")

    settings = Settings(_env_file=env_file)

    assert settings.environment is AppEnvironment.TEST


def test_env_var_takes_precedence_over_env_file(
    monkeypatch: pytest.MonkeyPatch, tmp_path: Path
) -> None:
    env_file = write_env_file(tmp_path, "MIMI_ENVIRONMENT=test\n")
    monkeypatch.setenv("MIMI_ENVIRONMENT", "production")

    settings = Settings(_env_file=env_file)

    assert settings.environment is AppEnvironment.PRODUCTION


def test_missing_env_file_falls_back_to_defaults(tmp_path: Path) -> None:
    settings = Settings(_env_file=tmp_path / "missing.env")

    assert settings.environment is AppEnvironment.DEVELOPMENT


def test_unknown_mimi_key_in_env_file_is_rejected(tmp_path: Path) -> None:
    env_file = write_env_file(tmp_path, "MIMI_ENVIROMENT=production\n")

    with pytest.raises(ValidationError, match="MIMI_ENVIROMENT|mimi_enviroment"):
        Settings(_env_file=env_file)


def test_database_url_is_required(monkeypatch: pytest.MonkeyPatch) -> None:
    monkeypatch.delenv("MIMI_DATABASE_URL")

    with pytest.raises(ValidationError, match="database_url"):
        Settings(_env_file=None)


def test_database_url_is_read_from_env_var() -> None:
    settings = Settings(_env_file=None)

    assert settings.database_url.get_secret_value() == VALID_DATABASE_URL


def test_database_url_is_read_from_env_file(
    monkeypatch: pytest.MonkeyPatch, tmp_path: Path
) -> None:
    monkeypatch.delenv("MIMI_DATABASE_URL")
    env_file = write_env_file(tmp_path, f"MIMI_DATABASE_URL={VALID_DATABASE_URL}\n")

    settings = Settings(_env_file=env_file)

    assert settings.database_url.get_secret_value() == VALID_DATABASE_URL


@pytest.mark.parametrize(
    "url",
    [
        "postgresql://mimi:s3cret@localhost:5432/mimi",
        "postgresql+asyncpg://mimi:s3cret@localhost:5432/mimi",
        "sqlite:///mimi.db",
        "not a url",
    ],
)
def test_invalid_database_url_is_rejected_without_leaking_it(
    monkeypatch: pytest.MonkeyPatch, url: str
) -> None:
    monkeypatch.setenv("MIMI_DATABASE_URL", url)

    with pytest.raises(ValidationError, match="database_url") as exc_info:
        Settings(_env_file=None)

    assert "s3cret" not in str(exc_info.value)


def test_database_url_is_masked_in_repr() -> None:
    settings = Settings(_env_file=None)

    assert "s3cret" not in repr(settings)
    assert "s3cret" not in str(settings)


def test_llm_settings_defaults() -> None:
    settings = Settings(_env_file=None)

    assert settings.llm_provider is LLMProviderName.OPENAI
    assert settings.llm_model is None
    assert settings.llm_api_key is None
    assert settings.llm_timeout_seconds == 10.0


def test_llm_settings_are_read_from_env_vars(monkeypatch: pytest.MonkeyPatch) -> None:
    monkeypatch.setenv("MIMI_LLM_PROVIDER", "openai")
    monkeypatch.setenv("MIMI_LLM_MODEL", "test-model")
    monkeypatch.setenv("MIMI_LLM_API_KEY", "sk-s3cret")
    monkeypatch.setenv("MIMI_LLM_TIMEOUT_SECONDS", "2.5")

    settings = Settings(_env_file=None)

    assert settings.llm_provider is LLMProviderName.OPENAI
    assert settings.llm_model == "test-model"
    assert settings.llm_api_key is not None
    assert settings.llm_api_key.get_secret_value() == "sk-s3cret"
    assert settings.llm_timeout_seconds == 2.5


def test_llm_settings_are_read_from_env_file(tmp_path: Path) -> None:
    env_file = write_env_file(
        tmp_path, "MIMI_LLM_MODEL=test-model\nMIMI_LLM_API_KEY=sk-s3cret\n"
    )

    settings = Settings(_env_file=env_file)

    assert settings.llm_model == "test-model"
    assert settings.llm_api_key is not None
    assert settings.llm_api_key.get_secret_value() == "sk-s3cret"


@pytest.mark.parametrize("value", ["anthropic", "OpenAI", ""])
def test_invalid_llm_provider_is_rejected(
    monkeypatch: pytest.MonkeyPatch, value: str
) -> None:
    monkeypatch.setenv("MIMI_LLM_PROVIDER", value)

    with pytest.raises(ValidationError, match="llm_provider"):
        Settings(_env_file=None)


def test_empty_llm_model_is_rejected(monkeypatch: pytest.MonkeyPatch) -> None:
    monkeypatch.setenv("MIMI_LLM_MODEL", "")

    with pytest.raises(ValidationError, match="llm_model"):
        Settings(_env_file=None)


@pytest.mark.parametrize("value", ["0", "-1", "not a number"])
def test_invalid_llm_timeout_is_rejected(
    monkeypatch: pytest.MonkeyPatch, value: str
) -> None:
    monkeypatch.setenv("MIMI_LLM_TIMEOUT_SECONDS", value)

    with pytest.raises(ValidationError, match="llm_timeout_seconds"):
        Settings(_env_file=None)


def test_llm_api_key_is_masked_in_repr(monkeypatch: pytest.MonkeyPatch) -> None:
    monkeypatch.setenv("MIMI_LLM_API_KEY", "sk-s3cret")

    settings = Settings(_env_file=None)

    assert "sk-s3cret" not in repr(settings)
    assert "sk-s3cret" not in str(settings)


def test_timezone_defaults_to_buenos_aires() -> None:
    settings = Settings(_env_file=None)

    assert settings.timezone == ZoneInfo("America/Argentina/Buenos_Aires")


def test_timezone_is_read_from_env_var(monkeypatch: pytest.MonkeyPatch) -> None:
    monkeypatch.setenv("MIMI_TIMEZONE", "America/Montevideo")

    settings = Settings(_env_file=None)

    assert settings.timezone == ZoneInfo("America/Montevideo")


def test_timezone_is_read_from_env_file(tmp_path: Path) -> None:
    env_file = write_env_file(tmp_path, "MIMI_TIMEZONE=UTC\n")

    settings = Settings(_env_file=env_file)

    assert settings.timezone == ZoneInfo("UTC")


@pytest.mark.parametrize("value", ["Mars/Olympus_Mons", "-03:00", ""])
def test_invalid_timezone_is_rejected(
    monkeypatch: pytest.MonkeyPatch, value: str
) -> None:
    monkeypatch.setenv("MIMI_TIMEZONE", value)

    with pytest.raises(ValidationError, match="timezone"):
        Settings(_env_file=None)


def test_demo_customer_is_optional() -> None:
    settings = Settings(_env_file=None)

    assert settings.demo_customer_id is None


def test_demo_customer_is_read_from_env_var(monkeypatch: pytest.MonkeyPatch) -> None:
    monkeypatch.setenv("MIMI_DEMO_CUSTOMER_ID", "0e275bc8-90cc-5472-a99f-ad4a4bdb416f")

    settings = Settings(_env_file=None)

    assert settings.demo_customer_id == UUID("0e275bc8-90cc-5472-a99f-ad4a4bdb416f")


def test_invalid_demo_customer_is_rejected(monkeypatch: pytest.MonkeyPatch) -> None:
    monkeypatch.setenv("MIMI_DEMO_CUSTOMER_ID", "valentina")

    with pytest.raises(ValidationError, match="demo_customer_id"):
        Settings(_env_file=None)
