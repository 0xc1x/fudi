import 'package:flutter/material.dart';
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
    final theme = Theme.of(context);
    final themeSecondary = theme.colorScheme.secondary;
    final themePrimary = theme.colorScheme.primary;
    final themeMutedForeground = theme.colorScheme.onSurface.withValues(alpha: 0.5);

    return Padding(
      padding: const EdgeInsets.only(right: FudiSpacing.xs),
      child: Chip(
        label: Text(label),
        onDeleted: onClear,
        deleteIconColor: themeMutedForeground,
        backgroundColor: backgroundColor ??
            themeSecondary.withValues(alpha: 0.3),
        side: BorderSide(
          color: borderColor ?? themePrimary.withValues(alpha: 0.2),
        ),
        labelStyle: FudiTypography.bodySmall.copyWith(
          color: textColor ?? themePrimary,
          fontWeight: FontWeight.w600,
        ),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}
