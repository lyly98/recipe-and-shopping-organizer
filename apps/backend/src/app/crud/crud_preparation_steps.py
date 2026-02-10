"""CRUD operations for PreparationStep model."""
from fastcrud import FastCRUD

from ..models.recipe import PreparationStep
from ..schemas.preparation_step import PreparationStepCreate, PreparationStepCreateInternal, PreparationStepRead, PreparationStepUpdate

CRUDPreparationStep = FastCRUD[PreparationStep, PreparationStepCreateInternal, PreparationStepUpdate, PreparationStepUpdate, PreparationStepUpdate, PreparationStepRead]
crud_preparation_steps = CRUDPreparationStep(PreparationStep)
