"""Recipe schemas for request/response validation."""
from datetime import datetime
from typing import Annotated
from uuid import UUID

from pydantic import BaseModel, ConfigDict, Field

from .ingredient import IngredientCreate, IngredientRead
from .preparation_step import PreparationStepCreate, PreparationStepRead


class RecipeBase(BaseModel):
    """Base recipe schema with common fields."""
    title: Annotated[str, Field(min_length=1, max_length=200, examples=["Chocolate Chip Cookies"])]
    meal_usage: Annotated[str | None, Field(max_length=1000, examples=["Great for dessert or snacks"], default=None)]
    prep_time_minutes: Annotated[int, Field(ge=0, examples=[15], default=0)]
    cook_time_minutes: Annotated[int, Field(ge=0, examples=[30], default=0)]
    servings: Annotated[int, Field(ge=1, examples=[4], default=1)]
    is_favorite: Annotated[bool, Field(examples=[False], default=False)]
    is_public: Annotated[bool, Field(examples=[False], default=False)]


class RecipeRead(RecipeBase):
    """Schema for reading a recipe (response)."""
    id: UUID
    user_id: UUID
    category_id: UUID | None
    image_urls: list[str] | None
    tags: list[str] | None
    view_count: int
    created_at: datetime
    updated_at: datetime | None
    
    # Include nested ingredients and steps
    ingredients: list[IngredientRead] = []
    preparation_steps: list[PreparationStepRead] = []


class RecipeCreate(RecipeBase):
    """Schema for creating a recipe (request)."""
    model_config = ConfigDict(extra="forbid")

    category_id: Annotated[UUID | None, Field(examples=["550e8400-e29b-41d4-a716-446655440000"], default=None)]
    image_urls: Annotated[list[str] | None, Field(examples=[["https://example.com/image.jpg"]], default=None)]
    tags: Annotated[list[str] | None, Field(examples=[["dessert", "quick"]], default=None)]
    
    # Nested creation
    ingredients: list[IngredientCreate] = []
    preparation_steps: list[PreparationStepCreate] = []


class RecipeCreateInternal(RecipeBase):
    """Internal schema for recipe creation (includes user_id, excludes nested objects)."""
    user_id: UUID
    category_id: Annotated[UUID | None, Field(examples=["550e8400-e29b-41d4-a716-446655440000"], default=None)]
    image_urls: Annotated[list[str] | None, Field(examples=[["https://example.com/image.jpg"]], default=None)]
    tags: Annotated[list[str] | None, Field(examples=[["dessert", "quick"]], default=None)]


class RecipeUpdateBase(BaseModel):
    """Flat (ORM-safe) fields shared between RecipeUpdate and RecipeUpdateInternal."""
    model_config = ConfigDict(extra="forbid")

    title: Annotated[str | None, Field(min_length=1, max_length=200, examples=["Chocolate Chip Cookies"], default=None)]
    category_id: Annotated[UUID | None, Field(examples=["550e8400-e29b-41d4-a716-446655440000"], default=None)]
    meal_usage: Annotated[str | None, Field(max_length=1000, examples=["Great for dessert or snacks"], default=None)]
    prep_time_minutes: Annotated[int | None, Field(ge=0, examples=[15], default=None)]
    cook_time_minutes: Annotated[int | None, Field(ge=0, examples=[30], default=None)]
    servings: Annotated[int | None, Field(ge=1, examples=[4], default=None)]
    image_urls: Annotated[list[str] | None, Field(examples=[["https://example.com/image.jpg"]], default=None)]
    tags: Annotated[list[str] | None, Field(examples=[["dessert", "quick"]], default=None)]
    is_favorite: Annotated[bool | None, Field(examples=[False], default=None)]
    is_public: Annotated[bool | None, Field(examples=[False], default=None)]


class RecipeUpdate(RecipeUpdateBase):
    """Schema for updating a recipe (request).

    When ``ingredients`` or ``preparation_steps`` are supplied, the existing
    items for the recipe are **replaced** (delete-all then re-create).
    """
    ingredients: list[IngredientCreate] | None = None
    preparation_steps: list[PreparationStepCreate] | None = None


class RecipeUpdateInternal(RecipeUpdateBase):
    """Internal schema passed to the ORM — contains only flat recipe columns."""
    updated_at: datetime
