from rest_framework import generics, permissions, status
from rest_framework.response import Response

from ..models import Cart
from ..serializers import CartSerializer
from customers.models import Address
from customers.serializers import AddressSerializer


class CheckoutView(generics.GenericAPIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request, *args, **kwargs):
        # Get user cart
        cart, _ = Cart.objects.get_or_create(user=request.user)
        cart_data = CartSerializer(cart).data

        # Get default address if available
        address = Address.objects.filter(user=request.user, is_default=True).first()
        address_data = AddressSerializer(address).data if address else None

        return Response(
            {
                "cart": cart_data,
                "default_address": address_data,
                "subtotal": cart.subtotal(),
            },
            status=status.HTTP_200_OK,
        )
