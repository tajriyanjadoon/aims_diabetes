/// Shared form-field validators for AIMS-Diabetes authentication flows.
///
/// Each method returns `null` when the value is valid, or a user-friendly
/// error message otherwise (the contract expected by `FormField.validator`).
///
/// Password policy (applied only where a password is *created*: registration
/// and password reset): at least [minPasswordLength] characters with at least
/// one lowercase letter, one uppercase letter, one digit and one special
/// character. Login only requires a non-empty password, so an existing
/// account's password is never re-validated against the policy.
abstract final class AppValidators {
  static const int minPasswordLength = 8;
  static const int otpLength = 6;

  /// Full password requirements, shown below password-creation fields.
  static const String passwordRequirementsText =
      'Password must contain at least 8 characters, including one uppercase '
      'letter, one lowercase letter, one number, and one special character.';

  static const String passwordTooShort =
      'Password must be at least 8 characters';
  static const String passwordNeedsLowercase =
      'Password must include a lowercase letter (a-z)';
  static const String passwordNeedsUppercase =
      'Password must include an uppercase letter (A-Z)';
  static const String passwordNeedsDigit =
      'Password must include a number (0-9)';
  static const String passwordNeedsSpecial =
      r'Password must include a special character (e.g. @#$!)';

  static final RegExp _emailRegex = RegExp(r'^[\w\.\-]+@[\w\-]+(\.[\w\-]+)+$');
  static final RegExp _lowercase = RegExp(r'[a-z]');
  static final RegExp _uppercase = RegExp(r'[A-Z]');
  static final RegExp _digit = RegExp(r'[0-9]');

  /// Any character that is not a letter, digit or whitespace counts as special.
  static final RegExp _special = RegExp(r'[^A-Za-z0-9\s]');
  static final RegExp _otpRegex = RegExp(r'^[0-9]{6}$');

  static String? email(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'Please enter your email';
    if (!_emailRegex.hasMatch(trimmed)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  static String? fullName(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'Please enter your full name';
    if (trimmed.length < 2) return 'Name must be at least 2 characters';
    return null;
  }

  /// Login password: required only. The creation policy is not enforced.
  static String? loginPassword(String? value) {
    if (value == null || value.isEmpty) return 'Please enter your password';
    return null;
  }

  /// Password creation policy (registration and password reset).
  /// Reports the first unmet requirement.
  static String? newPassword(String? value) {
    if (value == null || value.isEmpty) return 'Please create a password';
    if (value.length < minPasswordLength) return passwordTooShort;
    if (!_lowercase.hasMatch(value)) return passwordNeedsLowercase;
    if (!_uppercase.hasMatch(value)) return passwordNeedsUppercase;
    if (!_digit.hasMatch(value)) return passwordNeedsDigit;
    if (!_special.hasMatch(value)) return passwordNeedsSpecial;
    return null;
  }

  /// True when [value] satisfies the password creation policy.
  static bool isStrongPassword(String value) => newPassword(value) == null;

  static String? confirmPassword(String? value, String original) {
    if (value == null || value.isEmpty) return 'Please confirm your password';
    if (value != original) return 'Passwords do not match';
    return null;
  }

  static String? otp(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'Please enter the 6-digit code';
    if (!_otpRegex.hasMatch(trimmed)) {
      return 'Code must be exactly $otpLength digits';
    }
    return null;
  }
}
