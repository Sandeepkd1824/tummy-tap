import 'package:flutter/material.dart';

class ProductGrid extends StatefulWidget {
  final List<dynamic> products;
  final Function(int, int) onQuantityChanged; // itemId, newQty
  final Map<int, int> cartItems; // itemId -> qty

  const ProductGrid({
    super.key,
    required this.products,
    required this.onQuantityChanged,
    required this.cartItems,
  });

  @override
  State<ProductGrid> createState() => _ProductGridState();
}

class _ProductGridState extends State<ProductGrid> {
  final Set<int> _favorites = {}; // ✅ track liked items

  void _updateQuantity(int itemId, int newQty) {
    widget.onQuantityChanged(itemId, newQty);
  }

  void _toggleFavorite(int itemId) {
    setState(() {
      if (_favorites.contains(itemId)) {
        _favorites.remove(itemId);
      } else {
        _favorites.add(itemId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GridView.builder(
      padding: const EdgeInsets.all(10),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.products.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount:
            MediaQuery.of(context).size.width > 600 ? 3 : 2, // ✅ responsive
        childAspectRatio: 0.72,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemBuilder: (context, index) {
        final item = widget.products[index];
        final qty = widget.cartItems[item["id"]] ?? 0;
        final isFavorite = _favorites.contains(item["id"]);

        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ✅ Image with Favorite button
              Expanded(
                child: ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(12)),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: FadeInImage.assetNetwork(
                          placeholder: "assets/placeholder.png",
                          image: item["image"] ?? "",
                          fit: BoxFit.cover,
                          imageErrorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.fastfood, size: 50),
                        ),
                      ),
                      Positioned(
                        top: 6,
                        right: 6,
                        child: InkWell(
                          onTap: () => _toggleFavorite(item["id"]),
                          borderRadius: BorderRadius.circular(20),
                          child: CircleAvatar(
                            radius: 16,
                            backgroundColor: Colors.white.withOpacity(0.8),
                            child: Icon(
                              isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: isFavorite
                                  ? Colors.red
                                  : Colors.grey.shade600,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ✅ Item name
              Padding(
                padding: const EdgeInsets.all(6.0),
                child: Text(
                  item["name"] ?? "",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // ✅ Price
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Text(
                  "₹${item["price"]}",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ),
              const SizedBox(height: 5),

              // ✅ Add / Quantity controls
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: qty == 0
                    ? SizedBox(
                        width: double.infinity, // ✅ make button full width
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            minimumSize:
                                const Size.fromHeight(40), // ✅ taller button
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            _updateQuantity(item["id"], 1);
                          },
                          child: const Text(
                            "ADD",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      )
                    : Container(
                        width: double.infinity, // ✅ align with ADD button
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          border: Border.all(color: theme.colorScheme.primary),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: Icon(Icons.remove,
                                  color: theme.colorScheme.primary),
                              onPressed: () {
                                _updateQuantity(item["id"], qty - 1);
                              },
                            ),
                            Text(
                              "$qty",
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.add,
                                  color: theme.colorScheme.primary),
                              onPressed: () {
                                _updateQuantity(item["id"], qty + 1);
                              },
                            ),
                          ],
                        ),
                      ),
              ),
              const SizedBox(height: 6),
            ],
          ),
        );
      },
    );
  }
}
