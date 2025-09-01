import 'package:flutter/material.dart';
import 'success_screen.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String? _selectedMethod;

  void _confirmPayment() {
    if (_selectedMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a payment method")),
      );
      return;
    }

    // 🚀 Navigate to success screen after confirmation
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => SuccessScreen(paymentMethod: _selectedMethod!),
      ),
    );
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
              value: "Credit/Debit Card",
              groupValue: _selectedMethod,
              title: const Text("Credit/Debit Card"),
              secondary: const Icon(Icons.credit_card),
              onChanged: (value) => setState(() => _selectedMethod = value),
            ),
            RadioListTile<String>(
              value: "UPI (Google Pay)",
              groupValue: _selectedMethod,
              title: const Text("Google Pay (UPI)"),
              secondary: const Icon(Icons.account_balance_wallet),
              onChanged: (value) => setState(() => _selectedMethod = value),
            ),
            RadioListTile<String>(
              value: "Cash on Delivery",
              groupValue: _selectedMethod,
              title: const Text("Cash on Delivery"),
              secondary: const Icon(Icons.money),
              onChanged: (value) => setState(() => _selectedMethod = value),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _confirmPayment,
                child: const Text("CONFIRM PAYMENT"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
