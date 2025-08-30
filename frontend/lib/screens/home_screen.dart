import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/token_storage.dart';
import 'login_screen.dart';
import 'cart_screen.dart';
import '../widgets/product_grid.dart';

class HomeScreen extends StatefulWidget {
  static const String route = "/home";

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<dynamic>> menuItems;
  String searchQuery = "";
  Map<int, int> cart = {}; // itemId -> qty

  @override
  void initState() {
    super.initState();
    menuItems = ApiService.fetchMenuItems();
  }

  Future<void> _logout(BuildContext context) async {
    await TokenStorage.clearTokens();
    Navigator.pushReplacementNamed(context, LoginScreen.route);
  }

  void _updateCart(int itemId, int qty) async {
    setState(() {
      if (qty == 0) {
        cart.remove(itemId);
      } else {
        cart[itemId] = qty;
      }
    });

    // Sync with backend
    if (qty > 0) {
      await ApiService.addToCart(itemId, qty);
    } else {
      await ApiService.removeFromCart(itemId);
    }
  }

  int get totalItems =>
      cart.values.fold(0, (previous, current) => previous + current);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("TummyTap Menu"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search food...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (val) {
                setState(() {
                  searchQuery = val.toLowerCase();
                });
              },
            ),
          ),
        ),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: menuItems,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No menu items found"));
          } else {
            final items = snapshot.data!
                .where((item) =>
                    item["name"].toString().toLowerCase().contains(searchQuery))
                .toList();

            return SingleChildScrollView(
              child: ProductGrid(
                products: items,
                cartItems: cart,
                onQuantityChanged: _updateCart,
              ),
            );
          }
        },
      ),
      floatingActionButton: cart.isNotEmpty
          ? FloatingActionButton.extended(
              backgroundColor: Colors.deepOrange,
              icon: const Icon(Icons.shopping_cart),
              label: Text("View Cart ($totalItems)"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CartScreen()),
                );
              },
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
