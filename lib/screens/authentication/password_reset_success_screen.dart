import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../widgets/common/primary_button.dart';

/// Final step of the password-reset flow: confirms success and returns the
/// user to the Login screen (the root route managed by AuthGate).
class PasswordResetSuccessScreen extends StatelessWidget {
  const PasswordResetSuccessScreen({super.key});

  void _backToLogin(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    // The system back button also returns to Login instead of re-entering
    // the (already completed) reset flow.
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _backToLogin(context);
      },
      child: Scaffold(
        backgroundColor: colors.bgApp,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        color: colors.successSubtle,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check_rounded,
                        size: 56,
                        color: colors.successText,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    'Password Reset Successful',
                    key: const Key('reset_success_title'),
                    style: AppTextStyles.h1.copyWith(color: colors.textPrimary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Your password has been updated. You can now log in with your new password.',
                    style: AppTextStyles.bodyDefault
                        .copyWith(color: colors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  PrimaryButton(
                    key: const Key('reset_success_login_button'),
                    text: 'Back to Login',
                    onPressed: () => _backToLogin(context),
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
