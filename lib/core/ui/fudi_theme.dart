import 'package:flutter/material.dart';
import 'fudi_colors.dart';
import 'fudi_typography.dart';
import 'fudi_spacing.dart';

/// Extension to hold Fudi design system custom tokens not defined in [ColorScheme].
class FudiThemeExtension extends ThemeExtension<FudiThemeExtension> {
  const FudiThemeExtension({
    required this.cardBg,
    required this.border,
    required this.borderSolid,
    required this.mutedBackground,
    required this.surfaceShadow,
  });

  final Color cardBg;
  final Color border;
  final Color borderSolid;
  final Color mutedBackground;
  final Color surfaceShadow;

  @override
  ThemeExtension<FudiThemeExtension> copyWith({
    Color? cardBg,
    Color? border,
    Color? borderSolid,
    Color? mutedBackground,
    Color? surfaceShadow,
  }) {
    return FudiThemeExtension(
      cardBg: cardBg ?? this.cardBg,
      border: border ?? this.border,
      borderSolid: borderSolid ?? this.borderSolid,
      mutedBackground: mutedBackground ?? this.mutedBackground,
      surfaceShadow: surfaceShadow ?? this.surfaceShadow,
    );
  }

  @override
  ThemeExtension<FudiThemeExtension> lerp(
    covariant ThemeExtension<FudiThemeExtension>? other,
    double t,
  ) {
    if (other is! FudiThemeExtension) {
      return this;
    }
    return FudiThemeExtension(
      cardBg: Color.lerp(cardBg, other.cardBg, t)!,
      border: Color.lerp(border, other.border, t)!,
      borderSolid: Color.lerp(borderSolid, other.borderSolid, t)!,
      mutedBackground: Color.lerp(mutedBackground, other.mutedBackground, t)!,
      surfaceShadow: Color.lerp(surfaceShadow, other.surfaceShadow, t)!,
    );
  }

  static const light = FudiThemeExtension(
    cardBg: FudiColors.card,
    border: FudiColors.border,
    borderSolid: FudiColors.borderSolid,
    mutedBackground: FudiColors.muted,
    surfaceShadow: Color(0x0AFA4743),
  );

  static const dark = FudiThemeExtension(
    cardBg: FudiColorsDark.muted,
    border: FudiColorsDark.border,
    borderSolid: FudiColorsDark.border,
    mutedBackground: FudiColorsDark.surfaceMuted,
    surfaceShadow: Colors.transparent,
  );
}

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
        secondary: FudiColors.secondary,
        onSecondary: FudiColors.secondaryForeground,
        error: FudiColors.destructive,
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
          side: const BorderSide(color: FudiColors.foreground),
        ),
      ),
      textTheme: const TextTheme(
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
      dividerTheme: const DividerThemeData(
        color: FudiColors.borderSolid,
        thickness: 1,
        space: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: FudiColors.foreground,
        contentTextStyle: FudiTypography.bodyMedium.copyWith(color: FudiColors.background),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(FudiRadius.lg),
        ),
      ),
      extensions: const [FudiThemeExtension.light],
    );
  }

  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: 'DMSans',
      splashFactory: NoSplash.splashFactory,
      highlightColor: FudiColorsDark.primary.withValues(alpha: 0.08),
      hoverColor: FudiColorsDark.mutedForeground.withValues(alpha: 0.08),
      colorScheme: const ColorScheme.dark(
        primary: FudiColorsDark.primary,
        onPrimary: FudiColorsDark.primaryForeground,
        secondary: FudiColorsDark.mutedForeground,
        onSecondary: FudiColorsDark.muted,
        error: FudiColorsDark.destructive,
        surface: FudiColorsDark.background,
        onSurface: FudiColorsDark.foreground,
        outline: FudiColorsDark.border,
        surfaceContainerLow: FudiColorsDark.muted,
      ),
      scaffoldBackgroundColor: FudiColorsDark.background,
      cardTheme: CardThemeData(
        color: FudiColorsDark.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(FudiRadius.lg),
          side: const BorderSide(color: FudiColorsDark.border),
        ),
      ),
      textTheme: TextTheme(
        displayLarge: FudiTypography.h1.copyWith(color: FudiColorsDark.foreground),
        displayMedium: FudiTypography.h2.copyWith(color: FudiColorsDark.foreground),
        displaySmall: FudiTypography.h3.copyWith(color: FudiColorsDark.foreground),
        headlineMedium: FudiTypography.h4.copyWith(color: FudiColorsDark.foreground),
        bodyLarge: FudiTypography.bodyLarge.copyWith(color: FudiColorsDark.foreground),
        bodyMedium: FudiTypography.bodyMedium.copyWith(color: FudiColorsDark.foreground),
        bodySmall: FudiTypography.bodySmall.copyWith(color: FudiColorsDark.mutedForeground),
        labelLarge: FudiTypography.labelMedium.copyWith(color: FudiColorsDark.foreground),
        labelSmall: FudiTypography.labelSmall.copyWith(color: FudiColorsDark.foreground),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: FudiColorsDark.background,
        foregroundColor: FudiColorsDark.foreground,
        elevation: 0,
        centerTitle: false,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: FudiColorsDark.muted,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(FudiRadius.md),
          borderSide: const BorderSide(
            color: FudiColorsDark.border,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(FudiRadius.md),
          borderSide: const BorderSide(
            color: FudiColorsDark.border,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(FudiRadius.md),
          borderSide: const BorderSide(color: FudiColorsDark.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: FudiSpacing.lg,
          vertical: FudiSpacing.md,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: FudiColorsDark.primary,
          foregroundColor: FudiColorsDark.primaryForeground,
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
      dividerTheme: const DividerThemeData(
        color: FudiColorsDark.border,
        thickness: 1,
        space: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: FudiColorsDark.foreground,
        contentTextStyle: FudiTypography.bodyMedium.copyWith(color: FudiColorsDark.background),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(FudiRadius.lg),
        ),
      ),
      extensions: const [FudiThemeExtension.dark],
    );
  }
}
