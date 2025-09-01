import 'dart:convert';
import 'package:http/http.dart' as http;
import 'token_storage.dart';

class ApiService {
  // ----------------- BASE URLS -----------------
  static const String accountsBase = "http://127.0.0.1:8000/api/accounts";
  static const String restaurantsBase = "http://127.0.0.1:8000/api/restaurants";
  static const String cartBase = "http://127.0.0.1:8000/api/cart";

  // ----------------- AUTH -----------------

  // Register User
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

  // Verify OTP
  static Future<Map<String, dynamic>> verifyOtp(String email, String otp) async {
    final response = await http.post(
      Uri.parse("$accountsBase/verify-otp/"),
      body: {
        "email": email,
        "otp": otp,
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return {"error": "OTP verification failed"};
    }
  }

  // Login User - save tokens
  static Future<Map<String, dynamic>> loginUser(
      String username, String password) async {
    final response = await http.post(
      Uri.parse("$accountsBase/login/"),
      body: {
        "username": username,
        "password": password,
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await TokenStorage.saveTokens(data["access"], data["refresh"]);
      return data;
    } else {
      return {"error": "Login failed"};
    }
  }

  // Refresh JWT token
  static Future<bool> refreshToken() async {
    final refresh = await TokenStorage.getRefreshToken();
    if (refresh == null) return false;

    final response = await http.post(
      Uri.parse("$accountsBase/token/refresh/"),
      body: {"refresh": refresh},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // Save new access token, refresh token remains same
      await TokenStorage.saveTokens(data["access"], refresh);
      return true;
    } else {
      await TokenStorage.clearTokens();
      return false;
    }
  }

  // ----------------- MENU -----------------

  // Fetch all menu items (requires token with retry on 401)
  static Future<List<dynamic>> fetchMenuItems() async {
    String? token = await TokenStorage.getAccessToken();
    final url = Uri.parse("$restaurantsBase/menu-items/");

    http.Response response = await http.get(
      url,
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 401) {
      bool refreshed = await refreshToken();
      if (refreshed) {
        token = await TokenStorage.getAccessToken();
        response = await http.get(
          url,
          headers: {"Authorization": "Bearer $token"},
        );
      } else {
        throw Exception("Unauthorized - Please login again");
      }
    }

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["results"]; // paginated response
    } else {
      throw Exception("Failed to load menu items");
    }
  }

  // Fetch menu items by restaurant ID
  static Future<List<dynamic>> fetchMenuItemsByRestaurant(int restaurantId) async {
    String? token = await TokenStorage.getAccessToken();
    final url = Uri.parse("$restaurantsBase/$restaurantId/menu-items/");

    http.Response response = await http.get(
      url,
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 401) {
      bool refreshed = await refreshToken();
      if (refreshed) {
        token = await TokenStorage.getAccessToken();
        response = await http.get(
          url,
          headers: {"Authorization": "Bearer $token"},
        );
      } else {
        throw Exception("Unauthorized - Please login again");
      }
    }

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["results"];
    } else {
      throw Exception("Failed to load menu items for restaurant $restaurantId");
    }
  }

  // ----------------- CART -----------------

  // Add item to cart
  static Future<Map<String, dynamic>> addToCart(int itemId, int quantity) async {
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

// Get cart items
  static Future<Map<String, dynamic>> getCartItems() async {
    String? token = await TokenStorage.getAccessToken();
    final response = await http.get(
      Uri.parse("$cartBase/"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception("Failed to fetch cart items");
    }
  }

  // Remove item from cart
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

// Delete a specific item from cart
static Future<void> deleteCartItem(int itemId) async {
  final token = await TokenStorage.getAccessToken();  // ✅ FIXED
  final url = Uri.parse("$cartBase/delete_item/$itemId/");
  final response = await http.delete(url, headers: {
    "Authorization": "Bearer $token",
  });

  if (response.statusCode != 204 && response.statusCode != 200) {
    throw Exception("Failed to delete item from cart");
  }
}
}

