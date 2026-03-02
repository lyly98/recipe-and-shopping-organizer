"""CRUD operations for Category model."""
from fastcrud import FastCRUD

from ..models.recipe import Category
from ..schemas.category import (
    CategoryCreateInternal,
    CategoryRead,
    CategoryUpdate,
    CategoryUpdateInternal,
)

CRUDCategory = FastCRUD[
    Category,
    CategoryCreateInternal,
    CategoryUpdate,
    CategoryUpdateInternal,
    CategoryUpdate,
    CategoryRead,
]
crud_categories = CRUDCategory(Category)
