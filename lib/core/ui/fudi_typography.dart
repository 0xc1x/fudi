import 'package:flutter/material.dart';
import 'fudi_colors.dart';

/// Fudi Design System Typography
///
/// Mapping React mockup styles to Flutter TextStyle.
/// Headings: w500 (Medium) per theme.css.
class FudiTypography {
  FudiTypography._();

  // ─── Headings ─────────────────────────────────────────────────

  /// h1 - text-2xl (24px), w500, height 1.5
  static const TextStyle h1 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w500,
    height: 1.5,
    color: FudiColors.foreground,
  );

  /// h2 - text-xl (20px), w500, height 1.5
  static const TextStyle h2 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w500,
    height: 1.5,
    color: FudiColors.foreground,
  );

  /// h3 - text-lg (18px), w500, height 1.5
  static const TextStyle h3 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    height: 1.5,
    color: FudiColors.foreground,
  );

  /// h4 - text-base (16px), w500, height 1.5
  static const TextStyle h4 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.5,
    color: FudiColors.foreground,
  );

  /// headlineMedium - alias for h4 used by AppBar titles
  static const TextStyle headlineMedium = h4;

  /// headlineSmall - alias for h3 used by section headers
  static const TextStyle headlineSmall = h3;

  // ─── Body ─────────────────────────────────────────────────────

  /// Body Large - 16px, w400, height 1.5
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: FudiColors.foreground,
  );

  /// Body Medium - 14px, w400
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: FudiColors.foreground,
  );

  /// Body Small - 12px, w400
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: FudiColors.mutedForeground,
  );

  // ─── Labels / Interactive ─────────────────────────────────────

  /// Label Medium - 16px, w500
  static const TextStyle labelMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.5,
    color: FudiColors.foreground,
  );

  /// Label Small - 14px, w500
  static const TextStyle labelSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: FudiColors.foreground,
  );

  /// Price Text - used for deals
  static const TextStyle price = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: FudiColors.primary,
  );

  /// Strikethrough Price - original price
  static const TextStyle priceOriginal = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    decoration: TextDecoration.lineThrough,
    color: FudiColors.mutedForeground,
  );
}
