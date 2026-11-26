import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Semantic type of a [MessageBanner].
enum MessageBannerType { error, info, success, warning }

/// Inline banner for feedback messages (errors, notices, success), using the
/// semantic status colours from the design system.
class MessageBanner extends StatelessWidget {
  const MessageBanner({
    super.key,
    required this.message,
    this.type = MessageBannerType.info,
    this.icon,
  });

  final String message;
  final MessageBannerType type;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    final (Color bg, Color fill, Color fg, IconData defaultIcon) = switch (type) {
      MessageBannerType.error => (
          colors.dangerSubtle,
          colors.dangerFill,
          colors.dangerText,
          Icons.error_outline,
        ),
      MessageBannerType.success => (
          colors.successSubtle,
          colors.successFill,
          colors.successText,
          Icons.check_circle_outline,
        ),
      MessageBannerType.warning => (
          colors.warningSubtle,
          colors.warningFill,
          colors.warningText,
          Icons.warning_amber_rounded,
        ),
      MessageBannerType.info => (
          colors.infoSubtle,
          colors.infoFill,
          colors.infoText,
          Icons.info_outline,
        ),
    };

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: fill.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon ?? defaultIcon, size: 20, color: fg),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodyDefault.copyWith(color: fg),
            ),
          ),
        ],
      ),
    );
  }
}
