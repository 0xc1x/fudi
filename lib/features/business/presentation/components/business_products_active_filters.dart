import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/ui/fudi_colors.dart';
import '../../../../core/ui/fudi_pressable_scale.dart';
import '../../../../core/ui/fudi_spacing.dart';
import '../../../../core/ui/fudi_typography.dart';
import '../business_providers.dart';
import 'business_products_filters_sheet.dart';

class BusinessProductsActiveFilters extends ConsumerWidget {
  const BusinessProductsActiveFilters({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasActiveFilters =
        ref.watch(productsCategoryFilterProvider) != null;

    return FudiPressableScale(
      onTap: () => BusinessProductsFiltersSheet.show(context),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: FudiSpacing.md,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: hasActiveFilters
              ? FudiColors.primary
              : FudiColors.background,
          borderRadius: BorderRadius.circular(FudiRadius.xl),
          border: Border.all(
            color: hasActiveFilters
                ? FudiColors.primary
                : FudiColors.borderSolid,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.filter_list_rounded,
              size: 18,
              color: hasActiveFilters ? Colors.white : FudiColors.foreground,
            ),
            const SizedBox(width: 4),
            Text(
              'Filtrar',
              style: FudiTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
                color: hasActiveFilters ? Colors.white : FudiColors.foreground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
