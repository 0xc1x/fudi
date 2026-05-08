import 'package:flutter/material.dart';

/// Fudi Design System Colors
/// 
/// Authoritative tokens extracted from the React mockup theme.css.
class FudiColors {
  FudiColors._();

  // ─── Primary Palette ──────────────────────────────────────────
  
  /// Dark Fudi Green (primary) — --primary: 153 47% 27% (#256646)
  static const Color primary = Color(0xFF256646);
  static const Color primaryForeground = Color(0xFFFFFFFF);

  /// Light Lime (secondary) — --secondary: 81 74% 86% (#E3F7BE)
  static const Color secondary = Color(0xFFE3F7BE);
  static const Color secondaryForeground = Color(0xFF256646);

  /// Medium Green (accent) — --accent: 151 49% 41% (#359C6B)
  static const Color accent = Color(0xFF359C6B);
  static const Color accentForeground = Color(0xFFFFFFFF);

  /// Vibrant Lime (ring / chart highlight) — --ring: 75 81% 52% (#B8E822)
  static const Color ring = Color(0xFFB8E822);

  // ─── Semantic Colors ──────────────────────────────────────────
  
  /// --destructive: 0 84.2% 60.2% (#EF4444)
  static const Color destructive = Color(0xFFEF4444);
  static const Color destructiveForeground = Color(0xFFFFFFFF);
  
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  // ─── Surface Palette (Light Mode) ──────────────────────────────
  
  /// --background: 0 0% 100%
  static const Color background = Color(0xFFFFFFFF);
  
  /// --foreground: 0 0% 10% (#1A1A1A)
  static const Color foreground = Color(0xFF1A1A1A);
  
  /// --card: 0 0% 100%
  static const Color card = Color(0xFFFFFFFF);
  static const Color cardForeground = Color(0xFF1A1A1A);

  /// --muted: 0 0% 97% (#F8F8F8)
  static const Color muted = Color(0xFFF8F8F8);
  
  /// --muted-foreground: 0 0% 45% (#737373)
  static const Color mutedForeground = Color(0xFF737373);

  /// --border: 0 0% 0% / 0.08 (rgba(0,0,0,0.08))
  static const Color border = Color(0x14000000);
  
  /// Solid version of border for non-opacity containers
  static const Color borderSolid = Color(0xFFE5E5E5);
  
  /// --input: 0 0% 97%
  static const Color inputBackground = Color(0xFFF8F8F8);

  // ─── Chart / Statistics Palette ───────────────────────────────
  
  /// --chart-1: lima
  static const Color chart1 = Color(0xFFB8E822);
  
  /// --chart-2: coral
  static const Color chart2 = Color(0xFFFF8C61);
  
  /// --chart-3: salmon
  static const Color chart3 = Color(0xFFFFA586);
  
  /// --chart-4: rosa
  static const Color chart4 = Color(0xFFFFC4B0);
  
  /// --chart-5: crema
  static const Color chart5 = Color(0xFFFFE0D6);
}

/// Surface Palette (Dark Mode)
/// 
/// Values from .dark {} block in theme.css (converted from oklch).
class FudiColorsDark {
  FudiColorsDark._();

  /// oklch(0.985 0 0)
  static const Color primary = Color(0xFFFBFBFB);
  
  /// oklch(0.205 0 0)
  static const Color primaryForeground = Color(0xFF343434);
  
  /// oklch(0.145 0 0)
  static const Color background = Color(0xFF242424);
  static const Color foreground = Color(0xFFFBFBFB);
  
  /// oklch(0.269 0 0)
  static const Color muted = Color(0xFF454545);
  
  /// oklch(0.708 0 0)
  static const Color mutedForeground = Color(0xFFB4B4B4);
  
  /// oklch(0.396 0.141 25.723)
  static const Color destructive = Color(0xFFE54D4D);
  
  static const Color border = Color(0x33FFFFFF);
}
