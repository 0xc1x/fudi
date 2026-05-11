import 'package:flutter/material.dart';

enum AppLogoSize { sm, md, lg }

enum AppLogoVariant { default_, light }

class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.size = AppLogoSize.md,
    this.variant = AppLogoVariant.default_,
  });

  final AppLogoSize size;
  final AppLogoVariant variant;

  double get _height {
    switch (size) {
      case AppLogoSize.sm:
        return 32;
      case AppLogoSize.md:
        return 48;
      case AppLogoSize.lg:
        return 64;
    }
  }

  String get _assetPath {
    switch (variant) {
      case AppLogoVariant.default_:
        return 'assets/images/logo_white.png';
      case AppLogoVariant.light:
        return 'assets/images/logo_color.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.asset(
        _assetPath,
        height: _height,
        fit: BoxFit.contain,
      ),
    );
  }
}
