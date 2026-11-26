import 'package:flutter/foundation.dart';

import '../core/network/api_exception.dart';
import '../services/mock_password_reset_service.dart';
import '../services/password_reset_service.dart';

/// State for the multi-step forgot-password flow. Holds the flow data (email,
/// reset token) so screens contain no business logic.
///
/// Defaults to [MockPasswordResetService] during the offline development phase.
class PasswordResetProvider extends ChangeNotifier {
  PasswordResetProvider([PasswordResetService? service])
      : _service = service ?? MockPasswordResetService();

  final PasswordResetService _service;

  bool _isLoading = false;
  String? _errorMessage;
  String? _email;
  String? _resetToken;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Email the reset flow was started for.
  String? get email => _email;

  /// True once the OTP has been verified and a reset token is held.
  bool get isOtpVerified => _resetToken != null;

  /// Non-null only with development services; shown as a "dev only" notice.
  String? get developmentOtpHint => _service.developmentOtpHint;

  /// Clears all flow state (call when starting a new flow).
  void reset({bool notify = true}) {
    _isLoading = false;
    _errorMessage = null;
    _email = null;
    _resetToken = null;
    if (notify) notifyListeners();
  }

  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  /// Step 1: request a verification code for [email].
  Future<bool> requestOtp(String email) async {
    if (_isLoading) return false;
    final trimmed = email.trim();
    return _run(() async {
      await _service.requestOtp(trimmed);
      _email = trimmed;
      _resetToken = null;
    });
  }

  /// Re-sends the verification code to the email from step 1.
  Future<bool> resendOtp() async {
    final current = _email;
    if (current == null) return false;
    return requestOtp(current);
  }

  /// Step 2: verify the 6-digit [otp].
  Future<bool> verifyOtp(String otp) async {
    if (_isLoading) return false;
    final current = _email;
    if (current == null) {
      _errorMessage = 'Please enter your email first.';
      notifyListeners();
      return false;
    }
    return _run(() async {
      _resetToken = await _service.verifyOtp(email: current, otp: otp);
    });
  }

  /// Step 3: set [newPassword]. On success the flow state is cleared.
  Future<bool> resetPassword(String newPassword) async {
    if (_isLoading) return false;
    final current = _email;
    final token = _resetToken;
    if (current == null || token == null) {
      _errorMessage = 'Please verify your code first.';
      notifyListeners();
      return false;
    }
    final ok = await _run(() async {
      await _service.resetPassword(
        email: current,
        resetToken: token,
        newPassword: newPassword,
      );
    });
    if (ok) reset();
    return ok;
  }

  Future<bool> _run(Future<void> Function() action) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await action();
      return true;
    } catch (e) {
      _errorMessage = e is ApiException ? e.message : e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
