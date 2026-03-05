from fastapi import APIRouter

from .categories import router as categories_router
from .health import router as health_router
from .login import router as login_router
from .logout import router as logout_router
from .meal_plan import router as meal_plan_router
from .recipes import router as recipes_router
from .upload import router as upload_router
from .users import router as users_router
from .video_import import router as video_import_router

router = APIRouter(prefix="/v1")

# Core endpoints
router.include_router(health_router)
router.include_router(login_router)
router.include_router(logout_router)
router.include_router(users_router)

# Recipe application endpoints
router.include_router(categories_router)
router.include_router(recipes_router)
router.include_router(upload_router)
router.include_router(meal_plan_router)
router.include_router(video_import_router)
