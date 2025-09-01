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
  void _updateQuantity(int itemId, int newQty) {
    widget.onQuantityChanged(itemId, newQty);
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(10),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.products.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // 2 cards in row
        childAspectRatio: 0.72,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemBuilder: (context, index) {
        final item = widget.products[index];
        final qty = widget.cartItems[item["id"]] ?? 0;

        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(12)),
                  child: Image.network(
                    item["image"] ?? "",
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.fastfood, size: 50),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(6.0),
                child: Text(item["name"] ?? "",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15)),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Text("₹${item["price"]}",
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.green)),
              ),
              const SizedBox(height: 5),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: qty == 0
                    ? ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepOrange,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () {
                          _updateQuantity(item["id"], 1);
                        },
                        child: const Text("ADD"),
                      )
                    : Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.deepOrange),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove,
                                  color: Colors.deepOrange),
                              onPressed: () {
                                _updateQuantity(item["id"], qty - 1);
                              },
                            ),
                            Text("$qty",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16)),
                            IconButton(
                              icon: const Icon(Icons.add,
                                  color: Colors.deepOrange),
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