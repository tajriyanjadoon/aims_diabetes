import 'package:flutter/material.dart';

/// Asset paths for all official AIMS-Diabetes branding assets.
/// Centralized here so asset paths are never hardcoded in screens.
abstract final class AppBrandingAssets {
  static const String primaryHorizontal = 'assets/branding/logos/primary_horizontal.png';
  static const String stackedLogo = 'assets/branding/logos/stacked_logo.png';
  static const String symbolOnly = 'assets/branding/logos/symbol_only.png';
  static const String whiteLogo = 'assets/branding/logos/white_logo.png';
  static const String darkLogo = 'assets/branding/logos/dark_logo.png';
  static const String uiSymbol = 'assets/branding/logos/ui_symbol.png';

  // Splash assets
  static const String splashLightLogo = 'assets/splash/light/splash_light_logo.png';
  static const String splashLightSymbol = 'assets/splash/light/splash_light_symbol.png';
  static const String splashDarkLogo = 'assets/splash/dark/splash_dark_logo.png';
  static const String splashDarkSymbol = 'assets/splash/dark/splash_dark_symbol.png';

  // App icon masters
  static const String appIcon1024 = 'assets/branding/icons/app_icon_1024.png';
  static const String androidForeground = 'assets/branding/icons/android_foreground.png';
  static const String androidBackground = 'assets/branding/icons/android_background.png';
}

/// The available visual variations of the AIMS-Diabetes logo,
/// defined in the Brand Guidelines (page 3).
enum AppLogoVariant {
  /// Standard full brand lockup: violet droplet symbol + dark text.
  /// Intended for light backgrounds (AppBar, headers, welcome banners).
  horizontal,

  /// Centered lockup: droplet symbol stacked directly above the wordmark.
  /// Intended for hero sections, splash screens, and auth pages.
  stacked,

  /// Violet gradient badge with droplet spark.
  /// Intended for compact spaces, avatars, and app icons.
  symbolOnly,

  /// Flat minimalist droplet with spark (without the gradient badge).
  /// Intended for small in-app UI badges and list indicators.
  uiSymbol,

  /// Monochrome white horizontal logo.
  /// Intended specifically for dark surfaces (e.g., Deep Purple #2B1A63 or Dark Gray #14141F).
  whiteHorizontal,

  /// Monochrome dark horizontal logo.
  /// Intended for high-contrast neutral light surfaces.
  darkHorizontal,
}

/// A reusable, beginner-friendly widget for displaying the official
/// AIMS-Diabetes logo throughout the application.
///
/// Features:
/// - Maintains original aspect ratios without distortion.
/// - Uses [BoxFit.contain] by default.
/// - Allows explicit selection of the correct logo variant according to
///   the surrounding background and Brand Guidelines.
/// - Supports an optional [onDarkBackground] helper to pick the appropriate
///   contrast version for custom dark containers.
///
/// Example usage:
/// ```dart
/// // Standard horizontal header logo
/// const AppLogo(height: 36)
///
/// // Stacked logo on a welcome card
/// const AppLogo(variant: AppLogoVariant.stacked, height: 80)
///
/// // Logo on a dark container
/// const AppLogo(variant: AppLogoVariant.whiteHorizontal, height: 32)
/// ```
class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.variant = AppLogoVariant.horizontal,
    this.height,
    this.width,
    this.fit = BoxFit.contain,
    this.semanticLabel = 'AIMSD Logo',
  });

  /// Factory constructor for a logo placed on a dark background.
  /// Automatically uses the monochrome white logo.
  const AppLogo.onDark({
    super.key,
    this.height,
    this.width,
    this.fit = BoxFit.contain,
    this.semanticLabel = 'AIMSD Logo',
  }) : variant = AppLogoVariant.whiteHorizontal;

  /// Factory constructor for a compact icon mark (symbol only).
  const AppLogo.symbol({
    super.key,
    double size = 40,
    this.semanticLabel = 'AIMSD Mark',
  })  : variant = AppLogoVariant.symbolOnly,
        width = size,
        height = size,
        fit = BoxFit.contain;

  /// The logo variation to display.
  final AppLogoVariant variant;

  /// Optional fixed height for the logo.
  final double? height;

  /// Optional fixed width for the logo.
  final double? width;

  /// How the image should fit within its bounding box.
  final BoxFit fit;

  /// Accessibility label for screen readers.
  final String semanticLabel;

  String get _assetPath {
    switch (variant) {
      case AppLogoVariant.horizontal:
        return AppBrandingAssets.primaryHorizontal;
      case AppLogoVariant.stacked:
        return AppBrandingAssets.stackedLogo;
      case AppLogoVariant.symbolOnly:
        return AppBrandingAssets.symbolOnly;
      case AppLogoVariant.uiSymbol:
        return AppBrandingAssets.uiSymbol;
      case AppLogoVariant.whiteHorizontal:
        return AppBrandingAssets.whiteLogo;
      case AppLogoVariant.darkHorizontal:
        return AppBrandingAssets.darkLogo;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      _assetPath,
      width: width,
      height: height,
      fit: fit,
      semanticLabel: semanticLabel,
    );
  }
}
