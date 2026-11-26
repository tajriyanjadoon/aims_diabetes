import 'package:flutter/foundation.dart';

import '../core/network/api_exception.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/mock_auth_service.dart';

/// State management provider for authentication and session lifecycle.
///
/// Implements [ChangeNotifier] according to the Provider architecture.
/// Manages loading states, authenticated status, current user profile,
/// and error messages.
///
/// By default during offline development, initializes with [MockAuthService]
/// unless an alternative [AuthService] is injected.
class AuthProvider extends ChangeNotifier {
  AuthProvider([AuthService? service])
      : _service = service ?? MockAuthService();

  final AuthService _service;

  bool _isCheckingSession = true;
  bool _isAuthenticated = false;
  bool _isLoading = false;
  UserModel? _currentUser;
  String? _errorMessage;
  String? _successMessage;

  /// Message shown on the Login screen after a successful registration.
  static const String registrationSuccessMessage =
      'Registration successful! Please log in with your new account.';

  // ── Public Getters ────────────────────────────────────────────────────────

  /// True during startup when reading stored credentials from secure storage.
  bool get isCheckingSession => _isCheckingSession;

  /// True if the user is currently authenticated with a valid session.
  bool get isAuthenticated => _isAuthenticated;

  /// True if an authentication action (login, register, logout) is in progress.
  bool get isLoading => _isLoading;

  /// The profile of the currently logged-in user, or null if unauthenticated.
  UserModel? get currentUser => _currentUser;

  /// The latest error message, if any occurred during auth actions.
  String? get errorMessage => _errorMessage;

  /// Latest success notice (e.g. after registration), if any.
  String? get successMessage => _successMessage;

  // ── Convenience Aliases (matching Guide Edition 3.0 conventions) ──────────
  bool get isChecking => _isCheckingSession;
  bool get isLoggedIn => _isAuthenticated;
  bool get isBusy => _isLoading;
  UserModel? get user => _currentUser;
  String? get error => _errorMessage;

  // ── Actions ───────────────────────────────────────────────────────────────

  /// Called once during app startup to check if a stored session exists in secure storage.
  Future<void> initialize() async {
    _isCheckingSession = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _isAuthenticated = await _service.hasSession();
    } catch (e) {
      _isAuthenticated = false;
      _errorMessage = e is ApiException ? e.message : e.toString();
    } finally {
      _isCheckingSession = false;
      notifyListeners();
    }
  }

  /// Alias for [initialize] matching Guide Edition 3.0.
  Future<void> bootstrap() => initialize();

  /// Logs in using [email] and [password].
  ///
  /// Prevents duplicate submissions while an action is already in progress.
  /// Returns `true` on success, or `false` if authentication fails.
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    if (_isLoading) return false;

    return _runAuthAction(() => _service.login(
      email: email.trim(),
      password: password,
    ));
  }

  /// Registers a new user with [name], [email], and [password].
  ///
  /// Prevents duplicate submissions while an action is already in progress.
  /// Returns `true` on success, or `false` if registration fails.
  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    if (_isLoading) return false;

    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      await _service.register(
        name: name.trim(),
        email: email.trim(),
        password: password,
      );
      // Registration creates the account only; it never signs the user in.
      // Discard any session a service may have issued so the user must log in.
      await _service.logout();
      _isAuthenticated = false;
      _currentUser = null;
      _successMessage = registrationSuccessMessage;
      return true;
    } catch (e) {
      _errorMessage = e is ApiException ? e.message : e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Submits a password reset request for [email].
  Future<bool> forgotPassword(String email) async {
    if (_isLoading) return false;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _service.forgotPassword(email.trim());
      return true;
    } catch (e) {
      _errorMessage = e is ApiException ? e.message : e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Changes the user's password using [currentPassword] and [newPassword].
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (_isLoading) return false;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _service.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      return true;
    } catch (e) {
      _errorMessage = e is ApiException ? e.message : e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Logs out the user and clears secure credentials.
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _service.logout();
    } finally {
      _isAuthenticated = false;
      _currentUser = null;
      _errorMessage = null;
      _successMessage = null;
      _isCheckingSession = false;
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Called by the networking layer when a token refresh fails and the session expires.
  void onSessionExpired() {
    _isAuthenticated = false;
    _currentUser = null;
    _errorMessage = 'Your session has expired. Please log in again.';
    notifyListeners();
  }

  /// Clears any currently displayed error message.
  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  /// Clears both error and success messages (e.g. when leaving a screen).
  void clearMessages() {
    if (_errorMessage != null || _successMessage != null) {
      _errorMessage = null;
      _successMessage = null;
      notifyListeners();
    }
  }

  /// Internal helper to execute an authentication action with state transitions.
  Future<bool> _runAuthAction(Future<UserModel> Function() action) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      _currentUser = await action();
      _isAuthenticated = true;
      _isCheckingSession = false;
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
