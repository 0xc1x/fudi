import 'package:flutter/material.dart';
import '../fudi_colors.dart';
import '../fudi_spacing.dart';
import '../fudi_typography.dart';

class FudiChip extends StatelessWidget {
  const FudiChip({
    super.key,
    required this.label,
    this.icon,
    this.backgroundColor = FudiColors.muted,
    this.iconColor = FudiColors.mutedForeground,
    this.labelColor = FudiColors.foreground,
    this.borderRadius,
    this.horizontalPadding = FudiSpacing.sm,
    this.verticalPadding = 6,
    this.fontSize,
    this.fontWeight = FontWeight.w500,
  });

  final String label;
  final IconData? icon;
  final Color backgroundColor;
  final Color? iconColor;
  final Color labelColor;
  final double? borderRadius;
  final double horizontalPadding;
  final double verticalPadding;
  final double? fontSize;
  final FontWeight fontWeight;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius ?? FudiRadius.xs),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: iconColor ?? FudiColors.mutedForeground),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: FudiTypography.bodySmall.copyWith(
              fontWeight: fontWeight,
              color: labelColor,
              fontSize: fontSize,
            ),
          ),
        ],
      ),
    );
  }
}
