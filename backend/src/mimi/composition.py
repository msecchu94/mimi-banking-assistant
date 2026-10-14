from dataclasses import dataclass

from sqlalchemy import Engine
from sqlalchemy.orm import Session, sessionmaker

from mimi.config import Settings
from mimi.infrastructure.database.session import (
    create_db_engine,
    create_session_factory,
)
from mimi.infrastructure.database.transaction import PostgresTransactionScope


@dataclass(frozen=True)
class Container:
    settings: Settings
    engine: Engine
    session_factory: sessionmaker[Session]
    transaction_scope: PostgresTransactionScope

    def close(self) -> None:
        self.engine.dispose()


def build_container(settings: Settings) -> Container:
    engine = create_db_engine(settings.database_url.get_secret_value())
    session_factory = create_session_factory(engine)
    return Container(
        settings=settings,
        engine=engine,
        session_factory=session_factory,
        transaction_scope=PostgresTransactionScope(session_factory),
    )
