import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

/// Service responsible for managing persistent user authentication state
/// using SharedPreferences.
class AuthStorageService {
  static const String _keyUserJson = 'auth_user_json';
  static const String _keyUserId = 'auth_user_id';
  static const String _keyIsAuthenticated = 'auth_is_authenticated';

  /// Saves the authenticated User instance to SharedPreferences as a JSON string.
  Future<bool> saveUser(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = jsonEncode(user.toJson());
      await prefs.setString(_keyUserJson, userJson);
      await prefs.setInt(_keyUserId, user.id);
      await prefs.setBool(_keyIsAuthenticated, true);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Retrieves the saved authenticated User instance, or null if none exists or if data is corrupt.
  Future<User?> getSavedUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isAuth = prefs.getBool(_keyIsAuthenticated) ?? false;
      final userJson = prefs.getString(_keyUserJson);

      if (!isAuth || userJson == null || userJson.isEmpty) {
        return null;
      }

      final Map<String, dynamic> data = jsonDecode(userJson);
      final user = User.fromJson(data);

      // Verify that the restored user contains a valid integer ID
      if (user.id <= 0) {
        return null;
      }

      return user;
    } catch (_) {
      return null;
    }
  }

  /// Checks if a valid authenticated session exists.
  Future<bool> isAuthenticated() async {
    final user = await getSavedUser();
    return user != null && user.id > 0;
  }

  /// Retrieves the saved user ID or null if unauthenticated.
  Future<int?> getSavedUserId() async {
    final user = await getSavedUser();
    return user?.id;
  }

  /// Clears all authentication-related keys from persistent storage upon logout.
  Future<bool> clearUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyUserJson);
      await prefs.remove(_keyUserId);
      await prefs.remove(_keyIsAuthenticated);
      return true;
    } catch (_) {
      return false;
    }
  }
}
