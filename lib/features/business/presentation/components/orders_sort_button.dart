import 'package:flutter/material.dart';

import '../../../../core/ui/fudi_colors.dart';
import '../../../../core/ui/fudi_spacing.dart';
import '../../../../core/ui/fudi_theme.dart';
import '../../../../core/ui/fudi_typography.dart';

enum OrdersSort {
  newest,
  oldest,
}

class OrdersSortButton extends StatelessWidget {
  const OrdersSortButton({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final OrdersSort value;
  final ValueChanged<OrdersSort> onChanged;

  static const _labels = {
    OrdersSort.newest: 'Más recientes',
    OrdersSort.oldest: 'Más antiguos',
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final themeExt = theme.extension<FudiThemeExtension>();
    return PopupMenuButton<OrdersSort>(
      onSelected: onChanged,
      offset: const Offset(0, 40),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: themeExt?.borderSolid ?? FudiColors.borderSolid),
      ),
      color: colorScheme.surface,
      itemBuilder: (context) => OrdersSort.values.map((sort) {
        final isSelected = sort == value;
        return PopupMenuItem<OrdersSort>(
          value: sort,
          child: Row(
            children: [
              Icon(
                isSelected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off,
                size: 18,
                color:
                    isSelected ? FudiColors.primary : colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: FudiSpacing.sm),
              Text(
                _labels[sort]!,
                style: FudiTypography.bodyMedium.copyWith(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color:
                      isSelected ? FudiColors.primary : colorScheme.onSurface,
                ),
              ),
            ],
          ),
        );
      }).toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: FudiSpacing.sm,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: themeExt?.mutedBackground ?? FudiColors.muted,
          borderRadius: BorderRadius.circular(FudiRadius.xs),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.swap_vert,
              size: 16,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 4),
            Text(
              _labels[value]!,
              style: FudiTypography.bodySmall.copyWith(
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
