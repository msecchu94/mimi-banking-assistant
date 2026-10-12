import pytest
from fastapi import FastAPI
from fastapi.testclient import TestClient
from sqlalchemy import text

from mimi.api.app import create_app
from mimi.composition import Container, build_container
from mimi.config import Settings


def test_container_engine_uses_configured_database_url(
    test_settings: Settings,
) -> None:
    container = build_container(test_settings)

    rendered_url = container.engine.url.render_as_string(hide_password=False)
    assert rendered_url == test_settings.database_url.get_secret_value()
    assert container.settings is test_settings


def test_container_sessions_are_bound_to_container_engine(
    container: Container,
) -> None:
    with container.session_factory() as session:
        assert session.get_bind() is container.engine


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
