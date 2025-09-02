import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../services/api_service.dart';

class OrderDetailTrackingScreen extends StatefulWidget {
  final int orderId;
  const OrderDetailTrackingScreen({super.key, required this.orderId});

  @override
  State<OrderDetailTrackingScreen> createState() => _OrderDetailTrackingScreenState();
}

class _OrderDetailTrackingScreenState extends State<OrderDetailTrackingScreen> {
  bool isLoading = true;
  Map<String, dynamic>? order;

  @override
  void initState() {
    super.initState();
    _fetchOrder();
  }

  Future<void> _fetchOrder() async {
    setState(() => isLoading = true);
    try {
      final response = await ApiService.fetchOrder(widget.orderId); // GET /api/orders/:id
      setState(() => order = response);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error fetching order: $e")));
    } finally {
      setState(() => isLoading = false);
    }
  }

  String _labelStatus(String status) {
    switch (status) {
      case "pending":
        return "Placed";
      case "confirmed":
        return "Confirmed";
      case "preparing":
        return "Preparing";
      case "out_for_delivery":
        return "On the way";
      case "delivered":
        return "Delivered";
      case "cancelled":
        return "Cancelled";
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading || order == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final driverLatLng = (order!["driver_lat"] != null && order!["driver_lng"] != null)
        ? LatLng(double.parse(order!["driver_lat"]), double.parse(order!["driver_lng"]))
        : null;

    final addressLatLng = LatLng(double.parse(order!["latitude"]), double.parse(order!["longitude"]));

    final markers = <Marker>{};
    if (driverLatLng != null) {
      markers.add(Marker(markerId: const MarkerId('driver'), position: driverLatLng, infoWindow: const InfoWindow(title: "Driver")));
    }
    markers.add(Marker(markerId: const MarkerId('dest'), position: addressLatLng, infoWindow: const InfoWindow(title: "Delivery Address")));

    return Scaffold(
      appBar: AppBar(title: Text('Order #${order!["id"]}')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SizedBox(
            height: 220,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: driverLatLng ?? addressLatLng,
                  zoom: 13,
                ),
                markers: markers,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.flag, size: 20),
              const SizedBox(width: 8),
              Text('Status: ${_labelStatus(order!["status"])}'),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(),
          const Text('Items', style: TextStyle(fontWeight: FontWeight.bold)),
          ...((order!["items"] as List<dynamic>).map((it) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(it["item_name"]),
                trailing: Text('x${it["quantity"]}'),
                subtitle: Text('₹${it["unit_price"]} each'),
              ))),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('₹${order!["total"]}', style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}
