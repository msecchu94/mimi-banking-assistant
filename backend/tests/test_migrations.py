from pathlib import Path

import pytest
from alembic import command
from alembic.config import Config
from sqlalchemy import Engine, inspect

pytestmark = pytest.mark.integration

ALEMBIC_INI = Path(__file__).resolve().parents[1] / "alembic.ini"


def run_alembic(engine: Engine, *args: str) -> None:
    config = Config(ALEMBIC_INI)
    with engine.begin() as connection:
        config.attributes["connection"] = connection
        name, *arguments = args
        getattr(command, name)(config, *arguments)


def test_upgrade_and_downgrade_run_cleanly(test_engine: Engine) -> None:
    run_alembic(test_engine, "upgrade", "head")
    run_alembic(test_engine, "downgrade", "base")

    tables = set(inspect(test_engine).get_table_names()) - {"alembic_version"}
    assert tables == set()


def test_models_and_migrations_are_in_sync(test_engine: Engine) -> None:
    run_alembic(test_engine, "upgrade", "head")
    try:
        run_alembic(test_engine, "check")
    finally:
        run_alembic(test_engine, "downgrade", "base")
