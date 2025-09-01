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

  Future<void> _refreshMenu() async {
    setState(() => _isMenuLoading = true);
    try {
      menuItems = ApiService.fetchMenuItems();
    } catch (e) {
      debugPrint("Error fetching menu: $e");
    } finally {
      setState(() => _isMenuLoading = false);
    }
  }

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

  void _updateCart(int itemId, int newQty) async {
    final currentQty = cart[itemId] ?? 0;

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
      setState(() {
        if (currentQty == 0) {
          cart.remove(itemId);
        } else {
          cart[itemId] = currentQty;
        }
      });
    }
  }

  Future<void> _logout(BuildContext context) async {
    await TokenStorage.clearTokens();
    Navigator.pushReplacementNamed(context, LoginScreen.route);
  }

  int get totalItems =>
      cart.values.fold(0, (previous, current) => previous + current);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: RefreshIndicator(
        onRefresh: () async {
          await _refreshMenu();
          await _loadCart();
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverAppBar(
              floating: true,
              pinned: true,
              elevation: 2,
              backgroundColor: theme.colorScheme.primary,
              title: Text(
                "🍔 TummyTap",
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
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

            // ✅ Menu Section (Fixed scrolling)
            SliverToBoxAdapter(
              child: _isCartLoading
                  ? const Padding(
                      padding: EdgeInsets.all(50),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : FutureBuilder<List<dynamic>>(
                      future: menuItems,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Padding(
                            padding: EdgeInsets.all(50),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        } else if (snapshot.hasError) {
                          return Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                const Icon(Icons.error_outline,
                                    color: Colors.red, size: 40),
                                Text("Error: ${snapshot.error}"),
                                const SizedBox(height: 15),
                                ElevatedButton.icon(
                                  onPressed: _refreshMenu,
                                  icon: const Icon(Icons.refresh),
                                  label: const Text("Retry"),
                                ),
                              ],
                            ),
                          );
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.all(30),
                            child: Center(
                                child: Text("No menu items found 😢")),
                          );
                        } else {
                          final items = snapshot.data!
                              .where((item) => item["name"]
                                  .toString()
                                  .toLowerCase()
                                  .contains(searchQuery))
                              .toList();

                          return items.isEmpty
                              ? const Padding(
                                  padding: EdgeInsets.all(30),
                                  child: Center(
                                    child: Text(
                                        "No matching results found"),
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

      // ✅ Full-width bottom cart button
      bottomNavigationBar: cart.isNotEmpty
          ? Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.shopping_cart),
                  label: Text("View Cart ($totalItems)"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const CartScreen()),
                    );
                    _loadCart();
                  },
                ),
              ),
            )
          : null,
    );
  }
}
