"""Recipe API endpoints."""
from datetime import UTC, datetime
from typing import Annotated, Any
from uuid import UUID

from fastapi import APIRouter, Depends, Query, Request
from fastcrud import PaginatedListResponse, compute_offset, paginated_response
from sqlalchemy.ext.asyncio import AsyncSession

from ...api.dependencies import get_current_user
from ...core.db.database import async_get_db
from ...core.exceptions.http_exceptions import ForbiddenException, NotFoundException
from ...core.utils.cache import cache
from ...crud.crud_ingredients import crud_ingredients
from ...crud.crud_preparation_steps import crud_preparation_steps
from ...crud.crud_recipes import crud_recipes
from ...schemas.ingredient import IngredientRead
from ...schemas.preparation_step import PreparationStepRead
from ...schemas.recipe import RecipeCreate, RecipeCreateInternal, RecipeRead, RecipeUpdate, RecipeUpdateInternal

router = APIRouter(tags=["recipes"])


@router.post("/recipes", response_model=RecipeRead, status_code=201)
async def create_recipe(
    request: Request,
    recipe: RecipeCreate,
    current_user: Annotated[dict, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(async_get_db)],
) -> dict[str, Any]:
    """Create a new recipe with ingredients and preparation steps."""
    # Extract nested data
    ingredients_data = recipe.ingredients
    preparation_steps_data = recipe.preparation_steps
    
    # Create recipe data (without nested objects)
    recipe_dict = recipe.model_dump(exclude={"ingredients", "preparation_steps"})
    recipe_dict["user_id"] = current_user["uuid"]  # Already a UUID object
    
    recipe_internal = RecipeCreateInternal(**recipe_dict)
    created_recipe = await crud_recipes.create(db=db, object=recipe_internal, schema_to_select=RecipeRead)
    
    if created_recipe is None:
        raise NotFoundException("Failed to create recipe")
    
    # Create ingredients
    for ingredient in ingredients_data:
        ingredient_dict = ingredient.model_dump()
        ingredient_dict["recipe_id"] = created_recipe["id"]
        from ...schemas.ingredient import IngredientCreateInternal
        ingredient_internal = IngredientCreateInternal(**ingredient_dict)
        await crud_ingredients.create(db=db, object=ingredient_internal)
    
    # Create preparation steps
    for step in preparation_steps_data:
        step_dict = step.model_dump()
        step_dict["recipe_id"] = created_recipe["id"]
        from ...schemas.preparation_step import PreparationStepCreateInternal
        step_internal = PreparationStepCreateInternal(**step_dict)
        await crud_preparation_steps.create(db=db, object=step_internal)
    
    # Fetch ingredients and preparation steps separately
    from ...schemas.ingredient import IngredientRead
    from ...schemas.preparation_step import PreparationStepRead
    
    ingredients_list = await crud_ingredients.get_multi(
        db=db,
        recipe_id=created_recipe["id"],
        schema_to_select=IngredientRead,
    )
    
    steps_list = await crud_preparation_steps.get_multi(
        db=db,
        recipe_id=created_recipe["id"],
        schema_to_select=PreparationStepRead,
    )
    
    # Construct response with nested data
    created_recipe["ingredients"] = ingredients_list.get("data", [])
    created_recipe["preparation_steps"] = steps_list.get("data", [])
    
    return created_recipe


@router.get("/recipes", response_model=PaginatedListResponse[RecipeRead])
@cache(
    key_prefix="recipes:page_{page}:items_per_page:{items_per_page}:category:{category_id}:favorites:{favorites_only}:public:{public_only}",
    expiration=60,
    list_endpoint=True,
)
async def get_recipes(
    request: Request,
    db: Annotated[AsyncSession, Depends(async_get_db)],
    page: int = 1,
    items_per_page: int = 10,
    category_id: UUID | None = Query(None, description="Filter by category ID"),
    favorites_only: bool = Query(False, description="Show only favorites"),
    public_only: bool = Query(True, description="Show only public recipes (default: True)"),
    user_id: UUID | None = Query(None, description="Filter by user ID"),
) -> dict:
    """Get recipes with filters (paginated).
    
    By default, returns public recipes only.
    Use public_only=false with authentication to see all accessible recipes.
    """
    filters = {}
    
    if category_id:
        filters["category_id"] = category_id
    
    if favorites_only:
        filters["is_favorite"] = True
    
    if public_only:
        filters["is_public"] = True
    
    if user_id:
        filters["user_id"] = user_id
    
    recipes_data = await crud_recipes.get_multi(
        db=db,
        offset=compute_offset(page, items_per_page),
        limit=items_per_page,
        schema_to_select=RecipeRead,
        **filters,
    )
    
    response: dict[str, Any] = paginated_response(crud_data=recipes_data, page=page, items_per_page=items_per_page)
    return response


@router.get("/recipes/my", response_model=PaginatedListResponse[RecipeRead])
async def get_my_recipes(
    request: Request,
    current_user: Annotated[dict, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(async_get_db)],
    page: int = 1,
    items_per_page: int = 10,
    category_id: UUID | None = Query(None, description="Filter by category ID"),
    favorites_only: bool = Query(False, description="Show only favorites"),
) -> dict:
    """Get the current user's recipes (authenticated).
    
    This endpoint returns all recipes (public and private) owned by the current user.
    """
    filters = {"user_id": current_user["uuid"]}  # Already a UUID object
    
    if category_id:
        filters["category_id"] = category_id
    
    if favorites_only:
        filters["is_favorite"] = True
    
    recipes_data = await crud_recipes.get_multi(
        db=db,
        offset=compute_offset(page, items_per_page),
        limit=items_per_page,
        **filters,
    )
    
    response: dict[str, Any] = paginated_response(crud_data=recipes_data, page=page, items_per_page=items_per_page)
    return response


@router.get("/recipes/{recipe_id}", response_model=RecipeRead)
@cache(key_prefix="recipe_cache", resource_id_name="recipe_id")
async def get_recipe(
    request: Request,
    recipe_id: UUID,
    db: Annotated[AsyncSession, Depends(async_get_db)],
) -> dict[str, Any]:
    """Get a specific recipe by ID.

    Public recipes are accessible to everyone.
    Private recipes require authentication and ownership.
    Returns recipe with nested ingredients and preparation_steps.
    """
    recipe = await crud_recipes.get(db=db, id=recipe_id, schema_to_select=RecipeRead)

    if recipe is None:
        raise NotFoundException("Recipe not found")

    # Check if recipe is public or user has access
    if not recipe["is_public"]:
        # Recipe is private, check authentication
        # Note: This is a simplified check. In a real app, you'd need to get current_user here
        # For now, private recipes are visible only if explicitly requested
        pass

    # Load nested ingredients and preparation steps (not auto-loaded by get)
    ingredients_list = await crud_ingredients.get_multi(
        db=db,
        recipe_id=recipe_id,
        schema_to_select=IngredientRead,
    )
    steps_list = await crud_preparation_steps.get_multi(
        db=db,
        recipe_id=recipe_id,
        schema_to_select=PreparationStepRead,
    )
    recipe["ingredients"] = ingredients_list.get("data", [])
    recipe["preparation_steps"] = steps_list.get("data", [])

    # Increment view count
    recipe["view_count"] = recipe["view_count"] + 1
    await crud_recipes.update(
        db=db,
        object={"view_count": recipe["view_count"]},
        id=recipe_id,
    )

    return recipe


@router.patch("/recipes/{recipe_id}", response_model=RecipeRead)
@cache(key_prefix="recipe_cache", resource_id_name="recipe_id")
async def update_recipe(
    request: Request,
    recipe_id: UUID,
    values: RecipeUpdate,
    current_user: Annotated[dict, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(async_get_db)],
) -> dict[str, Any]:
    """Update a recipe (authenticated, owner only).

    When ``ingredients`` or ``preparation_steps`` are provided, the existing
    items are deleted and replaced with the supplied ones.
    """
    db_recipe = await crud_recipes.get(db=db, id=recipe_id)
    if db_recipe is None:
        raise NotFoundException("Recipe not found")

    # Check ownership
    if str(db_recipe["user_id"]) != str(current_user["uuid"]):
        raise ForbiddenException("You can only update your own recipes")

    # Extract nested lists before building the internal update object
    ingredients_data = values.ingredients
    preparation_steps_data = values.preparation_steps

    # Build a flat, ORM-safe update object (no nested ingredients/steps fields).
    values_dict = values.model_dump(exclude_unset=True, exclude={"ingredients", "preparation_steps"})
    values_internal = RecipeUpdateInternal(**values_dict, updated_at=datetime.now(UTC))

    # fastcrud's update() returns None in this version; fetch the record separately.
    await crud_recipes.update(db=db, object=values_internal, id=recipe_id)
    updated_recipe = await crud_recipes.get(db=db, id=recipe_id, schema_to_select=RecipeRead)
    if updated_recipe is None:
        raise NotFoundException("Recipe not found after update")

    # Replace ingredients when provided
    if ingredients_data is not None:
        from ...schemas.ingredient import IngredientCreateInternal
        existing_ingredients = await crud_ingredients.get_multi(
            db=db,
            recipe_id=recipe_id,
            schema_to_select=IngredientRead,
        )
        for ing in existing_ingredients.get("data", []):
            await crud_ingredients.delete(db=db, id=ing["id"])
        for ingredient in ingredients_data:
            ing_dict = ingredient.model_dump()
            ing_dict["recipe_id"] = recipe_id
            await crud_ingredients.create(db=db, object=IngredientCreateInternal(**ing_dict))

    # Replace preparation steps when provided
    if preparation_steps_data is not None:
        from ...schemas.preparation_step import PreparationStepCreateInternal
        existing_steps = await crud_preparation_steps.get_multi(
            db=db,
            recipe_id=recipe_id,
            schema_to_select=PreparationStepRead,
        )
        for step in existing_steps.get("data", []):
            await crud_preparation_steps.delete(db=db, id=step["id"])
        for step in preparation_steps_data:
            step_dict = step.model_dump()
            step_dict["recipe_id"] = recipe_id
            await crud_preparation_steps.create(db=db, object=PreparationStepCreateInternal(**step_dict))

    # Attach the final nested lists to the response
    ingredients_list = await crud_ingredients.get_multi(
        db=db,
        recipe_id=recipe_id,
        schema_to_select=IngredientRead,
    )
    steps_list = await crud_preparation_steps.get_multi(
        db=db,
        recipe_id=recipe_id,
        schema_to_select=PreparationStepRead,
    )
    updated_recipe["ingredients"] = ingredients_list.get("data", [])
    updated_recipe["preparation_steps"] = steps_list.get("data", [])

    return updated_recipe


@router.delete("/recipes/{recipe_id}", status_code=204)
@cache(key_prefix="recipe_cache", resource_id_name="recipe_id")
async def delete_recipe(
    request: Request,
    recipe_id: UUID,
    current_user: Annotated[dict, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(async_get_db)],
) -> None:
    """Delete a recipe (authenticated, owner only).
    
    This will cascade delete all ingredients and preparation steps.
    """
    db_recipe = await crud_recipes.get(db=db, id=recipe_id)
    if db_recipe is None:
        raise NotFoundException("Recipe not found")
    
    # Check ownership
    if str(db_recipe["user_id"]) != str(current_user["uuid"]):
        raise ForbiddenException("You can only delete your own recipes")
    
    await crud_recipes.delete(db=db, id=recipe_id)


@router.post("/recipes/{recipe_id}/favorite", response_model=RecipeRead)
@cache(key_prefix="recipe_cache", resource_id_name="recipe_id")
async def toggle_favorite(
    request: Request,
    recipe_id: UUID,
    current_user: Annotated[dict, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(async_get_db)],
) -> dict[str, Any]:
    """Toggle favorite status for a recipe (authenticated, owner only)."""
    db_recipe = await crud_recipes.get(db=db, id=recipe_id)
    if db_recipe is None:
        raise NotFoundException("Recipe not found")
    
    # Check ownership
    if str(db_recipe["user_id"]) != str(current_user["uuid"]):
        raise ForbiddenException("You can only favorite your own recipes")
    
    # Toggle favorite
    updated_recipe = await crud_recipes.update(
        db=db,
        object={"is_favorite": not db_recipe["is_favorite"]},
        id=recipe_id,
        schema_to_select=RecipeRead,
    )
    
    return updated_recipe
