"""Preparation step schemas for request/response validation."""
from typing import Annotated
from uuid import UUID

from pydantic import BaseModel, ConfigDict, Field


class PreparationStepBase(BaseModel):
    """Base preparation step schema with common fields."""
    step_number: Annotated[int, Field(ge=1, examples=[1])]
    instruction: Annotated[str, Field(min_length=1, max_length=1000, examples=["Preheat oven to 350°F"])]
    duration_minutes: Annotated[int | None, Field(ge=0, examples=[10], default=None)]


class PreparationStepRead(PreparationStepBase):
    """Schema for reading a preparation step (response)."""
    id: UUID
    recipe_id: UUID


class PreparationStepCreate(PreparationStepBase):
    """Schema for creating a preparation step (request)."""
    model_config = ConfigDict(extra="forbid")


class PreparationStepCreateInternal(PreparationStepBase):
    """Internal schema for creating a preparation step (includes recipe_id)."""
    recipe_id: UUID


class PreparationStepUpdate(BaseModel):
    """Schema for updating a preparation step (request)."""
    model_config = ConfigDict(extra="forbid")

    step_number: Annotated[int | None, Field(ge=1, examples=[1], default=None)]
    instruction: Annotated[str | None, Field(min_length=1, max_length=1000, examples=["Preheat oven to 375°F"], default=None)]
    duration_minutes: Annotated[int | None, Field(ge=0, examples=[10], default=None)]
