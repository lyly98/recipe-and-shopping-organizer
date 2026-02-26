"""CRUD operations for MealPlanEntry model."""
from fastcrud import FastCRUD

from ..models.meal_plan import MealPlanEntry
from ..schemas.meal_plan import MealPlanEntryCreateInternal, MealPlanEntryRead

CRUDMealPlan = FastCRUD[
    MealPlanEntry,
    MealPlanEntryCreateInternal,
    MealPlanEntryCreateInternal,  # no partial-update schema needed
    MealPlanEntryCreateInternal,
    MealPlanEntryCreateInternal,
    MealPlanEntryRead,
]
crud_meal_plan = CRUDMealPlan(MealPlanEntry)
