import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/validators.dart';
import '../../providers/password_reset_provider.dart';
import '../../widgets/common/app_text_field.dart';
import '../../widgets/common/brand_header.dart';
import '../../widgets/common/message_banner.dart';
import '../../widgets/common/password_requirements_text.dart';
import '../../widgets/common/primary_button.dart';
import 'password_reset_success_screen.dart';

/// Step 3 of the password-reset flow: choose and confirm a new password.
class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final navigator = Navigator.of(context);
    final ok = await context
        .read<PasswordResetProvider>()
        .resetPassword(_passwordController.text);
    if (ok && mounted) {
      // Replace the whole reset flow with the success screen; only the
      // root (AuthGate -> LoginScreen) stays underneath.
      navigator.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const PasswordResetSuccessScreen()),
        (route) => route.isFirst,
      );
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
            context.read<PasswordResetProvider>().clearError();
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
                  const BrandHeader(key: Key('reset_password_logo')),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'Create New Password',
                    style: AppTextStyles.h1.copyWith(color: colors.textPrimary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Choose a strong password you have not used before.',
                    style: AppTextStyles.bodyDefault
                        .copyWith(color: colors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Consumer<PasswordResetProvider>(
                    builder: (context, reset, _) {
                      if (reset.errorMessage == null) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: MessageBanner(
                          message: reset.errorMessage!,
                          type: MessageBannerType.error,
                        ),
                      );
                    },
                  ),
                  AppTextField(
                    key: const Key('reset_new_password_field'),
                    label: 'New Password',
                    hintText: 'Enter a new password',
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
                    key: Key('reset_password_requirements'),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppTextField(
                    key: const Key('reset_confirm_password_field'),
                    label: 'Confirm New Password',
                    hintText: 'Re-enter your new password',
                    controller: _confirmController,
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
                    onSubmitted: (_) => _submit(),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Consumer<PasswordResetProvider>(
                    builder: (context, reset, _) => PrimaryButton(
                      key: const Key('reset_submit_button'),
                      text: 'Reset Password',
                      isLoading: reset.isLoading,
                      onPressed: _submit,
                    ),
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
