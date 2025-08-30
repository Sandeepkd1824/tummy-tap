# restaurants/serializers.py
from rest_framework import serializers
from .models import Restaurant, MenuCategory, MenuItem


class MenuItemSerializer(serializers.ModelSerializer):
    class Meta:
        model = MenuItem
        fields = [
            "id",
            "name",
            "description",
            "price",
            "image",
            "is_available",
            "category",
            "restaurant",
        ]


class MenuCategorySerializer(serializers.ModelSerializer):
    items = MenuItemSerializer(many=True, read_only=True)

    class Meta:
        model = MenuCategory
        fields = ["id", "name", "sort_order", "items"]


class RestaurantSerializer(serializers.ModelSerializer):
    categories = MenuCategorySerializer(many=True, read_only=True)

    class Meta:
        model = Restaurant
        fields = [
            "id",
            "name",
            "description",
            "phone",
            "address_line1",
            "address_line2",
            "city",
            "postal_code",
            "latitude",
            "longitude",
            "service_radius_km",
            "is_open",
            "open_time",
            "close_time",
            "categories",
        ]
