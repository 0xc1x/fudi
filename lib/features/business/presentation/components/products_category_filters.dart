import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/ui/fudi_colors.dart';
import '../../../../core/ui/fudi_spacing.dart';
import '../../../../core/ui/fudi_typography.dart';
import '../../../offers/domain/offer_category.dart';
import '../business_providers.dart';

class ProductsCategoryFilters extends ConsumerWidget {
  const ProductsCategoryFilters({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategory = ref.watch(productsCategoryFilterProvider);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
            _CategoryChip(
            label: 'Todas',
            selected: selectedCategory == null,
            onTap: () =>
                ref.read(productsCategoryFilterProvider.notifier).select(null),
          ),
          const SizedBox(width: FudiSpacing.sm),
          for (final category in OfferCategory.values)
            _CategoryChip(
              label: category.emoji.isNotEmpty
                  ? '${category.emoji} ${category.dbValue}'
                  : category.dbValue,
              selected: selectedCategory == category,
              onTap: () => ref
                  .read(productsCategoryFilterProvider.notifier)
                  .select(category),
            ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: FudiSpacing.md,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: selected ? FudiColors.primary : FudiColors.background,
          borderRadius: BorderRadius.circular(FudiRadius.xl),
          border: Border.all(
            color: selected ? FudiColors.primary : FudiColors.borderSolid,
          ),
        ),
        child: Text(
          label,
          style: FudiTypography.bodySmall.copyWith(
            fontWeight: FontWeight.w500,
            color: selected ? Colors.white : FudiColors.foreground,
          ),
        ),
      ),
    );
  }
}
