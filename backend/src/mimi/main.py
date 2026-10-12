from mimi.api.app import create_app
from mimi.composition import build_container
from mimi.config import get_settings

# Fails fast at startup if configuration is invalid.
app = create_app(build_container(get_settings()))
