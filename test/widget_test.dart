import 'package:flutter_test/flutter_test.dart';

import 'package:aims_diabetes/core/routes/auth_gate.dart';
import 'package:aims_diabetes/main.dart';
import 'package:aims_diabetes/models/user_model.dart';
import 'package:aims_diabetes/providers/auth_provider.dart';
import 'package:aims_diabetes/screens/authentication/login_screen.dart';
import 'package:aims_diabetes/services/auth_service.dart';

class FakeAuthService implements AuthService {
  FakeAuthService({this.hasInitialSession = false});

  final bool hasInitialSession;
  bool sessionExists = false;

  @override
  Future<bool> hasSession() async {
    sessionExists = hasInitialSession;
    return sessionExists;
  }

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    sessionExists = true;
    return UserModel(id: 1, name: 'Sara Ahmed', email: email);
  }

  @override
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    sessionExists = true;
    return UserModel(id: 2, name: name, email: email);
  }

  @override
  Future<void> logout() async {
    sessionExists = false;
  }

  @override
  Future<void> refreshToken() async {}

  @override
  Future<void> forgotPassword(String email) async {}

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {}
}

void main() {
  testWidgets('MyApp boots up with AuthGate and renders LoginScreen when unauthenticated', (WidgetTester tester) async {
    final fakeService = FakeAuthService(hasInitialSession: false);
    final authProvider = AuthProvider(fakeService);
    await authProvider.initialize();

    await tester.pumpWidget(MyApp(authProvider: authProvider));
    await tester.pumpAndSettle();

    expect(find.byType(AuthGate), findsOneWidget);
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.text('Welcome Back'), findsOneWidget);
  });

  testWidgets('MyApp boots up with AuthGate and renders Authenticated screen when session exists', (WidgetTester tester) async {
    final fakeService = FakeAuthService(hasInitialSession: true);
    final authProvider = AuthProvider(fakeService);
    await authProvider.initialize();

    await tester.pumpWidget(MyApp(authProvider: authProvider));
    await tester.pumpAndSettle();

    expect(find.byType(AuthGate), findsOneWidget);
    expect(find.byType(AuthenticatedPlaceholderScreen), findsOneWidget);
    expect(find.textContaining('Welcome'), findsOneWidget);
  });
}
