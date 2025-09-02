import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'payment_screen.dart'; // you should create this for handling payments

class AddressScreen extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;

  const AddressScreen({super.key, required this.cartItems});

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  late Future<List<dynamic>> addressesFuture;
  int? selectedAddressId;

  @override
  void initState() {
    super.initState();
    addressesFuture = ApiService.fetchAddresses();
  }

  void _refreshAddresses() {
    setState(() {
      addressesFuture = ApiService.fetchAddresses();
    });
  }

  Future<void> _setDefaultAddress(int addressId) async {
    try {
      // Optionally call an API to set default address
      // For now we just set it locally
      setState(() {
        selectedAddressId = addressId;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error setting default: $e")),
      );
    }
  }

  void _proceedToPayment() {
    if (selectedAddressId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select an address")),
      );
      return;
    }

    // Navigate to PaymentScreen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentScreen(
          cartItems: widget.cartItems,
          addressId: selectedAddressId!,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Address"),
        centerTitle: true,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: addressesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text("Error: ${snapshot.error}", style: TextStyle(color: colors.error)),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text("No addresses found", style: TextStyle(color: colors.onBackground)),
            );
          }

          final addresses = snapshot.data!;

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: addresses.length,
                  itemBuilder: (context, index) {
                    final address = addresses[index];
                    final addressId = address["id"];
                    final isSelected = selectedAddressId == addressId;

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                      child: ListTile(
                        title: Text(address["label"] ?? "Address"),
                        subtitle: Text(
                          "${address["line1"]} ${address["line2"]}\n${address["city"]} - ${address["postal_code"]}\n${address["mobile"]}",
                        ),
                        isThreeLine: true,
                        trailing: isSelected
                            ? Icon(Icons.check_circle, color: colors.primary)
                            : null,
                        onTap: () => _setDefaultAddress(addressId),
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: _proceedToPayment,
                  child: const Text("Proceed to Payment", style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
