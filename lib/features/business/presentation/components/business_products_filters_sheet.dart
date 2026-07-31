import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/ui/fudi_colors.dart';
import '../../../../core/ui/fudi_pressable_scale.dart';
import '../../../../core/ui/fudi_spacing.dart';
import '../../../../core/ui/fudi_theme.dart';
import '../../../../core/ui/fudi_typography.dart';
import '../../../offers/domain/category.dart';
import '../../../offers/presentation/offer_providers.dart';
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
  String? _selectedCategoryId;
  List<Category> _categories = [];

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = ref.read(productsCategoryFilterProvider);
    unawaited(ref.read(categoriesProvider.future).then((cats) {
      if (mounted) setState(() => _categories = cats);
    }));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeExt = theme.extension<FudiThemeExtension>();
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
                color: themeExt?.borderSolid ?? FudiColors.borderSolid,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: FudiSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Categoría', style: FudiTypography.h2),
              if (_selectedCategoryId != null)
                FudiPressableScale(
                  onTap: () =>
                      setState(() => _selectedCategoryId = null),
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
          if (_categories.isEmpty)
            Text(
              'No hay categorías disponibles',
              style: FudiTypography.bodySmall.copyWith(
                color: FudiColors.mutedForeground,
              ),
            )
          else
            Wrap(
              spacing: FudiSpacing.sm,
              runSpacing: FudiSpacing.sm,
              children: _categories.map((cat) {
                final isSelected = _selectedCategoryId == cat.id;
                final label = (cat.emoji != null && cat.emoji!.isNotEmpty)
                    ? '${cat.emoji} ${cat.name}'
                    : cat.name;
                return FilterChip(
                  label: Text(label),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategoryId = selected ? cat.id : null;
                    });
                  },
                  selectedColor: FudiColors.secondary,
                  checkmarkColor: FudiColors.primary,
                  side: BorderSide(
                    color: themeExt?.borderSolid ?? FudiColors.borderSolid,
                  ),
                );
              }).toList(),
            ),
          const SizedBox(height: FudiSpacing.xl),
          FudiPressableScale(
            onTap: () {
              ref
                  .read(productsCategoryFilterProvider.notifier)
                  .select(_selectedCategoryId);
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
                    color: FudiColors.primaryForeground,
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
