import 'dart:convert';
import 'package:http/http.dart' as http;
import 'token_storage.dart';

class ApiService {
  // ----------------- BASE URLS -----------------
  static const String accountsBase = "http://127.0.0.1:8000/api/accounts";
  static const String restaurantsBase = "http://127.0.0.1:8000/api/restaurants";
  static const String cartBase = "http://127.0.0.1:8000/api/cart";
  static const String customersBase = "http://127.0.0.1:8000/api/customers";
  static const String ordersBase = "http://127.0.0.1:8000/api/orders";

  // ----------------- AUTH -----------------

  static Future<Map<String, dynamic>> registerUser(
      String username, String email, String password) async {
    final response = await http.post(
      Uri.parse("$accountsBase/register/"),
      body: {
        "username": username,
        "email": email,
        "password": password,
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      return {"error": "Registration failed"};
    }
  }

  static Future<Map<String, dynamic>> verifyOtp(
      String email, String otp) async {
    final response = await http.post(
      Uri.parse("$accountsBase/verify-otp/"),
      body: {"email": email, "otp": otp},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return {"error": "OTP verification failed"};
    }
  }

  static Future<Map<String, dynamic>> loginUser(
      String username, String password) async {
    final response = await http.post(
      Uri.parse("$accountsBase/login/"),
      body: {"username": username, "password": password},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await TokenStorage.saveTokens(data["access"], data["refresh"]);
      return data;
    } else {
      return {"error": "Login failed"};
    }
  }

  static Future<bool> refreshToken() async {
    final refresh = await TokenStorage.getRefreshToken();
    if (refresh == null) return false;

    final response = await http.post(
      Uri.parse("$accountsBase/token/refresh/"),
      body: {"refresh": refresh},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await TokenStorage.saveTokens(data["access"], refresh);
      return true;
    } else {
      await TokenStorage.clearTokens();
      return false;
    }
  }

  // ----------------- MENU -----------------

  static Future<List<dynamic>> fetchMenuItems() async {
    String? token = await TokenStorage.getAccessToken();
    final url = Uri.parse("$restaurantsBase/menu-items/");

    http.Response response = await http.get(
      url,
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 401 && await refreshToken()) {
      token = await TokenStorage.getAccessToken();
      response = await http.get(url, headers: {"Authorization": "Bearer $token"});
    }

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["results"];
    } else {
      throw Exception("Failed to load menu items");
    }
  }

  static Future<List<dynamic>> fetchMenuItemsByRestaurant(
      int restaurantId) async {
    String? token = await TokenStorage.getAccessToken();
    final url = Uri.parse("$restaurantsBase/$restaurantId/menu-items/");

    http.Response response = await http.get(
      url,
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 401 && await refreshToken()) {
      token = await TokenStorage.getAccessToken();
      response = await http.get(url, headers: {"Authorization": "Bearer $token"});
    }

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["results"];
    } else {
      throw Exception("Failed to load menu items for restaurant $restaurantId");
    }
  }

  // ----------------- CART -----------------

  static Future<Map<String, dynamic>> addToCart(
      int itemId, int quantity) async {
    String? token = await TokenStorage.getAccessToken();
    final response = await http.post(
      Uri.parse("$cartBase/add_item/"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: json.encode({"item_id": itemId, "quantity": quantity}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      return {"error": "Failed to add to cart"};
    }
  }

  static Future<Map<String, dynamic>> getCartItems() async {
    String? token = await TokenStorage.getAccessToken();
    final response = await http.get(
      Uri.parse("$cartBase/"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to fetch cart items");
    }
  }

  static Future<Map<String, dynamic>> removeFromCart(int itemId) async {
    String? token = await TokenStorage.getAccessToken();
    final response = await http.post(
      Uri.parse("$cartBase/remove_item/"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: json.encode({"item_id": itemId}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return {"error": "Failed to remove from cart"};
    }
  }

  static Future<void> deleteCartItem(int itemId) async {
    final token = await TokenStorage.getAccessToken();
    final url = Uri.parse("$cartBase/delete_item/$itemId/");
    final response =
        await http.delete(url, headers: {"Authorization": "Bearer $token"});

    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception("Failed to delete item from cart");
    }
  }

  // ----------------- ADDRESS -----------------

  static Future<Map<String, dynamic>> addAddress(
      Map<String, dynamic> address) async {
    String? token = await TokenStorage.getAccessToken();
    final response = await http.post(
      Uri.parse("$customersBase/addresses/"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: json.encode(address),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      return {"error": "Failed to add address"};
    }
  }

  static Future<List<dynamic>> fetchAddresses() async {
    String? token = await TokenStorage.getAccessToken();
    final response = await http.get(
      Uri.parse("$customersBase/addresses/"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["results"];
    } else {
      throw Exception("Failed to fetch addresses");
    }
  }

  static Future<Map<String, dynamic>> updateAddress(
      int id, Map<String, dynamic> address) async {
    String? token = await TokenStorage.getAccessToken();
    final response = await http.put(
      Uri.parse("$customersBase/addresses/$id/"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: json.encode(address),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return {"error": "Failed to update address"};
    }
  }

  static Future<bool> deleteAddress(int id) async {
    String? token = await TokenStorage.getAccessToken();
    final response = await http.delete(
      Uri.parse("$customersBase/addresses/$id/"),
      headers: {"Authorization": "Bearer $token"},
    );

    return response.statusCode == 204;
  }

  // ----------------- ORDERS -----------------

  static Future<Map<String, dynamic>> placeOrder(int addressId) async {
    String? token = await TokenStorage.getAccessToken();
    final response = await http.post(
      Uri.parse("$ordersBase/place/"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: json.encode({"address_id": addressId}),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      return {"error": "Failed to place order"};
    }
  }

  static Future<Map<String, dynamic>> fetchOrders() async {
    String? token = await TokenStorage.getAccessToken();
    final response = await http.get(
      Uri.parse("$ordersBase/"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to fetch orders");
    }
  }

  static Future<Map<String, dynamic>> fetchOrder(int orderId) async {
    String? token = await TokenStorage.getAccessToken();
    final response = await http.get(
      Uri.parse("$ordersBase/$orderId/"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to fetch order $orderId");
    }
  }

  static Future<Map<String, dynamic>> makePayment(
      int orderId, String method) async {
    String? token = await TokenStorage.getAccessToken();
    final response = await http.post(
      Uri.parse("$ordersBase/$orderId/payment/"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: json.encode({"method": method}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return {"error": "Payment failed"};
    }
  }
}
