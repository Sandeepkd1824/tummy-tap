import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers.dart';
import '../models.dart';
import 'order_tracking_screen.dart';

class CheckoutScreen extends StatefulWidget {
  static const route = '/checkout';
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  Address? selected;
  String payment = 'COD';
  bool placing = false;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final cart = context.watch<CartProvider>();

    selected ??= auth.addresses.first;

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Delivery Address', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<Address>(
              value: selected,
              items: auth.addresses.map((a) => DropdownMenuItem(value: a, child: Text('${a.label} • ${a.line1}'))).toList(),
              onChanged: (v) => setState(() => selected = v),
            ),
            const SizedBox(height: 20),
            const Text('Payment', style: TextStyle(fontWeight: FontWeight.bold)),
            RadioListTile(
              title: const Text('Cash on Delivery'),
              value: 'COD',
              groupValue: payment,
              onChanged: (v) => setState(() => payment = v as String),
            ),
            RadioListTile(
              title: const Text('Card / UPI (mock)'),
              value: 'CARD',
              groupValue: payment,
              onChanged: (v) => setState(() => payment = v as String),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('₹${cart.total.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: placing ? null : () async {
                  setState(() => placing = true);
                  final order = await context.read<OrderProvider>().placeOrder(
                        address: selected!,
                        paymentMethod: payment,
                        cart: context.read<CartProvider>(),
                      );
                  if (!mounted) return;
                  setState(() => placing = false);
                  Navigator.pushReplacementNamed(context, OrderTrackingScreen.route, arguments: order.id);
                },
                icon: const Icon(Icons.lock),
                label: Text(placing ? 'Placing order...' : 'Place order'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}