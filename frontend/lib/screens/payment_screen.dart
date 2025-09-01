import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'success_screen.dart';

class PaymentScreen extends StatefulWidget {
  final int addressId;

  const PaymentScreen({super.key, required this.addressId});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String? _selectedMethod;
  bool _isLoading = false;

  Future<void> _placeOrder() async {
    if (_selectedMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a payment method")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse("http://127.0.0.1:8000/api/orders/place/"), // 🔗 Replace with your server
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer YOUR_AUTH_TOKEN", // ✅ replace with real token
        },
        body: json.encode({
          "address_id": widget.addressId,
          "payment_method": _selectedMethod,
        }),
      );

      if (response.statusCode == 201) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => SuccessScreen(paymentMethod: _selectedMethod!),
          ),
        );
      } else {
        final error = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Order failed: ${error['error'] ?? 'Unknown error'}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Something went wrong: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Payment")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            RadioListTile<String>(
              value: "card",
              groupValue: _selectedMethod,
              title: const Text("Credit/Debit Card"),
              secondary: const Icon(Icons.credit_card),
              onChanged: (value) => setState(() => _selectedMethod = value),
            ),
            RadioListTile<String>(
              value: "gpay",
              groupValue: _selectedMethod,
              title: const Text("Google Pay (UPI)"),
              secondary: const Icon(Icons.account_balance_wallet),
              onChanged: (value) => setState(() => _selectedMethod = value),
            ),
            RadioListTile<String>(
              value: "cod",
              groupValue: _selectedMethod,
              title: const Text("Cash on Delivery"),
              secondary: const Icon(Icons.money),
              onChanged: (value) => setState(() => _selectedMethod = value),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _placeOrder,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("CONFIRM PAYMENT"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
