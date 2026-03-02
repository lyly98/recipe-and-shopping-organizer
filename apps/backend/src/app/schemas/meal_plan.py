"""Meal plan schemas for request/response validation."""
from datetime import date, datetime
from typing import Annotated
from uuid import UUID

from pydantic import BaseModel, ConfigDict, Field


class RecipeLightRead(BaseModel):
    """Light recipe info embedded in meal plan responses (no ingredients/steps)."""

    id: UUID
    title: str
    servings: int
    image_urls: list[str] | None = None


class MealPlanEntryCreate(BaseModel):
    """Request body for adding a recipe to a meal plan slot."""

    model_config = ConfigDict(extra="forbid")

    plan_date: Annotated[date, Field(examples=["2026-02-25"])]
    slot_index: Annotated[int, Field(ge=0, le=3, examples=[1])]
    recipe_id: Annotated[UUID, Field(examples=["550e8400-e29b-41d4-a716-446655440000"])]


class MealPlanEntryCreateInternal(MealPlanEntryCreate):
    """Internal schema that adds user_id before persisting."""

    user_id: UUID


class MealPlanEntryRead(BaseModel):
    """Response schema for a single meal plan entry."""

    id: UUID
    user_id: UUID
    plan_date: date
    slot_index: int
    recipe_id: UUID
    recipe: RecipeLightRead
    created_at: datetime
