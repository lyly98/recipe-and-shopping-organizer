"""Schemas for the video import / transcription feature."""
from typing import Any, Literal

from pydantic import BaseModel, HttpUrl


class VideoImportRequest(BaseModel):
    url: str
    language: str = "auto"


class VideoImportResponse(BaseModel):
    job_id: str


class VideoImportStatus(BaseModel):
    status: Literal["pending", "done", "error"]
    recipe_data: dict[str, Any] | None = None
    error_message: str | None = None
