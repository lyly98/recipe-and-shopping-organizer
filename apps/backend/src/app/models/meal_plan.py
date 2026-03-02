"""MealPlanEntry model for the recipe and shopping organizer."""
from __future__ import annotations

import uuid as uuid_pkg
from datetime import UTC, date, datetime
from typing import TYPE_CHECKING

from sqlalchemy import Date, DateTime, ForeignKey, Integer
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship
from uuid6 import uuid7

from ..core.db.database import Base

if TYPE_CHECKING:
    from .recipe import Recipe


class MealPlanEntry(Base):
    """
    A single planned recipe for a specific calendar date and meal slot.

    slot_index:
        0 = Petit-déjeuner
        1 = Déjeuner
        2 = Snack
        3 = Dîner
    """

    __tablename__ = "meal_plan_entries"

    id: Mapped[uuid_pkg.UUID] = mapped_column(
        UUID(as_uuid=True), primary_key=True, default_factory=uuid7, init=False
    )
    user_id: Mapped[uuid_pkg.UUID] = mapped_column(
        UUID(as_uuid=True), ForeignKey("user.uuid"), index=True
    )
    plan_date: Mapped[date] = mapped_column(Date, index=True)
    slot_index: Mapped[int] = mapped_column(Integer)
    recipe_id: Mapped[uuid_pkg.UUID] = mapped_column(
        UUID(as_uuid=True), ForeignKey("recipes.id"), index=True
    )
    display_order: Mapped[int] = mapped_column(Integer, default=0, init=False)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        default_factory=lambda: datetime.now(UTC),
        init=False,
    )

    recipe: Mapped[Recipe] = relationship(
        "Recipe", lazy="joined", init=False
    )
