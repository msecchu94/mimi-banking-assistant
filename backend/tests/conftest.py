import os
from collections.abc import Iterator
from pathlib import Path

import pytest
from alembic import command
from alembic.config import Config
from fastapi import FastAPI
from fastapi.testclient import TestClient
from pydantic import BaseModel, SecretStr
from sqlalchemy import Connection, Engine

from mimi.api.app import create_app
from mimi.application.llm import LLMProvider
from mimi.composition import Container, build_container
from mimi.config import AppEnvironment, Settings
from mimi.infrastructure.database.session import create_db_engine

TEST_DATABASE_URL_ENV = "MIMI_TEST_DATABASE_URL"

MIGRATIONS_DIR = Path(__file__).resolve().parents[1] / "migrations"

# Engines built from this URL are never connected to.
UNUSED_DATABASE_URL = "postgresql+psycopg://mimi:mimi@localhost:5432/mimi"


def require_test_database_url() -> str:
    url = os.environ.get(TEST_DATABASE_URL_ENV)
    if not url:
        pytest.skip(f"{TEST_DATABASE_URL_ENV} is not set")
    return url


def make_test_settings(database_url: str) -> Settings:
    return Settings(
        _env_file=None,
        environment=AppEnvironment.TEST,
        database_url=SecretStr(database_url),
    )


class FakeLLMProvider:
    """Stands in for the real provider where no test exercises the LLM."""

    def generate_structured[T: BaseModel](
        self, *, instructions: str, input_text: str, output_type: type[T]
    ) -> T:
        raise AssertionError("unexpected LLM call")


@pytest.fixture
def test_settings() -> Settings:
    return make_test_settings(UNUSED_DATABASE_URL)


@pytest.fixture
def llm_provider() -> LLMProvider:
    return FakeLLMProvider()


@pytest.fixture
def container(test_settings: Settings, llm_provider: LLMProvider) -> Container:
    return build_container(test_settings, llm_provider)


@pytest.fixture
def app(container: Container) -> FastAPI:
    return create_app(container)


@pytest.fixture
def client(app: FastAPI) -> Iterator[TestClient]:
    with TestClient(app) as client:
        yield client


@pytest.fixture(scope="session")
def test_engine() -> Engine:
    return create_db_engine(require_test_database_url())


def alembic_config(connection: Connection) -> Config:
    # No config file, so migrations/env.py leaves pytest's logging untouched.
    config = Config()
    config.set_main_option("script_location", str(MIGRATIONS_DIR))
    config.attributes["connection"] = connection
    return config


@pytest.fixture
def migrated_engine(test_engine: Engine) -> Iterator[Engine]:
    """Provide the test database migrated to head, reverted after the test."""
    with test_engine.begin() as connection:
        command.upgrade(alembic_config(connection), "head")
    try:
        yield test_engine
    finally:
        with test_engine.begin() as connection:
            command.downgrade(alembic_config(connection), "base")


@pytest.fixture
def test_container() -> Iterator[Container]:
    container = build_container(
        make_test_settings(require_test_database_url()), FakeLLMProvider()
    )
    yield container
    container.close()
