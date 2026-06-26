import 'package:flutter/material.dart';

import '../fudi_colors.dart';
import '../fudi_spacing.dart';
import '../fudi_typography.dart';
import '../fudi_surface_card.dart';

class FudiStatCard extends StatelessWidget {
  const FudiStatCard({
    super.key,
    this.icon,
    required this.value,
    required this.label,
    this.valueColor,
    this.labelColor,
    this.backgroundColor,
    this.iconColor,
    this.border,
    this.valueStyle = FudiStatCardValueStyle.medium,
    this.padding = const EdgeInsets.all(FudiSpacing.md),
    this.borderRadius,
    this.useSurfaceCard = false,
  });

  final IconData? icon;
  final String value;
  final String label;
  final Color? valueColor;
  final Color? labelColor;
  final Color? backgroundColor;
  final Color? iconColor;
  final BoxBorder? border;
  final FudiStatCardValueStyle valueStyle;
  final EdgeInsetsGeometry padding;
  final double? borderRadius;
  final bool useSurfaceCard;

  @override
  Widget build(BuildContext context) {
    final resolvedValueColor = valueColor ?? FudiColors.primary;
    final resolvedLabelColor =
        labelColor ?? FudiColors.primary.withValues(alpha: 0.6);

    final child = Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(
            icon,
            size: 20,
            color: iconColor ?? resolvedValueColor.withValues(alpha: 0.6),
          ),
          const SizedBox(height: FudiSpacing.xs),
        ],
        Text(
          value,
          style: valueStyle.textStyle.copyWith(color: resolvedValueColor),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: valueStyle == FudiStatCardValueStyle.large ? 2 : 4),
        Text(
          label,
          style: FudiTypography.bodySmall.copyWith(
            fontSize: valueStyle == FudiStatCardValueStyle.large ? 11 : 12,
            color: resolvedLabelColor,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );

    if (useSurfaceCard) {
      return FudiSurfaceCard(
        padding: padding,
        child: child,
      );
    }

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(borderRadius ?? FudiRadius.xl),
        border: border,
      ),
      child: child,
    );
  }
}

enum FudiStatCardValueStyle {
  small,
  medium,
  large;

  TextStyle get textStyle {
    return switch (this) {
      FudiStatCardValueStyle.small => const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      FudiStatCardValueStyle.medium => const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      FudiStatCardValueStyle.large => const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
    };
  }
}
