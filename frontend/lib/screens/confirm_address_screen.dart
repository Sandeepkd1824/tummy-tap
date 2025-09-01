import 'package:flutter/material.dart';
import 'payment_screen.dart';

class ConfirmAddressScreen extends StatelessWidget {
  final String address;
  final int addressId;

  const ConfirmAddressScreen({
    super.key,
    required this.address,
    required this.addressId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Confirm Address")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Deliver to:",
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const Icon(Icons.location_on, color: Colors.red),
                title: Text(
                  address,
                  style: theme.textTheme.bodyLarge,
                ),
              ),
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("CHANGE ADDRESS"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PaymentScreen(
                            addressId: addressId,
                          ),
                        ),
                      );
                    },
                    child: const Text("PROCEED TO PAYMENT"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
