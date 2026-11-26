import 'package:flutter/material.dart';

/// Every colour used in AIMS-Diabetes, taken from the Figma file
/// "AIMS-Diabetes — Mobile App UI" (variable collections `Primitives` and
/// `Color`).
///
/// There are two levels:
///
/// 1. [AppColors] — the raw **palette** (Figma "Primitives"), e.g.
///    `AppColors.purple500`. These never change between light and dark mode.
/// 2. [AppThemeColors] — the **meaning** of a colour (Figma "Color"), e.g.
///    "app background" or "secondary text". Each meaning has a light value and
///    a dark value.
///
/// Screens should normally use level 2 (through the theme) so they work in
/// both light and dark mode automatically. Never type a hex value like
/// `Color(0xFF7C5CF0)` inside a screen.
abstract final class AppColors {
  // ── Purple (brand) ──────────────────────────────────────────────────────
  static const Color purple50 = Color(0xFFF3F0FF);
  static const Color purple100 = Color(0xFFE9E3FF);
  static const Color purple200 = Color(0xFFD6CBFF);
  static const Color purple300 = Color(0xFFB9A5FA);
  static const Color purple400 = Color(0xFF9B7EF5);
  static const Color purple500 = Color(0xFF7C5CF0);
  static const Color purple600 = Color(0xFF6A43D8);
  static const Color purple700 = Color(0xFF5731B8);
  static const Color purple800 = Color(0xFF412593);
  static const Color purple900 = Color(0xFF2B1A63);
  static const Color purple950 = Color(0xFF1E1733);

  // ── Lavender ────────────────────────────────────────────────────────────
  static const Color lavender50 = Color(0xFFF8F6FF);
  static const Color lavender100 = Color(0xFFEFEAFC);
  static const Color lavender200 = Color(0xFFE4DCFA);
  static const Color lavender300 = Color(0xFFD3C7F5);

  // ── Gray (neutrals) ─────────────────────────────────────────────────────
  static const Color gray0 = Color(0xFFFFFFFF);
  static const Color gray50 = Color(0xFFF6F6FB);
  static const Color gray100 = Color(0xFFEEEEF4);
  static const Color gray200 = Color(0xFFE4E3ED);
  static const Color gray300 = Color(0xFFCFCEDC);
  static const Color gray400 = Color(0xFF9D9CB3);
  static const Color gray500 = Color(0xFF6F6E88);
  static const Color gray600 = Color(0xFF4F4E66);
  static const Color gray700 = Color(0xFF39384D);
  static const Color gray800 = Color(0xFF242336);
  static const Color gray850 = Color(0xFF1B1B29);
  static const Color gray900 = Color(0xFF14141F);

  // ── Green (success / in range) ──────────────────────────────────────────
  static const Color green50 = Color(0xFFE6F7EF);
  static const Color green500 = Color(0xFF1FB184);
  static const Color green600 = Color(0xFF14916B);
  static const Color green950 = Color(0xFF0E241A);

  // ── Amber (warning) ─────────────────────────────────────────────────────
  static const Color amber50 = Color(0xFFFDF3E1);
  static const Color amber500 = Color(0xFFF2A32C);
  static const Color amber600 = Color(0xFFD9871A);
  static const Color amber950 = Color(0xFF2B2008);

  // ── Red (danger / error) ────────────────────────────────────────────────
  static const Color red50 = Color(0xFFFCEAEC);
  static const Color red500 = Color(0xFFEA5A6B);
  static const Color red600 = Color(0xFFD23E50);
  static const Color red950 = Color(0xFF2E1416);

  // ── Blue (info) ─────────────────────────────────────────────────────────
  static const Color blue50 = Color(0xFFE8F2FE);
  static const Color blue500 = Color(0xFF3C9BF0);
  static const Color blue600 = Color(0xFF2E7FD1);
  static const Color blue950 = Color(0xFF10202E);
}

/// The semantic colours from the Figma `Color` collection, one value per
/// mode (Light / Dark).
///
/// Flutter's built-in [ColorScheme] has no slot for things like "success"
/// or "tertiary text", so these are attached to the theme as a
/// [ThemeExtension]. Read them in a widget with:
///
/// ```dart
/// final colors = context.appColors; // from app_theme.dart
/// Text('In range', style: TextStyle(color: colors.successText));
/// ```
@immutable
class AppThemeColors extends ThemeExtension<AppThemeColors> {
  const AppThemeColors({
    required this.bgApp,
    required this.bgSurface,
    required this.bgSurfaceAlt,
    required this.bgPrimary,
    required this.bgPrimaryHover,
    required this.bgPrimarySubtle,
    required this.bgLavender,
    required this.bgInverse,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.textBrand,
    required this.textOnPrimary,
    required this.borderDefault,
    required this.borderSubtle,
    required this.borderBrand,
    required this.successFill,
    required this.successSubtle,
    required this.successText,
    required this.warningFill,
    required this.warningSubtle,
    required this.warningText,
    required this.dangerFill,
    required this.dangerSubtle,
    required this.dangerText,
    required this.infoFill,
    required this.infoSubtle,
    required this.infoText,
  });

  // Backgrounds — color/bg/*
  final Color bgApp;
  final Color bgSurface;
  final Color bgSurfaceAlt;
  final Color bgPrimary;
  final Color bgPrimaryHover;
  final Color bgPrimarySubtle;
  final Color bgLavender;
  final Color bgInverse;

  // Text — color/text/*
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color textBrand;
  final Color textOnPrimary;

  // Borders — color/border/*
  final Color borderDefault;
  final Color borderSubtle;
  final Color borderBrand;

  // Status — color/success|warning|danger|info/*
  final Color successFill;
  final Color successSubtle;
  final Color successText;
  final Color warningFill;
  final Color warningSubtle;
  final Color warningText;
  final Color dangerFill;
  final Color dangerSubtle;
  final Color dangerText;
  final Color infoFill;
  final Color infoSubtle;
  final Color infoText;

  /// Figma `Color` collection — **Light** mode.
  static const AppThemeColors light = AppThemeColors(
    bgApp: AppColors.gray50,
    bgSurface: AppColors.gray0,
    bgSurfaceAlt: AppColors.gray50,
    bgPrimary: AppColors.purple500,
    bgPrimaryHover: AppColors.purple600,
    bgPrimarySubtle: AppColors.purple50,
    bgLavender: AppColors.lavender100,
    bgInverse: AppColors.gray900,
    textPrimary: AppColors.gray900,
    textSecondary: AppColors.gray500,
    textTertiary: AppColors.gray400,
    textBrand: AppColors.purple600,
    textOnPrimary: AppColors.gray0,
    borderDefault: AppColors.gray200,
    borderSubtle: AppColors.gray100,
    borderBrand: AppColors.purple300,
    successFill: AppColors.green500,
    successSubtle: AppColors.green50,
    successText: AppColors.green600,
    warningFill: AppColors.amber500,
    warningSubtle: AppColors.amber50,
    warningText: AppColors.amber600,
    dangerFill: AppColors.red500,
    dangerSubtle: AppColors.red50,
    dangerText: AppColors.red600,
    infoFill: AppColors.blue500,
    infoSubtle: AppColors.blue50,
    infoText: AppColors.blue600,
  );

  /// Figma `Color` collection — **Dark** mode.
  static const AppThemeColors dark = AppThemeColors(
    bgApp: AppColors.gray900,
    bgSurface: AppColors.gray800,
    bgSurfaceAlt: AppColors.gray850,
    bgPrimary: AppColors.purple500,
    bgPrimaryHover: AppColors.purple400,
    bgPrimarySubtle: AppColors.purple950,
    bgLavender: AppColors.purple950,
    bgInverse: AppColors.gray50,
    textPrimary: AppColors.gray50,
    textSecondary: AppColors.gray300,
    textTertiary: AppColors.gray400,
    textBrand: AppColors.purple300,
    textOnPrimary: AppColors.gray0,
    borderDefault: AppColors.gray700,
    borderSubtle: AppColors.gray800,
    borderBrand: AppColors.purple700,
    successFill: AppColors.green500,
    successSubtle: AppColors.green950,
    successText: AppColors.green500,
    warningFill: AppColors.amber500,
    warningSubtle: AppColors.amber950,
    warningText: AppColors.amber500,
    dangerFill: AppColors.red500,
    dangerSubtle: AppColors.red950,
    dangerText: AppColors.red500,
    infoFill: AppColors.blue500,
    infoSubtle: AppColors.blue950,
    infoText: AppColors.blue500,
  );

  @override
  AppThemeColors copyWith({
    Color? bgApp,
    Color? bgSurface,
    Color? bgSurfaceAlt,
    Color? bgPrimary,
    Color? bgPrimaryHover,
    Color? bgPrimarySubtle,
    Color? bgLavender,
    Color? bgInverse,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? textBrand,
    Color? textOnPrimary,
    Color? borderDefault,
    Color? borderSubtle,
    Color? borderBrand,
    Color? successFill,
    Color? successSubtle,
    Color? successText,
    Color? warningFill,
    Color? warningSubtle,
    Color? warningText,
    Color? dangerFill,
    Color? dangerSubtle,
    Color? dangerText,
    Color? infoFill,
    Color? infoSubtle,
    Color? infoText,
  }) {
    return AppThemeColors(
      bgApp: bgApp ?? this.bgApp,
      bgSurface: bgSurface ?? this.bgSurface,
      bgSurfaceAlt: bgSurfaceAlt ?? this.bgSurfaceAlt,
      bgPrimary: bgPrimary ?? this.bgPrimary,
      bgPrimaryHover: bgPrimaryHover ?? this.bgPrimaryHover,
      bgPrimarySubtle: bgPrimarySubtle ?? this.bgPrimarySubtle,
      bgLavender: bgLavender ?? this.bgLavender,
      bgInverse: bgInverse ?? this.bgInverse,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      textBrand: textBrand ?? this.textBrand,
      textOnPrimary: textOnPrimary ?? this.textOnPrimary,
      borderDefault: borderDefault ?? this.borderDefault,
      borderSubtle: borderSubtle ?? this.borderSubtle,
      borderBrand: borderBrand ?? this.borderBrand,
      successFill: successFill ?? this.successFill,
      successSubtle: successSubtle ?? this.successSubtle,
      successText: successText ?? this.successText,
      warningFill: warningFill ?? this.warningFill,
      warningSubtle: warningSubtle ?? this.warningSubtle,
      warningText: warningText ?? this.warningText,
      dangerFill: dangerFill ?? this.dangerFill,
      dangerSubtle: dangerSubtle ?? this.dangerSubtle,
      dangerText: dangerText ?? this.dangerText,
      infoFill: infoFill ?? this.infoFill,
      infoSubtle: infoSubtle ?? this.infoSubtle,
      infoText: infoText ?? this.infoText,
    );
  }

  /// Smoothly blends two colour sets — Flutter uses this when animating
  /// between light and dark mode.
  @override
  AppThemeColors lerp(ThemeExtension<AppThemeColors>? other, double t) {
    if (other is! AppThemeColors) return this;
    Color mix(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppThemeColors(
      bgApp: mix(bgApp, other.bgApp),
      bgSurface: mix(bgSurface, other.bgSurface),
      bgSurfaceAlt: mix(bgSurfaceAlt, other.bgSurfaceAlt),
      bgPrimary: mix(bgPrimary, other.bgPrimary),
      bgPrimaryHover: mix(bgPrimaryHover, other.bgPrimaryHover),
      bgPrimarySubtle: mix(bgPrimarySubtle, other.bgPrimarySubtle),
      bgLavender: mix(bgLavender, other.bgLavender),
      bgInverse: mix(bgInverse, other.bgInverse),
      textPrimary: mix(textPrimary, other.textPrimary),
      textSecondary: mix(textSecondary, other.textSecondary),
      textTertiary: mix(textTertiary, other.textTertiary),
      textBrand: mix(textBrand, other.textBrand),
      textOnPrimary: mix(textOnPrimary, other.textOnPrimary),
      borderDefault: mix(borderDefault, other.borderDefault),
      borderSubtle: mix(borderSubtle, other.borderSubtle),
      borderBrand: mix(borderBrand, other.borderBrand),
      successFill: mix(successFill, other.successFill),
      successSubtle: mix(successSubtle, other.successSubtle),
      successText: mix(successText, other.successText),
      warningFill: mix(warningFill, other.warningFill),
      warningSubtle: mix(warningSubtle, other.warningSubtle),
      warningText: mix(warningText, other.warningText),
      dangerFill: mix(dangerFill, other.dangerFill),
      dangerSubtle: mix(dangerSubtle, other.dangerSubtle),
      dangerText: mix(dangerText, other.dangerText),
      infoFill: mix(infoFill, other.infoFill),
      infoSubtle: mix(infoSubtle, other.infoSubtle),
      infoText: mix(infoText, other.infoText),
    );
  }
}
