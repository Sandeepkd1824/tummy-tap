from rest_framework import serializers
from .models import CustomUser
from django.contrib.auth import authenticate
from rest_framework_simplejwt.tokens import RefreshToken


class RegisterSerializer(serializers.ModelSerializer):
    class Meta:
        model = CustomUser
        fields = ['username', 'email', 'password']
        extra_kwargs = {'password': {'write_only': True}}

    def create(self, validated_data):
        user = CustomUser.objects.create_user(**validated_data)
        user.is_verified = False
        user.save()
        return user


class JWTLoginSerializer(serializers.Serializer):
    username = serializers.CharField()   # can be username OR email
    password = serializers.CharField(write_only=True)

    def validate(self, data):
        username_or_email = data.get("username")
        password = data.get("password")

        # Check if input is email or username
        try:
            if "@" in username_or_email:  # treat as email
                user = CustomUser.objects.get(email=username_or_email)
            else:  # treat as username
                user = CustomUser.objects.get(username=username_or_email)
        except CustomUser.DoesNotExist:
            raise serializers.ValidationError("No account found with these credentials")

        # Authenticate using username (Django default)
        user = authenticate(username=user.username, password=password)
        if not user:
            raise serializers.ValidationError("Invalid credentials")

        if not user.is_verified:
            raise serializers.ValidationError("Email not verified")

        # Generate JWT
        refresh = RefreshToken.for_user(user)
        return {
            "refresh": str(refresh),
            "access": str(refresh.access_token),
            "user": {
                "id": user.id,
                "email": user.email,
                "username": user.username,
            },
        }