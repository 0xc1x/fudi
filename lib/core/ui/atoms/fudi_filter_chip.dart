import 'package:flutter/material.dart';
import '../fudi_colors.dart';
import '../fudi_spacing.dart';
import '../fudi_typography.dart';

class FudiFilterChip extends StatelessWidget {
  const FudiFilterChip({
    super.key,
    required this.label,
    required this.onClear,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
  });

  final String label;
  final VoidCallback onClear;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: FudiSpacing.xs),
      child: Chip(
        label: Text(label),
        onDeleted: onClear,
        deleteIconColor: FudiColors.mutedForeground,
        backgroundColor: backgroundColor ??
            FudiColors.secondary.withValues(alpha: 0.3),
        side: BorderSide(
          color: borderColor ?? FudiColors.primary.withValues(alpha: 0.2),
        ),
        labelStyle: FudiTypography.bodySmall.copyWith(
          color: textColor ?? FudiColors.primary,
          fontWeight: FontWeight.w600,
        ),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}
