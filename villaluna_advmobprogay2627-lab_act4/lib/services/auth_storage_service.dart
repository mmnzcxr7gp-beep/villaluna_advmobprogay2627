import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';
import '../models/user.dart';

/// Service responsible for managing persistent user authentication state
/// using SharedPreferences.
class AuthStorageService {
  static const String _keyUserJson = 'auth_user_json';
  static const String _keyUserId = 'auth_user_id';
  static const String _keyIsAuthenticated = 'auth_is_authenticated';
  static const String _keyLoginType = 'auth_login_type';

  /// Saves the authenticated User instance to SharedPreferences as a JSON string.
  Future<bool> saveUser(User user,
      [LoginType type = LoginType.dummyJson]) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = jsonEncode(user.toJson());
      await prefs.setString(_keyUserJson, userJson);
      await prefs.setInt(_keyUserId, user.id);
      await prefs.setBool(_keyIsAuthenticated, true);
      await prefs.setString(_keyLoginType, type.name);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Saves only the active LoginType (used by Firebase sessions).
  Future<bool> saveLoginType(LoginType type) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyLoginType, type.name);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Retrieves the active LoginType from persistent storage.
  Future<LoginType?> getSavedLoginType() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final typeStr = prefs.getString(_keyLoginType);
      if (typeStr == LoginType.firebase.name) {
        return LoginType.firebase;
      } else if (typeStr == LoginType.dummyJson.name) {
        return LoginType.dummyJson;
      }
      return null;
    } catch (_) {
      return null;
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
      await prefs.remove(_keyLoginType);
      return true;
    } catch (_) {
      return false;
    }
  }
}
