from django.contrib import admin
from django.contrib.auth.admin import UserAdmin
from .models import CustomUser, EmailOTP


class CustomUserAdmin(UserAdmin):
    list_display = ("username", "email", "is_staff", "is_active", "is_verified", "date_joined")
    list_filter = ("is_staff", "is_active", "is_verified")
    fieldsets = (
        (None, {"fields": ("username","email", "password")}),
        (
            "Permissions",
            {
                "fields": (
                    "is_staff",
                    "is_active",
                    "is_verified",
                    "is_superuser",
                    "groups",
                    "user_permissions",
                )
            },
        ),
        (
            "Important dates",
            {"fields": ("last_login",)},
        ),  # Removed date_joined from here
    )
    add_fieldsets = (
        (
            None,
            {
                "classes": ("wide",),
                "fields": ("email", "password1", "password2", "is_staff", "is_active"),
            },
        ),
    )
    search_fields = ("email","username")
    ordering = ("email",)
    filter_horizontal = (
        "groups",
        "user_permissions",
    )
    readonly_fields = (
        "date_joined",
        "last_login",
    )  # Add date_joined to readonly_fields



# Register your models here
admin.site.register(CustomUser, CustomUserAdmin)
