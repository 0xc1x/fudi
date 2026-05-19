import 'package:flutter/material.dart';
import 'fudi_colors.dart';
import 'fudi_typography.dart';

enum FudiLogoVariant { primary, white, light }
enum FudiLogoSize { sm, md, lg }

/// Logo de Fudi estilizado.
///
/// Actualmente usa texto e iconos del sistema,
/// a reemplazar por SvgPicture cuando esté disponible.
class FudiLogo extends StatelessWidget {
  const FudiLogo({
    super.key,
    this.size = FudiLogoSize.md,
    this.variant = FudiLogoVariant.primary,
    this.showText = true,
  });

  final FudiLogoSize size;
  final FudiLogoVariant variant;
  final bool showText;

  @override
  Widget build(BuildContext context) {
    final double pixelSize = switch (size) {
      FudiLogoSize.sm => 18,
      FudiLogoSize.md => 24,
      FudiLogoSize.lg => 32,
    };

    final Color effectiveColor = switch (variant) {
      FudiLogoVariant.primary => Theme.of(context).colorScheme.primary,
      FudiLogoVariant.white => Colors.white,
      FudiLogoVariant.light => FudiColors.secondary,
    };

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.restaurant_menu_rounded, size: pixelSize, color: effectiveColor),
        if (showText) ...[
          const SizedBox(width: 8),
          Text(
            'Fudi',
            style: FudiTypography.h3.copyWith(
              color: effectiveColor,
              fontWeight: FontWeight.w700,
              fontSize: pixelSize * 0.9,
            ),
          ),
        ],
      ],
    );
  }
}

