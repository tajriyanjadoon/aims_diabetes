import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import 'app_logo.dart';

/// Reusable brand header used across authentication screens.
///
/// Renders the full-bleed purple rounded-square icon ([AppLogoVariant.symbolOnly])
/// above a theme-aware Flutter [Text] widget displaying `"AIMSD"`.
///
/// Why this widget exists instead of [AppLogoVariant.stacked]:
/// - The raster `stacked_logo.png` asset embeds dark-coloured text and large
///   transparent margins, causing the wordmark to disappear in Dark Mode and
///   making the icon appear small.
/// - Rendering the symbol asset alongside a real [Text] widget styled with
///   `Theme.of(context).colorScheme.onSurface` guarantees crisp legibility in
///   both Light Mode and Dark Mode and preserves the icon's 1:1 proportions.
class BrandHeader extends StatelessWidget {
  const BrandHeader({super.key, this.iconSize});

  /// Minimum and maximum responsive icon sizes (logical pixels).
  static const double minIconSize = 84;
  static const double maxIconSize = 112;
  static const double screenHeightFactor = 0.13;

  /// Horizontal padding used by auth screens (left + right).
  static const double horizontalPadding = AppSpacing.xl * 2;

  /// Optional explicit icon size; when omitted, scales responsively with
  /// the viewport height via [iconSizeFor].
  final double? iconSize;

  /// Computes a responsive, square icon size that fits comfortably on both
  /// compact phones and large screens without overflowing.
  static double iconSizeFor(Size screen) {
    final byHeight =
        (screen.height * screenHeightFactor).clamp(minIconSize, maxIconSize);
    final byWidth = screen.width - horizontalPadding;
    return math.min(byHeight, byWidth);
  }

  @override
  Widget build(BuildContext context) {
    final resolvedSize = iconSize ?? iconSizeFor(MediaQuery.sizeOf(context));
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AppLogo.symbol(
            size: resolvedSize,
            semanticLabel: '${AppConstants.appName} Logo',
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            AppConstants.appName,
            style: AppTextStyles.h2.copyWith(
              color: onSurface,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
