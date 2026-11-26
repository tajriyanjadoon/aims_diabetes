import '../core/network/api_exception.dart';
import '../core/utils/validators.dart';
import 'password_reset_service.dart';

/// Offline, development-only implementation of [PasswordResetService].
///
/// - No HTTP requests, no real email/SMS: the verification code is the fixed
///   development OTP [developmentOtp] (`123456`).
/// - Failure simulation: requesting a code for `fail@example.com` throws.
class MockPasswordResetService implements PasswordResetService {
  MockPasswordResetService({this.simulatedDelay = Duration.zero});

  /// DEVELOPMENT ONLY: the fixed one-time code accepted by this mock.
  static const String developmentOtp = '123456';

  final Duration simulatedDelay;

  /// Emails for which a (simulated) code has been requested.
  final Set<String> _requested = <String>{};

  @override
  String? get developmentOtpHint => developmentOtp;

  String _normalize(String email) => email.trim().toLowerCase();
  String _tokenFor(String email) => 'mock-reset-token-${_normalize(email)}';

  Future<void> _delay() async {
    if (simulatedDelay > Duration.zero) {
      await Future<void>.delayed(simulatedDelay);
    }
  }

  @override
  Future<void> requestOtp(String email) async {
    await _delay();
    final normalized = _normalize(email);
    if (normalized == 'fail@example.com') {
      throw ApiException(
        'Unable to send a verification code right now. Please try again.',
        statusCode: 500,
      );
    }
    _requested.add(normalized);
  }

  @override
  Future<String> verifyOtp({required String email, required String otp}) async {
    await _delay();
    final normalized = _normalize(email);
    if (!_requested.contains(normalized)) {
      throw ApiException(
        'No verification code was requested for this email.',
        statusCode: 400,
      );
    }
    if (otp.trim() != developmentOtp) {
      throw ApiException(
        'Invalid verification code. Please try again.',
        statusCode: 400,
      );
    }
    return _tokenFor(normalized);
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String resetToken,
    required String newPassword,
  }) async {
    await _delay();
    final normalized = _normalize(email);
    if (resetToken != _tokenFor(normalized) || !_requested.contains(normalized)) {
      throw ApiException(
        'Your reset session is invalid or has expired. Please start again.',
        statusCode: 401,
      );
    }
    final passwordError = AppValidators.newPassword(newPassword);
    if (passwordError != null) {
      throw ApiException(passwordError, statusCode: 422);
    }
    _requested.remove(normalized);
  }
}
