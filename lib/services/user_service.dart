import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../constants/constants.dart';
import '../models/user.dart';

/// Service class managing user authentication and remote API communication.
class UserService {
  final http.Client _client;

  UserService({http.Client? client}) : _client = client ?? http.Client();

  /// Authenticates user against DummyJSON Auth API endpoint (`$host/auth/login`).
  ///
  /// Sends credentials securely and parses the response into a [User] model.
  Future<User> login({
    required String username,
    required String password,
  }) async {
    final trimmedUsername = username.trim();
    final trimmedPassword = password.trim();

    if (trimmedUsername.isEmpty || trimmedPassword.isEmpty) {
      throw const FormatException('Username and password cannot be empty.');
    }

    final Uri url = Uri.parse('$host/auth/login');

    try {
      final response = await _client
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'username': trimmedUsername,
              'password': trimmedPassword,
              'expiresInMins': 60,
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final User user = User.fromJson(data);

        // Fetch full profile details (phone, gender, etc.) if available
        if (user.id > 0) {
          try {
            final fullProfile = await getUserById(user.id);
            return user.copyWith(
              phone:
                  fullProfile.phone.isNotEmpty ? fullProfile.phone : user.phone,
              gender: fullProfile.gender.isNotEmpty
                  ? fullProfile.gender
                  : user.gender,
              email:
                  fullProfile.email.isNotEmpty ? fullProfile.email : user.email,
              firstName: fullProfile.firstName.isNotEmpty
                  ? fullProfile.firstName
                  : user.firstName,
              lastName: fullProfile.lastName.isNotEmpty
                  ? fullProfile.lastName
                  : user.lastName,
              image:
                  fullProfile.image.isNotEmpty ? fullProfile.image : user.image,
            );
          } catch (_) {
            // If fetching extra details fails, proceed with the login user data
            return user;
          }
        }

        return user;
      } else if (response.statusCode == 400 || response.statusCode == 401) {
        try {
          final Map<String, dynamic> errorBody = jsonDecode(response.body);
          final String msg =
              errorBody['message']?.toString() ?? 'Invalid credentials.';
          throw Exception(
              msg.isNotEmpty ? msg : 'Invalid username or password.');
        } catch (e) {
          if (e is Exception && !e.toString().contains('FormatException')) {
            rethrow;
          }
          throw Exception('Invalid username or password.');
        }
      } else {
        throw Exception(
            'Server returned error status (${response.statusCode}). Please try again later.');
      }
    } on SocketException {
      throw Exception(
          'Unable to reach server. Please check your internet connection.');
    } on TimeoutException {
      throw Exception('Connection timed out. Please try again.');
    } on FormatException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('An unexpected authentication error occurred.');
    }
  }

  /// Retrieves user profile details by ID from `$host/users/$id`.
  Future<User> getUserById(int id) async {
    final Uri url = Uri.parse('$host/users/$id');

    try {
      final response = await _client.get(
        url,
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return User.fromJson(data);
      } else {
        throw Exception(
            'Failed to load user profile (status ${response.statusCode}).');
      }
    } on SocketException {
      throw Exception(
          'Unable to reach server. Please check your network connection.');
    } on TimeoutException {
      throw Exception('Request timed out while loading user profile.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('An error occurred while fetching the profile.');
    }
  }
}
