import 'package:flutter/material.dart';
import 'fudi_colors.dart';
import 'fudi_typography.dart';
import 'fudi_spacing.dart';

/// Central theme configuration for Fudi.
///
/// Integrates [FudiColors], [FudiTypography], and [FudiSpacing]
/// into Material 3 [ThemeData].
class FudiTheme {
  FudiTheme._();

  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: 'DMSans',
      splashFactory: NoSplash.splashFactory,
      highlightColor: FudiColors.primary.withValues(alpha: 0.08),
      hoverColor: FudiColors.secondary.withValues(alpha: 0.08),
      colorScheme: const ColorScheme.light(
        primary: FudiColors.primary,
        onPrimary: FudiColors.primaryForeground,
        secondary: FudiColors.secondary,
        onSecondary: FudiColors.secondaryForeground,
        error: FudiColors.destructive,
        onError: FudiColors.destructiveForeground,
        surface: FudiColors.background,
        onSurface: FudiColors.foreground,
        outline: FudiColors.foreground,
        surfaceContainerLow: FudiColors.muted,
      ),
      scaffoldBackgroundColor: FudiColors.background,
      cardTheme: CardThemeData(
        color: FudiColors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(FudiRadius.lg),
          side: const BorderSide(color: FudiColors.foreground, width: 1.0),
        ),
      ),
      textTheme: TextTheme(
        displayLarge: FudiTypography.h1,
        displayMedium: FudiTypography.h2,
        displaySmall: FudiTypography.h3,
        headlineMedium: FudiTypography.h4,
        bodyLarge: FudiTypography.bodyLarge,
        bodyMedium: FudiTypography.bodyMedium,
        bodySmall: FudiTypography.bodySmall,
        labelLarge: FudiTypography.labelMedium,
        labelSmall: FudiTypography.labelSmall,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: FudiColors.background,
        foregroundColor: FudiColors.foreground,
        elevation: 0,
        centerTitle: false,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: FudiColors.muted,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(FudiRadius.md),
          borderSide: BorderSide(
            color: FudiColors.border.withValues(alpha: 0.09),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(FudiRadius.md),
          borderSide: BorderSide(
            color: FudiColors.border.withValues(alpha: 0.09),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(FudiRadius.md),
          borderSide: const BorderSide(color: FudiColors.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: FudiSpacing.lg,
          vertical: FudiSpacing.md,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: FudiColors.primary,
          foregroundColor: FudiColors.primaryForeground,
          textStyle: FudiTypography.labelMedium,
          splashFactory: NoSplash.splashFactory,
          padding: const EdgeInsets.symmetric(
            horizontal: FudiSpacing.xl,
            vertical: FudiSpacing.lg,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(FudiRadius.full),
          ),
        ),
      ),
    );
  }

  static ThemeData dark() {
    // Basic dark theme mapping, to be refined later
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: FudiColorsDark.primary,
        onPrimary: FudiColorsDark.primaryForeground,
        error: FudiColorsDark.destructive,
        surface: FudiColorsDark.background,
        onSurface: FudiColorsDark.foreground,
        outline: FudiColorsDark.border,
      ),
      scaffoldBackgroundColor: FudiColorsDark.background,
      textTheme: TextTheme(
        bodyLarge: FudiTypography.bodyLarge.copyWith(
          color: FudiColorsDark.foreground,
        ),
        bodyMedium: FudiTypography.bodyMedium.copyWith(
          color: FudiColorsDark.foreground,
        ),
      ),
    );
  }
}
