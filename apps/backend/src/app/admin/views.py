from crudadmin import CRUDAdmin
from crudadmin.admin_interface.model_view import PasswordTransformer

from ..core.security import get_password_hash
from ..models.recipe import Category, Recipe
from ..models.user import User
from ..schemas.category import CategoryCreate, CategoryUpdate
from ..schemas.recipe import RecipeCreate, RecipeUpdate
from ..schemas.user import UserCreate, UserCreateInternal, UserUpdate


def register_admin_views(admin: CRUDAdmin) -> None:
    """Register all models and their schemas with the admin interface.

    This function adds all available models to the admin interface with appropriate
    schemas and permissions.
    """

    password_transformer = PasswordTransformer(
        password_field="password",
        hashed_field="hashed_password",
        hash_function=get_password_hash,
        required_fields=["name", "username", "email"],
    )

    # User management
    admin.add_view(
        model=User,
        create_schema=UserCreate,
        update_schema=UserUpdate,
        update_internal_schema=UserCreateInternal,
        password_transformer=password_transformer,
        allowed_actions={"view", "create", "update"},
    )

    # Category management
    admin.add_view(
        model=Category,
        create_schema=CategoryCreate,
        update_schema=CategoryUpdate,
        allowed_actions={"view", "create", "update", "delete"},
    )

    # Recipe management (view only for now, complex nested structure)
    admin.add_view(
        model=Recipe,
        create_schema=RecipeCreate,
        update_schema=RecipeUpdate,
        allowed_actions={"view"},
    )
