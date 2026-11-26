import '../core/dummy_data/dummy_user.dart';
import '../core/network/api_exception.dart';
import '../core/network/token_storage.dart';
import '../models/user_model.dart';
import 'auth_service.dart';

/// A registered mock account (profile + password), kept in memory only.
class _MockAccount {
  const _MockAccount(this.user, this.password);

  final UserModel user;
  final String password;
}

/// Mock implementation of [AuthService] for offline development and testing.
///
/// - Zero network or HTTP requests; completely isolated from [ApiClient].
/// - Keeps an in-memory account store (lives as long as this instance):
///   - [register] stores the account but does **not** create a session.
///   - [login] only succeeds for a stored email + exact password.
/// - A demo account is seeded by default: `sara@example.com` /
///   [dummyUserPassword] (DEVELOPMENT ONLY).
/// - Password strength is not checked here: registration rules are enforced by
///   the form validators, and login accepts whatever password the account was
///   stored with.
class MockAuthService implements AuthService {
  MockAuthService({
    TokenStorage? tokenStorage,
    this.simulatedDelay = Duration.zero,
    bool seedDemoAccount = true,
  }) : _tokenStorage = tokenStorage {
    if (seedDemoAccount) {
      _accounts[_normalize(dummyUser.email)] =
          _MockAccount(dummyUser, dummyUserPassword);
    }
  }

  static const String invalidCredentialsMessage = 'Incorrect email or password.';
  static const String duplicateEmailMessage =
      'User with this email already exists';

  final TokenStorage? _tokenStorage;
  final Duration simulatedDelay;

  final Map<String, _MockAccount> _accounts = <String, _MockAccount>{};
  int _nextId = 2; // id 1 is the seeded demo account

  bool _hasSession = false;
  UserModel? _currentUser;

  /// The currently signed-in simulated user profile.
  UserModel? get currentUser => _currentUser;

  /// Whether an account exists for [email] (case-insensitive).
  bool isRegistered(String email) => _accounts.containsKey(_normalize(email));

  String _normalize(String email) => email.trim().toLowerCase();

  Future<void> _delay() async {
    if (simulatedDelay > Duration.zero) {
      await Future<void>.delayed(simulatedDelay);
    }
  }

  Future<void> _saveMockTokens() async {
    final stamp = DateTime.now().millisecondsSinceEpoch;
    await _tokenStorage?.save(
      access: 'mock_jwt_access_token_$stamp',
      refresh: 'mock_jwt_refresh_token_$stamp',
    );
  }

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    await _delay();

    final account = _accounts[_normalize(email)];
    if (account == null || account.password != password) {
      throw ApiException(invalidCredentialsMessage, statusCode: 401);
    }

    _hasSession = true;
    _currentUser = account.user;
    await _saveMockTokens();
    return account.user;
  }

  @override
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    await _delay();

    final normalized = _normalize(email);
    if (normalized == 'existing@example.com' || _accounts.containsKey(normalized)) {
      throw ApiException(duplicateEmailMessage, statusCode: 409);
    }

    final user = UserModel(
      id: _nextId++,
      name: name.trim(),
      email: email.trim(),
      createdAt: DateTime.now(),
    );
    _accounts[normalized] = _MockAccount(user, password);

    // Registration only creates the account. No session, no tokens: the user
    // must sign in with the new credentials.
    return user;
  }

  @override
  Future<void> refreshToken() async {
    await _delay();
    await _tokenStorage?.save(
      access: 'mock_jwt_refreshed_access_${DateTime.now().millisecondsSinceEpoch}',
    );
  }

  @override
  Future<void> forgotPassword(String email) async {
    await _delay();
    if (_normalize(email) == 'fail@example.com') {
      throw ApiException('Unable to process password reset request', statusCode: 500);
    }
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _delay();
    if (currentPassword == 'wrong_password') {
      throw ApiException('Current password is incorrect', statusCode: 400);
    }
  }

  @override
  Future<bool> hasSession() async {
    if (_tokenStorage != null) {
      final token = await _tokenStorage.readAccess();
      return token != null && token.isNotEmpty;
    }
    return _hasSession;
  }

  @override
  Future<void> logout() async {
    await _delay();
    _hasSession = false;
    _currentUser = null;
    await _tokenStorage?.clear();
  }
}
