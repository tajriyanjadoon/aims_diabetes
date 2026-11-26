import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:aims_diabetes/core/network/api_exception.dart';
import 'package:aims_diabetes/core/theme/app_theme.dart';
import 'package:aims_diabetes/models/user_model.dart';
import 'package:aims_diabetes/providers/auth_provider.dart';
import 'package:aims_diabetes/providers/password_reset_provider.dart';
import 'package:aims_diabetes/screens/authentication/otp_verification_screen.dart';
import 'package:aims_diabetes/screens/authentication/forgot_password_screen.dart';
import 'package:aims_diabetes/screens/authentication/login_screen.dart';
import 'package:aims_diabetes/screens/authentication/register_screen.dart';
import 'package:aims_diabetes/services/auth_service.dart';

class FakeAuthService implements AuthService {
  bool sessionExists = false;
  UserModel? mockUser;
  Exception? errorToThrow;
  int loginCalls = 0;
  int registerCalls = 0;
  int logoutCalls = 0;
  int forgotPasswordCalls = 0;
  String? lastLoginEmail;
  String? lastLoginPassword;
  String? lastRegisterName;
  String? lastRegisterEmail;
  String? lastRegisterPassword;
  String? lastForgotPasswordEmail;

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
    lastLoginEmail = email;
    lastLoginPassword = password;
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
    lastRegisterName = name;
    lastRegisterEmail = email;
    lastRegisterPassword = password;
    if (errorToThrow != null) throw errorToThrow!;
    return mockUser ?? UserModel(id: 2, name: name, email: email);
  }

  @override
  Future<void> logout() async {
    logoutCalls++;
    sessionExists = false;
  }

  @override
  Future<void> refreshToken() async {
    if (errorToThrow != null) throw errorToThrow!;
  }

  @override
  Future<void> forgotPassword(String email) async {
    forgotPasswordCalls++;
    lastForgotPasswordEmail = email;
    if (errorToThrow != null) throw errorToThrow!;
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (errorToThrow != null) throw errorToThrow!;
  }
}

Widget _wrapAuthScreen(
  Widget screen,
  AuthProvider provider, [
  PasswordResetProvider? resetProvider,
]) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<AuthProvider>.value(value: provider),
      ChangeNotifierProvider<PasswordResetProvider>.value(
        value: resetProvider ?? PasswordResetProvider(),
      ),
    ],
    child: MaterialApp(
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      home: screen,
    ),
  );
}

void main() {
  late FakeAuthService fakeService;
  late AuthProvider authProvider;

  setUp(() {
    fakeService = FakeAuthService();
    authProvider = AuthProvider(fakeService);
  });

  group('LoginScreen Widget Tests', () {
    testWidgets('Renders all initial UI elements correctly', (tester) async {
      await tester.pumpWidget(_wrapAuthScreen(const LoginScreen(), authProvider));

      expect(find.text('Welcome Back'), findsOneWidget);
      expect(find.text('Sign in to manage your diabetes with AIMSD'), findsOneWidget);
      expect(find.byKey(const Key('login_email_field')), findsOneWidget);
      expect(find.byKey(const Key('login_password_field')), findsOneWidget);
      expect(find.text('Forgot Password?'), findsOneWidget);
      expect(find.byKey(const Key('login_submit_button')), findsOneWidget);
      expect(find.byKey(const Key('login_signup_link')), findsOneWidget);
    });

    testWidgets('Triggers validation error on empty fields', (tester) async {
      await tester.pumpWidget(_wrapAuthScreen(const LoginScreen(), authProvider));

      await tester.tap(find.byKey(const Key('login_submit_button')));
      await tester.pump();

      expect(find.text('Please enter your email'), findsOneWidget);
      expect(find.text('Please enter your password'), findsOneWidget);
      expect(fakeService.loginCalls, 0);
    });

    testWidgets('Triggers validation error on invalid email address', (tester) async {
      await tester.pumpWidget(_wrapAuthScreen(const LoginScreen(), authProvider));

      await tester.enterText(find.byKey(const Key('login_email_field')), 'not-an-email');
      await tester.enterText(find.byKey(const Key('login_password_field')), '123456');
      await tester.tap(find.byKey(const Key('login_submit_button')));
      await tester.pump();

      expect(find.text('Please enter a valid email address'), findsOneWidget);
      expect(fakeService.loginCalls, 0);
    });

    testWidgets('Valid submission calls AuthProvider.login', (tester) async {
      await tester.pumpWidget(_wrapAuthScreen(const LoginScreen(), authProvider));

      await tester.enterText(find.byKey(const Key('login_email_field')), 'patient@example.com');
      await tester.enterText(find.byKey(const Key('login_password_field')), 'password123');
      await tester.tap(find.byKey(const Key('login_submit_button')));
      await tester.pump();

      expect(fakeService.loginCalls, 1);
      expect(fakeService.lastLoginEmail, 'patient@example.com');
      expect(fakeService.lastLoginPassword, 'password123');
    });

    testWidgets('Renders error banner when authProvider has error message', (tester) async {
      fakeService.errorToThrow = ApiException('Invalid email or password', statusCode: 401);

      await tester.pumpWidget(_wrapAuthScreen(const LoginScreen(), authProvider));

      await tester.enterText(find.byKey(const Key('login_email_field')), 'patient@example.com');
      await tester.enterText(find.byKey(const Key('login_password_field')), 'wrongpass');
      await tester.tap(find.byKey(const Key('login_submit_button')));
      await tester.pumpAndSettle();

      expect(find.text('Invalid email or password'), findsOneWidget);
    });

    testWidgets('Navigates to RegisterScreen when Sign Up link is tapped', (tester) async {
      await tester.pumpWidget(_wrapAuthScreen(const LoginScreen(), authProvider));

      await tester.ensureVisible(find.byKey(const Key('login_signup_link')));
      await tester.tap(find.byKey(const Key('login_signup_link')));
      await tester.pumpAndSettle();

      expect(find.byType(RegisterScreen), findsOneWidget);
      expect(find.byKey(const Key('register_submit_button')), findsOneWidget);
    });

    testWidgets('Navigates to ForgotPasswordScreen when Forgot Password link is tapped', (tester) async {
      await tester.pumpWidget(_wrapAuthScreen(const LoginScreen(), authProvider));

      await tester.tap(find.text('Forgot Password?'));
      await tester.pumpAndSettle();

      expect(find.byType(ForgotPasswordScreen), findsOneWidget);
      expect(find.text('Forgot Password'), findsOneWidget);
    });
  });

  group('RegisterScreen Widget Tests', () {
    testWidgets('Renders all initial UI elements correctly', (tester) async {
      await tester.pumpWidget(_wrapAuthScreen(const RegisterScreen(), authProvider));

      expect(find.text('Create Account'), findsNWidgets(2)); // Title header + PrimaryButton text
      expect(find.byKey(const Key('register_name_field')), findsOneWidget);
      expect(find.byKey(const Key('register_email_field')), findsOneWidget);
      expect(find.byKey(const Key('register_password_field')), findsOneWidget);
      expect(find.byKey(const Key('register_confirm_password_field')), findsOneWidget);
      expect(find.byKey(const Key('register_submit_button')), findsOneWidget);
      expect(find.byKey(const Key('register_login_link')), findsOneWidget);
    });

    testWidgets('Validates short name and mismatched passwords', (tester) async {
      await tester.pumpWidget(_wrapAuthScreen(const RegisterScreen(), authProvider));

      // Enter short name and mismatched passwords
      await tester.enterText(find.byKey(const Key('register_name_field')), 'A');
      await tester.enterText(find.byKey(const Key('register_email_field')), 'new@example.com');
      await tester.enterText(find.byKey(const Key('register_password_field')), 'Secret@123');
      await tester.enterText(find.byKey(const Key('register_confirm_password_field')), 'Different@123');

      await tester.ensureVisible(find.byKey(const Key('register_submit_button')));
      await tester.tap(find.byKey(const Key('register_submit_button')));
      await tester.pump();

      expect(find.text('Name must be at least 2 characters'), findsOneWidget);
      expect(find.text('Passwords do not match'), findsOneWidget);
      expect(fakeService.registerCalls, 0);
    });

    testWidgets('Valid submission calls AuthProvider.register', (tester) async {
      await tester.pumpWidget(_wrapAuthScreen(const RegisterScreen(), authProvider));

      await tester.enterText(find.byKey(const Key('register_name_field')), 'Jane Doe');
      await tester.enterText(find.byKey(const Key('register_email_field')), 'jane@example.com');
      await tester.enterText(find.byKey(const Key('register_password_field')), 'Secure@Pass123');
      await tester.enterText(find.byKey(const Key('register_confirm_password_field')), 'Secure@Pass123');

      await tester.ensureVisible(find.byKey(const Key('register_submit_button')));
      await tester.tap(find.byKey(const Key('register_submit_button')));
      await tester.pump();

      expect(fakeService.registerCalls, 1);
      expect(fakeService.lastRegisterName, 'Jane Doe');
      expect(fakeService.lastRegisterEmail, 'jane@example.com');
      expect(fakeService.lastRegisterPassword, 'Secure@Pass123');
    });

    testWidgets('Renders error banner on duplicate registration error', (tester) async {
      fakeService.errorToThrow = ApiException('User with this email already exists', statusCode: 409);

      await tester.pumpWidget(_wrapAuthScreen(const RegisterScreen(), authProvider));

      await tester.enterText(find.byKey(const Key('register_name_field')), 'Jane Doe');
      await tester.enterText(find.byKey(const Key('register_email_field')), 'existing@example.com');
      await tester.enterText(find.byKey(const Key('register_password_field')), 'Secure@Pass123');
      await tester.enterText(find.byKey(const Key('register_confirm_password_field')), 'Secure@Pass123');

      await tester.ensureVisible(find.byKey(const Key('register_submit_button')));
      await tester.tap(find.byKey(const Key('register_submit_button')));
      await tester.pumpAndSettle();

      expect(find.text('User with this email already exists'), findsOneWidget);
    });

    testWidgets('Tapping Log In link pops screen', (tester) async {
      // Simulate pushing RegisterScreen from a root Navigator
      await tester.pumpWidget(
        ChangeNotifierProvider<AuthProvider>.value(
          value: authProvider,
          child: MaterialApp(
            theme: AppTheme.light,
            home: Builder(
              builder: (ctx) => Scaffold(
                body: ElevatedButton(
                  onPressed: () => Navigator.of(ctx).push(
                    MaterialPageRoute(builder: (_) => const RegisterScreen()),
                  ),
                  child: const Text('Go to Register'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Go to Register'));
      await tester.pumpAndSettle();
      expect(find.byType(RegisterScreen), findsOneWidget);

      await tester.ensureVisible(find.byKey(const Key('register_login_link')));
      await tester.tap(find.byKey(const Key('register_login_link')));
      await tester.pumpAndSettle();
      expect(find.byType(RegisterScreen), findsNothing);
    });
  });

  group('ForgotPasswordScreen Widget Tests', () {
    testWidgets('Renders all initial UI elements correctly', (tester) async {
      await tester.pumpWidget(_wrapAuthScreen(const ForgotPasswordScreen(), authProvider));

      expect(find.text('Forgot Password'), findsOneWidget);
      expect(find.byKey(const Key('forgot_password_email_field')), findsOneWidget);
      expect(find.byKey(const Key('forgot_password_submit_button')), findsOneWidget);
      expect(find.text('Send Code'), findsOneWidget);
      expect(find.byKey(const Key('forgot_password_back_button')), findsOneWidget);
    });

    testWidgets('Validates email field', (tester) async {
      await tester.pumpWidget(_wrapAuthScreen(const ForgotPasswordScreen(), authProvider));

      await tester.tap(find.byKey(const Key('forgot_password_submit_button')));
      await tester.pump();
      expect(find.text('Please enter your email'), findsOneWidget);

      await tester.enterText(find.byKey(const Key('forgot_password_email_field')), 'invalid');
      await tester.tap(find.byKey(const Key('forgot_password_submit_button')));
      await tester.pump();
      expect(find.text('Please enter a valid email address'), findsOneWidget);
      expect(find.byType(OtpVerificationScreen), findsNothing);
    });

    testWidgets('Valid email requests a code and opens the OTP screen', (tester) async {
      final reset = PasswordResetProvider();
      await tester.pumpWidget(_wrapAuthScreen(const ForgotPasswordScreen(), authProvider, reset));

      await tester.enterText(find.byKey(const Key('forgot_password_email_field')), 'reset@example.com');
      await tester.tap(find.byKey(const Key('forgot_password_submit_button')));
      await tester.pumpAndSettle();

      expect(reset.email, 'reset@example.com');
      expect(find.byType(OtpVerificationScreen), findsOneWidget);
      expect(find.byKey(const Key('otp_dev_banner')), findsOneWidget);
    });

    testWidgets('Failed code request shows an error and stays on the screen', (tester) async {
      await tester.pumpWidget(_wrapAuthScreen(const ForgotPasswordScreen(), authProvider));

      await tester.enterText(find.byKey(const Key('forgot_password_email_field')), 'fail@example.com');
      await tester.tap(find.byKey(const Key('forgot_password_submit_button')));
      await tester.pumpAndSettle();

      expect(find.textContaining('Unable to send a verification code'), findsOneWidget);
      expect(find.byType(OtpVerificationScreen), findsNothing);
      expect(find.byType(ForgotPasswordScreen), findsOneWidget);
    });
  });
}
