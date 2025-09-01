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
  Map<int, int> cart = {}; // itemId -> quantity
  bool _isCartLoading = true;
  bool _isMenuLoading = true;

  @override
  void initState() {
    super.initState();
    _refreshMenu();
    _loadCart();
  }

  /// Refresh menu items from API
  Future<void> _refreshMenu() async {
    setState(() {
      _isMenuLoading = true;
    });
    try {
      menuItems = ApiService.fetchMenuItems();
    } catch (e) {
      debugPrint("Error fetching menu: $e");
    } finally {
      setState(() {
        _isMenuLoading = false;
      });
    }
  }

  /// Load cart data from API
  Future<void> _loadCart() async {
    try {
      final cartData = await ApiService.getCartItems();
      final Map<int, int> updatedCart = {};

      if (cartData != null && cartData["restaurants"] != null) {
        for (var restaurant in cartData["restaurants"]) {
          for (var item in restaurant["items"]) {
            updatedCart[item["item"]] = item["quantity"];
          }
        }
      }

      setState(() {
        cart = updatedCart;
        _isCartLoading = false;
      });
    } catch (e) {
      debugPrint("Error fetching cart: $e");
      setState(() => _isCartLoading = false);
    }
  }

  /// Update cart quantity via API
  void _updateCart(int itemId, int newQty) async {
    final currentQty = cart[itemId] ?? 0;

    // Update UI immediately
    setState(() {
      if (newQty == 0) {
        cart.remove(itemId);
      } else {
        cart[itemId] = newQty;
      }
    });

    try {
      if (newQty == 0) {
        await ApiService.removeFromCart(itemId);
      } else if (newQty > currentQty) {
        final quantityToAdd = newQty - currentQty;
        await ApiService.addToCart(itemId, quantityToAdd);
      } else if (newQty < currentQty) {
        // Remove old quantity & add new if needed
        await ApiService.removeFromCart(itemId);
        if (newQty > 0) {
          await ApiService.addToCart(itemId, newQty);
        }
      }
    } catch (e) {
      debugPrint("Error updating cart: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to update cart. Try again!")),
      );

      // Rollback UI if API fails
      setState(() {
        if (currentQty == 0) {
          cart.remove(itemId);
        } else {
          cart[itemId] = currentQty;
        }
      });
    }
  }

  /// Logout user and redirect to login
  Future<void> _logout(BuildContext context) async {
    await TokenStorage.clearTokens();
    Navigator.pushReplacementNamed(context, LoginScreen.route);
  }

  /// Calculate total items in cart
  int get totalItems =>
      cart.values.fold(0, (previous, current) => previous + current);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: RefreshIndicator(
        onRefresh: () async {
          await _refreshMenu();
          await _loadCart();
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Top AppBar
            SliverAppBar(
              floating: true,
              pinned: true,
              snap: false,
              elevation: 2,
              backgroundColor: Colors.deepOrange,
              title: const Text(
                "🍔 TummyTap",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout, color: Colors.white),
                  onPressed: () => _logout(context),
                  tooltip: "Logout",
                ),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(70),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Material(
                    elevation: 2,
                    borderRadius: BorderRadius.circular(12),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Search food...",
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      onChanged: (val) {
                        setState(() => searchQuery = val.toLowerCase());
                      },
                    ),
                  ),
                ),
              ),
            ),

            // Menu Items Section
            SliverFillRemaining(
              child: _isCartLoading
                  ? const Center(child: CircularProgressIndicator())
                  : FutureBuilder<List<dynamic>>(
                      future: menuItems,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.error_outline,
                                    color: Colors.red, size: 40),
                                const SizedBox(height: 10),
                                Text(
                                  "Error loading menu\n${snapshot.error}",
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: Colors.red),
                                ),
                                const SizedBox(height: 15),
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.refresh),
                                  label: const Text("Retry"),
                                  onPressed: _refreshMenu,
                                )
                              ],
                            ),
                          );
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return const Center(
                            child: Text(
                              "No menu items found 😢",
                              style: TextStyle(fontSize: 18),
                            ),
                          );
                        } else {
                          final items = snapshot.data!
                              .where((item) => item["name"]
                                  .toString()
                                  .toLowerCase()
                                  .contains(searchQuery))
                              .toList();

                          return items.isEmpty
                              ? const Center(
                                  child: Text(
                                    "No matching results found",
                                    style: TextStyle(fontSize: 16),
                                  ),
                                )
                              : Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ProductGrid(
                                    products: items,
                                    cartItems: cart,
                                    onQuantityChanged: _updateCart,
                                  ),
                                );
                        }
                      },
                    ),
            ),
          ],
        ),
      ),

      // Floating Cart Button
      floatingActionButton: cart.isNotEmpty
          ? FloatingActionButton.extended(
              backgroundColor: Colors.deepOrange,
              icon: const Icon(Icons.shopping_cart),
              label: Text("View Cart ($totalItems)"),
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const CartScreen()),
                );
                _loadCart();
              },
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
