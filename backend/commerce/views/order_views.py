from rest_framework import generics, permissions, status
from rest_framework.response import Response
from django.db import transaction
from ..models import Cart, Order, OrderItem
from ..serializers import OrderSerializer
from customers.models import Address


class OrderListView(generics.ListAPIView):
    permission_classes = [permissions.IsAuthenticated]
    serializer_class = OrderSerializer

    def get_queryset(self):
        return self.request.user.orders.all().order_by("-created_at")


class PlaceOrderView(generics.GenericAPIView):
    permission_classes = [permissions.IsAuthenticated]
    serializer_class = OrderSerializer

    def post(self, request, *args, **kwargs):
        address_id = request.data.get("address_id")
        payment_method = request.data.get("payment_method", "cod")

        if payment_method not in dict(Order.PAYMENT_CHOICES):
            return Response(
                {"error": "Invalid payment method"},
                status=status.HTTP_400_BAD_REQUEST,
            )

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
                    payment_method=payment_method,
                )
                for ci in items:
                    OrderItem.objects.create(
                        order=order,
                        item_name=ci.item.name,
                        unit_price=ci.unit_price,
                        quantity=ci.quantity,
                    )
                created_orders.append(order)

            cart.items.all().delete()

        return Response(
            OrderSerializer(created_orders, many=True).data,
            status=status.HTTP_201_CREATED,
        )


class UpdateOrderStatusView(generics.UpdateAPIView):
    permission_classes = [permissions.IsAuthenticated]
    serializer_class = OrderSerializer
    queryset = Order.objects.all()

    def patch(self, request, *args, **kwargs):
        order = self.get_object()

        # Only allow restaurant owners (or admin) to update
        if order.restaurant.owner != request.user and not request.user.is_staff:
            return Response({"error": "Not allowed"}, status=status.HTTP_403_FORBIDDEN)

        new_status = request.data.get("status")
        if new_status not in dict(Order.STATUS_CHOICES):
            return Response(
                {"error": "Invalid status"}, status=status.HTTP_400_BAD_REQUEST
            )

        order.status = new_status
        order.save()
        return Response(OrderSerializer(order).data)
