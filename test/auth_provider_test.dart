import 'package:flutter_test/flutter_test.dart';

import 'package:aims_diabetes/core/network/api_exception.dart';
import 'package:aims_diabetes/models/user_model.dart';
import 'package:aims_diabetes/providers/auth_provider.dart';
import 'package:aims_diabetes/services/auth_service.dart';

// Fake AuthService to test AuthProvider in total isolation
class FakeAuthService implements AuthService {
  bool sessionExists = false;
  UserModel? mockUser;
  Exception? errorToThrow;
  int loginCalls = 0;
  int registerCalls = 0;
  int logoutCalls = 0;

  @override
  Future<bool> hasSession() async {
    if (errorToThrow != null) throw errorToThrow!;
    return sessionExists;
  }

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    loginCalls++;
    if (errorToThrow != null) throw errorToThrow!;
    return mockUser ?? const UserModel(id: 1, name: 'Test User', email: 'test@example.com');
  }

  @override
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    registerCalls++;
    if (errorToThrow != null) throw errorToThrow!;
    return mockUser ?? UserModel(id: 2, name: name, email: email);
  }

  @override
  Future<void> logout() async {
    logoutCalls++;
    sessionExists = false;
  }

  @override
  Future<void> forgotPassword(String email) async {
    if (errorToThrow != null) throw errorToThrow!;
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (errorToThrow != null) throw errorToThrow!;
  }

  @override
  Future<void> refreshToken() async {
    if (errorToThrow != null) throw errorToThrow!;
  }
}

void main() {
  group('AuthProvider', () {
    late FakeAuthService fakeService;
    late AuthProvider authProvider;

    const sampleUser = UserModel(
      id: 42,
      name: 'Jane Doe',
      email: 'jane@example.com',
      age: 29,
    );

    setUp(() {
      fakeService = FakeAuthService();
      authProvider = AuthProvider(fakeService);
    });

    test('Initial state is unauthenticated and checking session', () {
      expect(authProvider.isCheckingSession, isTrue);
      expect(authProvider.isAuthenticated, isFalse);
      expect(authProvider.isLoading, isFalse);
      expect(authProvider.currentUser, isNull);
      expect(authProvider.errorMessage, isNull);
    });

    test('initialize() detects existing session and updates state', () async {
      fakeService.sessionExists = true;

      var notified = false;
      authProvider.addListener(() => notified = true);

      await authProvider.initialize();

      expect(authProvider.isCheckingSession, isFalse);
      expect(authProvider.isAuthenticated, isTrue);
      expect(notified, isTrue);
    });

    test('initialize() handles session absence gracefully', () async {
      fakeService.sessionExists = false;

      await authProvider.initialize();

      expect(authProvider.isCheckingSession, isFalse);
      expect(authProvider.isAuthenticated, isFalse);
    });

    test('login() updates user, sets authenticated, and notifies listeners', () async {
      fakeService.mockUser = sampleUser;

      final states = <bool>[];
      authProvider.addListener(() {
        states.add(authProvider.isLoading);
      });

      final success = await authProvider.login(
        email: 'jane@example.com',
        password: 'password123',
      );

      expect(success, isTrue);
      expect(authProvider.isAuthenticated, isTrue);
      expect(authProvider.currentUser?.name, 'Jane Doe');
      expect(authProvider.errorMessage, isNull);
      expect(fakeService.loginCalls, 1);
      // Verify loading state was flipped true then false
      expect(states, contains(true));
      expect(authProvider.isLoading, isFalse);
    });

    test('login() captures ApiException on failure', () async {
      fakeService.errorToThrow = ApiException('Incorrect email or password.', statusCode: 401);

      final success = await authProvider.login(
        email: 'jane@example.com',
        password: 'wrong_password',
      );

      expect(success, isFalse);
      expect(authProvider.isAuthenticated, isFalse);
      expect(authProvider.currentUser, isNull);
      expect(authProvider.errorMessage, 'Incorrect email or password.');
    });

    test('Prevents duplicate submissions when login is already loading', () async {
      // Simulate by directly triggering a slow login
      fakeService.mockUser = sampleUser;

      final firstCall = authProvider.login(email: 'a@b.com', password: '123');
      final secondCall = authProvider.login(email: 'a@b.com', password: '123');

      final results = await Future.wait([firstCall, secondCall]);
      expect(results[0], isTrue);
      expect(results[1], isFalse); // duplicate was rejected immediately
      expect(fakeService.loginCalls, 1);
    });

    test('register() creates the account without authenticating', () async {
      fakeService.mockUser = sampleUser;

      final success = await authProvider.register(
        name: 'Jane Doe',
        email: 'jane@example.com',
        password: 'Jane@2026',
      );

      expect(success, isTrue);
      expect(authProvider.isAuthenticated, isFalse);
      expect(authProvider.currentUser, isNull);
      expect(authProvider.successMessage, AuthProvider.registrationSuccessMessage);
      expect(authProvider.errorMessage, isNull);
      expect(fakeService.registerCalls, 1);
      // Any session a service might issue on registration is discarded.
      expect(fakeService.logoutCalls, 1);
    });

    test('register() failure sets error and no success message', () async {
      fakeService.errorToThrow = ApiException('User with this email already exists', statusCode: 409);

      final success = await authProvider.register(
        name: 'Jane Doe',
        email: 'jane@example.com',
        password: 'Jane@2026',
      );

      expect(success, isFalse);
      expect(authProvider.isAuthenticated, isFalse);
      expect(authProvider.successMessage, isNull);
      expect(authProvider.errorMessage, 'User with this email already exists');
    });

    test('login() clears a previous registration success message', () async {
      await authProvider.register(name: 'Jane', email: 'jane@example.com', password: 'Jane@2026');
      expect(authProvider.successMessage, isNotNull);

      await authProvider.login(email: 'jane@example.com', password: 'Jane@2026');
      expect(authProvider.successMessage, isNull);
      expect(authProvider.isAuthenticated, isTrue);
    });

    test('logout() clears session and user profile', () async {
      fakeService.mockUser = sampleUser;
      await authProvider.login(email: 'jane@example.com', password: 'password123');
      expect(authProvider.isAuthenticated, isTrue);

      await authProvider.logout();

      expect(authProvider.isAuthenticated, isFalse);
      expect(authProvider.currentUser, isNull);
      expect(fakeService.logoutCalls, 1);
    });

    test('onSessionExpired() resets state and sets user-friendly error message', () {
      authProvider.onSessionExpired();

      expect(authProvider.isAuthenticated, isFalse);
      expect(authProvider.currentUser, isNull);
      expect(authProvider.errorMessage, contains('session has expired'));
    });

    test('clearError() removes message and notifies listeners', () {
      fakeService.errorToThrow = ApiException('Test error');
      authProvider.login(email: 'x', password: 'y');

      authProvider.clearError();
      expect(authProvider.errorMessage, isNull);
    });
  });
}
