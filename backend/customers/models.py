# customers/models.py
from django.db import models
from django.contrib.auth import get_user_model

User = get_user_model()


class Address(models.Model):
    HOME = "home"
    WORK = "work"
    OTHER = "other"
    TYPE_CHOICES = [(HOME, "Home"), (WORK, "Work"), (OTHER, "Other")]

    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name="addresses")
    label = models.CharField(max_length=50, choices=TYPE_CHOICES, default=HOME)
    line1 = models.CharField(max_length=255)
    line2 = models.CharField(max_length=255, blank=True)
    city = models.CharField(max_length=120)
    postal_code = models.CharField(max_length=20, blank=True)
    latitude = models.DecimalField(max_digits=9, decimal_places=6)
    longitude = models.DecimalField(max_digits=9, decimal_places=6)
    is_default = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"{self.label}: {self.line1}"
