import os
from pathlib import Path

import pytest
from pydantic import ValidationError

from mimi.config import AppEnvironment, Settings


@pytest.fixture(autouse=True)
def clear_mimi_env(monkeypatch: pytest.MonkeyPatch) -> None:
    for name in list(os.environ):
        if name.startswith("MIMI_"):
            monkeypatch.delenv(name)


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
