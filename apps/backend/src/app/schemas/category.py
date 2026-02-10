"""Category schemas for request/response validation."""
from datetime import datetime
from typing import Annotated
from uuid import UUID

from pydantic import BaseModel, ConfigDict, Field


class CategoryBase(BaseModel):
    """Base category schema with common fields."""
    name: Annotated[str, Field(min_length=1, max_length=100, examples=["Breakfast"])]
    description: Annotated[str | None, Field(max_length=500, examples=["Morning meals and recipes"], default=None)]
    emoji: Annotated[str | None, Field(max_length=10, examples=["🍳"], default=None)]
    color: Annotated[str | None, Field(max_length=7, pattern=r"^#[0-9A-Fa-f]{6}$", examples=["#FF5733"], default=None)]


class CategoryRead(CategoryBase):
    """Schema for reading a category (response)."""
    id: UUID
    user_id: UUID
    display_order: int
    created_at: datetime
    updated_at: datetime | None


class CategoryCreate(CategoryBase):
    """Schema for creating a category (request)."""
    model_config = ConfigDict(extra="forbid")


class CategoryCreateInternal(CategoryCreate):
    """Internal schema for category creation (includes user_id)."""
    user_id: UUID


class CategoryUpdate(BaseModel):
    """Schema for updating a category (request)."""
    model_config = ConfigDict(extra="forbid")

    name: Annotated[str | None, Field(min_length=1, max_length=100, examples=["Breakfast"], default=None)]
    description: Annotated[str | None, Field(max_length=500, examples=["Morning meals and recipes"], default=None)]
    emoji: Annotated[str | None, Field(max_length=10, examples=["🍳"], default=None)]
    color: Annotated[str | None, Field(max_length=7, pattern=r"^#[0-9A-Fa-f]{6}$", examples=["#FF5733"], default=None)]
    display_order: Annotated[int | None, Field(ge=0, examples=[0], default=None)]


class CategoryUpdateInternal(CategoryUpdate):
    """Internal schema for category updates."""
    updated_at: datetime
