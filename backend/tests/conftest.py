import os
from collections.abc import Iterator

import pytest
from fastapi import FastAPI
from fastapi.testclient import TestClient
from pydantic import SecretStr
from sqlalchemy import Engine

from mimi.api.app import create_app
from mimi.composition import Container, build_container
from mimi.config import AppEnvironment, Settings
from mimi.infrastructure.database.session import create_db_engine

TEST_DATABASE_URL_ENV = "MIMI_TEST_DATABASE_URL"

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


@pytest.fixture
def test_settings() -> Settings:
    return make_test_settings(UNUSED_DATABASE_URL)


@pytest.fixture
def container(test_settings: Settings) -> Container:
    return build_container(test_settings)


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


@pytest.fixture
def test_container() -> Iterator[Container]:
    container = build_container(make_test_settings(require_test_database_url()))
    yield container
    container.close()
