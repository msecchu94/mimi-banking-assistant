import os

import pytest
from sqlalchemy import Engine

from mimi.infrastructure.database.session import create_db_engine

TEST_DATABASE_URL_ENV = "MIMI_TEST_DATABASE_URL"

# Lets the app be imported without a real database; nothing connects with it.
os.environ.setdefault(
    "MIMI_DATABASE_URL", "postgresql+psycopg://mimi:mimi@localhost:5432/mimi"
)


@pytest.fixture(scope="session")
def test_engine() -> Engine:
    url = os.environ.get(TEST_DATABASE_URL_ENV)
    if not url:
        pytest.skip(f"{TEST_DATABASE_URL_ENV} is not set")
    return create_db_engine(url)
