# commerce/serializers.py
from rest_framework import serializers
from .models import Cart, CartItem, Order, OrderItem
from restaurants.models import MenuItem, Restaurant


class CartItemSerializer(serializers.ModelSerializer):
    item_name = serializers.CharField(source="item.name", read_only=True)

    class Meta:
        model = CartItem
        fields = ["id", "item", "item_name", "unit_price", "quantity"]


class CartRestaurantGroupSerializer(serializers.Serializer):
    """Group of cart items belonging to one restaurant."""
    restaurant_id = serializers.IntegerField()
    restaurant_name = serializers.CharField()
    items = CartItemSerializer(many=True)
    restaurant_total = serializers.FloatField()


class CartSerializer(serializers.ModelSerializer):
    restaurants = serializers.SerializerMethodField()
    subtotal = serializers.SerializerMethodField()

    class Meta:
        model = Cart
        fields = ["id", "restaurants", "subtotal"]

    def get_restaurants(self, obj):
        # Group items by restaurant
        grouped = {}
        for ci in obj.items.select_related("item__restaurant").all():
            rest = ci.item.restaurant
            if rest.id not in grouped:
                grouped[rest.id] = {
                    "restaurant_id": rest.id,
                    "restaurant_name": rest.name,
                    "items": [],
                    "restaurant_total": 0,
                }
            grouped[rest.id]["items"].append(CartItemSerializer(ci).data)
            grouped[rest.id]["restaurant_total"] += float(ci.unit_price) * ci.quantity

        return list(grouped.values())

    def get_subtotal(self, obj):
        return obj.subtotal()


class AddToCartSerializer(serializers.Serializer):
    item_id = serializers.IntegerField()
    quantity = serializers.IntegerField(min_value=1, default=1)

    def validate(self, data):
        try:
            item = MenuItem.objects.get(pk=data["item_id"])
        except MenuItem.DoesNotExist:
            raise serializers.ValidationError("Item does not exist")
        if not item.is_available:
            raise serializers.ValidationError("Item not available")
        data["item"] = item
        return data


class OrderItemSerializer(serializers.ModelSerializer):
    class Meta:
        model = OrderItem
        fields = ["item_name", "unit_price", "quantity"]


class OrderSerializer(serializers.ModelSerializer):
    items = OrderItemSerializer(many=True, read_only=True)
    restaurant_name = serializers.CharField(source="restaurant.name", read_only=True)

    class Meta:
        model = Order
        fields = [
            "id",
            "restaurant",
            "restaurant_name",
            "status",
            "total",
            "address_line1",
            "address_line2",
            "city",
            "postal_code",
            "latitude",
            "longitude",
            "items",
            "created_at",
        ]
