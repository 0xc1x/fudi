import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/ui/fudi_colors.dart';
import '../../../../core/ui/fudi_spacing.dart';
import '../../../../core/ui/fudi_typography.dart';
import '../../../offers/presentation/offer_providers.dart';
import '../business_providers.dart';

class ProductsCategoryFilters extends ConsumerWidget {
  const ProductsCategoryFilters({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategoryId = ref.watch(productsCategoryFilterProvider);
    final categoriesAsync = ref.watch(categoriesProvider);

    return categoriesAsync.when(
      data: (categories) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _CategoryChip(
              label: 'Todas',
              selected: selectedCategoryId == null,
              onTap: () =>
                  ref.read(productsCategoryFilterProvider.notifier).select(null),
            ),
            const SizedBox(width: FudiSpacing.sm),
            for (final category in categories)
              _CategoryChip(
                label: (category.emoji != null && category.emoji!.isNotEmpty)
                    ? '${category.emoji} ${category.name}'
                    : category.name,
                selected: selectedCategoryId == category.id,
                onTap: () => ref
                    .read(productsCategoryFilterProvider.notifier)
                    .select(category.id),
              ),
          ],
        ),
      ),
      loading: () => const SizedBox(
        height: 40,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      error: (_, _) => const SizedBox.shrink(),
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
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: FudiSpacing.md,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: selected ? FudiColors.primary : colorScheme.surface,
          borderRadius: BorderRadius.circular(FudiRadius.xl),
          border: Border.all(
            color: selected ? FudiColors.primary : colorScheme.outlineVariant,
          ),
        ),
        child: Text(
          label,
          style: FudiTypography.bodySmall.copyWith(
            fontWeight: FontWeight.w500,
            color: selected ? FudiColors.primaryForeground : colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}
