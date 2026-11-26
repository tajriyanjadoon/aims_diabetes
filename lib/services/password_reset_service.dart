/// Contract for the multi-step "forgot password" flow
/// (request code -> verify code -> set new password).
///
/// NOTE: The current FastAPI backend only exposes `POST /auth/forgot-password`
/// (it validates the email and logs the request); it has no OTP verification
/// or reset endpoint. Until the backend adds them, the app runs this flow on
/// `MockPasswordResetService`. A real implementation can be added later behind
/// this same interface without touching the provider or screens.
abstract class PasswordResetService {
  /// Non-null only for development implementations: the fixed OTP that the UI
  /// should advertise as "development only". Real services return null.
  String? get developmentOtpHint => null;

  /// Requests a verification code for [email].
  Future<void> requestOtp(String email);

  /// Verifies the 6-digit [otp] for [email]; returns a short-lived reset token.
  Future<String> verifyOtp({required String email, required String otp});

  /// Sets [newPassword] for [email] using the [resetToken] from [verifyOtp].
  Future<void> resetPassword({
    required String email,
    required String resetToken,
    required String newPassword,
  });
}
