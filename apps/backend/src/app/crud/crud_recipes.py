"""CRUD operations for Recipe model."""
from fastcrud import FastCRUD

from ..models.recipe import Recipe
from ..schemas.recipe import RecipeCreateInternal, RecipeRead, RecipeUpdate, RecipeUpdateInternal

CRUDRecipe = FastCRUD[Recipe, RecipeCreateInternal, RecipeUpdate, RecipeUpdateInternal, RecipeUpdate, RecipeRead]
crud_recipes = CRUDRecipe(Recipe)
