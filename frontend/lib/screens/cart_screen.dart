import 'package:flutter/material.dart';
import '../services/api_service.dart';

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
        const SnackBar(
          content: Text("Item removed from cart"),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _incrementItem(int itemId, int currentQty) async {
    try {
      await ApiService.addToCart(itemId, currentQty + 1);
      _refreshCart();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _decrementItem(int itemId, int currentQty, int cartItemId) async {
    try {
      if (currentQty > 1) {
        await ApiService.addToCart(itemId, currentQty - 1);
      } else {
        await ApiService.deleteCartItem(cartItemId);
      }
      _refreshCart();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Cart"),
        centerTitle: true,
        elevation: 2,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: cartData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error: ${snapshot.error}",
                style: const TextStyle(color: Colors.red),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!["restaurants"] == null || (snapshot.data!["restaurants"] as List).isEmpty) {
            return const Center(
              child: Text(
                "Your cart is empty",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          final cart = snapshot.data!;
          final restaurants = cart["restaurants"] as List<dynamic>;
          final subtotal = cart["subtotal"] ?? 0;

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: restaurants.length,
                  itemBuilder: (context, index) {
                    final restaurant = restaurants[index];
                    final restaurantName = restaurant["restaurant_name"];
                    final restaurantTotal = restaurant["restaurant_total"];
                    final items = restaurant["items"] as List<dynamic>;

                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Restaurant Header
                            Text(
                              restaurantName,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Divider(),
                            // Items of the restaurant
                            ...items.map((item) {
                              final cartItemId = item["id"];
                              final itemId = item["item"];
                              final itemName = item["item_name"];
                              final qty = item["quantity"];
                              final price = double.tryParse(item["unit_price"].toString()) ?? 0;
                              final lineTotal = (price * qty).toStringAsFixed(2);

                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 6),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        itemName,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.remove_circle, color: Colors.red),
                                      onPressed: () => _decrementItem(itemId, qty, cartItemId),
                                    ),
                                    Text(
                                      "$qty",
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.add_circle, color: Colors.green),
                                      onPressed: () => _incrementItem(itemId, qty),
                                    ),
                                    Text(
                                      "₹$lineTotal",
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blueGrey,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => _deleteItem(cartItemId),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                            const Divider(),
                            // Restaurant total
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                "Restaurant Total: ₹${restaurantTotal.toStringAsFixed(2)}",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Grand Total
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      offset: const Offset(0, -2),
                      blurRadius: 5,
                    )
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Grand Total",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "₹${subtotal.toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
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
