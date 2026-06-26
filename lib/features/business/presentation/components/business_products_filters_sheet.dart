import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/ui/fudi_colors.dart';
import '../../../../core/ui/fudi_pressable_scale.dart';
import '../../../../core/ui/fudi_spacing.dart';
import '../../../../core/ui/fudi_typography.dart';
import '../../../offers/domain/offer_category.dart';
import '../business_providers.dart';

class BusinessProductsFiltersSheet extends ConsumerStatefulWidget {
  const BusinessProductsFiltersSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(FudiRadius.xl),
        ),
      ),
      builder: (_) => const BusinessProductsFiltersSheet(),
    );
  }

  @override
  ConsumerState<BusinessProductsFiltersSheet> createState() =>
      _BusinessProductsFiltersSheetState();
}

class _BusinessProductsFiltersSheetState
    extends ConsumerState<BusinessProductsFiltersSheet> {
  OfferCategory? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _selectedCategory = ref.read(productsCategoryFilterProvider);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        FudiSpacing.lg,
        FudiSpacing.lg,
        FudiSpacing.lg,
        MediaQuery.of(context).viewInsets.bottom + FudiSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: FudiColors.borderSolid,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: FudiSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Categoría', style: FudiTypography.h2),
              if (_selectedCategory != null)
                FudiPressableScale(
                  onTap: () => setState(() => _selectedCategory = null),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: Text(
                      'Limpiar',
                      style: FudiTypography.bodySmall.copyWith(
                        color: FudiColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: FudiSpacing.lg),
          Wrap(
            spacing: FudiSpacing.sm,
            runSpacing: FudiSpacing.sm,
            children: OfferCategory.values.map((cat) {
              final isSelected = _selectedCategory == cat;
              return FilterChip(
                label: Text(cat.dbValue),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _selectedCategory = selected ? cat : null;
                  });
                },
                selectedColor: FudiColors.secondary,
                checkmarkColor: FudiColors.primary,
                side: BorderSide(color: FudiColors.borderSolid),
              );
            }).toList(),
          ),
          const SizedBox(height: FudiSpacing.xl),
          FudiPressableScale(
            onTap: () {
              ref.read(productsCategoryFilterProvider.notifier).select(
                _selectedCategory,
              );
              Navigator.of(context).pop();
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: FudiColors.primary,
                borderRadius: BorderRadius.circular(FudiRadius.lg),
              ),
              child: Center(
                child: Text(
                  'Aplicar filtro',
                  style: FudiTypography.labelMedium.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
