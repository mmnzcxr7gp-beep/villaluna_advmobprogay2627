import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:http/http.dart' as http;
import '../constants.dart';
import '../models/user.dart';
import 'auth_storage_service.dart';

/// Centralized authentication service managing remote API communication (DummyJSON)
/// and Firebase Authentication workflows.
class UserService {
  final http.Client _client;
  final fb_auth.FirebaseAuth _auth;
  final AuthStorageService _authStorageService;

  UserService({
    http.Client? client,
    fb_auth.FirebaseAuth? auth,
    AuthStorageService? authStorageService,
  })  : _client = client ?? http.Client(),
        _auth = auth ?? fb_auth.FirebaseAuth.instance,
        _authStorageService = authStorageService ?? AuthStorageService();

  // ==========================================
  // FIREBASE AUTHENTICATION IMPLEMENTATION
  // ==========================================

  /// Signs in an existing Firebase user with email and password.
  Future<fb_auth.UserCredential?> signIn({
    required String email,
    required String password,
  }) async {
    final trimmedEmail = email.trim();
    final trimmedPassword = password.trim();

    if (trimmedEmail.isEmpty || trimmedPassword.isEmpty) {
      throw const FormatException('Email and password cannot be empty.');
    }

    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: trimmedEmail,
        password: trimmedPassword,
      );

      // Persist Firebase session type
      await _authStorageService.saveLoginType(LoginType.firebase);

      return credential;
    } on fb_auth.FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('An unexpected error occurred during Firebase sign-in.');
    }
  }

  /// Creates a new Firebase account using email and password.
  Future<fb_auth.UserCredential?> createAccount({
    required String email,
    required String password,
  }) async {
    final trimmedEmail = email.trim();
    final trimmedPassword = password.trim();

    if (trimmedEmail.isEmpty || trimmedPassword.isEmpty) {
      throw const FormatException('Email and password cannot be empty.');
    }

    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: trimmedEmail,
        password: trimmedPassword,
      );

      return credential;
    } on fb_auth.FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('An unexpected error occurred during account creation.');
    }
  }

  /// Signs out the currently authenticated user from Firebase and clears local sessions.
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await _authStorageService.clearUser();
    } catch (e) {
      throw Exception('Failed to sign out: ${e.toString()}');
    }
  }

  /// Updates the Firebase user's display name / username.
  Future<void> updateUsername(String username) async {
    final trimmedName = username.trim();
    if (trimmedName.isEmpty) {
      throw const FormatException('Username cannot be empty.');
    }

    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('No authenticated Firebase user found.');
      }

      await currentUser.updateDisplayName(trimmedName);
      await currentUser.reload();
    } on fb_auth.FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Failed to update username: ${e.toString()}');
    }
  }

  /// Reauthenticates current user and updates password.
  Future<void> resetPasswordFromCurrentPassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _auth.currentUser;
    if (user == null || user.email == null) {
      throw Exception('No authenticated Firebase user found.');
    }

    if (currentPassword.isEmpty || newPassword.isEmpty) {
      throw const FormatException('Passwords cannot be empty.');
    }

    try {
      // Re-authenticate user before critical security action
      final credential = fb_auth.EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);
    } on fb_auth.FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Failed to change password: ${e.toString()}');
    }
  }

  /// Deletes the currently authenticated Firebase user account.
  /// Reauthenticates beforehand if [password] is provided.
  Future<void> deleteAccount({String? password}) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No authenticated Firebase user found.');
    }

    try {
      // Reauthenticate if password is provided
      if (password != null && password.isNotEmpty && user.email != null) {
        final credential = fb_auth.EmailAuthProvider.credential(
          email: user.email!,
          password: password,
        );
        await user.reauthenticateWithCredential(credential);
      }

      await user.delete();
      await _authStorageService.clearUser();
    } on fb_auth.FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Failed to delete account: ${e.toString()}');
    }
  }

  /// Retrieves user profile data based on active login type and session.
  /// Returns a structured map containing all relevant user metadata.
  Future<Map<String, dynamic>?> getUserData() async {
    try {
      // Check Firebase session first
      final firebaseUser = _auth.currentUser;
      if (firebaseUser != null) {
        await firebaseUser.reload();
        final refreshed = _auth.currentUser ?? firebaseUser;

        return {
          'loginType': LoginType.firebase,
          'displayName': (refreshed.displayName != null &&
                  refreshed.displayName!.trim().isNotEmpty)
              ? refreshed.displayName!
              : 'Anonymous User',
          'email': refreshed.email ?? 'No email provided',
          'uid': refreshed.uid,
          'emailVerified': refreshed.emailVerified,
          'creationTime': refreshed.metadata.creationTime != null
              ? refreshed.metadata.creationTime!.toLocal().toString()
              : 'N/A',
          'lastSignInTime': refreshed.metadata.lastSignInTime != null
              ? refreshed.metadata.lastSignInTime!.toLocal().toString()
              : 'N/A',
        };
      }

      // Check DummyJSON persistent session
      final dummyUser = await _authStorageService.getSavedUser();
      if (dummyUser != null) {
        return {
          'loginType': LoginType.dummyJson,
          'id': dummyUser.id,
          'firstName': dummyUser.firstName,
          'lastName': dummyUser.lastName,
          'username': dummyUser.username,
          'email': dummyUser.email,
          'phone': dummyUser.phone,
          'gender': dummyUser.gender,
          'image': dummyUser.image,
          'age': dummyUser.age,
        };
      }

      return null;
    } catch (_) {
      return null;
    }
  }

  /// Maps Firebase authentication exceptions to human-friendly error messages.
  Exception _handleFirebaseAuthException(fb_auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return Exception('No account found with this email.');
      case 'wrong-password':
      case 'invalid-credential':
        return Exception('Invalid email or password.');
      case 'email-already-in-use':
        return Exception('An account with this email address already exists.');
      case 'invalid-email':
        return Exception('The email address provided is invalid.');
      case 'weak-password':
        return Exception(
            'The password is too weak. Please choose a stronger password.');
      case 'requires-recent-login':
        return Exception(
            'This action is sensitive and requires recent authentication. Please verify your current password.');
      case 'user-disabled':
        return Exception('This account has been disabled.');
      case 'too-many-requests':
        return Exception(
            'Too many attempts. Please try again in a few moments.');
      case 'network-request-failed':
        return Exception(
            'Network communication failed. Please check your internet connection.');
      default:
        return Exception(
            e.message ?? 'A Firebase authentication error occurred.');
    }
  }

  // ==========================================
  // DUMMYJSON AUTHENTICATION IMPLEMENTATION
  // ==========================================

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

        // Fetch full profile details (phone, gender, age, etc.) if available
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
              age: fullProfile.age > 0 ? fullProfile.age : user.age,
            );
          } catch (_) {
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
