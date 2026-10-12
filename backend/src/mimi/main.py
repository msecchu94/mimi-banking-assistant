from fastapi import FastAPI

from mimi.api import health

app = FastAPI(title="Mimi")
app.include_router(health.router)
