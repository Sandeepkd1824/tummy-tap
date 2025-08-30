# restaurants/urls.py
from rest_framework.routers import DefaultRouter
from .views import RestaurantViewSet, MenuItemViewSet, MenuCategoryViewSet

router = DefaultRouter()
router.register("restaurants", RestaurantViewSet, basename="restaurants")
router.register("menu-categories", MenuCategoryViewSet, basename="menu-categories")
router.register("menu-items", MenuItemViewSet, basename="menu-items")

urlpatterns = router.urls
