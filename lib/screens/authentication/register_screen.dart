import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/app_text_field.dart';
import '../../widgets/common/brand_header.dart';
import '../../widgets/common/password_requirements_text.dart';
import '../../widgets/common/primary_button.dart';

/// Screen: User Registration Screen for AIMS-Diabetes.
///
/// Implements user registration against FastAPI `/api/v1/auth/register`:
/// - Stacked brand logo lockup.
/// - Full Name, Email, Password, and Confirm Password fields.
/// - Real-time and on-submit form validation.
/// - Direct connection to [AuthProvider.register].
/// - Inline error banner reflecting API error messages.
/// - Quick navigation back to Login.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister(BuildContext context) async {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState?.validate() ?? false) {
      final navigator = Navigator.of(context);
      final auth = context.read<AuthProvider>();
      final success = await auth.register(
        name: _nameController.text,
        email: _emailController.text,
        password: _passwordController.text,
      );
      // Registration only creates the account (it does not sign the user in).
      // Return to the Login screen, passing back the email so it can be
      // pre-filled; the provider's success message is shown there.
      // On failure we stay here and the error banner is shown.
      if (success && mounted && navigator.canPop()) {
        navigator.pop(_emailController.text.trim());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Scaffold(
      backgroundColor: colors.bgApp,
      appBar: AppBar(
        leading: BackButton(
          color: colors.textPrimary,
          onPressed: () {
            context.read<AuthProvider>().clearError();
            Navigator.of(context).pop();
          },
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.md,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Brand Header ───────────────────────────────────────────
                  const BrandHeader(key: Key('register_logo')),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'Create Account',
                    style: AppTextStyles.h1.copyWith(color: colors.textPrimary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Join AIMSD to track and manage your health',
                    style: AppTextStyles.bodyDefault.copyWith(color: colors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xl),

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
                    key: const Key('register_name_field'),
                    label: 'Full Name',
                    hintText: 'Enter your full name',
                    controller: _nameController,
                    textInputAction: TextInputAction.next,
                    prefixIcon: Icon(
                      Icons.person_outline,
                      size: 20,
                      color: colors.textSecondary,
                    ),
                    validator: AppValidators.fullName,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppTextField(
                    key: const Key('register_email_field'),
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
                    key: const Key('register_password_field'),
                    label: 'Password',
                    hintText: 'Create a password',
                    controller: _passwordController,
                    isPassword: true,
                    textInputAction: TextInputAction.next,
                    prefixIcon: Icon(
                      Icons.lock_outline,
                      size: 20,
                      color: colors.textSecondary,
                    ),
                    validator: AppValidators.newPassword,
                  ),
                  const PasswordRequirementsText(
                    key: Key('register_password_requirements'),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppTextField(
                    key: const Key('register_confirm_password_field'),
                    label: 'Confirm Password',
                    hintText: 'Re-enter your password',
                    controller: _confirmPasswordController,
                    isPassword: true,
                    textInputAction: TextInputAction.done,
                    prefixIcon: Icon(
                      Icons.lock_outline,
                      size: 20,
                      color: colors.textSecondary,
                    ),
                    validator: (value) => AppValidators.confirmPassword(
                      value,
                      _passwordController.text,
                    ),
                    onSubmitted: (_) => _handleRegister(context),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // ── Action Button ─────────────────────────────────────────
                  Consumer<AuthProvider>(
                    builder: (context, auth, _) => PrimaryButton(
                      key: const Key('register_submit_button'),
                      text: 'Create Account',
                      isLoading: auth.isLoading,
                      onPressed: () => _handleRegister(context),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // ── Login Footer ──────────────────────────────────────────
                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: AppTextStyles.bodyDefault.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                      GestureDetector(
                        key: const Key('register_login_link'),
                        onTap: () {
                          context.read<AuthProvider>().clearError();
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          'Log In',
                          style: AppTextStyles.labelStrong.copyWith(
                            color: colors.textBrand,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
