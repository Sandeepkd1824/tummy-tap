import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models.dart';
import '../providers.dart';

class ProductDetailScreen extends StatelessWidget {
  static const route = '/product';
  final Product product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    int qty = 1;
    return Scaffold(
      appBar: AppBar(title: Text(product.name)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16/10,
              child: Image.network(product.imageUrl, fit: BoxFit.cover),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name, style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 6),
                  Text('₹${product.price.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Text(product.description),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Text('Qty:'),
                      const SizedBox(width: 10),
                      _QtyPicker(
                        onChanged: (v) => qty = v,
                      ),
                      const Spacer(),
                      ElevatedButton.icon(
                        onPressed: () {
                          context.read<CartProvider>().add(product, qty: qty);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Added to cart')),
                          );
                        },
                        icon: const Icon(Icons.add_shopping_cart),
                        label: const Text('Add to cart'),
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _QtyPicker extends StatefulWidget {
  final void Function(int) onChanged;
  const _QtyPicker({required this.onChanged});

  @override
  State<_QtyPicker> createState() => _QtyPickerState();
}

class _QtyPickerState extends State<_QtyPicker> {
  int qty = 1;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: qty > 1 ? () { setState(() { qty--; }); widget.onChanged(qty); } : null,
          icon: const Icon(Icons.remove_circle_outline),
        ),
        Text('$qty'),
        IconButton(
          onPressed: () { setState(() { qty++; }); widget.onChanged(qty); },
          icon: const Icon(Icons.add_circle_outline),
        ),
      ],
    );
  }
}