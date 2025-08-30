import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'models.dart';
import 'mock_api.dart';

class AuthProvider extends ChangeNotifier {
  String? _token;
  String? _name;
  List<Address> _addresses = [
    const Address(
      id: 'addr1',
      label: 'Home',
      line1: '221B Baker Street',
      city: 'Delhi',
      pin: '110001',
      lat: 28.6139,
      lng: 77.2090,
    ),
  ];

  bool get isLoggedIn => _token != null;
  String get name => _name ?? 'Guest';
  List<Address> get addresses => List.unmodifiable(_addresses);

  Future<void> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    _name = prefs.getString('name');
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final prefs = await SharedPreferences.getInstance();
    _token = 'demo_token';
    _name = email.split('@').first;
    await prefs.setString('token', _token!);
    await prefs.setString('name', _name!);
    notifyListeners();
  }

  Future<void> register(String name, String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 800));
    final prefs = await SharedPreferences.getInstance();
    _token = 'demo_token';
    _name = name;
    await prefs.setString('token', _token!);
    await prefs.setString('name', _name!);
    notifyListeners();
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('name');
    _token = null;
    _name = null;
    notifyListeners();
  }

  void addAddress(Address a) {
    _addresses.add(a);
    notifyListeners();
  }

  void removeAddress(String id) {
    _addresses.removeWhere((e) => e.id == id);
    notifyListeners();
  }
}

class CartProvider extends ChangeNotifier {
  final Map<String, CartItem> _items = {}; // key: productId

  Map<String, CartItem> get items => Map.unmodifiable(_items);

  int get count => _items.values.fold(0, (p, e) => p + e.qty);

  double get subtotal =>
      _items.values.fold(0.0, (sum, item) => sum + item.total);

  double get deliveryFee => subtotal == 0 ? 0 : 25.0;

  double get total => subtotal + deliveryFee;

  void add(Product p, {int qty = 1}) {
    if (_items.containsKey(p.id)) {
      _items[p.id]!.qty += qty;
    } else {
      _items[p.id] = CartItem(product: p, qty: qty);
    }
    notifyListeners();
  }

  void remove(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void decrement(String productId) {
    if (!_items.containsKey(productId)) return;
    final item = _items[productId]!;
    if (item.qty > 1) {
      item.qty--;
    } else {
      _items.remove(productId);
    }
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}

class OrderProvider extends ChangeNotifier {
  final List<Order> _orders = [];
  final Map<String, Timer> _timers = {};

  List<Order> get orders => List.unmodifiable(_orders);

  Order? getById(String id) =>
      _orders.firstWhere((o) => o.id == id, orElse: () => null as Order);

  Future<Order> placeOrder({
    required Address address,
    required String paymentMethod,
    required CartProvider cart,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final order = Order(
      id: id,
      items: cart.items.values.map((e) => CartItem(product: e.product, qty: e.qty)).toList(),
      total: cart.total,
      status: OrderStatus.placed,
      createdAt: DateTime.now(),
      address: address,
      driverLatLng: LatLng(address.lat + 0.02, address.lng - 0.02),
    );
    _orders.insert(0, order);
    cart.clear();
    _simulateProgress(order);
    notifyListeners();
    return order;
  }

  void _simulateProgress(Order order) {
    // Simulate status updates + driver movement every few seconds
    const steps = [
      OrderStatus.confirmed,
      OrderStatus.preparing,
      OrderStatus.outForDelivery,
      OrderStatus.delivered,
    ];
    int index = 0;
    _timers[order.id]?.cancel();
    _timers[order.id] = Timer.periodic(const Duration(seconds: 4), (t) {
      if (index < steps.length) {
        order.status = steps[index];
        index++;
        // Move driver towards destination while out for delivery
        if (order.status == OrderStatus.outForDelivery && order.driverLatLng != null) {
          final d = order.driverLatLng!;
          final target = LatLng(order.address.lat, order.address.lng);
          final newLat = d.latitude + (target.latitude - d.latitude) * 0.4;
          final newLng = d.longitude + (target.longitude - d.longitude) * 0.4;
          order.driverLatLng = LatLng(newLat, newLng);
        }
        if (order.status == OrderStatus.delivered) {
          t.cancel();
        }
        notifyListeners();
      } else {
        t.cancel();
      }
    });
  }

  @override
  void dispose() {
    for (final t in _timers.values) {
      t.cancel();
    }
    super.dispose();
  }
}

// Convenience: expose products stream-like (no real backend yet)
class ProductRepository extends ChangeNotifier {
  List<Product> _products = MockApi.products;

  List<Product> get products => _products;

  Future<void> refresh() async {
    _products = await MockApi.fetchProducts();
    notifyListeners();
  }

  Future<List<Product>> search(String q) => MockApi.search(q);
}