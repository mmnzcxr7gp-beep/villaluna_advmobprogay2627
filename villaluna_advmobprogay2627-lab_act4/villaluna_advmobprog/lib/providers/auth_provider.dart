import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:flutter/material.dart';
import '../constants.dart';
import '../models/user.dart';
import '../services/auth_storage_service.dart';
import '../services/user_service.dart';

/// State management provider for authentication flows, session persistence,
/// and profile state handling both DummyJSON and Firebase authentication modes.
class AuthProvider with ChangeNotifier {
  final UserService _userService;
  final AuthStorageService _authStorageService;

  LoginType _loginType = LoginType.dummyJson;
  User? _dummyUser;
  fb_auth.User? _firebaseUser;
  Map<String, dynamic>? _profileData;
  bool _isLoading = false;
  String? _errorMessage;

  AuthProvider({
    UserService? userService,
    AuthStorageService? authStorageService,
  })  : _userService = userService ?? UserService(),
        _authStorageService = authStorageService ?? AuthStorageService() {
    _init();
  }

  // Getters
  LoginType get loginType => _loginType;
  User? get dummyUser => _dummyUser;
  fb_auth.User? get firebaseUser => _firebaseUser;
  Map<String, dynamic>? get profileData => _profileData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  bool get isAuthenticated =>
      _firebaseUser != null || (_dummyUser != null && _dummyUser!.id > 0);

  /// Initializes authentication state by restoring any persisted session.
  Future<void> _init() async {
    await checkPersistedSession();
  }

  /// Sets the active login mode (DummyJSON vs Firebase) and resets any previous errors.
  void setLoginType(LoginType type) {
    if (_loginType != type) {
      _loginType = type;
      _errorMessage = null;
      notifyListeners();
    }
  }

  /// Clears any transient error message.
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Checks persistent storage and Firebase auth state to restore the user session.
  Future<void> checkPersistedSession() async {
    try {
      final fbUser = fb_auth.FirebaseAuth.instance.currentUser;
      if (fbUser != null) {
        _firebaseUser = fbUser;
        _loginType = LoginType.firebase;
        await refreshProfile();
        return;
      }

      final savedUser = await _authStorageService.getSavedUser();
      if (savedUser != null && savedUser.id > 0) {
        _dummyUser = savedUser;
        _loginType = LoginType.dummyJson;
        await refreshProfile();
        return;
      }
    } catch (_) {
      // Ignore initial restore errors
    }
  }

  /// Authenticates user against DummyJSON Auth API.
  Future<bool> loginDummyJson({
    required String username,
    required String password,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final user = await _userService.login(
        username: username,
        password: password,
      );

      _dummyUser = user;
      _firebaseUser = null;
      _loginType = LoginType.dummyJson;

      await _authStorageService.saveUser(user, LoginType.dummyJson);
      await refreshProfile();

      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _setLoading(false);
      return false;
    }
  }

  /// Authenticates user with Firebase Authentication.
  Future<bool> loginFirebase({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final cred = await _userService.signIn(
        email: email,
        password: password,
      );

      _firebaseUser = cred?.user ?? fb_auth.FirebaseAuth.instance.currentUser;
      _dummyUser = null;
      _loginType = LoginType.firebase;

      await _authStorageService.saveLoginType(LoginType.firebase);
      await refreshProfile();

      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _setLoading(false);
      return false;
    }
  }

  /// Registers a new user account with Firebase Authentication.
  Future<bool> signupFirebase({
    required String email,
    required String password,
    required String username,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final cred = await _userService.createAccount(
        email: email,
        password: password,
      );

      if (cred?.user != null) {
        await _userService.updateUsername(username);
      }

      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _setLoading(false);
      return false;
    }
  }

  /// Refreshes user profile details from UserService.
  Future<void> refreshProfile() async {
    try {
      _profileData = await _userService.getUserData();
      if (_loginType == LoginType.firebase) {
        _firebaseUser = fb_auth.FirebaseAuth.instance.currentUser;
      } else {
        _dummyUser = await _authStorageService.getSavedUser();
      }
      notifyListeners();
    } catch (_) {
      // Non-critical profile refresh error
    }
  }

  /// Updates Firebase display name.
  Future<bool> updateUsername(String newUsername) async {
    _setLoading(true);
    try {
      await _userService.updateUsername(newUsername);
      await refreshProfile();
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _setLoading(false);
      return false;
    }
  }

  /// Changes password for the currently signed-in Firebase user.
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    _setLoading(true);
    try {
      await _userService.resetPasswordFromCurrentPassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _setLoading(false);
      return false;
    }
  }

  /// Deletes the currently signed-in Firebase account.
  Future<bool> deleteAccount({String? password}) async {
    _setLoading(true);
    try {
      await _userService.deleteAccount(password: password);
      _firebaseUser = null;
      _dummyUser = null;
      _profileData = null;
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _setLoading(false);
      return false;
    }
  }

  /// Logs out the user and clears all active sessions.
  Future<void> logout() async {
    _setLoading(true);
    try {
      await _userService.signOut();
      _firebaseUser = null;
      _dummyUser = null;
      _profileData = null;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
