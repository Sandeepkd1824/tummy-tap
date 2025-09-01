import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../services/api_service.dart';
import 'confirm_address_screen.dart';

class AddressScreen extends StatefulWidget {
  const AddressScreen({super.key});

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  List<Map<String, dynamic>> addresses = [];
  int? selectedAddressId;
  bool isLoading = true;

  final TextEditingController _line1Controller = TextEditingController();
  final TextEditingController _line2Controller = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();

  String _label = "home";
  LatLng? _markerPosition;

  @override
  void initState() {
    super.initState();
    _fetchAddresses();
    _getCurrentLocation();
  }

  Future<void> _fetchAddresses() async {
    try {
      final response = await ApiService.fetchAddresses();
      final List<Map<String, dynamic>> fetchedAddresses =
          List<Map<String, dynamic>>.from(response);
      setState(() {
        addresses = fetchedAddresses;
        if (addresses.isNotEmpty) {
          selectedAddressId = addresses.first["id"] as int;
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

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    if (permission == LocationPermission.deniedForever) return;

    final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _markerPosition = LatLng(position.latitude, position.longitude);
    });

    await _reverseGeocode(position.latitude, position.longitude);
  }

  Future<void> _reverseGeocode(double lat, double lng) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        setState(() {
          _line1Controller.text = place.street ?? '';
          _cityController.text = place.locality ?? '';
          _postalCodeController.text = place.postalCode ?? '';
        });
      }
    } catch (e) {
      debugPrint("Reverse geocoding failed: $e");
    }
  }

  void _addAddressDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text("Add New Address"),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    value: _label,
                    items: const [
                      DropdownMenuItem(value: "home", child: Text("Home")),
                      DropdownMenuItem(value: "work", child: Text("Work")),
                      DropdownMenuItem(value: "other", child: Text("Other")),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _label = val);
                    },
                    decoration: const InputDecoration(labelText: "Label"),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _line1Controller,
                    decoration:
                        const InputDecoration(labelText: "Address Line 1"),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _line2Controller,
                    decoration:
                        const InputDecoration(labelText: "Address Line 2"),
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
                  const SizedBox(height: 8),
                  TextField(
                    controller: _mobileController,
                    decoration: const InputDecoration(labelText: "Mobile"),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 12),
                  _markerPosition != null
                      ? SizedBox(
                          height: 300,
                          child: FlutterMap(
                            options: MapOptions(
                              initialCenter: _markerPosition!,
                              initialZoom: 16,
                              onTap: (tapPos, latlng) async {
                                _markerPosition = latlng;
                                await _reverseGeocode(latlng.latitude, latlng.longitude);
                                setState(() {});
                              },
                            ),
                            children: [
                              TileLayer(
                                urlTemplate:
                                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                userAgentPackageName: 'com.example.app',
                              ),
                              MarkerLayer(
                                markers: [
                                  Marker(
                                    point: _markerPosition!,
                                    width: 50,
                                    height: 50,
                                    child: const Icon(
                                      Icons.location_on,
                                      color: Colors.red,
                                      size: 40,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )
                      : const CircularProgressIndicator(),
                  const SizedBox(height: 8),
                  const Text(
                      "Tap on map to move marker. Address fields auto-update."),
                ],
              ),
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
                    _postalCodeController.text.isEmpty ||
                    _mobileController.text.isEmpty ||
                    _markerPosition == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Please fill all required fields")),
                  );
                  return;
                }

                try {
                  await ApiService.addAddress({
                    "label": _label,
                    "line1": _line1Controller.text.trim(),
                    "line2": _line2Controller.text.trim(),
                    "city": _cityController.text.trim(),
                    "postal_code": _postalCodeController.text.trim(),
                    "mobile": _mobileController.text.trim(),
                    "latitude": _markerPosition!.latitude,
                    "longitude": _markerPosition!.longitude,
                  });

                  Navigator.pop(ctx);

                  _line1Controller.clear();
                  _line2Controller.clear();
                  _cityController.clear();
                  _postalCodeController.clear();
                  _mobileController.clear();
                  _label = "home";

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
                              value: addr["id"] as int,
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
                                          (a) => a["id"] == selectedAddressId);
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
