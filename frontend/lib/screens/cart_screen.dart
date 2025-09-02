import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'address_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late Future<Map<String, dynamic>> cartData;

  @override
  void initState() {
    super.initState();
    cartData = ApiService.getCartItems();
  }

  void _refreshCart() {
    setState(() {
      cartData = ApiService.getCartItems();
    });
  }

  Future<void> _deleteItem(int cartItemId) async {
    try {
      await ApiService.deleteCartItem(cartItemId);
      _refreshCart();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Item removed from cart"),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  Future<void> _incrementItem(int itemId) async {
    try {
      await ApiService.addToCart(itemId, 1);
      _refreshCart();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  Future<void> _decrementItem(int itemId, int currentQty, int cartItemId) async {
    try {
      if (currentQty > 1) {
        await ApiService.removeFromCart(itemId);
      } else {
        await ApiService.deleteCartItem(cartItemId);
      }
      _refreshCart();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Cart"),
        centerTitle: true,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: cartData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text("Error: ${snapshot.error}", style: TextStyle(color: colors.error)),
            );
          } else if (!snapshot.hasData || (snapshot.data!["restaurants"] as List).isEmpty) {
            return Center(
              child: Text("Your cart is empty", style: TextStyle(color: colors.onBackground)),
            );
          }

          final cart = snapshot.data!;
          final restaurants = cart["restaurants"] as List<dynamic>;
          final subtotal = cart["subtotal"] ?? 0;
          final cartItems = restaurants.expand((r) => r["items"] as List<dynamic>).toList();

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: restaurants.length,
                  itemBuilder: (context, index) {
                    final restaurant = restaurants[index];
                    final items = restaurant["items"] as List<dynamic>;

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              restaurant["restaurant_name"],
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colors.primary),
                            ),
                            const Divider(),
                            ...items.map((item) {
                              final cartItemId = item["id"];
                              final itemId = item["item"];
                              final qty = item["quantity"];
                              final price = double.tryParse(item["unit_price"].toString()) ?? 0;
                              final lineTotal = (price * qty).toStringAsFixed(2);

                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(child: Text(item["item_name"], style: const TextStyle(fontWeight: FontWeight.w500))),
                                    IconButton(
                                      icon: Icon(Icons.remove_circle, color: colors.error),
                                      onPressed: () => _decrementItem(itemId, qty, cartItemId),
                                    ),
                                    Text("$qty", style: const TextStyle(fontWeight: FontWeight.bold)),
                                    IconButton(
                                      icon: Icon(Icons.add_circle, color: colors.secondary),
                                      onPressed: () => _incrementItem(itemId),
                                    ),
                                    Text("₹$lineTotal", style: TextStyle(fontWeight: FontWeight.bold, color: colors.onBackground)),
                                    IconButton(
                                      icon: Icon(Icons.delete, color: colors.error),
                                      onPressed: () => _deleteItem(cartItemId),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                            const Divider(),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                "Restaurant Total: ₹${restaurant["restaurant_total"].toStringAsFixed(2)}",
                                style: TextStyle(fontWeight: FontWeight.bold, color: colors.secondary),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: colors.background, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), offset: const Offset(0, -2), blurRadius: 5)]),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Grand Total", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        Text("₹${subtotal.toStringAsFixed(2)}", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colors.secondary)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: cartItems.isEmpty
                          ? null
                          : () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AddressScreen(cartItems: cartItems.cast<Map<String, dynamic>>()),
                                ),
                              );
                            },
                      child: const Text("ORDER NOW", style: TextStyle(fontSize: 18)),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
