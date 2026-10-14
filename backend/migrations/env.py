from logging.config import fileConfig

from alembic import context
from sqlalchemy import Connection, create_engine, pool

from mimi.config import get_settings
from mimi.infrastructure.database import models  # noqa: F401 - registers tables
from mimi.infrastructure.database.base import Base

config = context.config

if config.config_file_name is not None:
    fileConfig(config.config_file_name)

target_metadata = Base.metadata


def run_migrations_offline() -> None:
    context.configure(
        url=get_settings().database_url.get_secret_value(),
        target_metadata=target_metadata,
        literal_binds=True,
        dialect_opts={"paramstyle": "named"},
        compare_type=True,
    )

    with context.begin_transaction():
        context.run_migrations()


def run_migrations_with_connection(connection: Connection) -> None:
    context.configure(
        connection=connection,
        target_metadata=target_metadata,
        compare_type=True,
    )

    with context.begin_transaction():
        context.run_migrations()


def run_migrations_online() -> None:
    # Callers such as tests may provide their own connection.
    connection = config.attributes.get("connection")
    if connection is not None:
        run_migrations_with_connection(connection)
        return

    engine = create_engine(
        get_settings().database_url.get_secret_value(),
        poolclass=pool.NullPool,
    )
    with engine.connect() as connection:
        run_migrations_with_connection(connection)


if context.is_offline_mode():
    run_migrations_offline()
else:
    run_migrations_online()
