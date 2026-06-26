import 'package:flutter/material.dart';

import '../fudi_colors.dart';
import '../fudi_spacing.dart';
import '../fudi_typography.dart';

class FudiKeyValueRow extends StatelessWidget {
  const FudiKeyValueRow({
    required this.label,
    required this.value,
    this.icon,
    this.iconColor,
    this.valueColor,
    this.iconSize = 18,
    super.key,
  });

  final IconData? icon;
  final Color? iconColor;
  final String label;
  final String value;
  final Color? valueColor;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(
            icon,
            size: iconSize,
            color: iconColor ?? valueColor ?? FudiColors.mutedForeground,
          ),
          const SizedBox(width: FudiSpacing.sm),
        ],
        Text(label, style: FudiTypography.bodyMedium),
        const Spacer(),
        Text(
          value,
          style: FudiTypography.labelSmall.copyWith(
            color: valueColor ?? FudiColors.foreground,
          ),
        ),
      ],
    );
  }
}
