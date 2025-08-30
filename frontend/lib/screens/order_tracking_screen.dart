import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../providers.dart';
import '../models.dart';

class OrderTrackingScreen extends StatelessWidget {
  static const route = '/track';
  final String orderId;
  const OrderTrackingScreen({super.key, required this.orderId});

  String _label(OrderStatus s) {
    switch (s) {
      case OrderStatus.placed:
        return 'Placed';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.preparing:
        return 'Preparing';
      case OrderStatus.outForDelivery:
        return 'On the way';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OrderProvider>();
    final order = provider.orders.firstWhere((o) => o.id == orderId);

    final markers = <Marker>{};
    if (order.driverLatLng != null) {
      markers.add(Marker(markerId: const MarkerId('driver'), position: order.driverLatLng!));
      markers.add(Marker(
        markerId: const MarkerId('dest'),
        position: LatLng(order.address.lat, order.address.lng),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      ));
    }

    return Scaffold(
      appBar: AppBar(title: Text('Order #${order.id.substring(order.id.length - 5)}')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SizedBox(
            height: 220,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: order.driverLatLng ?? LatLng(order.address.lat, order.address.lng),
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
              Text('Status: ${_label(order.status)}'),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(),
          const Text('Items', style: TextStyle(fontWeight: FontWeight.bold)),
          ...order.items.map((it) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(it.product.name),
                trailing: Text('x${it.qty}'),
                subtitle: Text('₹${it.product.price.toStringAsFixed(0)} each'),
              )),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('₹${order.total.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}