# commerce/views.py
from rest_framework import viewsets, permissions, status
from rest_framework.decorators import action
from rest_framework.response import Response
from django.db import transaction
from .models import Cart, CartItem, Order, OrderItem
from .serializers import CartSerializer, AddToCartSerializer, OrderSerializer
from customers.models import Address


class CartViewSet(viewsets.ViewSet):
    permission_classes = [permissions.IsAuthenticated]

    def _get_cart(self, request):
        cart, _ = Cart.objects.get_or_create(user=request.user)
        return cart

    def list(self, request):
        cart = self._get_cart(request)
        return Response(CartSerializer(cart).data)

    @action(detail=False, methods=["post"])
    def add_item(self, request):
        ser = AddToCartSerializer(data=request.data)
        ser.is_valid(raise_exception=True)
        data = ser.validated_data
        cart = self._get_cart(request)
        item = data["item"]
        quantity = data.get("quantity", 1)

        # ✅ No restaurant restriction
        ci, created = CartItem.objects.get_or_create(
            cart=cart,
            item=item,
            defaults={"unit_price": item.price, "quantity": quantity},
        )
        if not created:
            ci.quantity += quantity
            ci.save()
        return Response(CartSerializer(cart).data)

    @action(detail=False, methods=["post"])
    def remove_item(self, request):
        item_id = request.data.get("item_id")
        cart = self._get_cart(request)
        CartItem.objects.filter(cart=cart, item_id=item_id).delete()
        return Response(CartSerializer(cart).data)

    @action(detail=False, methods=["post"])
    def clear(self, request):
        cart = self._get_cart(request)
        cart.items.all().delete()
        return Response({"message": "Cart cleared"})


class OrderViewSet(viewsets.ViewSet):
    permission_classes = [permissions.IsAuthenticated]

    def list(self, request):
        orders = request.user.orders.all().order_by("-created_at")
        return Response([OrderSerializer(o).data for o in orders])

    @action(detail=False, methods=["post"])
    def place(self, request):
        address_id = request.data.get("address_id")
        try:
            address = Address.objects.get(pk=address_id, user=request.user)
        except Address.DoesNotExist:
            return Response(
                {"error": "Address not found"}, status=status.HTTP_400_BAD_REQUEST
            )

        cart, _ = Cart.objects.get_or_create(user=request.user)
        if not cart.items.exists():
            return Response(
                {"error": "Cart is empty"}, status=status.HTTP_400_BAD_REQUEST
            )

        created_orders = []
        with transaction.atomic():
            # ✅ Group items by restaurant
            items_by_restaurant = {}
            for ci in cart.items.all():
                items_by_restaurant.setdefault(ci.item.restaurant, []).append(ci)

            for restaurant, items in items_by_restaurant.items():
                total = sum(ci.unit_price * ci.quantity for ci in items)
                order = Order.objects.create(
                    user=request.user,
                    restaurant=restaurant,
                    total=total,
                    address_line1=address.line1,
                    address_line2=address.line2,
                    city=address.city,
                    postal_code=address.postal_code,
                    latitude=address.latitude,
                    longitude=address.longitude,
                )
                for ci in items:
                    OrderItem.objects.create(
                        order=order,
                        item_name=ci.item.name,
                        unit_price=ci.unit_price,
                        quantity=ci.quantity,
                    )
                created_orders.append(order)

            # ✅ Clear cart after placing all orders
            cart.items.all().delete()

        return Response(
            [OrderSerializer(o).data for o in created_orders],
            status=status.HTTP_201_CREATED,
        )
