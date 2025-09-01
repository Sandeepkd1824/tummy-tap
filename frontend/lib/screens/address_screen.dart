import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'confirm_address_screen.dart';

class AddressScreen extends StatefulWidget {
  const AddressScreen({super.key});

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  List<dynamic> addresses = [];
  int? selectedAddressId;
  bool isLoading = true;

  final TextEditingController _line1Controller = TextEditingController();
  final TextEditingController _line2Controller = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchAddresses();
  }

  Future<void> _fetchAddresses() async {
    try {
      final data = await ApiService.fetchAddresses();
      setState(() {
        addresses = data;
        if (addresses.isNotEmpty) {
          selectedAddressId = addresses.first["id"];
        }
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching addresses: $e")),
      );
    }
  }

  void _addAddressDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text("Add New Address"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: _line1Controller,
                  decoration: const InputDecoration(labelText: "Address Line 1"),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _line2Controller,
                  decoration: const InputDecoration(labelText: "Address Line 2"),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _cityController,
                  decoration: const InputDecoration(labelText: "City"),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _postalCodeController,
                  decoration: const InputDecoration(labelText: "Postal Code"),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_line1Controller.text.isEmpty ||
                    _cityController.text.isEmpty ||
                    _postalCodeController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please fill required fields")),
                  );
                  return;
                }

                try {
                  await ApiService.addAddress({
                    "line1": _line1Controller.text.trim(),
                    "line2": _line2Controller.text.trim(),
                    "city": _cityController.text.trim(),
                    "postal_code": _postalCodeController.text.trim(),
                  });

                  Navigator.pop(ctx);
                  _line1Controller.clear();
                  _line2Controller.clear();
                  _cityController.clear();
                  _postalCodeController.clear();

                  _fetchAddresses();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error adding address: $e")),
                  );
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : addresses.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("No addresses found"),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _addAddressDialog,
                        child: const Text("Add Address"),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: addresses.length,
                        itemBuilder: (context, index) {
                          final addr = addresses[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: RadioListTile<int>(
                              value: addr["id"],
                              groupValue: selectedAddressId,
                              onChanged: (val) {
                                setState(() {
                                  selectedAddressId = val;
                                });
                              },
                              title: Text(
                                "${addr["line1"]}, ${addr["city"]} - ${addr["postal_code"]}",
                              ),
                              subtitle: addr["line2"] != null
                                  ? Text(addr["line2"])
                                  : null,
                            ),
                          );
                        },
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _addAddressDialog,
                              icon: const Icon(Icons.add),
                              label: const Text("Add New Address"),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: selectedAddressId == null
                                  ? null
                                  : () {
                                      final selectedAddress = addresses.firstWhere(
                                        (a) => a["id"] == selectedAddressId,
                                      );
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => ConfirmAddressScreen(
                                            address:
                                                "${selectedAddress["line1"]}, ${selectedAddress["city"]} - ${selectedAddress["postal_code"]}",
                                            addressId: selectedAddress["id"],
                                          ),
                                        ),
                                      );
                                    },
                              child: const Text("CONFIRM ADDRESS"),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
}
