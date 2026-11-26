import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Spacing scale from the Figma `Spacing` collection (in logical pixels).
/// Use these for padding and gaps instead of typing numbers in screens.
abstract final class AppSpacing {
  static const double xxs = 4; // spacing/2xs
  static const double xs = 8; // spacing/xs
  static const double sm = 12; // spacing/sm
  static const double md = 16; // spacing/md
  static const double lg = 20; // spacing/lg
  static const double xl = 24; // spacing/xl
  static const double xxl = 32; // spacing/2xl
  static const double xxxl = 40; // spacing/3xl
}

/// Corner-radius scale from the Figma `Radius` collection.
abstract final class AppRadius {
  static const double xs = 8; // radius/xs
  static const double sm = 12; // radius/sm  — input fields
  static const double md = 16; // radius/md  — buttons
  static const double lg = 20; // radius/lg
  static const double xl = 24; // radius/xl  — cards
  static const double xxl = 28; // radius/2xl
  static const double full = 999; // radius/full — pills / circles
}

/// The 13 text styles from Figma (font: Plus Jakarta Sans).
///
/// Figma gives line height in pixels and letter spacing in percent; Flutter
/// wants `height` as a multiplier (lineHeight / fontSize) and letter spacing
/// in pixels (fontSize × percent / 100). The values below are already
/// converted. Colours are not set here — the theme adds them.
abstract final class AppTextStyles {
  static const TextStyle displayNumber = TextStyle(
    fontSize: 34,
    fontWeight: FontWeight.w800,
    height: 40 / 34,
    letterSpacing: -0.51,
  );
  static const TextStyle h1 = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w700,
    height: 32 / 26,
    letterSpacing: -0.39,
  );
  static const TextStyle h2 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 26 / 20,
    letterSpacing: -0.2,
  );
  static const TextStyle h3 = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    height: 24 / 17,
    letterSpacing: -0.085,
  );
  static const TextStyle titleCard = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    height: 20 / 15,
    letterSpacing: -0.03,
  );
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 24 / 16,
  );
  static const TextStyle bodyDefault = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 20 / 14,
  );
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 20 / 14,
  );
  static const TextStyle labelStrong = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 18 / 14,
  );
  static const TextStyle labelButton = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    height: 20 / 15,
  );
  static const TextStyle captionDefault = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 16 / 12,
  );
  static const TextStyle captionStrong = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 16 / 12,
  );
  static const TextStyle overline = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    height: 14 / 11,
    letterSpacing: 0.66,
  );
}

/// Builds the light and dark [ThemeData] for the whole app (Material 3).
///
/// Use in `main.dart`:
/// ```dart
/// MaterialApp(
///   theme: AppTheme.light,
///   darkTheme: AppTheme.dark,
///   themeMode: ThemeMode.system,
/// )
/// ```
abstract final class AppTheme {
  /// Font family used in Figma. Until the font files are added to the
  /// project, Flutter silently falls back to the default system font.
  static const String fontFamily = 'PlusJakartaSans';

  static ThemeData get light => _build(AppThemeColors.light, Brightness.light);
  static ThemeData get dark => _build(AppThemeColors.dark, Brightness.dark);

  /// One builder for both modes, so light and dark can never drift apart —
  /// only the colour set [c] changes.
  static ThemeData _build(AppThemeColors c, Brightness brightness) {
    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: c.bgPrimary,
      onPrimary: c.textOnPrimary,
      primaryContainer: c.bgPrimarySubtle,
      onPrimaryContainer: c.textBrand,
      secondary: c.textBrand,
      onSecondary: c.textOnPrimary,
      secondaryContainer: c.bgLavender,
      onSecondaryContainer: c.textBrand,
      error: c.dangerFill,
      onError: c.textOnPrimary,
      errorContainer: c.dangerSubtle,
      onErrorContainer: c.dangerText,
      surface: c.bgSurface,
      onSurface: c.textPrimary,
      onSurfaceVariant: c.textSecondary,
      surfaceContainerLowest: c.bgSurface,
      surfaceContainerLow: c.bgSurface,
      surfaceContainer: c.bgSurfaceAlt,
      surfaceContainerHigh: c.bgSurfaceAlt,
      surfaceContainerHighest: c.bgSurfaceAlt,
      outline: c.borderDefault,
      outlineVariant: c.borderSubtle,
      inverseSurface: c.bgInverse,
      onInverseSurface: c.bgApp,
      inversePrimary: c.borderBrand,
      surfaceTint: Colors.transparent, // flat surfaces, as in Figma
    );

    const textTheme = TextTheme(
      displaySmall: AppTextStyles.displayNumber,
      headlineSmall: AppTextStyles.h1,
      titleLarge: AppTextStyles.h2,
      titleMedium: AppTextStyles.h3,
      titleSmall: AppTextStyles.titleCard,
      bodyLarge: AppTextStyles.bodyLarge,
      bodyMedium: AppTextStyles.bodyDefault,
      bodySmall: AppTextStyles.captionDefault,
      labelLarge: AppTextStyles.labelButton,
      labelMedium: AppTextStyles.labelStrong,
      labelSmall: AppTextStyles.overline,
    );

    final buttonShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
    );
    const buttonPadding = EdgeInsets.symmetric(horizontal: AppSpacing.xl);
    const buttonMinSize = Size(64, 52); // Figma Button height = 52

    OutlineInputBorder fieldBorder(Color color) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.sm),
      borderSide: BorderSide(color: color, width: 1.5),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      fontFamily: fontFamily,
      scaffoldBackgroundColor: c.bgApp,
      textTheme: textTheme.apply(
        bodyColor: c.textPrimary,
        displayColor: c.textPrimary,
        fontFamily: fontFamily,
      ),
      extensions: <ThemeExtension<dynamic>>[c],

      appBarTheme: AppBarTheme(
        backgroundColor: c.bgApp,
        foregroundColor: c.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: AppTextStyles.h3.copyWith(
          color: c.textPrimary,
          fontFamily: fontFamily,
        ),
      ),

      // Figma "Button / Style=Primary": purple fill, white label.
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: c.bgPrimary,
          foregroundColor: c.textOnPrimary,
          minimumSize: buttonMinSize,
          padding: buttonPadding,
          shape: buttonShape,
          textStyle: AppTextStyles.labelButton,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: c.bgPrimary,
          foregroundColor: c.textOnPrimary,
          elevation: 0,
          minimumSize: buttonMinSize,
          padding: buttonPadding,
          shape: buttonShape,
          textStyle: AppTextStyles.labelButton,
        ),
      ),
      // Figma "Button / Style=Ghost": surface fill, 1.5px default border.
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: c.bgSurface,
          foregroundColor: c.textPrimary,
          side: BorderSide(color: c.borderDefault, width: 1.5),
          minimumSize: buttonMinSize,
          padding: buttonPadding,
          shape: buttonShape,
          textStyle: AppTextStyles.labelButton,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: c.textBrand,
          textStyle: AppTextStyles.labelButton,
        ),
      ),
      // Figma "Button / Style=Secondary" (lavender fill, brand text) is not a
      // built-in Material button; it will be a variant of PrimaryButton in
      // widgets/common/ (Phase 1, Task "common widgets").

      // Figma "Input": label above, 52px field, 12px radius, 1.5px border.
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.bgSurface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        hintStyle: AppTextStyles.bodyDefault.copyWith(color: c.textTertiary),
        labelStyle: AppTextStyles.labelStrong.copyWith(color: c.textSecondary),
        border: fieldBorder(c.borderDefault),
        enabledBorder: fieldBorder(c.borderDefault),
        focusedBorder: fieldBorder(c.borderBrand),
        errorBorder: fieldBorder(c.dangerFill),
        focusedErrorBorder: fieldBorder(c.dangerFill),
      ),

      // Figma "Card": surface fill, 24px radius, no shadow.
      cardTheme: CardThemeData(
        color: c.bgSurface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
      ),

      dividerTheme: DividerThemeData(color: c.borderSubtle, thickness: 1),
    );
  }
}

/// Shortcut so any widget can write `context.appColors.successText`
/// instead of `Theme.of(context).extension<AppThemeColors>()!.successText`.
extension AppThemeContext on BuildContext {
  AppThemeColors get appColors => Theme.of(this).extension<AppThemeColors>()!;
}
