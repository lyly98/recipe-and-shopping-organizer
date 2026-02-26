"""Meal plan API endpoints."""
from datetime import date
from typing import Annotated, Any
from uuid import UUID

from fastapi import APIRouter, Depends, Query, Request
from sqlalchemy.ext.asyncio import AsyncSession

from ...api.dependencies import get_current_user
from ...core.db.database import async_get_db
from ...core.exceptions.http_exceptions import ForbiddenException, NotFoundException
from ...crud.crud_meal_plan import crud_meal_plan
from ...crud.crud_recipes import crud_recipes
from ...schemas.meal_plan import (
    MealPlanEntryCreate,
    MealPlanEntryCreateInternal,
    MealPlanEntryRead,
    RecipeLightRead,
)

router = APIRouter(tags=["meal-plan"])


def _build_entry_read(entry: dict, recipe: dict) -> dict[str, Any]:
    """Assemble a MealPlanEntryRead dict from raw ORM dicts."""
    return {
        "id": entry["id"],
        "user_id": entry["user_id"],
        "plan_date": entry["plan_date"],
        "slot_index": entry["slot_index"],
        "recipe_id": entry["recipe_id"],
        "created_at": entry["created_at"],
        "recipe": {
            "id": recipe["id"],
            "title": recipe["title"],
            "servings": recipe["servings"],
            "image_urls": recipe.get("image_urls"),
        },
    }


@router.get("/meal-plan", response_model=list[MealPlanEntryRead])
async def get_meal_plan(
    request: Request,
    current_user: Annotated[dict, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(async_get_db)],
    start_date: date = Query(..., description="Inclusive start date (YYYY-MM-DD)"),
    end_date: date = Query(..., description="Inclusive end date (YYYY-MM-DD)"),
) -> list[dict[str, Any]]:
    """Return all meal plan entries for the current user within [start_date, end_date]."""
    from sqlalchemy import and_, select
    from ...models.meal_plan import MealPlanEntry
    from ...models.recipe import Recipe

    async with db as session:
        stmt = (
            select(MealPlanEntry, Recipe)
            .join(Recipe, MealPlanEntry.recipe_id == Recipe.id)
            .where(
                and_(
                    MealPlanEntry.user_id == current_user["uuid"],
                    MealPlanEntry.plan_date >= start_date,
                    MealPlanEntry.plan_date <= end_date,
                )
            )
            .order_by(MealPlanEntry.plan_date, MealPlanEntry.slot_index, MealPlanEntry.display_order)
        )
        rows = (await session.execute(stmt)).all()

    result = []
    for entry_obj, recipe_obj in rows:
        entry_dict = {
            "id": entry_obj.id,
            "user_id": entry_obj.user_id,
            "plan_date": entry_obj.plan_date,
            "slot_index": entry_obj.slot_index,
            "recipe_id": entry_obj.recipe_id,
            "created_at": entry_obj.created_at,
        }
        recipe_dict = {
            "id": recipe_obj.id,
            "title": recipe_obj.title,
            "servings": recipe_obj.servings,
            "image_urls": recipe_obj.image_urls,
        }
        result.append(_build_entry_read(entry_dict, recipe_dict))

    return result


@router.post("/meal-plan", response_model=MealPlanEntryRead, status_code=201)
async def add_meal_plan_entry(
    request: Request,
    body: MealPlanEntryCreate,
    current_user: Annotated[dict, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(async_get_db)],
) -> dict[str, Any]:
    """Add a recipe to a meal slot for a specific date."""
    # Validate the recipe exists and belongs to the current user
    recipe = await crud_recipes.get(db=db, id=body.recipe_id)
    if recipe is None:
        raise NotFoundException("Recipe not found")
    if str(recipe["user_id"]) != str(current_user["uuid"]):
        raise ForbiddenException("You can only plan your own recipes")

    internal = MealPlanEntryCreateInternal(
        plan_date=body.plan_date,
        slot_index=body.slot_index,
        recipe_id=body.recipe_id,
        user_id=current_user["uuid"],
    )
    created = await crud_meal_plan.create(db=db, object=internal)
    if created is None:
        raise NotFoundException("Failed to create meal plan entry")

    entry_dict = {
        "id": created.id,
        "user_id": created.user_id,
        "plan_date": created.plan_date,
        "slot_index": created.slot_index,
        "recipe_id": created.recipe_id,
        "created_at": created.created_at,
    }
    return _build_entry_read(entry_dict, recipe)


@router.delete("/meal-plan/{entry_id}", status_code=204)
async def delete_meal_plan_entry(
    request: Request,
    entry_id: UUID,
    current_user: Annotated[dict, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(async_get_db)],
) -> None:
    """Remove a meal plan entry (owner only)."""
    entry = await crud_meal_plan.get(db=db, id=entry_id)
    if entry is None:
        raise NotFoundException("Meal plan entry not found")
    if str(entry["user_id"]) != str(current_user["uuid"]):
        raise ForbiddenException("You can only delete your own meal plan entries")

    await crud_meal_plan.delete(db=db, id=entry_id)
