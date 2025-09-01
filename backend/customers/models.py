# customers/models.py
from django.db import models
from django.contrib.auth import get_user_model
from django.core.validators import RegexValidator

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
    mobile = models.CharField(
        max_length=15,
        validators=[
            RegexValidator(
                regex=r"^\+?1?\d{9,15}$", message="Enter a valid mobile number"
            )
        ],
        blank=False,  # required for new rows
        null=False,
        help_text="Mobile number in international format, e.g. +911234567890",
    )

    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"{self.label}: {self.line1}"
