from collections.abc import Iterator

import pytest
from sqlalchemy import Engine, text
from sqlalchemy.orm import Session, sessionmaker

from mimi.infrastructure.database.session import create_session_factory

PROBE_TABLE = "bf03_session_probe"


class ProbeError(Exception):
    pass


@pytest.fixture
def session_factory(test_engine: Engine) -> Iterator[sessionmaker[Session]]:
    with test_engine.begin() as connection:
        connection.execute(text(f"CREATE TABLE {PROBE_TABLE} (value integer)"))
    yield create_session_factory(test_engine)
    with test_engine.begin() as connection:
        connection.execute(text(f"DROP TABLE {PROBE_TABLE}"))


def count_probe_rows(session_factory: sessionmaker[Session]) -> int:
    with session_factory() as session:
        return session.execute(text(f"SELECT count(*) FROM {PROBE_TABLE}")).scalar_one()


def test_session_connects_to_postgresql(
    session_factory: sessionmaker[Session],
) -> None:
    with session_factory() as session:
        assert session.execute(text("SELECT 1")).scalar_one() == 1


def test_session_commits_on_success(
    session_factory: sessionmaker[Session],
) -> None:
    with session_factory.begin() as session:
        session.execute(text(f"INSERT INTO {PROBE_TABLE} VALUES (1)"))

    assert count_probe_rows(session_factory) == 1


def test_session_rolls_back_on_error(
    session_factory: sessionmaker[Session],
) -> None:
    with pytest.raises(ProbeError):
        with session_factory.begin() as session:
            session.execute(text(f"INSERT INTO {PROBE_TABLE} VALUES (1)"))
            raise ProbeError

    assert count_probe_rows(session_factory) == 0
