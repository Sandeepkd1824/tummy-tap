# config/urls.py
from django.contrib import admin
from django.urls import path, include

urlpatterns = [
    path("admin/", admin.site.urls),
    path("api/restaurants/", include("restaurants.urls")),
    path("api/customers/", include("customers.urls")),
    path("api/", include("commerce.urls")),
    # include your accounts endpoints too:
    path("api/accounts/", include("accounts.urls")),  # keep your existing accounts urls
    # Simple JWT token endpoints (if you want direct token obtain)
    
]
