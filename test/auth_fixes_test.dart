import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:aims_diabetes/core/dummy_data/dummy_user.dart';
import 'package:aims_diabetes/core/network/api_exception.dart';
import 'package:aims_diabetes/core/routes/auth_gate.dart';
import 'package:aims_diabetes/core/theme/app_theme.dart';
import 'package:aims_diabetes/core/utils/validators.dart';
import 'package:aims_diabetes/main.dart';
import 'package:aims_diabetes/providers/auth_provider.dart';
import 'package:aims_diabetes/providers/password_reset_provider.dart';
import 'package:aims_diabetes/screens/authentication/forgot_password_screen.dart';
import 'package:aims_diabetes/screens/authentication/login_screen.dart';
import 'package:aims_diabetes/screens/authentication/otp_verification_screen.dart';
import 'package:aims_diabetes/screens/authentication/password_reset_success_screen.dart';
import 'package:aims_diabetes/screens/authentication/register_screen.dart';
import 'package:aims_diabetes/screens/authentication/reset_password_screen.dart';
import 'package:aims_diabetes/services/mock_password_reset_service.dart';
import 'package:aims_diabetes/widgets/common/app_logo.dart';
import 'package:aims_diabetes/widgets/common/brand_header.dart';

// ── Helpers ────────────────────────────────────────────────────────────────

Future<void> _setScreen(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

/// Boots the real app (MockAuthService + MockPasswordResetService) on a
/// phone-sized surface and waits for the AuthGate to show the Login screen.
Future<void> _pumpApp(WidgetTester tester, {Size size = const Size(400, 900)}) async {
  await _setScreen(tester, size);
  await tester.pumpWidget(const MyApp());
  await tester.pumpAndSettle();
}

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

AuthProvider _auth(WidgetTester tester) =>
    Provider.of<AuthProvider>(tester.element(find.byType(MaterialApp)), listen: false);

Finder _editable(Key key) =>
    find.descendant(of: find.byKey(key), matching: find.byType(EditableText));

/// The [AppLogo] rendered inside an [AuthLogo] identified by [key].
Finder _appLogoIn(Key key) =>
    find.descendant(of: find.byKey(key), matching: find.byType(AppLogo));

bool _isObscured(WidgetTester tester, Key key) =>
    tester.widget<EditableText>(_editable(key)).obscureText;

String _fieldText(WidgetTester tester, Key key) =>
    tester.widget<EditableText>(_editable(key)).controller.text;

Future<void> _toggleVisibility(WidgetTester tester, Key key) async {
  final button = find.descendant(of: find.byKey(key), matching: find.byType(IconButton));
  await tester.ensureVisible(button);
  await tester.tap(button);
  await tester.pump();
}

const String _strongPassword = 'Tajriyan@2026';

Future<void> _openRegister(WidgetTester tester) async {
  await _tap(tester, find.byKey(const Key('login_signup_link')));
  expect(find.byType(RegisterScreen), findsOneWidget);
}

Future<void> _fillRegister(
  WidgetTester tester, {
  String name = 'Jane Doe',
  String email = 'jane@example.com',
  String password = _strongPassword,
  String? confirm,
}) async {
  await tester.enterText(find.byKey(const Key('register_name_field')), name);
  await tester.enterText(find.byKey(const Key('register_email_field')), email);
  await tester.enterText(find.byKey(const Key('register_password_field')), password);
  await tester.enterText(
    find.byKey(const Key('register_confirm_password_field')),
    confirm ?? password,
  );
}

Future<void> _submitRegister(WidgetTester tester) =>
    _tap(tester, find.byKey(const Key('register_submit_button')));

Future<void> _login(WidgetTester tester, String email, String password) async {
  await tester.enterText(find.byKey(const Key('login_email_field')), email);
  await tester.enterText(find.byKey(const Key('login_password_field')), password);
  await _tap(tester, find.byKey(const Key('login_submit_button')));
}

Future<void> _openForgotPassword(WidgetTester tester) async {
  await _tap(tester, find.text('Forgot Password?'));
  expect(find.byType(ForgotPasswordScreen), findsOneWidget);
}

Future<void> _requestCode(WidgetTester tester, String email) async {
  await tester.enterText(find.byKey(const Key('forgot_password_email_field')), email);
  await _tap(tester, find.byKey(const Key('forgot_password_submit_button')));
}

Future<void> _reachResetScreen(WidgetTester tester) async {
  await _openForgotPassword(tester);
  await _requestCode(tester, 'patient@example.com');
  await tester.enterText(find.byKey(const Key('otp_field')), '123456');
  await _tap(tester, find.byKey(const Key('otp_verify_button')));
  expect(find.byType(ResetPasswordScreen), findsOneWidget);
}

/// Physical phone viewports (logical pixels).
const List<Size> _phoneSizes = <Size>[
  Size(320, 568), // iPhone SE (1st gen) - smallest supported
  Size(360, 640), // common small Android
  Size(375, 667), // iPhone 8 / SE 2nd gen
  Size(390, 844), // iPhone 13/14
  Size(411, 731), // Pixel-class
  Size(412, 915), // modern large Android
];

void main() {
  // ══════════════════════════════════════════════════════════════════════════
  // 1. SIGN UP -> LOGIN -> DASHBOARD
  // ══════════════════════════════════════════════════════════════════════════
  group('Sign up navigation', () {
    testWidgets('Registration redirects to Login with a success message', (tester) async {
      await _pumpApp(tester);
      await _openRegister(tester);
      await _fillRegister(tester, email: 'new.user@example.com');
      await _submitRegister(tester);

      expect(find.byType(RegisterScreen), findsNothing);
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.byType(AuthenticatedPlaceholderScreen), findsNothing);

      expect(find.byKey(const Key('login_success_banner')), findsOneWidget);
      expect(find.text(AuthProvider.registrationSuccessMessage), findsOneWidget);

      // Email is pre-filled, password is left empty.
      expect(_fieldText(tester, const Key('login_email_field')), 'new.user@example.com');
      expect(_fieldText(tester, const Key('login_password_field')), isEmpty);

      final navigator = tester.state<NavigatorState>(find.byType(Navigator).first);
      expect(navigator.canPop(), isFalse);
    });

    testWidgets('Registration does not authenticate the user', (tester) async {
      await _pumpApp(tester);
      await _openRegister(tester);
      await _fillRegister(tester);
      await _submitRegister(tester);

      final auth = _auth(tester);
      expect(auth.isAuthenticated, isFalse);
      expect(auth.currentUser, isNull);
      expect(find.byType(AuthenticatedPlaceholderScreen), findsNothing);
    });

    testWidgets('Newly registered credentials log in and open the Dashboard', (tester) async {
      await _pumpApp(tester);
      await _openRegister(tester);
      await _fillRegister(tester, name: 'Tajriyan Khan', email: 'tajriyan@example.com');
      await _submitRegister(tester);

      await _login(tester, 'tajriyan@example.com', _strongPassword);

      expect(_auth(tester).isAuthenticated, isTrue);
      expect(find.byType(LoginScreen), findsNothing);
      expect(find.byType(AuthenticatedPlaceholderScreen), findsOneWidget);
      expect(find.text('Welcome, Tajriyan Khan!'), findsOneWidget);
    });

    testWidgets('Incorrect password for a registered account shows an error', (tester) async {
      await _pumpApp(tester);
      await _openRegister(tester);
      await _fillRegister(tester, email: 'jane@example.com');
      await _submitRegister(tester);

      await _login(tester, 'jane@example.com', 'Wrong@2026');

      expect(find.text('Incorrect email or password.'), findsOneWidget);
      expect(find.byKey(const Key('login_success_banner')), findsNothing);
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(_auth(tester).isAuthenticated, isFalse);
    });

    testWidgets('Unknown account shows an error', (tester) async {
      await _pumpApp(tester);
      await _login(tester, 'nobody@example.com', _strongPassword);

      expect(find.text('Incorrect email or password.'), findsOneWidget);
      expect(find.byType(AuthenticatedPlaceholderScreen), findsNothing);
    });

    testWidgets('Duplicate registration stays on Sign Up and shows the error', (tester) async {
      await _pumpApp(tester);
      await _openRegister(tester);
      await _fillRegister(tester, email: 'sara@example.com'); // seeded demo account
      await _submitRegister(tester);

      expect(find.byType(RegisterScreen), findsOneWidget);
      expect(find.text('User with this email already exists'), findsOneWidget);
      expect(_auth(tester).successMessage, isNull);
    });

    testWidgets('Demo account still works, and logout returns to Login', (tester) async {
      await _pumpApp(tester);
      await _login(tester, 'sara@example.com', dummyUserPassword);
      expect(find.byType(AuthenticatedPlaceholderScreen), findsOneWidget);

      await _tap(tester, find.byKey(const Key('auth_placeholder_logout_button')));
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.byType(AuthenticatedPlaceholderScreen), findsNothing);
    });

    testWidgets('Login accepts a stored password without re-applying the policy', (tester) async {
      await _pumpApp(tester);
      // The demo password is checked only for equality at login.
      await tester.enterText(find.byKey(const Key('login_email_field')), 'sara@example.com');
      await tester.enterText(find.byKey(const Key('login_password_field')), 'x');
      await _tap(tester, find.byKey(const Key('login_submit_button')));
      // Short password is NOT rejected by a policy message, only by credentials.
      expect(find.text(AppValidators.passwordTooShort), findsNothing);
      expect(find.text('Incorrect email or password.'), findsOneWidget);
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  // 2. BRAND HEADER & LOGO SIZE (Login, Sign Up, Forgot Password + Light/Dark)
  // ══════════════════════════════════════════════════════════════════════════
  group('Auth BrandHeader & AIMSD branding', () {
    test('iconSizeFor: clamps, caps by width, and scales with height', () {
      expect(BrandHeader.iconSizeFor(const Size(360, 400)), BrandHeader.minIconSize);
      expect(BrandHeader.iconSizeFor(const Size(400, 1400)), BrandHeader.maxIconSize);
      expect(BrandHeader.iconSizeFor(const Size(768, 1024)), BrandHeader.maxIconSize);
      expect(
        BrandHeader.iconSizeFor(const Size(120, 900)),
        120 - BrandHeader.horizontalPadding,
      );
      expect(BrandHeader.iconSizeFor(const Size(390, 844)), closeTo(109.72, 0.1));
    });

    for (final size in _phoneSizes) {
      final label = '${size.width.toInt()}x${size.height.toInt()}';

      testWidgets('Login, Sign Up, and Forgot Password share BrandHeader at $label', (tester) async {
        await _pumpApp(tester, size: size);
        final expected = BrandHeader.iconSizeFor(size);

        // ── Login ──
        final loginFinder = _appLogoIn(const Key('login_logo'));
        final login = tester.widget<AppLogo>(loginFinder);
        expect(login.variant, AppLogoVariant.symbolOnly);
        expect(login.fit, BoxFit.contain);
        expect(login.height, expected);
        expect(login.width, expected);
        expect(tester.getSize(loginFinder), Size(expected, expected));
        expect(tester.getCenter(loginFinder).dx, closeTo(size.width / 2, 0.5));
        expect(find.descendant(of: find.byKey(const Key('login_logo')), matching: find.text('AIMSD')), findsOneWidget);
        expect(find.textContaining('AIMS-Diabetes'), findsNothing);
        expect(find.textContaining('DiaDoc AI'), findsNothing);
        expect(tester.takeException(), isNull);

        // ── Sign Up ──
        await _openRegister(tester);
        final registerFinder = _appLogoIn(const Key('register_logo'));
        final register = tester.widget<AppLogo>(registerFinder);
        expect(register.variant, AppLogoVariant.symbolOnly);
        expect(register.height, expected);
        expect(register.width, expected);
        expect(tester.getSize(registerFinder), Size(expected, expected));
        expect(tester.getCenter(registerFinder).dx, closeTo(size.width / 2, 0.5));
        expect(find.descendant(of: find.byKey(const Key('register_logo')), matching: find.text('AIMSD')), findsOneWidget);
        expect(find.textContaining('AIMS-Diabetes'), findsNothing);
        expect(tester.takeException(), isNull);

        // ── Forgot Password ──
        await tester.pageBack();
        await tester.pumpAndSettle();
        await _openForgotPassword(tester);
        final forgotFinder = _appLogoIn(const Key('forgot_password_logo'));
        final forgot = tester.widget<AppLogo>(forgotFinder);
        expect(forgot.variant, AppLogoVariant.symbolOnly);
        expect(forgot.height, expected);
        expect(forgot.width, expected);
        expect(tester.getCenter(forgotFinder).dx, closeTo(size.width / 2, 0.5));
        expect(find.descendant(of: find.byKey(const Key('forgot_password_logo')), matching: find.text('AIMSD')), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('BrandHeader text uses colorScheme.onSurface in both Light and Dark Mode', (tester) async {
      for (final theme in [AppTheme.light, AppTheme.dark]) {
        await tester.pumpWidget(
          MaterialApp(
            theme: theme,
            home: const Scaffold(body: BrandHeader()),
          ),
        );
        await tester.pumpAndSettle();

        final textFinder = find.text('AIMSD');
        expect(textFinder, findsOneWidget);

        final textWidget = tester.widget<Text>(textFinder);
        expect(textWidget.style?.color, theme.colorScheme.onSurface);
        // High-contrast against the scaffold background in both modes.
        expect(textWidget.style?.color, isNot(equals(theme.scaffoldBackgroundColor)));
      }
    });

    testWidgets('Sign Up BrandHeader sits below the app bar with spacing before the title', (tester) async {
      await _pumpApp(tester, size: const Size(360, 640));
      await _openRegister(tester);

      final headerRect = tester.getRect(find.byKey(const Key('register_logo')));
      final titleRect = tester.getRect(find.text('Create Account').first);
      final appBarRect = tester.getRect(find.byType(AppBar));

      expect(headerRect.top, greaterThanOrEqualTo(appBarRect.bottom));
      expect(titleRect.top - headerRect.bottom, greaterThanOrEqualTo(16));
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  // 3. PASSWORD REQUIREMENTS
  // ══════════════════════════════════════════════════════════════════════════
  group('Password validator', () {
    test('Examples from the specification', () {
      expect(AppValidators.newPassword('Tajriyan@2026'), isNull);
      expect(AppValidators.newPassword('tajriyan123'), AppValidators.passwordNeedsUppercase);
      expect(AppValidators.newPassword('TAJRIYAN@123'), AppValidators.passwordNeedsLowercase);
      expect(AppValidators.newPassword('Tajriyan@'), AppValidators.passwordNeedsDigit);
      expect(AppValidators.newPassword('Tajriyan123'), AppValidators.passwordNeedsSpecial);
    });

    test('Each rule is enforced individually', () {
      expect(AppValidators.newPassword(''), 'Please create a password');
      expect(AppValidators.newPassword(null), 'Please create a password');
      expect(AppValidators.newPassword('Ta@1'), AppValidators.passwordTooShort);
      expect(AppValidators.newPassword('Ta@1abc'), AppValidators.passwordTooShort); // 7 chars
      expect(AppValidators.newPassword('TA@1ABCD'), AppValidators.passwordNeedsLowercase);
      expect(AppValidators.newPassword('ta@1abcd'), AppValidators.passwordNeedsUppercase);
      expect(AppValidators.newPassword('Ta@Abcde'), AppValidators.passwordNeedsDigit);
      expect(AppValidators.newPassword('Ta1Abcde'), AppValidators.passwordNeedsSpecial);
      expect(AppValidators.newPassword('Ta@1abcd'), isNull); // exactly 8
    });

    test('Whitespace does not count as a special character', () {
      expect(AppValidators.newPassword('Tajriyan 2026'), AppValidators.passwordNeedsSpecial);
      expect(AppValidators.newPassword('Taj riyan@2026'), isNull);
    });

    test('Accepts a range of special characters', () {
      for (final c in r'@#$!%^&*()_+-=[]{};:,.<>/?|~`"\'.split('')) {
        expect(AppValidators.newPassword('Abcdef1$c'), isNull, reason: 'char "$c"');
      }
    });

    test('isStrongPassword mirrors newPassword', () {
      expect(AppValidators.isStrongPassword('Tajriyan@2026'), isTrue);
      expect(AppValidators.isStrongPassword('Tajriyan123'), isFalse);
    });

    test('Login password only needs to be non-empty', () {
      expect(AppValidators.loginPassword(''), 'Please enter your password');
      expect(AppValidators.loginPassword('x'), isNull);
      expect(AppValidators.loginPassword('tajriyan123'), isNull);
    });

    test('Confirm password and OTP validators', () {
      expect(AppValidators.confirmPassword('', 'abc'), 'Please confirm your password');
      expect(AppValidators.confirmPassword('abd', 'abc'), 'Passwords do not match');
      expect(AppValidators.confirmPassword('abc', 'abc'), isNull);
      expect(AppValidators.otp('12345a'), 'Code must be exactly 6 digits');
      expect(AppValidators.otp('123456'), isNull);
    });
  });

  group('Password requirements in forms', () {
    const invalid = <String, String>{
      'tajriyan123': AppValidators.passwordNeedsUppercase,
      'TAJRIYAN@123': AppValidators.passwordNeedsLowercase,
      'Tajriyan@': AppValidators.passwordNeedsDigit,
      'Tajriyan123': AppValidators.passwordNeedsSpecial,
      'Taj@1': AppValidators.passwordTooShort,
    };

    testWidgets('Sign Up rejects every invalid example and creates no account', (tester) async {
      await _pumpApp(tester);
      await _openRegister(tester);

      for (final entry in invalid.entries) {
        await _fillRegister(tester, email: 'weak@example.com', password: entry.key);
        await _submitRegister(tester);
        expect(find.text(entry.value), findsOneWidget, reason: entry.key);
        expect(find.byType(RegisterScreen), findsOneWidget);
      }
      expect(_auth(tester).successMessage, isNull);

      // The account was never created.
      await tester.pageBack();
      await tester.pumpAndSettle();
      await _login(tester, 'weak@example.com', 'Tajriyan123');
      expect(find.text('Incorrect email or password.'), findsOneWidget);
    });

    testWidgets('Sign Up accepts Tajriyan@2026', (tester) async {
      await _pumpApp(tester);
      await _openRegister(tester);
      await _fillRegister(tester, password: 'Tajriyan@2026');
      await _submitRegister(tester);
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.byKey(const Key('login_success_banner')), findsOneWidget);
    });

    testWidgets('Reset Password rejects every invalid example', (tester) async {
      await _pumpApp(tester);
      await _reachResetScreen(tester);

      for (final entry in invalid.entries) {
        await tester.enterText(find.byKey(const Key('reset_new_password_field')), entry.key);
        await tester.enterText(find.byKey(const Key('reset_confirm_password_field')), entry.key);
        await _tap(tester, find.byKey(const Key('reset_submit_button')));
        expect(find.text(entry.value), findsOneWidget, reason: entry.key);
        expect(find.byType(PasswordResetSuccessScreen), findsNothing);
      }
    });

    testWidgets('Password fields are obscured, toggleable and accept any characters', (tester) async {
      const specials = r'Aa1!@#$%^&*()_+-=[]{};:,.<>/?|~ x';
      await _pumpApp(tester);

      const loginPw = Key('login_password_field');
      expect(_isObscured(tester, loginPw), isTrue);
      await _toggleVisibility(tester, loginPw);
      expect(_isObscured(tester, loginPw), isFalse);
      await tester.enterText(find.byKey(loginPw), specials);
      expect(_fieldText(tester, loginPw), specials);

      await _openRegister(tester);
      const pw = Key('register_password_field');
      const confirm = Key('register_confirm_password_field');
      expect(_isObscured(tester, pw), isTrue);
      expect(_isObscured(tester, confirm), isTrue);
      await _toggleVisibility(tester, pw);
      expect(_isObscured(tester, pw), isFalse);
      expect(_isObscured(tester, confirm), isTrue);
      await tester.enterText(find.byKey(pw), specials);
      expect(_fieldText(tester, pw), specials);
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  // 4. PASSWORD HELPER TEXT FULLY VISIBLE
  // ══════════════════════════════════════════════════════════════════════════
  group('Password requirements text', () {
    test('Uses the exact required wording', () {
      expect(
        AppValidators.passwordRequirementsText,
        'Password must contain at least 8 characters, including one uppercase '
        'letter, one lowercase letter, one number, and one special character.',
      );
    });

    void expectFullyVisible(WidgetTester tester, Finder textFinder, Size screen) {
      expect(textFinder, findsOneWidget);
      final text = tester.widget<Text>(textFinder);
      expect(text.maxLines, isNull);
      expect(text.overflow, isNot(TextOverflow.ellipsis));
      expect(text.softWrap, isNot(false));

      final paragraph = tester.renderObject<RenderParagraph>(textFinder);
      expect(paragraph.didExceedMaxLines, isFalse);

      final rect = tester.getRect(textFinder);
      expect(rect.left, greaterThanOrEqualTo(0));
      expect(rect.right, lessThanOrEqualTo(screen.width));
      // Wraps onto several lines rather than being cut to one.
      expect(rect.height, greaterThan(18 * 1.5));
    }

    for (final size in [const Size(320, 568), const Size(360, 640), const Size(412, 915)]) {
      final label = '${size.width.toInt()}x${size.height.toInt()}';

      testWidgets('Fully visible on Sign Up at $label', (tester) async {
        await _pumpApp(tester, size: size);
        await _openRegister(tester);

        final finder = find.text(AppValidators.passwordRequirementsText);
        await tester.ensureVisible(finder);
        await tester.pumpAndSettle();
        expectFullyVisible(tester, finder, size);
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('Stays fully visible while a validation error is shown', (tester) async {
      const size = Size(320, 568);
      await _pumpApp(tester, size: size);
      await _openRegister(tester);
      await _fillRegister(tester, password: 'tajriyan123');
      await _submitRegister(tester);

      expect(find.text(AppValidators.passwordNeedsUppercase), findsOneWidget);
      final finder = find.text(AppValidators.passwordRequirementsText);
      await tester.ensureVisible(finder);
      await tester.pumpAndSettle();
      expectFullyVisible(tester, finder, size);

      // Error and requirements text do not overlap.
      final errorRect = tester.getRect(find.text(AppValidators.passwordNeedsUppercase));
      final reqRect = tester.getRect(finder);
      expect(errorRect.overlaps(reqRect), isFalse);
    });

    testWidgets('Fully visible on Reset Password at 320x568', (tester) async {
      const size = Size(320, 568);
      await _pumpApp(tester, size: size);
      await _reachResetScreen(tester);

      final finder = find.text(AppValidators.passwordRequirementsText);
      await tester.ensureVisible(finder);
      await tester.pumpAndSettle();
      expectFullyVisible(tester, finder, size);
      expect(tester.takeException(), isNull);
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  // Password reset (mock service, provider and full flow)
  // ══════════════════════════════════════════════════════════════════════════
  group('MockPasswordResetService', () {
    test('Exposes the fixed development OTP', () {
      expect(MockPasswordResetService.developmentOtp, '123456');
      expect(MockPasswordResetService().developmentOtpHint, '123456');
    });

    test('Full happy path works without any network', () async {
      final service = MockPasswordResetService();
      await service.requestOtp('  User@Example.com ');
      final token = await service.verifyOtp(email: 'user@example.com', otp: '123456');
      await service.resetPassword(email: 'USER@example.com', resetToken: token, newPassword: 'NewPass123!');
    });

    test('Rejects wrong OTP, missing request, bad token and weak password', () async {
      final service = MockPasswordResetService();
      expect(
        () => service.verifyOtp(email: 'nobody@example.com', otp: '123456'),
        throwsA(isA<ApiException>().having((e) => e.statusCode, 'status', 400)),
      );
      await service.requestOtp('user@example.com');
      expect(
        () => service.verifyOtp(email: 'user@example.com', otp: '000000'),
        throwsA(isA<ApiException>().having((e) => e.statusCode, 'status', 400)),
      );
      expect(
        () => service.resetPassword(email: 'user@example.com', resetToken: 'bogus', newPassword: 'NewPass123!'),
        throwsA(isA<ApiException>().having((e) => e.statusCode, 'status', 401)),
      );
      final token = await service.verifyOtp(email: 'user@example.com', otp: '123456');
      expect(
        () => service.resetPassword(email: 'user@example.com', resetToken: token, newPassword: 'Tajriyan123'),
        throwsA(isA<ApiException>()
            .having((e) => e.statusCode, 'status', 422)
            .having((e) => e.message, 'message', AppValidators.passwordNeedsSpecial)),
      );
    });

    test('Simulates a send failure for fail@example.com (500)', () {
      expect(
        () => MockPasswordResetService().requestOtp('fail@example.com'),
        throwsA(isA<ApiException>().having((e) => e.statusCode, 'status', 500)),
      );
    });
  });

  group('PasswordResetProvider', () {
    test('Walks through request -> verify -> reset and clears state', () async {
      final provider = PasswordResetProvider();
      expect(await provider.requestOtp(' me@example.com '), isTrue);
      expect(provider.email, 'me@example.com');
      expect(await provider.verifyOtp('123456'), isTrue);
      expect(provider.isOtpVerified, isTrue);
      expect(await provider.resetPassword('BrandNew@123'), isTrue);
      expect(provider.email, isNull);
      expect(provider.isOtpVerified, isFalse);
    });

    test('Wrong OTP sets an error and leaves the code unverified', () async {
      final provider = PasswordResetProvider();
      await provider.requestOtp('me@example.com');
      expect(await provider.verifyOtp('111111'), isFalse);
      expect(provider.errorMessage, 'Invalid verification code. Please try again.');
      expect(provider.isOtpVerified, isFalse);
    });

    test('Cannot verify before requesting, or reset before verifying', () async {
      final provider = PasswordResetProvider();
      expect(await provider.verifyOtp('123456'), isFalse);
      await provider.requestOtp('me@example.com');
      expect(await provider.resetPassword('BrandNew@123'), isFalse);
      expect(provider.errorMessage, 'Please verify your code first.');
    });

    test('A failed reset keeps the verified state so the user can retry', () async {
      final provider = PasswordResetProvider();
      await provider.requestOtp('me@example.com');
      await provider.verifyOtp('123456');
      expect(await provider.resetPassword('Tajriyan123'), isFalse);
      expect(provider.isOtpVerified, isTrue);
      expect(await provider.resetPassword('Strong@Pass1'), isTrue);
    });

    test('Resend and duplicate-submission guard', () async {
      final provider = PasswordResetProvider(
        MockPasswordResetService(simulatedDelay: const Duration(milliseconds: 20)),
      );
      expect(await provider.resendOtp(), isFalse);
      final first = provider.requestOtp('me@example.com');
      expect(await provider.requestOtp('me@example.com'), isFalse);
      expect(await first, isTrue);
      expect(await provider.resendOtp(), isTrue);
    });
  });

  group('Forgot password flow', () {
    testWidgets('OTP screen clearly marks the development OTP', (tester) async {
      await _pumpApp(tester);
      await _openForgotPassword(tester);
      await _requestCode(tester, 'patient@example.com');

      expect(find.byType(OtpVerificationScreen), findsOneWidget);
      expect(find.byKey(const Key('otp_dev_banner')), findsOneWidget);
      expect(find.textContaining('DEVELOPMENT ONLY'), findsOneWidget);
      expect(find.textContaining('123456'), findsOneWidget);
    });

    testWidgets('OTP field accepts digits only and at most six', (tester) async {
      await _pumpApp(tester);
      await _openForgotPassword(tester);
      await _requestCode(tester, 'patient@example.com');
      await tester.enterText(find.byKey(const Key('otp_field')), '1a2b3c4d5e6f789');
      expect(_fieldText(tester, const Key('otp_field')), '123456');
    });

    testWidgets('Wrong code keeps the user on the OTP screen', (tester) async {
      await _pumpApp(tester);
      await _openForgotPassword(tester);
      await _requestCode(tester, 'patient@example.com');

      await tester.enterText(find.byKey(const Key('otp_field')), '000000');
      await _tap(tester, find.byKey(const Key('otp_verify_button')));
      expect(find.text('Invalid verification code. Please try again.'), findsOneWidget);
      expect(find.byType(ResetPasswordScreen), findsNothing);
    });

    testWidgets('Reset screen validates confirmation match', (tester) async {
      await _pumpApp(tester);
      await _reachResetScreen(tester);

      await tester.enterText(find.byKey(const Key('reset_new_password_field')), 'NewPass@123');
      await tester.enterText(find.byKey(const Key('reset_confirm_password_field')), 'Different@123');
      await _tap(tester, find.byKey(const Key('reset_submit_button')));
      expect(find.text('Passwords do not match'), findsOneWidget);
      expect(find.byType(PasswordResetSuccessScreen), findsNothing);
    });

    testWidgets('Complete flow: email -> OTP -> new password -> success -> Login', (tester) async {
      await _pumpApp(tester);
      await _reachResetScreen(tester);

      await tester.enterText(find.byKey(const Key('reset_new_password_field')), r'N3w!Passw0rd#');
      await tester.enterText(find.byKey(const Key('reset_confirm_password_field')), r'N3w!Passw0rd#');
      await _tap(tester, find.byKey(const Key('reset_submit_button')));

      expect(find.byType(PasswordResetSuccessScreen), findsOneWidget);
      expect(find.byType(ResetPasswordScreen), findsNothing);
      expect(find.byType(OtpVerificationScreen), findsNothing);
      expect(find.byType(ForgotPasswordScreen), findsNothing);

      await _tap(tester, find.byKey(const Key('reset_success_login_button')));
      expect(find.byType(LoginScreen), findsOneWidget);
      final navigator = tester.state<NavigatorState>(find.byType(Navigator).first);
      expect(navigator.canPop(), isFalse);
    });

    testWidgets('System back on the success screen also returns to Login', (tester) async {
      await _pumpApp(tester);
      await _reachResetScreen(tester);
      await tester.enterText(find.byKey(const Key('reset_new_password_field')), 'NewPass@123');
      await tester.enterText(find.byKey(const Key('reset_confirm_password_field')), 'NewPass@123');
      await _tap(tester, find.byKey(const Key('reset_submit_button')));
      expect(find.byType(PasswordResetSuccessScreen), findsOneWidget);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byType(LoginScreen), findsOneWidget);
    });
  });
}
