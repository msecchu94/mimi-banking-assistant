from fastapi import FastAPI

from mimi.api import health
from mimi.config import get_settings

# Fail fast at startup if configuration is invalid.
get_settings()

app = FastAPI(title="Mimi")
app.include_router(health.router)
