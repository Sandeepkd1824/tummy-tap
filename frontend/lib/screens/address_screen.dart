import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../services/api_service.dart';
import 'payment_screen.dart';

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

  // --- Get current location ---
  Future<Map<String, double>> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception("Location services are disabled.");
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception("Location permission denied.");
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception("Location permissions are permanently denied.");
    }

    final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    return {"latitude": pos.latitude, "longitude": pos.longitude};
  }

  // --- Dialog for adding/updating address ---
  Future<Map<String, dynamic>?> _showAddressDialog(
      {Map<String, dynamic>? existing}) async {
    final line1Controller =
        TextEditingController(text: existing != null ? existing["line1"] : "");
    final line2Controller =
        TextEditingController(text: existing != null ? existing["line2"] : "");
    final cityController =
        TextEditingController(text: existing != null ? existing["city"] : "");
    final postalController = TextEditingController(
        text: existing != null ? existing["postal_code"] : "");
    final mobileController =
        TextEditingController(text: existing != null ? existing["mobile"] : "");
    final labelController =
        TextEditingController(text: existing != null ? existing["label"] : "");

    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(existing == null ? "Add Address" : "Edit Address"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                    controller: labelController,
                    decoration: const InputDecoration(labelText: "Label")),
                TextField(
                    controller: line1Controller,
                    decoration: const InputDecoration(labelText: "Line 1")),
                TextField(
                    controller: line2Controller,
                    decoration: const InputDecoration(labelText: "Line 2")),
                TextField(
                    controller: cityController,
                    decoration: const InputDecoration(labelText: "City")),
                TextField(
                    controller: postalController,
                    decoration:
                        const InputDecoration(labelText: "Postal Code")),
                TextField(
                    controller: mobileController,
                    decoration: const InputDecoration(labelText: "Mobile")),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, null),
                child: const Text("Cancel")),
            ElevatedButton(
              onPressed: () async {
                try {
                  final coords = await _getCurrentLocation();
                  Navigator.pop(ctx, {
                    "label": labelController.text,
                    "line1": line1Controller.text,
                    "line2": line2Controller.text,
                    "city": cityController.text,
                    "postal_code": postalController.text,
                    "mobile": mobileController.text,
                    "latitude": coords["latitude"],
                    "longitude": coords["longitude"],
                  });
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Location error: $e")),
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
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Address"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final newAddress = await _showAddressDialog();
              if (newAddress != null) {
                await ApiService.addAddress(newAddress);
                _refreshAddresses();
              }
            },
          )
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: addressesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text("Error: ${snapshot.error}",
                  style: TextStyle(color: colors.error)),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text("No addresses found",
                  style: TextStyle(color: colors.onBackground)),
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
                      margin: const EdgeInsets.symmetric(
                          vertical: 6, horizontal: 12),
                      child: ListTile(
                        title: Text(address["label"] ?? "Address"),
                        subtitle: Text(
                          "${address["line1"]} ${address["line2"]}\n"
                          "${address["city"]} - ${address["postal_code"]}\n"
                          "${address["mobile"]}",
                        ),
                        isThreeLine: true,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon:
                                  const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () async {
                                final updated =
                                    await _showAddressDialog(existing: address);
                                if (updated != null) {
                                  await ApiService.updateAddress(
                                      addressId, updated);
                                  _refreshAddresses();
                                }
                              },
                            ),
                            IconButton(
                              icon:
                                  const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                final confirmed = await showDialog(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text("Delete Address"),
                                    content: const Text(
                                        "Are you sure you want to delete this address?"),
                                    actions: [
                                      TextButton(
                                          onPressed: () =>
                                              Navigator.pop(ctx, false),
                                          child: const Text("Cancel")),
                                      ElevatedButton(
                                          onPressed: () =>
                                              Navigator.pop(ctx, true),
                                          child: const Text("Delete")),
                                    ],
                                  ),
                                );

                                if (confirmed == true) {
                                  final success = await ApiService.deleteAddress(
                                      addressId);
                                  if (success) {
                                    _refreshAddresses();
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              "Failed to delete address")),
                                    );
                                  }
                                }
                              },
                            ),
                            if (isSelected)
                              Icon(Icons.check_circle, color: colors.primary),
                          ],
                        ),
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
                  child: const Text("Proceed to Payment",
                      style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
