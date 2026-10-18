from mimi.api.app import create_app
from mimi.composition import build_container, build_llm_provider
from mimi.config import get_settings

settings = get_settings()

# Fails fast at startup if configuration is invalid.
app = create_app(build_container(settings, build_llm_provider(settings)))
