import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'order_detail_tracking_screen.dart';

class OrderTrackingScreen extends StatefulWidget {
  const OrderTrackingScreen({super.key});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  bool isLoading = true;
  List<dynamic> orders = [];

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    setState(() => isLoading = true);
    try {
      final Map<String, dynamic> response = await ApiService.fetchOrders();
      if (response.containsKey("results")) {
        setState(() => orders = response["results"]);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error fetching orders: $e")));
    } finally {
      setState(() => isLoading = false);
    }
  }

  Widget _buildOrderCard(order) {
    final items = (order["items"] as List<dynamic>)
        .map((it) => "${it['item_name']} x${it['quantity']}")
        .join(", ");

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        title: Text("Order #${order['id']} - ${order['status']}"),
        subtitle: Text(items),
        trailing: Text("₹${order['total']}"),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OrderDetailTrackingScreen(orderId: order['id']),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Track Orders")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : orders.isEmpty
              ? const Center(child: Text("No orders yet"))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: orders.map((order) => _buildOrderCard(order)).toList(),
                ),
    );
  }
}
