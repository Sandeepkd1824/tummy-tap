from django.db import models
from django.conf import settings
import random
from django.contrib.auth.models import AbstractBaseUser, BaseUserManager, PermissionsMixin
from django.utils import timezone
from datetime import timedelta


class EmailOTP(models.Model):
    user = models.OneToOneField(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="otp")
    code = models.CharField(max_length=6)
    created_at = models.DateTimeField(auto_now_add=True)

    def generate_code(self):
        self.code = str(random.randint(100000, 999999))
        self.created_at = timezone.now()
        self.save()
        return self.code

    def is_expired(self):
        return timezone.now() > self.created_at + timedelta(minutes=5)  # expires after 5 min

    def __str__(self):
        return f"OTP for {self.user.email}: {self.code}"


class CustomUserManager(BaseUserManager):
    def create_user(self, email, username=None, password=None, **extra_fields):
        if not email:
            raise ValueError('Email is required')
        if not username:
            raise ValueError('Username is required')

        email = self.normalize_email(email)
        user = self.model(email=email, username=username, **extra_fields)
        user.set_password(password)
        user.save(using=self._db)
        return user

    def create_superuser(self, email, username=None, password=None, **extra_fields):
        extra_fields.setdefault("is_staff", True)
        extra_fields.setdefault("is_superuser", True)
        return self.create_user(email, username, password, **extra_fields)


class CustomUser(AbstractBaseUser, PermissionsMixin):
    username = models.CharField(max_length=150, unique=True)
    email = models.EmailField(unique=True)
    name = models.CharField(max_length=255, blank=True)
    phone = models.CharField(max_length=15, blank=True)
    primary_address = models.TextField(blank=True)

    is_active = models.BooleanField(default=True)
    is_staff = models.BooleanField(default=False)
    is_verified = models.BooleanField(default=False)
    date_joined = models.DateTimeField(auto_now_add=True)

    USERNAME_FIELD = "username"   # <-- This makes username the default login field
    REQUIRED_FIELDS = ["email"]   # <-- Email is also required when creating superuser

    objects = CustomUserManager()

    def __str__(self):
        return self.username or self.email
