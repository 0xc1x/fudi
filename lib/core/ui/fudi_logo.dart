import 'package:flutter/material.dart';
import 'fudi_typography.dart';

/// Logo de Fudi estilizado.
/// 
/// Actualmente usa texto e iconos del sistema, 
/// a reemplazar por SvgPicture cuando esté disponible.
class FudiLogo extends StatelessWidget {
  const FudiLogo({
    super.key,
    this.size = 24,
    this.showText = true,
    this.color,
  });

  final double size;
  final bool showText;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? Theme.of(context).colorScheme.primary;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.restaurant_menu_rounded,
          size: size,
          color: effectiveColor,
        ),
        if (showText) ...[
          const SizedBox(width: 8),
          Text(
            'Fudi',
            style: FudiTypography.h3.copyWith(
              color: effectiveColor,
              fontWeight: FontWeight.w700,
              fontSize: size * 0.9,
            ),
          ),
        ],
      ],
    );
  }
}
