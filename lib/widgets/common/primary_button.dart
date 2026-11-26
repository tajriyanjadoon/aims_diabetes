import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Reusable primary call-to-action button for AIMS-Diabetes.
///
/// Features:
/// - Supports loading state (shows a circular progress indicator and disables taps).
/// - Supports disabled state (`onPressed == null` or `isEnabled == false`).
/// - Matches Figma design tokens: 16px corner radius ([AppRadius.md]), 52px default height.
/// - Supports optional leading icon.
/// - Full width by default, with option for inline shrink-wrapped width.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.icon,
    this.height = 52.0,
    this.width = double.infinity,
    this.backgroundColor,
    this.foregroundColor,
  });

  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isEnabled;
  final Widget? icon;
  final double height;
  final double? width;
  final Color? backgroundColor;
  final Color? foregroundColor;

  bool get _canPress => isEnabled && !isLoading && onPressed != null;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    final effectiveBg = backgroundColor ?? colors.bgPrimary;
    final effectiveFg = foregroundColor ?? colors.textOnPrimary;

    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: _canPress ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: effectiveBg,
          foregroundColor: effectiveFg,
          disabledBackgroundColor: effectiveBg.withValues(alpha: 0.4),
          disabledForegroundColor: effectiveFg.withValues(alpha: 0.6),
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        ),
        child: isLoading
            ? SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(effectiveFg),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    icon!,
                    const SizedBox(width: AppSpacing.xs),
                  ],
                  Flexible(
                    child: Text(
                      text,
                      style: AppTextStyles.labelButton.copyWith(color: effectiveFg),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
