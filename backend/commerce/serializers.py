from rest_framework import serializers
from .models import Cart, CartItem, Order, OrderItem
from restaurants.models import MenuItem


class CartItemSerializer(serializers.ModelSerializer):
    item_name = serializers.CharField(source="item.name")
    unit_price = serializers.DecimalField(
        source="item.price", max_digits=10, decimal_places=2
    )
    restaurant_id = serializers.IntegerField(source="item.restaurant.id")
    restaurant_name = serializers.CharField(source="item.restaurant.name")

    class Meta:
        model = CartItem
        fields = [
            "id",
            "item",
            "item_name",
            "unit_price",
            "quantity",
            "restaurant_id",
            "restaurant_name",
        ]


class CartSerializer(serializers.ModelSerializer):
    restaurants = serializers.SerializerMethodField()
    subtotal = serializers.SerializerMethodField()

    class Meta:
        model = Cart
        fields = ["id", "restaurants", "subtotal"]

    def get_restaurants(self, obj):
        restaurants = {}
        for item in obj.items.all():
            rid = item.item.restaurant.id
            if rid not in restaurants:
                restaurants[rid] = {
                    "restaurant_id": rid,
                    "restaurant_name": item.item.restaurant.name,
                    "items": [],
                    "restaurant_total": 0,
                }
            data = CartItemSerializer(item).data
            restaurants[rid]["items"].append(data)
            restaurants[rid]["restaurant_total"] += (
                float(item.item.price) * item.quantity
            )
        return list(restaurants.values())

    def get_subtotal(self, obj):
        return sum(float(item.item.price) * item.quantity for item in obj.items.all())


class RestaurantCartSerializer(serializers.Serializer):
    restaurant_id = serializers.IntegerField()
    restaurant_name = serializers.CharField()
    items = CartItemSerializer(many=True)
    restaurant_total = serializers.FloatField()


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
            "payment_method",
            "items",
            "created_at",
        ]
