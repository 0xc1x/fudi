import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'fudi_colors.dart';

enum FudiLogoVariant { icon, wordmark }
enum FudiLogoSize { sm, md, lg }

/// Logo de Fudi utilizando assets SVG.
/// 
/// Permite seleccionar entre el icono solo o el wordmark completo (Fudi),
/// así como personalizar el color y tamaño.
class FudiLogo extends StatelessWidget {
  const FudiLogo({
    super.key,
    this.variant = FudiLogoVariant.wordmark,
    this.size = FudiLogoSize.md,
    this.color,
    this.width,
  });

  final FudiLogoVariant variant;
  final FudiLogoSize size;
  final Color? color;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final double effectiveWidth = width ?? switch (size) {
      FudiLogoSize.sm => variant == FudiLogoVariant.icon ? 24.0 : 60.0,
      FudiLogoSize.md => variant == FudiLogoVariant.icon ? 32.0 : 80.0,
      FudiLogoSize.lg => variant == FudiLogoVariant.icon ? 48.0 : 120.0,
    };

    final Color effectiveColor = color ?? FudiColors.primary;

    final String assetPath = switch (variant) {
      FudiLogoVariant.icon => 'assets/svgs/icon.svg',
      FudiLogoVariant.wordmark => 'assets/svgs/role_wordmark.svg',
    };

    return SvgPicture.asset(
      assetPath,
      width: effectiveWidth,
      colorFilter: ColorFilter.mode(effectiveColor, BlendMode.srcIn),
    );
  }
}
