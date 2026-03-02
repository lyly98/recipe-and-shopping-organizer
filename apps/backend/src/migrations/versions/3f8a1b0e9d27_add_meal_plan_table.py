"""Add meal plan entries table

Revision ID: 3f8a1b0e9d27
Revises: c92428c04220
Create Date: 2026-02-25 00:00:00.000000

"""
from collections.abc import Sequence
from typing import Union

import sqlalchemy as sa
from alembic import op
from sqlalchemy.dialects import postgresql

# revision identifiers, used by Alembic.
revision: str = "3f8a1b0e9d27"
down_revision: Union[str, None] = "c92428c04220"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.create_table(
        "meal_plan_entries",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column(
            "user_id",
            postgresql.UUID(as_uuid=True),
            sa.ForeignKey("user.uuid", ondelete="CASCADE"),
            nullable=False,
        ),
        sa.Column("plan_date", sa.Date, nullable=False),
        sa.Column("slot_index", sa.Integer, nullable=False),
        sa.Column(
            "recipe_id",
            postgresql.UUID(as_uuid=True),
            sa.ForeignKey("recipes.id", ondelete="CASCADE"),
            nullable=False,
        ),
        sa.Column("display_order", sa.Integer, nullable=False, server_default="0"),
        sa.Column(
            "created_at",
            sa.DateTime(timezone=True),
            nullable=False,
            server_default=sa.func.now(),
        ),
    )
    op.create_index("ix_meal_plan_entries_user_id", "meal_plan_entries", ["user_id"])
    op.create_index("ix_meal_plan_entries_plan_date", "meal_plan_entries", ["plan_date"])
    op.create_index("ix_meal_plan_entries_recipe_id", "meal_plan_entries", ["recipe_id"])


def downgrade() -> None:
    op.drop_index("ix_meal_plan_entries_recipe_id", table_name="meal_plan_entries")
    op.drop_index("ix_meal_plan_entries_plan_date", table_name="meal_plan_entries")
    op.drop_index("ix_meal_plan_entries_user_id", table_name="meal_plan_entries")
    op.drop_table("meal_plan_entries")
