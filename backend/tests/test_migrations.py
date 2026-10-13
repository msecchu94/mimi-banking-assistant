import os
import subprocess
import sys
from pathlib import Path

import pytest
from sqlalchemy import Engine, inspect

pytestmark = pytest.mark.integration

BACKEND_DIR = Path(__file__).resolve().parents[1]
ALEMBIC_INI = BACKEND_DIR / "alembic.ini"


def run_alembic(engine: Engine, *args: str) -> None:
    # A separate process sees only what migrations/env.py imports, not models
    # registered on Base.metadata during pytest collection.
    database_url = engine.url.render_as_string(hide_password=False)
    result = subprocess.run(
        [sys.executable, "-m", "alembic", "-c", str(ALEMBIC_INI), *args],
        cwd=BACKEND_DIR,
        env={**os.environ, "MIMI_DATABASE_URL": database_url},
        capture_output=True,
        text=True,
    )
    assert result.returncode == 0, result.stderr


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
