import 'package:flutter/material.dart';
import 'confirm_address_screen.dart';

class AddressScreen extends StatefulWidget {
  const AddressScreen({super.key});

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  String? savedAddress; // pretend from DB
  final TextEditingController _addressController = TextEditingController();

  void _addOrChangeAddress(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(savedAddress == null ? "Add Address" : "Change Address"),
          content: TextField(
            controller: _addressController,
            decoration: const InputDecoration(
              hintText: "Enter your delivery address",
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                if (_addressController.text.trim().isNotEmpty) {
                  setState(() {
                    savedAddress = _addressController.text.trim();
                  });
                  Navigator.pop(ctx);
                }
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Delivery Address")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            savedAddress == null
                ? const Text("No address found. Please add one.")
                : Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.home),
                      title: Text(savedAddress!),
                      trailing: TextButton(
                        onPressed: () => _addOrChangeAddress(context),
                        child: const Text("Change"),
                      ),
                    ),
                  ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (savedAddress == null) {
                    _addOrChangeAddress(context);
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ConfirmAddressScreen(
                          address: savedAddress!,
                        ),
                      ),
                    );
                  }
                },
                child: Text(savedAddress == null
                    ? "ADD ADDRESS"
                    : "CONFIRM ADDRESS"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
