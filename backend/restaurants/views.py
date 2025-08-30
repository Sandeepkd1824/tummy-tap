# restaurants/views.py
from rest_framework import viewsets, permissions
from rest_framework.decorators import action
from rest_framework.response import Response
from .models import Restaurant, MenuItem, MenuCategory
from .serializers import (
    RestaurantSerializer,
    MenuItemSerializer,
    MenuCategorySerializer,
)
from config.utils import haversine_km


class RestaurantViewSet(viewsets.ModelViewSet):
    queryset = Restaurant.objects.all()
    serializer_class = RestaurantSerializer
    permission_classes = [permissions.AllowAny]

    @action(detail=False, methods=["get"], permission_classes=[permissions.AllowAny])
    def nearby(self, request):
        lat = request.query_params.get("lat")
        lng = request.query_params.get("lng")
        max_km = float(request.query_params.get("max_km", 10))
        if not lat or not lng:
            return Response(
                {"error": "lat & lng query params are required"}, status=400
            )
        lat = float(lat)
        lng = float(lng)
        data = []
        for r in Restaurant.objects.filter(is_open=True):
            d = haversine_km(lat, lng, float(r.latitude), float(r.longitude))
            if d <= min(max_km, float(r.service_radius_km)):
                rdata = RestaurantSerializer(r).data
                rdata["distance_km"] = round(d, 2)
                data.append(rdata)
        data.sort(key=lambda x: x["distance_km"])
        return Response(data)


class MenuCategoryViewSet(viewsets.ModelViewSet):
    queryset = MenuCategory.objects.all()
    serializer_class = MenuCategorySerializer
    permission_classes = [permissions.AllowAny]


class MenuItemViewSet(viewsets.ModelViewSet):
    queryset = MenuItem.objects.all()
    serializer_class = MenuItemSerializer
    permission_classes = [permissions.AllowAny]
