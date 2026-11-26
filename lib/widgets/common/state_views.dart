import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import 'primary_button.dart';

/// Loading skeleton view for cards and lists while data is being fetched.
///
/// Features an animated shimmer-like opacity pulse across card placeholders.
class SkeletonLoader extends StatefulWidget {
  const SkeletonLoader({
    super.key,
    this.itemCount = 4,
    this.itemHeight = 72.0,
    this.padding = const EdgeInsets.all(AppSpacing.md),
  });

  final int itemCount;
  final double itemHeight;
  final EdgeInsetsGeometry padding;

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.4, end: 0.9).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ListView.separated(
          padding: widget.padding,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: widget.itemCount,
          separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.sm),
          itemBuilder: (context, index) {
            return Container(
              height: widget.itemHeight,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: colors.bgSurface,
                borderRadius: BorderRadius.circular(AppRadius.xl),
                border: Border.all(color: colors.borderSubtle),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: colors.bgSurfaceAlt.withValues(alpha: _animation.value),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: double.infinity,
                          height: 14,
                          decoration: BoxDecoration(
                            color: colors.bgSurfaceAlt.withValues(alpha: _animation.value),
                            borderRadius: BorderRadius.circular(AppRadius.xs),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Container(
                          width: 120,
                          height: 10,
                          decoration: BoxDecoration(
                            color: colors.bgSurfaceAlt.withValues(alpha: _animation.value),
                            borderRadius: BorderRadius.circular(AppRadius.xs),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

/// Standard error state view displaying an icon, message, and a retry button.
class ErrorState extends StatelessWidget {
  const ErrorState({
    super.key,
    required this.message,
    this.title = 'Something went wrong',
    this.onRetry,
    this.retryLabel = 'Try Again',
    this.padding = const EdgeInsets.all(AppSpacing.xl),
  });

  final String message;
  final String title;
  final VoidCallback? onRetry;
  final String retryLabel;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Center(
      child: Padding(
        padding: padding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: colors.dangerSubtle,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                color: colors.dangerText,
                size: 32,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              title,
              style: AppTextStyles.h3.copyWith(color: colors.textPrimary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              message,
              style: AppTextStyles.bodyDefault.copyWith(color: colors.textSecondary),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.lg),
              PrimaryButton(
                text: retryLabel,
                onPressed: onRetry,
                width: null,
                icon: const Icon(Icons.refresh_rounded, size: 20),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Standard empty state view with illustration/icon, title, message, and call-to-action button.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.title,
    required this.message,
    this.icon,
    this.buttonLabel,
    this.onPressed,
    this.padding = const EdgeInsets.all(AppSpacing.xl),
  });

  final String title;
  final String message;
  final Widget? icon;
  final String? buttonLabel;
  final VoidCallback? onPressed;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Center(
      child: Padding(
        padding: padding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: colors.bgPrimarySubtle,
                shape: BoxShape.circle,
              ),
              child: icon ??
                  Icon(
                    Icons.inbox_outlined,
                    color: colors.textBrand,
                    size: 32,
                  ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              title,
              style: AppTextStyles.h3.copyWith(color: colors.textPrimary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              message,
              style: AppTextStyles.bodyDefault.copyWith(color: colors.textSecondary),
              textAlign: TextAlign.center,
            ),
            if (buttonLabel != null && onPressed != null) ...[
              const SizedBox(height: AppSpacing.lg),
              PrimaryButton(
                text: buttonLabel!,
                onPressed: onPressed,
                width: null,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
