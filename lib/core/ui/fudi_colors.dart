import 'package:flutter/material.dart';

/// Fudi Design System Colors
///
/// Updated colors based on the new branding guidelines.
class FudiColors {
  FudiColors._();

  // ─── Primary Palette ──────────────────────────────────────────

  /// New Fudi Red/Orange (primary) — #FA4743
  static const Color primary = Color(0xFFFA4743);
  static const Color primaryForeground = Color(0xFFFFFFFF);

  /// Soft Green (secondary) — #B1CDB6
  static const Color secondary = Color(0xFFB1CDB6);
  static const Color secondaryForeground = Color(0xFF1A1A18);

  /// Dark Slate/Green (accent) — #2D4142
  static const Color accent = Color(0xFF2D4142);
  static const Color accentForeground = Color(0xFFFFFFFF);

  /// Purple Lavender — #A398DA
  static const Color purpleLight = Color(0xFFA398DA);

  /// Indigo Purple — #725EFE
  static const Color purpleDeep = Color(0xFF725EFE);

  // ─── Semantic Colors ──────────────────────────────────────────

  /// Dark Red — #901B35
  static const Color destructive = Color(0xFF901B35);
  static const Color destructiveForeground = Color(0xFFFFFFFF);

  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  // ─── Surface Palette (Light Mode) ──────────────────────────────

  /// Cream Background — #F5F1E8
  static const Color background = Color(0xFFF5F1E8);

  /// Near Black Foreground — #1A1A18
  static const Color foreground = Color(0xFF1A1A18);

  /// Light Cream Surface — #F7EFE4
  static const Color card = Color(0xFFF7EFE4);
  static const Color cardForeground = Color(0xFF1A1A18);

  /// Cream Muted (Secondary surface) — #F7EFE4
  static const Color muted = Color(0xFFF7EFE4);

  /// Muted Foreground (Opacity version of foreground)
  static const Color mutedForeground = Color(0xFF737373);

  /// Deep Navy — #05102F
  static const Color navyDeep = Color(0xFF05102F);

  /// Deep Navy Alternative — #04102D
  static const Color navyDark = Color(0xFF04102D);

  /// Border version
  static const Color border = Color(0x14000000);
  static const Color borderSolid = Color(0xFFE5E5E5);

  /// Ring — subtle focus ring / outline accent
  static const Color ring = Color(0x1A000000);

  /// Input Background
  static const Color inputBackground = Color(0xFFFFFFFF);

  // ─── Chart / Statistics Palette ───────────────────────────────

  static const Color chart1 = Color(0xFFFA4743);
  static const Color chart2 = Color(0xFF725EFE);
  static const Color chart3 = Color(0xFFB1CDB6);
  static const Color chart4 = Color(0xFF2D4142);
  static const Color chart5 = Color(0xFFA398DA);

  // ─── PALETA ALTERNATIVA (Solo para referencia) ────────────────

  /// Naranja Vibrante — #FC5C2B
  static const Color altPrimary = Color(0xFFFC5C2B);

  /// Negro Carbón — #201C1C
  static const Color altDark = Color(0xFF201C1C);

  /// Verde Menta — #AEF2CD
  static const Color altGreen = Color(0xFFAEF2CD);

  /// Blanco Hueso — #F7F7F5
  static const Color altLight = Color(0xFFF7F7F5);
}

/// Surface Palette (Dark Mode)
class FudiColorsDark {
  FudiColorsDark._();

  static const Color primary = Color(0xFFFA4743);
  static const Color primaryForeground = Color(0xFFFFFFFF);

  static const Color background = Color(0xFF05102F);
  static const Color foreground = Color(0xFFF5F1E8);

  static const Color muted = Color(0xFF2D4142);
  static const Color mutedForeground = Color(0xFFB1CDB6);

  static const Color destructive = Color(0xFF901B35);

  static const Color border = Color(0x33FFFFFF);
}
