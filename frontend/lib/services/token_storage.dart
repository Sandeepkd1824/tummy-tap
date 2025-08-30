// lib/services/token_storage.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static final _storage = FlutterSecureStorage();

  static Future<void> saveTokens(String access, String refresh) async {
    await _storage.write(key: "access_token", value: access);
    await _storage.write(key: "refresh_token", value: refresh);
  }

  static Future<String?> getAccessToken() async {
    return await _storage.read(key: "access_token");
  }

  static Future<String?> getRefreshToken() async {
    return await _storage.read(key: "refresh_token");
  }

  static Future<void> clearTokens() async {
    await _storage.delete(key: "access_token");
    await _storage.delete(key: "refresh_token");
  }
}
