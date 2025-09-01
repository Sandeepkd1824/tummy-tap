from django.urls import path
from .views.cart_views import (
    CartListView,
    CartAddItemView,
    CartRemoveItemView,
    CartDeleteItemView,
    CartClearView,
)
from .views.order_views import OrderListView, PlaceOrderView

urlpatterns = [
    # Cart APIs
    path("cart/", CartListView.as_view(), name="cart-list"),
    path("cart/add_item/", CartAddItemView.as_view(), name="cart-add"),
    path("cart/remove_item/", CartRemoveItemView.as_view(), name="cart-remove"),
    path(
        "cart/delete_item/<int:item_id>/", CartDeleteItemView.as_view(), name="cart-delete"
    ),
    path("cart/clear/", CartClearView.as_view(), name="cart-clear"),
    # Order APIs
    path("orders/", OrderListView.as_view(), name="orders-list"),
    path("orders/place/", PlaceOrderView.as_view(), name="orders-place"),
]
