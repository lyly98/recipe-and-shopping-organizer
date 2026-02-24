"""Category API endpoints."""
from typing import Annotated, Any
from uuid import UUID

from fastapi import APIRouter, Depends, Request
from fastcrud import PaginatedListResponse, compute_offset, paginated_response
from sqlalchemy.ext.asyncio import AsyncSession

from ...api.dependencies import get_current_superuser, get_current_user
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
    """Create a new category.
    
    Note: Currently any authenticated user can create categories.
    In production, you may want to restrict this to admins only.
    """
    # Add user_id from current user
    category_dict = category.model_dump()
    category_dict["user_id"] = current_user["uuid"]  # Already a UUID object
    category_internal = CategoryCreateInternal(**category_dict)
    
    created_category = await crud_categories.create(db=db, object=category_internal, schema_to_select=CategoryRead)
    
    if created_category is None:
        raise NotFoundException("Failed to create category")
    
    return created_category


@router.get("/categories", response_model=PaginatedListResponse[CategoryRead])
@cache(
    key_prefix="categories:page_{page}:items_per_page:{items_per_page}",
    expiration=300,  # 5 minutes cache
    list_endpoint=True,
)
async def get_categories(
    request: Request,
    db: Annotated[AsyncSession, Depends(async_get_db)],
    page: int = 1,
    items_per_page: int = 10,
) -> dict:
    """Get all categories (paginated).
    
    Public endpoint - no authentication required.
    """
    categories_data = await crud_categories.get_multi(
        db=db,
        offset=compute_offset(page, items_per_page),
        limit=items_per_page,
    )
    
    response: dict[str, Any] = paginated_response(crud_data=categories_data, page=page, items_per_page=items_per_page)
    return response


@router.get("/categories/{category_id}", response_model=CategoryRead)
@cache(key_prefix="category_cache", resource_id_name="category_id")
async def get_category(
    request: Request,
    category_id: UUID,
    db: Annotated[AsyncSession, Depends(async_get_db)],
) -> dict[str, Any]:
    """Get a specific category by ID.
    
    Public endpoint - no authentication required.
    """
    category = await crud_categories.get(db=db, id=category_id, schema_to_select=CategoryRead)
    
    if category is None:
        raise NotFoundException("Category not found")
    
    return category


@router.patch("/categories/{category_id}", response_model=CategoryRead)
async def update_category(
    request: Request,
    category_id: UUID,
    values: CategoryUpdate,
    current_user: Annotated[dict, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(async_get_db)],
) -> dict[str, Any]:
    """Update a category.
    
    Note: Currently any authenticated user can update categories.
    In production, you may want to restrict this to admins only.
    """
    db_category = await crud_categories.get(db=db, id=category_id)
    if db_category is None:
        raise NotFoundException("Category not found")
    
    updated_category = await crud_categories.update(
        db=db,
        object=values,
        id=category_id,
        schema_to_select=CategoryRead,
    )
    
    return updated_category


@router.delete("/categories/{category_id}", status_code=204)
async def delete_category(
    request: Request,
    category_id: UUID,
    current_user: Annotated[dict, Depends(get_current_superuser)],  # Only superusers can delete
    db: Annotated[AsyncSession, Depends(async_get_db)],
) -> None:
    """Delete a category (superuser only).
    
    This will fail if there are recipes associated with this category.
    """
    db_category = await crud_categories.get(db=db, id=category_id)
    if db_category is None:
        raise NotFoundException("Category not found")
    
    await crud_categories.delete(db=db, id=category_id)
