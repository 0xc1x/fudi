/// Fudi Design System Spacing and Radius
///
/// Based on Tailwind spacing (p-1 to p-8) and --radius from React mockup.
class FudiSpacing {
  FudiSpacing._();

  /// xs - 4.0 (p-1)
  static const double xs = 4.0;

  /// sm - 8.0 (p-2)
  static const double sm = 8.0;

  /// md - 12.0 (p-3)
  static const double md = 12.0;

  /// lg - 16.0 (p-4)
  static const double lg = 16.0;

  /// xl - 24.0 (p-6)
  static const double xl = 24.0;

  /// xxl - 32.0 (p-8)
  static const double xxl = 32.0;
}

class FudiRadius {
  FudiRadius._();

  /// sm - 10.0 (calc(14-4))
  static const double sm = 10.0;

  /// md - 12.0 (calc(14-2))
  static const double md = 12.0;

  /// lg - 14.0 (base --radius: 0.875rem)
  static const double lg = 14.0;

  /// xl - 18.0 (calc(14+4))
  static const double xl = 18.0;

  /// full - 9999.0 (rounded-full)
  static const double full = 9999.0;

  /// xxl - 24.0 (extra extra large)
  static const double xxl = 24.0;
}
