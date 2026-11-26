import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:aims_diabetes/core/dummy_data/dummy_user.dart';
import 'package:aims_diabetes/core/network/api_exception.dart';
import 'package:aims_diabetes/core/network/token_storage.dart';
import 'package:aims_diabetes/core/theme/app_theme.dart';
import 'package:aims_diabetes/providers/auth_provider.dart';
import 'package:aims_diabetes/screens/authentication/login_screen.dart';
import 'package:aims_diabetes/screens/authentication/register_screen.dart';
import 'package:aims_diabetes/services/mock_auth_service.dart';

// In-memory fake implementation of FlutterSecureStorage for testing persistent tokens
class FakeSecureStorage extends FlutterSecureStorage {
  FakeSecureStorage() : super();
  final Map<String, String> _data = {};

  @override
  Future<String?> read({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async => _data[key];

  @override
  Future<void> write({
    required String key,
    required String? value,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (value != null) {
      _data[key] = value;
    } else {
      _data.remove(key);
    }
  }

  @override
  Future<void> delete({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async => _data.remove(key);
}

Widget _wrapScreen(Widget screen, AuthProvider provider) {
  return ChangeNotifierProvider<AuthProvider>.value(
    value: provider,
    child: MaterialApp(
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      home: screen,
    ),
  );
}

void main() {
  group('MockAuthService Unit Tests', () {
    test('Seeded demo account logs in and returns the dummy UserModel', () async {
      final mockService = MockAuthService();
      expect(await mockService.hasSession(), isFalse);

      final user = await mockService.login(
        email: 'sara@example.com',
        password: dummyUserPassword,
      );

      expect(user.id, 1);
      expect(user.email, 'sara@example.com');
      expect(user.name, 'Sara Ahmed');
      expect(user.diabetesType, 'Type 2');
      expect(await mockService.hasSession(), isTrue);
      expect(mockService.currentUser, isNotNull);
    });

    test('Login email is case-insensitive', () async {
      final mockService = MockAuthService();
      final user = await mockService.login(email: '  SARA@Example.com ', password: dummyUserPassword);
      expect(user.name, 'Sara Ahmed');
    });

    test('Login for an unknown account throws ApiException 401', () async {
      final mockService = MockAuthService();
      expect(
        () => mockService.login(email: 'nobody@example.com', password: 'Any@2026'),
        throwsA(isA<ApiException>()
            .having((e) => e.statusCode, 'statusCode', 401)
            .having((e) => e.message, 'message', MockAuthService.invalidCredentialsMessage)),
      );
      expect(await mockService.hasSession(), isFalse);
    });

    test('Login with a wrong password throws ApiException 401', () async {
      final mockService = MockAuthService();
      expect(
        () => mockService.login(email: 'sara@example.com', password: 'wrong_password'),
        throwsA(isA<ApiException>().having((e) => e.statusCode, 'statusCode', 401)),
      );
      expect(await mockService.hasSession(), isFalse);
    });

    test('Registration stores the account but does not create a session', () async {
      final mockService = MockAuthService();
      final user = await mockService.register(
        name: 'John Doe',
        email: 'john@example.com',
        password: 'John@2026',
      );

      expect(user.name, 'John Doe');
      expect(user.email, 'john@example.com');
      expect(mockService.isRegistered('john@example.com'), isTrue);
      expect(await mockService.hasSession(), isFalse);
      expect(mockService.currentUser, isNull);
    });

    test('Registered credentials work for a subsequent login (exact password)', () async {
      final mockService = MockAuthService();
      await mockService.register(name: 'John Doe', email: 'john@example.com', password: 'John@2026');

      expect(
        () => mockService.login(email: 'john@example.com', password: 'john@2026'),
        throwsA(isA<ApiException>()),
      );

      final user = await mockService.login(email: 'john@example.com', password: 'John@2026');
      expect(user.name, 'John Doe');
      expect(await mockService.hasSession(), isTrue);
    });

    test('Login does not re-apply the registration password policy', () async {
      // The service stores whatever password the account was created with.
      final mockService = MockAuthService();
      await mockService.register(name: 'Legacy', email: 'legacy@example.com', password: 'weak');
      final user = await mockService.login(email: 'legacy@example.com', password: 'weak');
      expect(user.email, 'legacy@example.com');
    });

    test('Registration with an existing email simulates a duplicate conflict (409)', () async {
      final mockService = MockAuthService();

      expect(
        () => mockService.register(name: 'X', email: 'existing@example.com', password: 'Pass@1234'),
        throwsA(isA<ApiException>().having((e) => e.statusCode, 'statusCode', 409)),
      );
      expect(
        () => mockService.register(name: 'X', email: 'SARA@example.com', password: 'Pass@1234'),
        throwsA(isA<ApiException>().having((e) => e.statusCode, 'statusCode', 409)),
      );
    });

    test('Forgot Password simulates success, and failure for fail@example.com', () async {
      final mockService = MockAuthService();
      await expectLater(mockService.forgotPassword('user@example.com'), completes);
      expect(
        () => mockService.forgotPassword('fail@example.com'),
        throwsA(isA<ApiException>().having((e) => e.statusCode, 'statusCode', 500)),
      );
    });

    test('Logout clears session without network calls', () async {
      final mockService = MockAuthService();
      await mockService.login(email: 'sara@example.com', password: dummyUserPassword);
      expect(await mockService.hasSession(), isTrue);

      await mockService.logout();
      expect(await mockService.hasSession(), isFalse);
      expect(mockService.currentUser, isNull);
    });

    test('TokenStorage: login writes tokens, register does not, logout clears', () async {
      final tokenStorage = TokenStorage(storage: FakeSecureStorage());
      final mockService = MockAuthService(tokenStorage: tokenStorage);

      await mockService.register(name: 'T', email: 'token.user@example.com', password: 'Token@2026');
      expect(await tokenStorage.readAccess(), isNull);
      expect(await mockService.hasSession(), isFalse);

      await mockService.login(email: 'token.user@example.com', password: 'Token@2026');
      expect(await tokenStorage.readAccess(), isNotNull);
      expect(await mockService.hasSession(), isTrue);

      await mockService.logout();
      expect(await tokenStorage.readAccess(), isNull);
      expect(await mockService.hasSession(), isFalse);
    });
  });

  group('AuthProvider with MockAuthService', () {
    test('Defaults to MockAuthService when initialized without arguments', () async {
      final provider = AuthProvider();
      expect(provider.isAuthenticated, isFalse);
      expect(provider.currentUser, isNull);
      expect(await provider.login(email: 'sara@example.com', password: dummyUserPassword), isTrue);
    });

    test('Login flow updates state and notifies listeners', () async {
      final provider = AuthProvider();
      var notifications = 0;
      provider.addListener(() => notifications++);

      final success = await provider.login(email: 'sara@example.com', password: dummyUserPassword);

      expect(success, isTrue);
      expect(provider.isAuthenticated, isTrue);
      expect(provider.currentUser?.name, 'Sara Ahmed');
      expect(provider.errorMessage, isNull);
      expect(notifications, greaterThanOrEqualTo(2));
    });

    test('Login failure populates errorMessage', () async {
      final provider = AuthProvider();
      final success = await provider.login(email: 'sara@example.com', password: 'wrong_password');

      expect(success, isFalse);
      expect(provider.isAuthenticated, isFalse);
      expect(provider.errorMessage, 'Incorrect email or password.');
      expect(provider.currentUser, isNull);
    });

    test('Registration does not authenticate; the new account can then log in', () async {
      final provider = AuthProvider();

      final registered = await provider.register(
        name: 'Emma Watson',
        email: 'emma@example.com',
        password: 'Emma@2026',
      );
      expect(registered, isTrue);
      expect(provider.isAuthenticated, isFalse);
      expect(provider.currentUser, isNull);
      expect(provider.successMessage, AuthProvider.registrationSuccessMessage);

      final loggedIn = await provider.login(email: 'emma@example.com', password: 'Emma@2026');
      expect(loggedIn, isTrue);
      expect(provider.isAuthenticated, isTrue);
      expect(provider.currentUser?.name, 'Emma Watson');
      expect(provider.successMessage, isNull);
    });

    test('forgotPassword returns true without network requests', () async {
      final provider = AuthProvider();
      expect(await provider.forgotPassword('patient@example.com'), isTrue);
      expect(provider.errorMessage, isNull);
    });

    test('Logout resets all authentication state', () async {
      final provider = AuthProvider();
      await provider.login(email: 'sara@example.com', password: dummyUserPassword);
      expect(provider.isAuthenticated, isTrue);

      await provider.logout();
      expect(provider.isAuthenticated, isFalse);
      expect(provider.currentUser, isNull);
      expect(provider.errorMessage, isNull);
    });
  });

  group('Authentication UI Screens with MockAuthService', () {
    testWidgets('LoginScreen logs in with the demo credentials', (tester) async {
      final provider = AuthProvider();
      await tester.pumpWidget(_wrapScreen(const LoginScreen(), provider));

      await tester.enterText(find.byKey(const Key('login_email_field')), 'sara@example.com');
      await tester.enterText(find.byKey(const Key('login_password_field')), dummyUserPassword);

      await tester.ensureVisible(find.byKey(const Key('login_submit_button')));
      await tester.tap(find.byKey(const Key('login_submit_button')));
      await tester.pumpAndSettle();

      expect(provider.isAuthenticated, isTrue);
      expect(provider.currentUser?.name, 'Sara Ahmed');
      expect(provider.errorMessage, isNull);
    });

    testWidgets('LoginScreen displays invalid credential error', (tester) async {
      final provider = AuthProvider();
      await tester.pumpWidget(_wrapScreen(const LoginScreen(), provider));

      await tester.enterText(find.byKey(const Key('login_email_field')), 'sara@example.com');
      await tester.enterText(find.byKey(const Key('login_password_field')), 'wrong_password');

      await tester.ensureVisible(find.byKey(const Key('login_submit_button')));
      await tester.tap(find.byKey(const Key('login_submit_button')));
      await tester.pumpAndSettle();

      expect(provider.isAuthenticated, isFalse);
      expect(find.text('Incorrect email or password.'), findsOneWidget);
    });

    testWidgets('RegisterScreen creates an account without signing in', (tester) async {
      final provider = AuthProvider();
      await tester.pumpWidget(_wrapScreen(const RegisterScreen(), provider));

      await tester.enterText(find.byKey(const Key('register_name_field')), 'Michael Scott');
      await tester.enterText(find.byKey(const Key('register_email_field')), 'michael@dunder.com');
      await tester.enterText(find.byKey(const Key('register_password_field')), 'Dunder@123');
      await tester.enterText(find.byKey(const Key('register_confirm_password_field')), 'Dunder@123');

      await tester.ensureVisible(find.byKey(const Key('register_submit_button')));
      await tester.tap(find.byKey(const Key('register_submit_button')));
      await tester.pumpAndSettle();

      expect(provider.isAuthenticated, isFalse);
      expect(provider.currentUser, isNull);
      expect(provider.successMessage, AuthProvider.registrationSuccessMessage);
      expect(provider.errorMessage, isNull);

      // The stored account works afterwards.
      expect(await provider.login(email: 'michael@dunder.com', password: 'Dunder@123'), isTrue);
    });
  });
}
