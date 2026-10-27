from collections.abc import AsyncIterator
from contextlib import asynccontextmanager

from fastapi import FastAPI

from mimi.api import chat, health
from mimi.api.chat import require_demo_customer_id
from mimi.api.errors import register_error_handlers
from mimi.composition import Container


def create_app(container: Container) -> FastAPI:
    """Build the API around a container whose lifetime the app now owns.

    Raises ``ValueError`` when the configuration cannot serve the Chat API.
    """
    require_demo_customer_id(container.settings)

    @asynccontextmanager
    async def lifespan(app: FastAPI) -> AsyncIterator[None]:
        yield
        container.close()

    app = FastAPI(title="Mimi", lifespan=lifespan)
    app.state.container = container
    register_error_handlers(app)
    app.include_router(health.router)
    app.include_router(chat.router)
    return app
