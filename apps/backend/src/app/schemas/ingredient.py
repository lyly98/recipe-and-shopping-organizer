"""Ingredient schemas for request/response validation."""
from typing import Annotated
from uuid import UUID

from pydantic import BaseModel, ConfigDict, Field


class IngredientBase(BaseModel):
    """Base ingredient schema with common fields."""
    name: Annotated[str, Field(min_length=1, max_length=200, examples=["Flour"])]
    quantity: Annotated[str, Field(min_length=1, max_length=50, examples=["2"])]
    unit: Annotated[str | None, Field(max_length=50, examples=["cups"], default=None)]
    display_order: Annotated[int, Field(ge=0, examples=[0], default=0)]


class IngredientRead(IngredientBase):
    """Schema for reading an ingredient (response)."""
    id: UUID
    recipe_id: UUID


class IngredientCreate(IngredientBase):
    """Schema for creating an ingredient (request)."""
    model_config = ConfigDict(extra="forbid")


class IngredientCreateInternal(IngredientBase):
    """Internal schema for creating an ingredient (includes recipe_id)."""
    recipe_id: UUID


class IngredientUpdate(BaseModel):
    """Schema for updating an ingredient (request)."""
    model_config = ConfigDict(extra="forbid")

    name: Annotated[str | None, Field(min_length=1, max_length=200, examples=["Flour"], default=None)]
    quantity: Annotated[str | None, Field(min_length=1, max_length=50, examples=["2"], default=None)]
    unit: Annotated[str | None, Field(max_length=50, examples=["cups"], default=None)]
    display_order: Annotated[int | None, Field(ge=0, examples=[0], default=None)]
