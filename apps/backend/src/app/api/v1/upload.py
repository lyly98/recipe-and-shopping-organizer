"""Image upload endpoint for recipe photos."""
import uuid
from pathlib import Path
from typing import Annotated

from fastapi import APIRouter, Depends, File, UploadFile

from ...api.dependencies import get_current_user
from ...core.exceptions.http_exceptions import BadRequestException

router = APIRouter(tags=["upload"])

# Directory for uploaded files (relative to backend app root)
UPLOADS_DIR = Path(__file__).resolve().parent.parent.parent.parent.parent / "static" / "uploads"
ALLOWED_CONTENT_TYPES = {"image/jpeg", "image/png", "image/webp", "image/gif"}
MAX_SIZE_BYTES = 10 * 1024 * 1024  # 10 MB


def _ensure_uploads_dir() -> Path:
    UPLOADS_DIR.mkdir(parents=True, exist_ok=True)
    return UPLOADS_DIR


@router.post("/upload/image")
async def upload_recipe_image(
    current_user: Annotated[dict, Depends(get_current_user)],
    file: UploadFile = File(..., description="Image file (JPEG, PNG, WebP, GIF)"),
) -> dict[str, str]:
    """Upload an image for a recipe. Returns a URL path to use in recipe image_urls."""
    content_type = file.content_type or ""
    if content_type not in ALLOWED_CONTENT_TYPES:
        raise BadRequestException(f"Invalid content type. Allowed: {ALLOWED_CONTENT_TYPES}")

    ext = _extension_for_content_type(content_type)
    name = f"recipe_{uuid.uuid4().hex[:12]}{ext}"
    dir_path = _ensure_uploads_dir()
    path = dir_path / name

    contents = await file.read()
    if len(contents) > MAX_SIZE_BYTES:
        raise BadRequestException("File too large (max 10 MB)")

    path.write_bytes(contents)

    # Return path that the client can append to its API base URL
    return {"url": f"/static/uploads/{name}"}


def _extension_for_content_type(content_type: str) -> str:
    m = {
        "image/jpeg": ".jpg",
        "image/png": ".png",
        "image/webp": ".webp",
        "image/gif": ".gif",
    }
    return m.get(content_type, ".jpg")
