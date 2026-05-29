import 'package:flutter/material.dart';
import 'fudi_colors.dart';

/// Fudi Design System Typography
///
/// Mapping React mockup styles to Flutter TextStyle.
/// Headings: w500 (Medium) per theme.css.
class FudiTypography {
  FudiTypography._();

  // ─── Headings (Outfit) ─────────────────────────────────────────

  /// h1 - text-2xl (24px), w700 (Bold), height 1.3
  static const TextStyle h1 = TextStyle(
    fontFamily: 'Outfit',
    fontSize: 24,
    fontWeight: FontWeight.bold,
    height: 1.3,
    color: FudiColors.foreground,
  );

  /// h2 - text-xl (20px), w700 (Bold), height 1.3
  static const TextStyle h2 = TextStyle(
    fontFamily: 'Outfit',
    fontSize: 20,
    fontWeight: FontWeight.bold,
    height: 1.3,
    color: FudiColors.foreground,
  );

  /// h3 - text-lg (18px), w700 (Bold), height 1.3
  static const TextStyle h3 = TextStyle(
    fontFamily: 'Outfit',
    fontSize: 18,
    fontWeight: FontWeight.bold,
    height: 1.3,
    color: FudiColors.foreground,
  );

  /// h4 - text-base (16px), w700 (Bold), height 1.3
  static const TextStyle h4 = TextStyle(
    fontFamily: 'Outfit',
    fontSize: 16,
    fontWeight: FontWeight.bold,
    height: 1.3,
    color: FudiColors.foreground,
  );

  /// headlineMedium - alias for h4 used by AppBar titles
  static const TextStyle headlineMedium = h4;

  /// headlineSmall - alias for h3 used by section headers
  static const TextStyle headlineSmall = h3;

  // ─── Body (DMSans) ─────────────────────────────────────────────

  /// Body Large - 16px, w400, height 1.5
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: 'DMSans',
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: FudiColors.foreground,
  );

  /// Body Medium - 14px, w400, height 1.4
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: 'DMSans',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: FudiColors.foreground,
  );

  /// Body Small - 12px, w400
  static const TextStyle bodySmall = TextStyle(
    fontFamily: 'DMSans',
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: FudiColors.mutedForeground,
  );

  // ─── Labels / Interactive (DMSans) ─────────────────────────────

  /// Label Medium - 16px, w500 (Medium)
  static const TextStyle labelMedium = TextStyle(
    fontFamily: 'DMSans',
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.5,
    color: FudiColors.foreground,
  );

  /// Label Small - 14px, w500 (Medium)
  static const TextStyle labelSmall = TextStyle(
    fontFamily: 'DMSans',
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: FudiColors.foreground,
  );

  /// Price Text - used for deals (Outfit)
  static const TextStyle price = TextStyle(
    fontFamily: 'Outfit',
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: FudiColors.primary,
  );

  /// Strikethrough Price - original price (DMSans)
  static const TextStyle priceOriginal = TextStyle(
    fontFamily: 'DMSans',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    decoration: TextDecoration.lineThrough,
    color: FudiColors.mutedForeground,
  );

  /// Price Text Large - used in Home cards (Outfit)
  static const TextStyle priceLarge = TextStyle(
    fontFamily: 'Outfit',
    fontSize: 24,
    fontWeight: FontWeight.w800,
    color: FudiColors.primary,
  );
}
