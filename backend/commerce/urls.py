from django.urls import path
from .views.cart_views import (
    CartListView,
    CartAddItemView,
    CartRemoveItemView,
    CartDeleteItemView,
    CartClearView,
)
from .views.order_views import OrderListView, PlaceOrderView, UpdateOrderStatusView
from .views.checkout import CheckoutView

urlpatterns = [
    # Cart APIs
    path("cart/", CartListView.as_view(), name="cart-list"),
    path("cart/add_item/", CartAddItemView.as_view(), name="cart-add"),
    path("cart/remove_item/", CartRemoveItemView.as_view(), name="cart-remove"),
    path(
        "cart/delete_item/<int:item_id>/",
        CartDeleteItemView.as_view(),
        name="cart-delete",
    ),
    path("cart/clear/", CartClearView.as_view(), name="cart-clear"),
    # Order APIs
    path("orders/", OrderListView.as_view(), name="order-list"),
    path("orders/place/", PlaceOrderView.as_view(), name="place-order"),
    path(
        "orders/<int:pk>/status/",
        UpdateOrderStatusView.as_view(),
        name="update-order-status",
    ),
    path("checkout/", CheckoutView.as_view(), name="checkout"),
]
