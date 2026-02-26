"""Category API endpoints."""
from typing import Annotated, Any
from uuid import UUID

from fastapi import APIRouter, Depends, Request
from fastcrud import PaginatedListResponse, compute_offset, paginated_response
from sqlalchemy.ext.asyncio import AsyncSession

from ...api.dependencies import get_current_user
from ...core.db.database import async_get_db
from ...core.exceptions.http_exceptions import ForbiddenException, NotFoundException
from ...core.utils.cache import cache
from ...crud.crud_categories import crud_categories
from ...schemas.category import CategoryCreate, CategoryCreateInternal, CategoryRead, CategoryUpdate

router = APIRouter(tags=["categories"])


@router.post("/categories", response_model=CategoryRead, status_code=201)
async def create_category(
    request: Request,
    category: CategoryCreate,
    current_user: Annotated[dict, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(async_get_db)],
) -> dict[str, Any]:
    """Create a new category for the authenticated user."""
    category_dict = category.model_dump()
    category_dict["user_id"] = current_user["uuid"]
    category_internal = CategoryCreateInternal(**category_dict)

    created_category = await crud_categories.create(db=db, object=category_internal, schema_to_select=CategoryRead)

    if created_category is None:
        raise NotFoundException("Failed to create category")

    return created_category


@router.get("/categories", response_model=PaginatedListResponse[CategoryRead])
async def get_categories(
    request: Request,
    current_user: Annotated[dict, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(async_get_db)],
    page: int = 1,
    items_per_page: int = 10,
) -> dict:
    """Get the authenticated user's categories (paginated)."""
    categories_data = await crud_categories.get_multi(
        db=db,
        offset=compute_offset(page, items_per_page),
        limit=items_per_page,
        user_id=current_user["uuid"],
    )

    response: dict[str, Any] = paginated_response(crud_data=categories_data, page=page, items_per_page=items_per_page)
    return response


@router.get("/categories/{category_id}", response_model=CategoryRead)
@cache(key_prefix="category_cache", resource_id_name="category_id")
async def get_category(
    request: Request,
    category_id: UUID,
    current_user: Annotated[dict, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(async_get_db)],
) -> dict[str, Any]:
    """Get a specific category by ID (must belong to the authenticated user)."""
    category = await crud_categories.get(db=db, id=category_id, schema_to_select=CategoryRead)

    if category is None:
        raise NotFoundException("Category not found")

    if str(category["user_id"]) != str(current_user["uuid"]):
        raise ForbiddenException("You can only access your own categories")

    return category


@router.patch("/categories/{category_id}", response_model=CategoryRead)
async def update_category(
    request: Request,
    category_id: UUID,
    values: CategoryUpdate,
    current_user: Annotated[dict, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(async_get_db)],
) -> dict[str, Any]:
    """Update a category (authenticated, owner only)."""
    db_category = await crud_categories.get(db=db, id=category_id)
    if db_category is None:
        raise NotFoundException("Category not found")

    if str(db_category["user_id"]) != str(current_user["uuid"]):
        raise ForbiddenException("You can only update your own categories")

    # fastcrud's update() returns None in this version; fetch the record separately.
    await crud_categories.update(db=db, object=values, id=category_id)

    updated_category = await crud_categories.get(db=db, id=category_id, schema_to_select=CategoryRead)
    if updated_category is None:
        raise NotFoundException("Category not found after update")

    return updated_category


@router.delete("/categories/{category_id}", status_code=204)
async def delete_category(
    request: Request,
    category_id: UUID,
    current_user: Annotated[dict, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(async_get_db)],
) -> None:
    """Delete a category (authenticated, owner only)."""
    db_category = await crud_categories.get(db=db, id=category_id)
    if db_category is None:
        raise NotFoundException("Category not found")

    if str(db_category["user_id"]) != str(current_user["uuid"]):
        raise ForbiddenException("You can only delete your own categories")

    await crud_categories.delete(db=db, id=category_id)
