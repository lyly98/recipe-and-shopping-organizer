"""CRUD operations for Ingredient model."""
from fastcrud import FastCRUD

from ..models.recipe import Ingredient
from ..schemas.ingredient import (
    IngredientCreateInternal,
    IngredientRead,
    IngredientUpdate,
)

CRUDIngredient = FastCRUD[
    Ingredient,
    IngredientCreateInternal,
    IngredientUpdate,
    IngredientUpdate,
    IngredientUpdate,
    IngredientRead,
]
crud_ingredients = CRUDIngredient(Ingredient)
