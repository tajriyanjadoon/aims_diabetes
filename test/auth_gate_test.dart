import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:aims_diabetes/core/dummy_data/dummy_user.dart';
import 'package:aims_diabetes/core/routes/auth_gate.dart';
import 'package:aims_diabetes/core/theme/app_theme.dart';
import 'package:aims_diabetes/models/user_model.dart';
import 'package:aims_diabetes/providers/auth_provider.dart';
import 'package:aims_diabetes/screens/authentication/login_screen.dart';
import 'package:aims_diabetes/services/auth_service.dart';
import 'package:aims_diabetes/services/mock_auth_service.dart';

class StubAuthService implements AuthService {
  StubAuthService({this.initialSession = false});

  final bool initialSession;
  bool session = false;
  int logoutCount = 0;

  @override
  Future<bool> hasSession() async {
    session = initialSession;
    return session;
  }

  @override
  Future<UserModel> login({required String email, required String password}) async {
    session = true;
    return UserModel(id: 1, name: 'Test Patient', email: email);
  }

  @override
  Future<UserModel> register({required String name, required String email, required String password}) async {
    session = true;
    return UserModel(id: 2, name: name, email: email);
  }

  @override
  Future<void> logout() async {
    logoutCount++;
    session = false;
  }

  @override
  Future<void> refreshToken() async {}

  @override
  Future<void> forgotPassword(String email) async {}

  @override
  Future<void> changePassword({required String currentPassword, required String newPassword}) async {}
}

Widget _wrapGate(AuthProvider provider) {
  return ChangeNotifierProvider<AuthProvider>.value(
    value: provider,
    child: MaterialApp(
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      home: const AuthGate(),
    ),
  );
}

void main() {
  group('AuthGate Routing & State Tests', () {
    testWidgets('Shows loading indicator while session is checking', (tester) async {
      // By default AuthProvider is in isCheckingSession = true until initialize is run
      final provider = AuthProvider(StubAuthService());
      expect(provider.isCheckingSession, isTrue);

      await tester.pumpWidget(_wrapGate(provider));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(LoginScreen), findsNothing);
      expect(find.byType(AuthenticatedPlaceholderScreen), findsNothing);
    });

    testWidgets('Shows LoginScreen when user is unauthenticated', (tester) async {
      final provider = AuthProvider(StubAuthService(initialSession: false));
      await provider.initialize();
      expect(provider.isCheckingSession, isFalse);
      expect(provider.isAuthenticated, isFalse);

      await tester.pumpWidget(_wrapGate(provider));
      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.text('Welcome Back'), findsOneWidget);
      expect(find.byType(AuthenticatedPlaceholderScreen), findsNothing);
    });

    testWidgets('Shows AuthenticatedPlaceholderScreen when user is authenticated', (tester) async {
      final mockService = MockAuthService();
      final provider = AuthProvider(mockService);
      await provider.login(email: 'sara@example.com', password: dummyUserPassword);
      expect(provider.isAuthenticated, isTrue);

      await tester.pumpWidget(_wrapGate(provider));
      await tester.pumpAndSettle();

      expect(find.byType(AuthenticatedPlaceholderScreen), findsOneWidget);
      expect(find.text('Welcome, Sara Ahmed!'), findsOneWidget);
      expect(find.text('sara@example.com'), findsOneWidget);
      expect(find.text('Session Active (Mock Mode)'), findsOneWidget);
      expect(find.byType(LoginScreen), findsNothing);
    });

    testWidgets('Tapping Log Out button returns user to LoginScreen', (tester) async {
      final stubService = StubAuthService(initialSession: true);
      final provider = AuthProvider(stubService);
      await provider.login(email: 'patient@example.com', password: 'password');
      expect(provider.isAuthenticated, isTrue);

      await tester.pumpWidget(_wrapGate(provider));
      await tester.pumpAndSettle();
      expect(find.byType(AuthenticatedPlaceholderScreen), findsOneWidget);

      await tester.ensureVisible(find.byKey(const Key('auth_placeholder_logout_button')));
      await tester.tap(find.byKey(const Key('auth_placeholder_logout_button')));
      await tester.pumpAndSettle();

      expect(stubService.logoutCount, 1);
      expect(provider.isAuthenticated, isFalse);
      expect(find.byType(AuthenticatedPlaceholderScreen), findsNothing);
      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets('Tapping Log Out AppBar icon returns user to LoginScreen', (tester) async {
      final stubService = StubAuthService(initialSession: true);
      final provider = AuthProvider(stubService);
      await provider.login(email: 'patient@example.com', password: 'password');
      expect(provider.isAuthenticated, isTrue);

      await tester.pumpWidget(_wrapGate(provider));
      await tester.pumpAndSettle();
      expect(find.byType(AuthenticatedPlaceholderScreen), findsOneWidget);

      await tester.tap(find.byKey(const Key('auth_placeholder_logout_icon')));
      await tester.pumpAndSettle();

      expect(stubService.logoutCount, 1);
      expect(provider.isAuthenticated, isFalse);
      expect(find.byType(AuthenticatedPlaceholderScreen), findsNothing);
      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets('Logging in from LoginScreen automatically routes to authenticated screen', (tester) async {
      final mockService = MockAuthService();
      final provider = AuthProvider(mockService);
      await provider.initialize();
      expect(provider.isAuthenticated, isFalse);

      await tester.pumpWidget(_wrapGate(provider));
      await tester.pumpAndSettle();
      expect(find.byType(LoginScreen), findsOneWidget);

      // Perform simulated login
      await tester.enterText(find.byKey(const Key('login_email_field')), 'sara@example.com');
      await tester.enterText(find.byKey(const Key('login_password_field')), dummyUserPassword);

      await tester.ensureVisible(find.byKey(const Key('login_submit_button')));
      await tester.tap(find.byKey(const Key('login_submit_button')));
      await tester.pumpAndSettle();

      expect(provider.isAuthenticated, isTrue);
      expect(find.byType(LoginScreen), findsNothing);
      expect(find.byType(AuthenticatedPlaceholderScreen), findsOneWidget);
      expect(find.text('Welcome, Sara Ahmed!'), findsOneWidget);
    });
  });
}
