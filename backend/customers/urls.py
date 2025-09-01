from django.urls import path
from .views import AddressListCreateView, AddressDetailView, SetDefaultAddressView

urlpatterns = [
    path("addresses/", AddressListCreateView.as_view(), name="address-list-create"),
    path("addresses/<int:pk>/", AddressDetailView.as_view(), name="address-detail"),
    path("addresses/<int:pk>/set-default/", SetDefaultAddressView.as_view(), name="set-default-address"),
]
