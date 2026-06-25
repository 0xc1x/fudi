import 'package:flutter/material.dart';

/// Fudi Design System Colors
///
/// Updated colors based on the new branding guidelines.
class FudiColors {
  FudiColors._();

  // ─── Primary Palette ──────────────────────────────────────────

  /// New Fudi Red/Orange (primary) — #bf1c19
  static const Color primary = Color(0xFFbf1c19);
  static const Color primaryForeground = Color(0xFFFFFFFF);

  /// Soft Green (secondary) — #B1CDB6
  static const Color secondary = Color(0xFF96BF85);
  static const Color secondaryForeground = Color(0xFF1A1A18);

  /// Dark Slate/Green (accent) — #2D4142
  static const Color accent = Color(0xFF435D38);
  static const Color accentForeground = Color(0xFFFFFFFF);

  /// Dark Background — #111C15
  static const Color greenDark = Color(0xFF111C15);
  static const Color greenDarkForeground = Color(0xFFFFFFFF);

  static const Color green = Color(0xFF7CB342);
  static const Color greenForeground = Color(0xFFFFFFFF);

  static const Color greenMidDark = Color(0xFF233529);
  static const Color greenMidDarkForeground = Color(0xFFFFFFFF);

  static const Color greenMid = Color(0xFF4CAF50);
  static const Color greenMidForeground = Color(0xFFFFFFFF);

  static const Color yellowDark = Color(0xFFF59E0B);
  static const Color yellowDarkForeground = Color(0xFFFFFFFF);

  static const Color yellow = Color(0xFFFBBF24);
  static const Color yellowForeground = Color(0xFF1A1A18);

  static const Color yellowLight = Color(0xFFFDE68A);
  static const Color yellowLightForeground = Color(0xFF1A1A18);

  /// Purple Lavender — #A398DA
  static const Color purpleLight = Color(0xFFA398DA);
  static const Color purpleLightForeground = Color(0xFFFFFFFF);

  /// Indigo Purple — #725EFE
  static const Color purpleDeep = Color(0xFF725EFE);

  // ─── Semantic Colors ──────────────────────────────────────────

  /// Dark Red — #901B35
  static const Color destructive = Color(0xFF901B35);
  static const Color destructiveForeground = Color(0xFFFFFFFF);

  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  static const Color statusPending = Color(0xFFF59E0B);
  static const Color statusPendingBackground = Color(0x33F59E0B);
  static const Color statusConfirmed = Color(0xFF3B82F6);
  static const Color statusConfirmedBackground = Color(0x333B82F6);
  static const Color statusReady = Color(0xFF22C55E);
  static const Color statusReadyBackground = Color(0x3322C55E);
  static const Color statusPickedUp = Color(0xFF6B7280);
  static const Color statusPickedUpBackground = Colors.transparent;
  static const Color statusCompleted = Color(0xFF062A73);
  static const Color statusCompletedBackground = Color(0xFF3A7BFC);
  static const Color statusCancelled = Color(0xFFEF4444);
  static const Color statusCancelledBackground = Color(0x33EF4444);
  static const Color statusExpired = Color(0xFFEF4444);
  static const Color statusExpiredBackground = Color(0x33EF4444);

  // ─── Surface Palette (Light Mode) ──────────────────────────────

  /// Cream Background — #faf9f7
  static const Color background = Color(0xFFfaf9f7);

  /// Near Black Foreground — #1A1A18
  static const Color foreground = Color(0xFF1A1A18);

  /// Light Cream Surface — #fff5f5
  static const Color card = Color(0xFFfff5f5);
  static const Color cardForeground = Color(0xFF1A1A18);

  /// Cream Muted (Secondary surface) — #fff5f5
  static const Color muted = Color(0xFFfff5f5);

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

  static const Color chart1 = Color(0xFFbf1c19);
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

  static const Color primary = Color(0xFFbf1c19);
  static const Color primaryForeground = Color(0xFFFFFFFF);

  static const Color background = Color(0xFF05102F);
  static const Color foreground = Color(0xFFfaf9f7);

  static const Color muted = Color(0xFF2D4142);
  static const Color mutedForeground = Color(0xFFB1CDB6);

  static const Color destructive = Color(0xFF901B35);

  static const Color border = Color(0x33FFFFFF);
}
