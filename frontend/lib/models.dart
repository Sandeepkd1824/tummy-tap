import 'package:google_maps_flutter/google_maps_flutter.dart';

class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String category;

  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
  });
}

class CartItem {
  final Product product;
  int qty;
  CartItem({required this.product, this.qty = 1});
  double get total => product.price * qty;
}

enum OrderStatus {
  placed,
  confirmed,
  preparing,
  outForDelivery,
  delivered,
  cancelled
}

class Address {
  final String id;
  final String label; // Home, Work
  final String line1;
  final String city;
  final String pin;
  final double lat;
  final double lng;

  const Address({
    required this.id,
    required this.label,
    required this.line1,
    required this.city,
    required this.pin,
    required this.lat,
    required this.lng,
  });
}

class Order {
  final String id;
  final List<CartItem> items;
  final double total;
  OrderStatus status;
  final DateTime createdAt;
  final Address address;
  LatLng? driverLatLng; // live location (mock)

  Order({
    required this.id,
    required this.items,
    required this.total,
    required this.status,
    required this.createdAt,
    required this.address,
    this.driverLatLng,
  });
}