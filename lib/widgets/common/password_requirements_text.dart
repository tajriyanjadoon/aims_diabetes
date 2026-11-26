import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/validators.dart';

/// Always-visible password requirements shown below password-creation fields
/// (registration and password reset).
///
/// Rendered as its own widget instead of `InputDecoration.helperText` because
/// helper text is single-line and ellipsized by default. This text wraps over
/// as many lines as needed (no `maxLines`, no ellipsis) and stays visible even
/// while a validation error is displayed under the field.
class PasswordRequirementsText extends StatelessWidget {
  const PasswordRequirementsText({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Padding(
      padding: const EdgeInsets.only(
        top: AppSpacing.xs,
        left: AppSpacing.xxs,
        right: AppSpacing.xxs,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Icon(
              Icons.info_outline,
              size: 16,
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              AppValidators.passwordRequirementsText,
              softWrap: true,
              overflow: TextOverflow.visible,
              style: AppTextStyles.captionDefault.copyWith(
                color: colors.textSecondary,
                height: 18 / 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
