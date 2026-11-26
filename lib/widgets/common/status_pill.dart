import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Semantic status variant for [StatusPill].
enum StatusPillType {
  success,
  warning,
  danger,
  info,
  brand,
  neutral,
}

/// Reusable semantic status chip/badge for displaying health states,
/// reading classifications (In-Range / High / Low), and medication adherence.
///
/// Matches Figma pill tokens: rounded full pill ([AppRadius.full]) and caption typography.
class StatusPill extends StatelessWidget {
  const StatusPill({
    super.key,
    required this.label,
    this.type = StatusPillType.info,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.padding = const EdgeInsets.symmetric(
      horizontal: AppSpacing.sm,
      vertical: AppSpacing.xxs,
    ),
  });

  final String label;
  final StatusPillType type;
  final Widget? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    Color bg;
    Color fg;

    switch (type) {
      case StatusPillType.success:
        bg = colors.successSubtle;
        fg = colors.successText;
      case StatusPillType.warning:
        bg = colors.warningSubtle;
        fg = colors.warningText;
      case StatusPillType.danger:
        bg = colors.dangerSubtle;
        fg = colors.dangerText;
      case StatusPillType.info:
        bg = colors.infoSubtle;
        fg = colors.infoText;
      case StatusPillType.brand:
        bg = colors.bgPrimarySubtle;
        fg = colors.textBrand;
      case StatusPillType.neutral:
        bg = colors.bgSurfaceAlt;
        fg = colors.textSecondary;
    }

    final effectiveBg = backgroundColor ?? bg;
    final effectiveFg = textColor ?? fg;

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: effectiveBg,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            icon!,
            const SizedBox(width: AppSpacing.xxs),
          ],
          Text(
            label,
            style: AppTextStyles.captionStrong.copyWith(color: effectiveFg),
          ),
        ],
      ),
    );
  }
}
