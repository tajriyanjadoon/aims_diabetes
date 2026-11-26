import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/app_text_field.dart';
import '../../widgets/common/brand_header.dart';
import '../../widgets/common/message_banner.dart';
import '../../widgets/common/primary_button.dart';
import 'forgot_password_screen.dart';
import 'register_screen.dart';

/// Screen S01: Login Screen for AIMS-Diabetes.
///
/// Implements the official Figma auth flow:
/// - Stacked brand logo lockup.
/// - Welcome headline and subheader.
/// - Form validation for email and password.
/// - Integrated password visibility toggle.
/// - Direct connection to [AuthProvider] for login actions.
/// - Inline error banner reflecting API error messages.
/// - Navigation to [RegisterScreen] and [ForgotPasswordScreen].
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin(BuildContext context) async {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState?.validate() ?? false) {
      final auth = context.read<AuthProvider>();
      await auth.login(
        email: _emailController.text,
        password: _passwordController.text,
      );
    }
  }

  Future<void> _navigateToRegister(BuildContext context) async {
    context.read<AuthProvider>().clearMessages();
    // RegisterScreen pops with the newly registered email on success.
    final registeredEmail = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const RegisterScreen()),
    );
    if (registeredEmail != null && mounted) {
      _emailController.text = registeredEmail;
      _passwordController.clear();
    }
  }

  void _navigateToForgotPassword(BuildContext context) {
    context.read<AuthProvider>().clearMessages();
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Scaffold(
      backgroundColor: colors.bgApp,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.lg,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Brand Header ───────────────────────────────────────────
                  const BrandHeader(key: Key('login_logo')),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'Welcome Back',
                    style: AppTextStyles.h1.copyWith(color: colors.textPrimary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Sign in to manage your diabetes with AIMSD',
                    style: AppTextStyles.bodyDefault.copyWith(color: colors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // ── Registration Success Banner ───────────────────────────
                  Consumer<AuthProvider>(
                    builder: (context, auth, _) {
                      if (auth.successMessage == null) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: MessageBanner(
                          key: const Key('login_success_banner'),
                          message: auth.successMessage!,
                          type: MessageBannerType.success,
                        ),
                      );
                    },
                  ),

                  // ── API Error Banner ──────────────────────────────────────
                  Consumer<AuthProvider>(
                    builder: (context, auth, _) {
                      if (auth.errorMessage == null) {
                        return const SizedBox.shrink();
                      }
                      return Container(
                        margin: const EdgeInsets.only(bottom: AppSpacing.md),
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: colors.dangerSubtle,
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                          border: Border.all(
                            color: colors.dangerFill.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 20,
                              color: colors.dangerText,
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Expanded(
                              child: Text(
                                auth.errorMessage!,
                                style: AppTextStyles.bodyDefault.copyWith(
                                  color: colors.dangerText,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  // ── Form Fields ───────────────────────────────────────────
                  AppTextField(
                    key: const Key('login_email_field'),
                    label: 'Email',
                    hintText: 'Enter your email',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    prefixIcon: Icon(
                      Icons.mail_outline,
                      size: 20,
                      color: colors.textSecondary,
                    ),
                    validator: AppValidators.email,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppTextField(
                    key: const Key('login_password_field'),
                    label: 'Password',
                    hintText: 'Enter your password',
                    controller: _passwordController,
                    isPassword: true,
                    textInputAction: TextInputAction.done,
                    prefixIcon: Icon(
                      Icons.lock_outline,
                      size: 20,
                      color: colors.textSecondary,
                    ),
                    validator: AppValidators.loginPassword,
                    onSubmitted: (_) => _handleLogin(context),
                  ),

                  // ── Forgot Password Link ──────────────────────────────────
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => _navigateToForgotPassword(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.xs,
                          horizontal: AppSpacing.xxs,
                        ),
                      ),
                      child: Text(
                        'Forgot Password?',
                        style: AppTextStyles.labelStrong.copyWith(
                          color: colors.textBrand,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  // ── Action Button ─────────────────────────────────────────
                  Consumer<AuthProvider>(
                    builder: (context, auth, _) => PrimaryButton(
                      key: const Key('login_submit_button'),
                      text: 'Log In',
                      isLoading: auth.isLoading,
                      onPressed: () => _handleLogin(context),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // ── Sign Up Footer ────────────────────────────────────────
                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: AppTextStyles.bodyDefault.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                      GestureDetector(
                        key: const Key('login_signup_link'),
                        onTap: () => _navigateToRegister(context),
                        child: Text(
                          'Sign Up',
                          style: AppTextStyles.labelStrong.copyWith(
                            color: colors.textBrand,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
