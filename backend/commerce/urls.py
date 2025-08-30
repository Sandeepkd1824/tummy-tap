# commerce/urls.py
from django.urls import path
from rest_framework.routers import DefaultRouter
from .views import CartViewSet, OrderViewSet
from django.urls import include

router = DefaultRouter()
# these ViewSets use custom actions, register manually by include as viewset routes:
# We'll expose custom endpoints:
urlpatterns = [
    path("cart/", CartViewSet.as_view({"get": "list"})),
    path("cart/add_item/", CartViewSet.as_view({"post": "add_item"})),
    path("cart/remove_item/", CartViewSet.as_view({"post": "remove_item"})),
    path("cart/clear/", CartViewSet.as_view({"post": "clear"})),
    path("orders/", OrderViewSet.as_view({"get": "list"})),
    path("orders/place/", OrderViewSet.as_view({"post": "place"})),
]
