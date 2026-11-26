import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/validators.dart';
import '../../providers/password_reset_provider.dart';
import '../../widgets/common/app_text_field.dart';
import '../../widgets/common/brand_header.dart';
import '../../widgets/common/message_banner.dart';
import '../../widgets/common/primary_button.dart';
import 'otp_verification_screen.dart';

/// Step 1 of the password-reset flow: the user enters their email and a
/// verification code is requested through [PasswordResetProvider].
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Starting this screen always starts a fresh reset flow (silent: no
    // notification while the widget tree is building).
    context.read<PasswordResetProvider>().reset(notify: false);
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final navigator = Navigator.of(context);
    final ok = await context
        .read<PasswordResetProvider>()
        .requestOtp(_emailController.text);
    if (ok && mounted) {
      navigator.push(
        MaterialPageRoute(builder: (_) => const OtpVerificationScreen()),
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
            context.read<PasswordResetProvider>().reset();
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
                  const BrandHeader(key: Key('forgot_password_logo')),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'Forgot Password',
                    style: AppTextStyles.h1.copyWith(color: colors.textPrimary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Enter the email address linked to your AIMSD account and we will send you a 6-digit verification code.',
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
                    key: const Key('forgot_password_email_field'),
                    label: 'Email',
                    hintText: 'Enter your email',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    prefixIcon: Icon(
                      Icons.mail_outline,
                      size: 20,
                      color: colors.textSecondary,
                    ),
                    validator: AppValidators.email,
                    onSubmitted: (_) => _submit(),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Consumer<PasswordResetProvider>(
                    builder: (context, reset, _) => PrimaryButton(
                      key: const Key('forgot_password_submit_button'),
                      text: 'Send Code',
                      isLoading: reset.isLoading,
                      onPressed: _submit,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Center(
                    child: TextButton.icon(
                      key: const Key('forgot_password_back_button'),
                      onPressed: () {
                        context.read<PasswordResetProvider>().reset();
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.arrow_back, size: 18),
                      label: const Text('Back to Login'),
                      style: TextButton.styleFrom(
                        foregroundColor: colors.textBrand,
                        textStyle: AppTextStyles.labelStrong,
                      ),
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
