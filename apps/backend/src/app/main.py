import logging
from collections.abc import AsyncGenerator
from contextlib import asynccontextmanager
from pathlib import Path

from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles
from sqlalchemy.exc import IntegrityError, OperationalError

from .admin.initialize import create_admin_interface
from .api import router
from .core.config import settings
from .core.setup import create_application, lifespan_factory

admin = create_admin_interface()
logger = logging.getLogger(__name__)


@asynccontextmanager
async def lifespan_with_admin(app: FastAPI) -> AsyncGenerator[None, None]:
    """Custom lifespan that includes admin initialization."""
    # Get the default lifespan
    default_lifespan = lifespan_factory(settings)

    # Run the default lifespan initialization and our admin initialization
    async with default_lifespan(app):
        # Initialize admin interface if it exists
        if admin:
            # Initialize admin database and setup.
            # Under multi-worker startup, concurrent creation of the initial
            # admin account or admin tables can race; treat duplicates as already initialized.
            try:
                await admin.initialize()
            except IntegrityError as exc:
                message = str(exc.orig) if getattr(exc, "orig", None) else str(exc)
                if "UNIQUE constraint failed: admin_user.username" not in message:
                    raise
                logger.warning("Admin user already exists; continuing startup.")
            except OperationalError as exc:
                message = str(exc.orig) if getattr(exc, "orig", None) else str(exc)
                if "already exists" not in message:
                    raise
                logger.warning("Admin table already exists; continuing startup.")

        yield


app = create_application(router=router, settings=settings, lifespan=lifespan_with_admin)


@app.get("/", include_in_schema=False)
async def root() -> dict[str, str]:
    return {"status": "ok"}


# Serve uploaded recipe images at /static/uploads/...
static_dir = Path(__file__).resolve().parent.parent.parent / "static"
(static_dir / "uploads").mkdir(parents=True, exist_ok=True)
app.mount("/static", StaticFiles(directory=str(static_dir)), name="static")

# Mount admin interface if enabled
if admin:
    app.mount(settings.CRUD_ADMIN_MOUNT_PATH, admin.app)
