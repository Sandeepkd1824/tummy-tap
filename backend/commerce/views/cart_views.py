from rest_framework import generics, permissions, status
from rest_framework.views import APIView
from rest_framework.response import Response
from ..models import Cart, CartItem
from ..serializers import CartSerializer, AddToCartSerializer
from django.shortcuts import get_object_or_404


def get_user_cart(user):
    """Get or create the current user's cart."""
    cart, _ = Cart.objects.get_or_create(user=user)
    return cart


# 🛒 GET /cart/
class CartListView(generics.RetrieveAPIView):
    permission_classes = [permissions.IsAuthenticated]
    serializer_class = CartSerializer

    def get_object(self):
        return get_user_cart(self.request.user)


# ➕ POST /cart/add/
class CartAddItemView(generics.GenericAPIView):
    permission_classes = [permissions.IsAuthenticated]
    serializer_class = AddToCartSerializer

    def post(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        item = serializer.validated_data["item"]
        quantity = serializer.validated_data["quantity"]
        cart = get_user_cart(request.user)

        # ✅ Check if cart has items from another restaurant
        if cart.items.exists():
            existing_restaurant = cart.items.first().item.restaurant
            if existing_restaurant != item.restaurant:
                # Clear the cart if item is from a different restaurant
                cart.items.all().delete()

        cart_item, created = CartItem.objects.get_or_create(
            cart=cart,
            item=item,
            defaults={"unit_price": item.price, "quantity": quantity},
        )
        if not created:
            cart_item.quantity += quantity
            cart_item.save()

        return Response(CartSerializer(cart).data, status=status.HTTP_200_OK)


# ➖ POST /cart/remove/
class CartRemoveItemView(generics.GenericAPIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, *args, **kwargs):
        item_id = request.data.get("item_id")
        cart = get_user_cart(request.user)

        try:
            cart_item = CartItem.objects.get(cart=cart, item_id=item_id)
        except CartItem.DoesNotExist:
            return Response(
                {"error": "Item not found"}, status=status.HTTP_404_NOT_FOUND
            )

        if cart_item.quantity > 1:
            cart_item.quantity -= 1
            cart_item.save()
        else:
            cart_item.delete()

        return Response(CartSerializer(cart).data, status=status.HTTP_200_OK)


# 🗑️ DELETE /cart/delete/<item_id>/
class CartDeleteItemView(APIView):
    """
    Delete a specific item from the cart.
    URL: /api/cart/delete_item/<int:item_id>/
    """

    def delete(self, request, item_id):
        try:
            # Get user's active cart
            cart = get_object_or_404(Cart, user=request.user)

            # Get the item inside this cart
            cart_item = get_object_or_404(CartItem, id=item_id, cart=cart)

            # Delete the item
            cart_item.delete()

            # Recalculate subtotal after deletion
            subtotal = sum(
                float(item.unit_price) * item.quantity for item in cart.items.all()
            )

            return Response(
                {"message": "Item removed successfully", "subtotal": subtotal},
                status=status.HTTP_200_OK,
            )
        except Exception as e:
            return Response(
                {"error": str(e)},
                status=status.HTTP_400_BAD_REQUEST,
            )


# 🧹 POST /cart/clear/
class CartClearView(generics.GenericAPIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, *args, **kwargs):
        cart = get_user_cart(request.user)
        cart.items.all().delete()
        return Response(CartSerializer(cart).data, status=status.HTTP_200_OK)
