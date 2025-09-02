import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'order_tracking_screen.dart';

class PaymentScreen extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;
  final int addressId;

  const PaymentScreen({super.key, required this.cartItems, required this.addressId});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool isLoading = false;
  String? selectedMethod;
  final List<String> paymentMethods = ["Cash", "UPI", "Card"];

  Future<void> _placeOrderAndPay() async {
    if (selectedMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a payment method")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final orderResponse = await ApiService.placeOrder(widget.addressId);
      if (orderResponse.containsKey("error")) throw Exception(orderResponse["error"]);

      final orderId = orderResponse["id"];
      final paymentResponse = await ApiService.makePayment(orderId, selectedMethod!);
      if (paymentResponse.containsKey("error")) throw Exception(paymentResponse["error"]);

      // Navigate to order tracking (all orders)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OrderTrackingScreen()),
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text("Payment"), centerTitle: true),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Select Payment Method", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  ...paymentMethods.map((method) {
                    final isSelected = selectedMethod == method;
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        title: Text(method),
                        trailing: isSelected ? Icon(Icons.check_circle, color: colors.primary) : null,
                        onTap: () => setState(() => selectedMethod = method),
                      ),
                    );
                  }).toList(),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _placeOrderAndPay,
                      child: const Text("Pay & Place Order", style: TextStyle(fontSize: 18)),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
