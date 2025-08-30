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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Your Cart")),
      body: FutureBuilder<Map<String, dynamic>>(
        future: cartData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Your cart is empty"));
          } else {
            final cart = snapshot.data!;
            final restaurants = cart["restaurants"] as List<dynamic>? ?? [];
            final subtotal = cart["subtotal"] ?? 0;

            if (restaurants.isEmpty) {
              return const Center(child: Text("Your cart is empty"));
            }

            return ListView(
              padding: const EdgeInsets.all(12),
              children: [
                // Loop restaurants
                ...restaurants.map((rest) {
                  final restName = rest["restaurant_name"];
                  final items = rest["items"] as List<dynamic>;
                  final restTotal = rest["restaurant_total"];

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    child: ExpansionTile(
                      title: Text(restName,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      subtitle: Text("Restaurant Total: ₹$restTotal"),
                      children: items.map((item) {
                        final itemName = item["item_name"];
                        final qty = item["quantity"];
                        final price = double.tryParse(item["unit_price"].toString()) ?? 0;
                        final lineTotal = (price * qty).toStringAsFixed(2);

                        return ListTile(
                          title: Text(itemName),
                          subtitle: Text("Qty: $qty"),
                          trailing: Text("₹$lineTotal"),
                        );
                      }).toList(),
                    ),
                  );
                }).toList(),

                const Divider(),
                ListTile(
                  title: const Text("Grand Total",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  trailing: Text("₹$subtotal",
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green)),
                )
              ],
            );
          }
        },
      ),
    );
  }
}
