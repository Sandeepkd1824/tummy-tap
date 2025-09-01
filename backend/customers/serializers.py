# customers/serializers.py
from rest_framework import serializers
from .models import Address


class AddressSerializer(serializers.ModelSerializer):
    class Meta:
        model = Address
        fields = [
            "id",
            "label",
            "line1",
            "line2",
            "city",
            "postal_code",
            "latitude",
            "longitude",
            "mobile",
            "is_default",
            "created_at",
            "updated_at",
        ]

    def create(self, validated_data):
        user = self.context["request"].user
        addr = Address.objects.create(user=user, **validated_data)
        if addr.is_default:
            Address.objects.filter(user=user).exclude(id=addr.id).update(
                is_default=False
            )
        return addr

    def update(self, instance, validated_data):
        instance = super().update(instance, validated_data)
        if instance.is_default:
            Address.objects.filter(user=instance.user).exclude(id=instance.id).update(
                is_default=False
            )
        return instance
