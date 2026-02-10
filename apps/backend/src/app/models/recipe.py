"""
Recipe Models for Recipe and Shopping Organizer

This file contains SQLAlchemy models for recipes and related data.
Each model represents a table in the PostgreSQL database.

Based on: docs/04-database-schema.md
"""

import uuid as uuid_pkg
from datetime import UTC, datetime

from sqlalchemy import (
    ARRAY,
    Boolean,
    DateTime,
    ForeignKey,
    Integer,
    String,
    Text,
)
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship
from uuid6 import uuid7

from ..core.db.database import Base


class Category(Base):
    """
    Recipe Categories (e.g., Plats, Pains, Desserts, Jus, Snacks, Soupes)
    
    Each category groups related recipes together.
    Example: "Desserts" category contains all dessert recipes.
    """
    
    __tablename__ = "categories"
    
    # Primary key (auto-generated)
    id: Mapped[uuid_pkg.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default_factory=uuid7, init=False)
    
    # Required fields (no defaults, must come first for dataclass)
    user_id: Mapped[uuid_pkg.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("user.uuid"), index=True)
    name: Mapped[str] = mapped_column(String(100))
    
    # Optional fields (with explicit defaults)
    emoji: Mapped[str | None] = mapped_column(String(10), default=None)
    description: Mapped[str | None] = mapped_column(Text, default=None)
    color: Mapped[str | None] = mapped_column(String(7), default=None)
    display_order: Mapped[int] = mapped_column(Integer, default=0, init=False)
    
    # Timestamps (auto-managed)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default_factory=lambda: datetime.now(UTC), init=False)
    updated_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), default=None, onupdate=lambda: datetime.now(UTC), init=False)
    
    # Relationships
    recipes: Mapped[list["Recipe"]] = relationship("Recipe", back_populates="category", cascade="all, delete-orphan", init=False)


class Recipe(Base):
    """Recipe - Core model for storing recipe information"""
    
    __tablename__ = "recipes"
    
    id: Mapped[uuid_pkg.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default_factory=uuid7, init=False)
    
    # Required fields (no defaults)
    user_id: Mapped[uuid_pkg.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("user.uuid"), index=True)
    title: Mapped[str] = mapped_column(String(200))
    
    # Optional fields (with defaults)
    category_id: Mapped[uuid_pkg.UUID | None] = mapped_column(UUID(as_uuid=True), ForeignKey("categories.id"), index=True, default=None)
    meal_usage: Mapped[str | None] = mapped_column(Text, default=None)
    prep_time_minutes: Mapped[int] = mapped_column(Integer, default=0)
    cook_time_minutes: Mapped[int] = mapped_column(Integer, default=0)
    servings: Mapped[int] = mapped_column(Integer, default=1)
    image_urls: Mapped[list[str] | None] = mapped_column(ARRAY(String), default=None)
    tags: Mapped[list[str] | None] = mapped_column(ARRAY(String), default=None)
    is_favorite: Mapped[bool] = mapped_column(Boolean, default=False)
    is_public: Mapped[bool] = mapped_column(Boolean, default=False)
    view_count: Mapped[int] = mapped_column(Integer, default=0)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default_factory=lambda: datetime.now(UTC))
    updated_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), default=None, onupdate=lambda: datetime.now(UTC))
    
    # Relationships
    category: Mapped["Category"] = relationship("Category", back_populates="recipes", init=False)
    ingredients: Mapped[list["Ingredient"]] = relationship("Ingredient", back_populates="recipe", cascade="all, delete-orphan", init=False)
    preparation_steps: Mapped[list["PreparationStep"]] = relationship("PreparationStep", back_populates="recipe", cascade="all, delete-orphan", init=False)


class Ingredient(Base):
    """Ingredient - Items needed for a recipe"""
    
    __tablename__ = "ingredients"
    
    id: Mapped[uuid_pkg.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default_factory=uuid7, init=False)
    
    # Required fields
    recipe_id: Mapped[uuid_pkg.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("recipes.id"), index=True)
    name: Mapped[str] = mapped_column(String(200))
    
    # Optional fields
    quantity: Mapped[str | None] = mapped_column(String(50), default=None)
    unit: Mapped[str | None] = mapped_column(String(50), default=None)
    notes: Mapped[str | None] = mapped_column(Text, default=None)
    category: Mapped[str | None] = mapped_column(String(100), default=None)
    display_order: Mapped[int] = mapped_column(Integer, default=0)
    
    # Relationship
    recipe: Mapped["Recipe"] = relationship("Recipe", back_populates="ingredients", init=False)


class PreparationStep(Base):
    """Preparation Step - Step-by-step instructions for a recipe"""
    
    __tablename__ = "preparation_steps"
    
    id: Mapped[uuid_pkg.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default_factory=uuid7, init=False)
    
    # Required fields
    recipe_id: Mapped[uuid_pkg.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("recipes.id"), index=True)
    step_number: Mapped[int] = mapped_column(Integer)
    instruction: Mapped[str] = mapped_column(Text)
    
    # Optional fields
    duration_minutes: Mapped[int] = mapped_column(Integer, default=0)
    image_url: Mapped[str | None] = mapped_column(String(500), default=None)
    
    # Relationship
    recipe: Mapped["Recipe"] = relationship("Recipe", back_populates="preparation_steps", init=False)
