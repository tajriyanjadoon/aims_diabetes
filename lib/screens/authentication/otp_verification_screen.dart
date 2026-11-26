import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/validators.dart';
import '../../providers/password_reset_provider.dart';
import '../../widgets/common/app_text_field.dart';
import '../../widgets/common/brand_header.dart';
import '../../widgets/common/message_banner.dart';
import '../../widgets/common/primary_button.dart';
import 'reset_password_screen.dart';

/// Step 2 of the password-reset flow: the user enters the 6-digit code.
///
/// While a development service is active, a clearly marked "development only"
/// banner shows the fixed OTP. No email or SMS is ever sent.
class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final navigator = Navigator.of(context);
    final ok =
        await context.read<PasswordResetProvider>().verifyOtp(_otpController.text);
    if (ok && mounted) {
      navigator.push(
        MaterialPageRoute(builder: (_) => const ResetPasswordScreen()),
      );
    }
  }

  Future<void> _resend() async {
    final messenger = ScaffoldMessenger.of(context);
    final ok = await context.read<PasswordResetProvider>().resendOtp();
    if (ok && mounted) {
      messenger.showSnackBar(
        const SnackBar(content: Text('A new verification code has been sent.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final reset = context.watch<PasswordResetProvider>();
    final devOtp = reset.developmentOtpHint;

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
                  const BrandHeader(key: Key('otp_logo')),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'Verify Your Email',
                    style: AppTextStyles.h1.copyWith(color: colors.textPrimary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Enter the 6-digit verification code for ${reset.email ?? 'your account'}.',
                    style: AppTextStyles.bodyDefault
                        .copyWith(color: colors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  if (devOtp != null) ...[
                    MessageBanner(
                      key: const Key('otp_dev_banner'),
                      type: MessageBannerType.warning,
                      message:
                          'DEVELOPMENT ONLY: no email or SMS is sent. Use the fixed code $devOtp. This will be removed when real OTP delivery is added.',
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],
                  if (reset.errorMessage != null) ...[
                    MessageBanner(
                      message: reset.errorMessage!,
                      type: MessageBannerType.error,
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],
                  AppTextField(
                    key: const Key('otp_field'),
                    label: 'Verification Code',
                    hintText: '000000',
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    textAlign: TextAlign.center,
                    maxLength: AppValidators.otpLength,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    textStyle: AppTextStyles.h2.copyWith(
                      color: colors.textPrimary,
                      letterSpacing: 8,
                    ),
                    validator: AppValidators.otp,
                    onSubmitted: (_) => _verify(),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  PrimaryButton(
                    key: const Key('otp_verify_button'),
                    text: 'Verify Code',
                    isLoading: reset.isLoading,
                    onPressed: _verify,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Center(
                    child: TextButton(
                      key: const Key('otp_resend_button'),
                      onPressed: reset.isLoading ? null : _resend,
                      child: Text(
                        'Resend Code',
                        style: AppTextStyles.labelStrong
                            .copyWith(color: colors.textBrand),
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
