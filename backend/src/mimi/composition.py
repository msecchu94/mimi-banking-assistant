from dataclasses import dataclass

from openai import OpenAI
from sqlalchemy import Engine
from sqlalchemy.orm import Session, sessionmaker

from mimi.application.llm import LLMProvider
from mimi.config import LLMProviderName, Settings
from mimi.infrastructure.database.session import (
    create_db_engine,
    create_session_factory,
)
from mimi.infrastructure.database.transaction import PostgresTransactionScope
from mimi.infrastructure.llm.openai_provider import OpenAILLMProvider


@dataclass(frozen=True)
class Container:
    settings: Settings
    engine: Engine
    session_factory: sessionmaker[Session]
    transaction_scope: PostgresTransactionScope
    llm_provider: LLMProvider

    def close(self) -> None:
        self.engine.dispose()


def build_llm_provider(settings: Settings) -> LLMProvider:
    if settings.llm_model is None:
        raise ValueError("MIMI_LLM_MODEL is required to build the LLM provider")
    if settings.llm_api_key is None:
        raise ValueError("MIMI_LLM_API_KEY is required to build the LLM provider")
    match settings.llm_provider:
        case LLMProviderName.OPENAI:
            client = OpenAI(
                api_key=settings.llm_api_key.get_secret_value(),
                timeout=settings.llm_timeout_seconds,
                max_retries=0,
            )
            return OpenAILLMProvider(client, settings.llm_model)


def build_container(settings: Settings, llm_provider: LLMProvider) -> Container:
    engine = create_db_engine(settings.database_url.get_secret_value())
    session_factory = create_session_factory(engine)
    return Container(
        settings=settings,
        engine=engine,
        session_factory=session_factory,
        transaction_scope=PostgresTransactionScope(session_factory),
        llm_provider=llm_provider,
    )
