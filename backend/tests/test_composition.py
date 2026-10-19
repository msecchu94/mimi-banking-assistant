import pytest
from fastapi import FastAPI
from fastapi.testclient import TestClient
from pydantic import SecretStr
from sqlalchemy import text

from mimi.api.app import create_app
from mimi.application.conversation_engine import ConversationEngine
from mimi.application.llm import LLMProvider
from mimi.composition import Container, build_container, build_llm_provider
from mimi.config import Settings
from mimi.infrastructure.llm.openai_provider import OpenAILLMProvider

FAKE_API_KEY = "sk-test-not-a-real-key"


def test_container_engine_uses_configured_database_url(
    test_settings: Settings, llm_provider: LLMProvider
) -> None:
    container = build_container(test_settings, llm_provider)

    rendered_url = container.engine.url.render_as_string(hide_password=False)
    assert rendered_url == test_settings.database_url.get_secret_value()
    assert container.settings is test_settings


def test_container_sessions_are_bound_to_container_engine(
    container: Container,
) -> None:
    with container.session_factory() as session:
        assert session.get_bind() is container.engine


def test_container_exposes_given_llm_provider(
    container: Container, llm_provider: LLMProvider
) -> None:
    assert container.llm_provider is llm_provider


def test_container_wires_conversation_engine_to_transaction_scope(
    container: Container,
) -> None:
    assert isinstance(container.conversation_engine, ConversationEngine)
    assert (
        container.conversation_engine._transaction_scope is container.transaction_scope
    )


def test_llm_provider_is_openai_adapter_with_configured_client(
    test_settings: Settings,
) -> None:
    settings = test_settings.model_copy(
        update={
            "llm_model": "test-model",
            "llm_api_key": SecretStr(FAKE_API_KEY),
            "llm_timeout_seconds": 3.5,
        }
    )

    provider = build_llm_provider(settings)

    assert isinstance(provider, OpenAILLMProvider)
    assert provider._model == "test-model"
    assert provider._client.api_key == FAKE_API_KEY
    assert provider._client.timeout == 3.5
    assert provider._client.max_retries == 0


@pytest.mark.parametrize(
    ("missing", "setting_name"),
    [("llm_model", "MIMI_LLM_MODEL"), ("llm_api_key", "MIMI_LLM_API_KEY")],
)
def test_llm_provider_requires_model_and_api_key(
    test_settings: Settings, missing: str, setting_name: str
) -> None:
    settings = test_settings.model_copy(
        update={"llm_model": "test-model", "llm_api_key": SecretStr(FAKE_API_KEY)}
        | {missing: None}
    )

    with pytest.raises(ValueError, match=setting_name) as exc_info:
        build_llm_provider(settings)

    assert FAKE_API_KEY not in str(exc_info.value)


def test_app_exposes_given_container(app: FastAPI, container: Container) -> None:
    assert app.state.container is container


def test_app_shutdown_disposes_engine(app: FastAPI, container: Container) -> None:
    pool_before_shutdown = container.engine.pool

    with TestClient(app):
        assert container.engine.pool is pool_before_shutdown

    assert container.engine.pool is not pool_before_shutdown


@pytest.mark.integration
def test_container_session_connects_to_postgresql(
    test_container: Container,
) -> None:
    app = create_app(test_container)

    with TestClient(app), test_container.session_factory() as session:
        assert session.execute(text("SELECT 1")).scalar_one() == 1
