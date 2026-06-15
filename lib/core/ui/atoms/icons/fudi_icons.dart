import 'package:flutter/widgets.dart';

/// Centralized Fudi icons using Lucide font glyphs.
///
/// Source: lucide_icons 0.257.0 codepoints.
/// Rebuilt with direct [IconData] construction to avoid
/// the deprecated `extends IconData` pattern that breaks
/// on Flutter 3.44+ where [IconData] is `final`.
///
/// Notes on naming:
/// - Lucide icons are outline by default, so `heartOutline`
///   and `mapPinOutline` use the same codepoint as their
///   filled counterparts (Lucide has no separate outline variant).
/// - `error` → `alertCircle`, `favorites` → `heart`,
///   `offline` → `wifiOff`, `orders` → `shoppingBag`,
///   `storefront` → `store` (closest Lucide equivalents).
class FudiIcons {
  FudiIcons._();

  // Navigation
  static const IconData home = IconData(0xf35e, fontFamily: 'Lucide', fontPackage: 'lucide_icons');
  static const IconData search = IconData(0xf4ad, fontFamily: 'Lucide', fontPackage: 'lucide_icons');
  static const IconData user = IconData(0xf564, fontFamily: 'Lucide', fontPackage: 'lucide_icons');
  static const IconData mapPin = IconData(0xf3c0, fontFamily: 'Lucide', fontPackage: 'lucide_icons');
  static const IconData favorites = IconData(0xf354, fontFamily: 'Lucide', fontPackage: 'lucide_icons');
  static const IconData orders = IconData(0xf4c7, fontFamily: 'Lucide', fontPackage: 'lucide_icons');

  // Chevrons & Arrows
  static const IconData chevronDown = IconData(0xf1f5, fontFamily: 'Lucide', fontPackage: 'lucide_icons');
  static const IconData chevronRight = IconData(0xf1fb, fontFamily: 'Lucide', fontPackage: 'lucide_icons');
  static const IconData chevronLeft = IconData(0xf1f9, fontFamily: 'Lucide', fontPackage: 'lucide_icons');
  static const IconData arrowLeft = IconData(0xf14f, fontFamily: 'Lucide', fontPackage: 'lucide_icons');
  static const IconData navigation = IconData(0xf407, fontFamily: 'Lucide', fontPackage: 'lucide_icons');

  // Business & Offers
  static const IconData star = IconData(0xf500, fontFamily: 'Lucide', fontPackage: 'lucide_icons');
  static const IconData starHalf = IconData(0xf501, fontFamily: 'Lucide', fontPackage: 'lucide_icons');
  static const IconData starOutline = IconData(0xf502, fontFamily: 'Lucide', fontPackage: 'lucide_icons');
  static const IconData clock = IconData(0xf221, fontFamily: 'Lucide', fontPackage: 'lucide_icons');
  static const IconData calendar = IconData(0xf180, fontFamily: 'Lucide', fontPackage: 'lucide_icons');
  static const IconData store = IconData(0xf509, fontFamily: 'Lucide', fontPackage: 'lucide_icons');
  static const IconData package_ = IconData(0xf414, fontFamily: 'Lucide', fontPackage: 'lucide_icons');
  static const IconData shoppingBag = IconData(0xf4c7, fontFamily: 'Lucide', fontPackage: 'lucide_icons');
  static const IconData building2 = IconData(0xf1cd, fontFamily: 'Lucide', fontPackage: 'lucide_icons');
  static const IconData storefront = IconData(0xf509, fontFamily: 'Lucide', fontPackage: 'lucide_icons');
  static const IconData tag = IconData(0xf521, fontFamily: 'Lucide', fontPackage: 'lucide_icons');
  static const IconData qrCode = IconData(0xf46e, fontFamily: 'Lucide', fontPackage: 'lucide_icons');

  // Actions
  static const IconData plus = IconData(0xf45e, fontFamily: 'Lucide', fontPackage: 'lucide_icons');
  static const IconData edit = IconData(0xf292, fontFamily: 'Lucide', fontPackage: 'lucide_icons');
  static const IconData delete = IconData(0xf546, fontFamily: 'Lucide', fontPackage: 'lucide_icons');
  static const IconData share = IconData(0xf4bd, fontFamily: 'Lucide', fontPackage: 'lucide_icons');
  static const IconData filter = IconData(0xf4db, fontFamily: 'Lucide', fontPackage: 'lucide_icons');
  static const IconData slidersHorizontal = IconData(0xf4dc, fontFamily: 'Lucide', fontPackage: 'lucide_icons');
  static const IconData x = IconData(0xf59e, fontFamily: 'Lucide', fontPackage: 'lucide_icons');
  static const IconData xCircle = IconData(0xf59f, fontFamily: 'Lucide', fontPackage: 'lucide_icons');
  static const IconData logOut = IconData(0xf3b0, fontFamily: 'Lucide', fontPackage: 'lucide_icons');
  static const IconData zoomIn = IconData(0xf5a5, fontFamily: 'Lucide', fontPackage: 'lucide_icons');
  static const IconData zoomOut = IconData(0xf5a6, fontFamily: 'Lucide', fontPackage: 'lucide_icons');
  static const IconData checkCircle = IconData(0xf1f0, fontFamily: 'Lucide', fontPackage: 'lucide_icons');
  static const IconData imageOff = IconData(0xf367, fontFamily: 'Lucide', fontPackage: 'lucide_icons');
  static const IconData heart = IconData(0xf354, fontFamily: 'Lucide', fontPackage: 'lucide_icons');
  static const IconData heartOutline = IconData(0xf354, fontFamily: 'Lucide', fontPackage: 'lucide_icons');
  static const IconData mapPinOutline = IconData(0xf3c0, fontFamily: 'Lucide', fontPackage: 'lucide_icons');

  // Profile & Settings
  static const IconData bell = IconData(0xf19c, fontFamily: 'Lucide', fontPackage: 'lucide_icons');
  static const IconData creditCard = IconData(0xf264, fontFamily: 'Lucide', fontPackage: 'lucide_icons');
  static const IconData helpCircle = IconData(0xf359, fontFamily: 'Lucide', fontPackage: 'lucide_icons');
  static const IconData settings = IconData(0xf4b9, fontFamily: 'Lucide', fontPackage: 'lucide_icons');
  static const IconData userCircle = IconData(0xf568, fontFamily: 'Lucide', fontPackage: 'lucide_icons');
  static const IconData mail = IconData(0xf3b4, fontFamily: 'Lucide', fontPackage: 'lucide_icons');
  static const IconData lock = IconData(0xf3ae, fontFamily: 'Lucide', fontPackage: 'lucide_icons');
  static const IconData eye = IconData(0xf29c, fontFamily: 'Lucide', fontPackage: 'lucide_icons');
  static const IconData eyeOff = IconData(0xf29d, fontFamily: 'Lucide', fontPackage: 'lucide_icons');
  static const IconData phone = IconData(0xf440, fontFamily: 'Lucide', fontPackage: 'lucide_icons');
  static const IconData messageSquare = IconData(0xf3ce, fontFamily: 'Lucide', fontPackage: 'lucide_icons');

  // Status & Semantic
  static const IconData alertTriangle = IconData(0xf10d, fontFamily: 'Lucide', fontPackage: 'lucide_icons');
  static const IconData alertCircle = IconData(0xf10b, fontFamily: 'Lucide', fontPackage: 'lucide_icons');
  static const IconData error = IconData(0xf10b, fontFamily: 'Lucide', fontPackage: 'lucide_icons');
  static const IconData info = IconData(0xf36e, fontFamily: 'Lucide', fontPackage: 'lucide_icons');
  static const IconData success = IconData(0xf1f0, fontFamily: 'Lucide', fontPackage: 'lucide_icons');
  static const IconData leaf = IconData(0xf38f, fontFamily: 'Lucide', fontPackage: 'lucide_icons');
  static const IconData award = IconData(0xf172, fontFamily: 'Lucide', fontPackage: 'lucide_icons');
  static const IconData trendingUp = IconData(0xf54c, fontFamily: 'Lucide', fontPackage: 'lucide_icons');
  static const IconData offline = IconData(0xf597, fontFamily: 'Lucide', fontPackage: 'lucide_icons');
}
