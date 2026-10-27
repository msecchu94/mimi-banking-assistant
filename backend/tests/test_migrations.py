import os
import subprocess
import sys
from pathlib import Path

import pytest
from sqlalchemy import Engine, inspect, text

from mimi.infrastructure.database.base import Base

pytestmark = pytest.mark.integration

BACKEND_DIR = Path(__file__).resolve().parents[1]
ALEMBIC_INI = BACKEND_DIR / "alembic.ini"

V1_TABLES = {
    "customers",
    "accounts",
    "beneficiaries",
    "cards",
    "transfers",
    "transactions",
    "conversations",
    "messages",
}

# Catalog facts compared between the migrated schema and the models:
# columns with type and nullability, constraints (PK, FK, unique, CHECK) with
# their definitions, and indexes.
SCHEMA_QUERIES = {
    "columns": """
        SELECT c.relname, a.attname, format_type(a.atttypid, a.atttypmod),
               a.attnotnull
        FROM pg_attribute a
        JOIN pg_class c ON c.oid = a.attrelid
        JOIN pg_namespace n ON n.oid = c.relnamespace
        WHERE n.nspname = 'public' AND c.relkind = 'r'
          AND c.relname <> 'alembic_version'
          AND a.attnum > 0 AND NOT a.attisdropped
    """,
    "constraints": """
        SELECT c.relname, con.conname, con.contype, pg_get_constraintdef(con.oid)
        FROM pg_constraint con
        JOIN pg_class c ON c.oid = con.conrelid
        JOIN pg_namespace n ON n.oid = c.relnamespace
        WHERE n.nspname = 'public' AND c.relname <> 'alembic_version'
    """,
    "indexes": """
        SELECT tablename, indexname, indexdef
        FROM pg_indexes
        WHERE schemaname = 'public' AND tablename <> 'alembic_version'
    """,
}

Schema = dict[str, set[tuple[object, ...]]]


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


def table_names(engine: Engine) -> set[str]:
    return set(inspect(engine).get_table_names()) - {"alembic_version"}


def schema_snapshot(engine: Engine) -> Schema:
    with engine.connect() as connection:
        return {
            name: {tuple(row) for row in connection.execute(text(query))}
            for name, query in SCHEMA_QUERIES.items()
        }


def test_upgrade_downgrade_and_upgrade_again(test_engine: Engine) -> None:
    try:
        run_alembic(test_engine, "upgrade", "head")
        assert table_names(test_engine) == V1_TABLES
        first_schema = schema_snapshot(test_engine)

        run_alembic(test_engine, "downgrade", "base")
        assert table_names(test_engine) == set()

        run_alembic(test_engine, "upgrade", "head")
        assert schema_snapshot(test_engine) == first_schema
    finally:
        run_alembic(test_engine, "downgrade", "base")


def test_models_and_migrations_are_in_sync(test_engine: Engine) -> None:
    run_alembic(test_engine, "upgrade", "head")
    try:
        run_alembic(test_engine, "check")
    finally:
        run_alembic(test_engine, "downgrade", "base")


def test_migrated_schema_matches_models(test_engine: Engine) -> None:
    # alembic check does not compare CHECK constraints; the catalog does.
    run_alembic(test_engine, "upgrade", "head")
    try:
        migrated_schema = schema_snapshot(test_engine)
    finally:
        run_alembic(test_engine, "downgrade", "base")

    Base.metadata.create_all(test_engine)
    try:
        model_schema = schema_snapshot(test_engine)
    finally:
        Base.metadata.drop_all(test_engine)

    assert migrated_schema == model_schema


WAITING_ID = "00000000-0000-0000-0000-00000000000a"
COLLECTING_ID = "00000000-0000-0000-0000-00000000000b"

# Rows at revision 0002: one operation waiting for confirmation and one being
# collected.
REVISION_0002_ROWS = f"""
    INSERT INTO customers (id, first_name, last_name)
    VALUES ('00000000-0000-0000-0000-000000000001', 'Ana', 'García');
    INSERT INTO accounts (id, customer_id, name, balance, currency, status)
    VALUES ('00000000-0000-0000-0000-000000000002',
            '00000000-0000-0000-0000-000000000001',
            'Caja de ahorro', 150000.00, 'ARS', 'ACTIVE');
    INSERT INTO cards (id, account_id, type, brand, last_four, status)
    VALUES ('00000000-0000-0000-0000-000000000003',
            '00000000-0000-0000-0000-000000000002',
            'DEBIT', 'VISA', '4821', 'ACTIVE');
    INSERT INTO conversations (id, customer_id, status, created_at, updated_at,
                               flow_state, context, pending_operation_type,
                               pending_card_id, pending_missing_fields)
    VALUES ('{WAITING_ID}', '00000000-0000-0000-0000-000000000001', 'ACTIVE',
            now(), now(), 'WAITING_CONFIRMATION', '{{}}', 'FREEZE_CARD',
            '00000000-0000-0000-0000-000000000003', '{{}}'),
           ('{COLLECTING_ID}', '00000000-0000-0000-0000-000000000001', 'ACTIVE',
            now(), now(), 'COLLECTING_DATA', '{{}}', 'FREEZE_CARD',
            NULL, '{{card_id}}');
"""


def test_upgrade_discards_operations_waiting_for_confirmation(
    test_engine: Engine,
) -> None:
    # They were offered without the operation id a CONFIRM must now name.
    run_alembic(test_engine, "upgrade", "0002")
    try:
        with test_engine.begin() as connection:
            connection.execute(text(REVISION_0002_ROWS))

        run_alembic(test_engine, "upgrade", "head")

        with test_engine.connect() as connection:
            rows = connection.execute(
                text(
                    "SELECT id::text, flow_state, pending_operation_type, "
                    "pending_card_id, pending_missing_fields, pending_operation_id "
                    "FROM conversations ORDER BY id"
                )
            ).all()
    finally:
        run_alembic(test_engine, "downgrade", "base")

    assert [tuple(row) for row in rows] == [
        (WAITING_ID, "READY", None, None, None, None),
        (COLLECTING_ID, "COLLECTING_DATA", "FREEZE_CARD", None, ["card_id"], None),
    ]
