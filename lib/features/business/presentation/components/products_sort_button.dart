import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/ui/fudi_colors.dart';
import '../../../../core/ui/fudi_spacing.dart';
import '../../../../core/ui/fudi_theme.dart';
import '../../../../core/ui/fudi_typography.dart';
import '../business_providers.dart';

class ProductsSortButton extends ConsumerWidget {
  const ProductsSortButton({super.key});

  static const _labels = {
    ProductsSort.newest: 'Más recientes',
    ProductsSort.nameAZ: 'Nombre A-Z',
    ProductsSort.nameZA: 'Nombre Z-A',
    ProductsSort.priceLow: 'Menor precio',
    ProductsSort.priceHigh: 'Mayor precio',
    ProductsSort.stockLow: 'Menor stock',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(productsSortProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final mutedBg = theme.extension<FudiThemeExtension>()?.mutedBackground ?? FudiColors.muted;

    return PopupMenuButton<ProductsSort>(
      onSelected: (value) =>
          ref.read(productsSortProvider.notifier).select(value),
      offset: const Offset(0, 40),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      color: colorScheme.surface,
      itemBuilder: (context) => ProductsSort.values.map((sort) {
        final isSelected = sort == current;
        return PopupMenuItem<ProductsSort>(
          value: sort,
          child: Row(
            children: [
              Icon(
                isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                size: 18,
                color: isSelected ? FudiColors.primary : colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: FudiSpacing.sm),
              Text(
                _labels[sort]!,
                style: FudiTypography.bodyMedium.copyWith(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? FudiColors.primary : colorScheme.onSurface,
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
          color: mutedBg,
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
              _labels[current]!,
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
