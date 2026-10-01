/// Centralized form validation utilities for authentication workflows.
class Validators {
  /// Validates required first name with at least 2 characters.
  static String? validateFirstName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'First name is required.';
    }
    if (value.trim().length < 2) {
      return 'First name must be at least 2 characters.';
    }
    return null;
  }

  /// Validates required last name with at least 2 characters.
  static String? validateLastName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Last name is required.';
    }
    if (value.trim().length < 2) {
      return 'Last name must be at least 2 characters.';
    }
    return null;
  }

  /// Validates integer age with minimum of 18.
  static String? validateAge(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Age is required.';
    }
    final trimmed = value.trim();
    final parsed = int.tryParse(trimmed);
    if (parsed == null) {
      return 'Age must be an integer only.';
    }
    if (parsed < 18) {
      return 'You must be at least 18 years old.';
    }
    return null;
  }

  /// Validates numeric-only contact number with standard phone length.
  static String? validateContactNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Contact number is required.';
    }
    final trimmed = value.trim();
    if (!RegExp(r'^[0-9]+$').hasMatch(trimmed)) {
      return 'Contact number must contain digits only.';
    }
    if (trimmed.length < 7) {
      return 'Contact number must be at least 7 digits.';
    }
    return null;
  }

  /// Validates required username with minimum 4 characters.
  static String? validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Username is required.';
    }
    if (value.trim().length < 4) {
      return 'Username must be at least 4 characters.';
    }
    return null;
  }

  /// Validates standard email address format.
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email address is required.';
    }
    final trimmed = value.trim();
    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(trimmed)) {
      return 'Please enter a valid email address.';
    }
    return null;
  }

  /// Validates password complexity:
  /// - Minimum 8 characters
  /// - Uppercase letter required
  /// - Lowercase letter required
  /// - Number required
  /// - Special character required
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required.';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters.';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain at least one uppercase letter.';
    }
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Password must contain at least one lowercase letter.';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain at least one number.';
    }
    if (!RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-+=\[\]\\\/~`]').hasMatch(value)) {
      return 'Password must contain at least one special character.';
    }
    return null;
  }

  /// Validates that confirm password matches the primary password.
  static String? validateConfirmPassword(
      String? value, String originalPassword) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password.';
    }
    if (value != originalPassword) {
      return 'Passwords do not match.';
    }
    return null;
  }
}
