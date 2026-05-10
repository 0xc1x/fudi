import 'package:flutter/material.dart';

import '../../../core/ui/fudi_colors.dart';
import '../../../core/ui/fudi_spacing.dart';
import '../../../core/ui/fudi_typography.dart';

class FudiFilterState {
  const FudiFilterState({
    this.category,
    this.maxPrice,
    this.maxDistanceKm,
    this.searchQuery,
  });

  final String? category;
  final double? maxPrice;
  final double? maxDistanceKm;
  final String? searchQuery;

  bool get hasActiveFilters =>
      category != null ||
      maxPrice != null ||
      maxDistanceKm != null ||
      (searchQuery != null && searchQuery!.isNotEmpty);

  FudiFilterState clear() => const FudiFilterState();

  FudiFilterState copyWith({
    String? category,
    double? maxPrice,
    double? maxDistanceKm,
    String? searchQuery,
    bool clearCategory = false,
    bool clearMaxPrice = false,
    bool clearMaxDistance = false,
    bool clearSearchQuery = false,
  }) {
    return FudiFilterState(
      category: clearCategory ? null : (category ?? this.category),
      maxPrice: clearMaxPrice ? null : (maxPrice ?? this.maxPrice),
      maxDistanceKm: clearMaxDistance ? null : (maxDistanceKm ?? this.maxDistanceKm),
      searchQuery: clearSearchQuery ? null : (searchQuery ?? this.searchQuery),
    );
  }
}

class FudiFiltersSheet extends StatefulWidget {
  const FudiFiltersSheet({
    required this.currentFilters,
    required this.onApply,
    super.key,
  });

  final FudiFilterState currentFilters;
  final ValueChanged<FudiFilterState> onApply;

  static Future<void> show(
    BuildContext context, {
    required FudiFilterState currentFilters,
    required ValueChanged<FudiFilterState> onApply,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(FudiRadius.xl)),
      ),
      builder: (_) => FudiFiltersSheet(
        currentFilters: currentFilters,
        onApply: onApply,
      ),
    );
  }

  @override
  State<FudiFiltersSheet> createState() => _FudiFiltersSheetState();
}

class _FudiFiltersSheetState extends State<FudiFiltersSheet> {
  late FudiFilterState _filters;

  static const _categories = [
    'Japanese',
    'Bakery',
    'Italian',
    'Cafe',
  ];

  static const _distanceOptions = [2.0, 5.0, 10.0];
  static const _priceOptions = [10000.0, 20000.0, 50000.0];

  @override
  void initState() {
    super.initState();
    _filters = widget.currentFilters;
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
              Text('Filtros', style: FudiTypography.h2),
              if (_filters.hasActiveFilters)
                TextButton(
                  onPressed: _clearAll,
                  child: Text(
                    'Limpiar todo',
                    style: FudiTypography.bodySmall.copyWith(
                      color: FudiColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: FudiSpacing.lg),
          Text('Categoría', style: FudiTypography.labelMedium),
          const SizedBox(height: FudiSpacing.sm),
          Wrap(
            spacing: FudiSpacing.sm,
            children: _categories.map((cat) {
              final key = cat.toLowerCase();
              final isSelected = _filters.category == key;
              return FilterChip(
                label: Text(cat),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _filters = _filters.copyWith(
                      category: selected ? key : null,
                      clearCategory: !selected,
                    );
                  });
                },
                selectedColor: FudiColors.secondary,
                checkmarkColor: FudiColors.primary,
                side: BorderSide(color: FudiColors.borderSolid),
              );
            }).toList(),
          ),
          const SizedBox(height: FudiSpacing.lg),
          Text('Distancia máxima', style: FudiTypography.labelMedium),
          const SizedBox(height: FudiSpacing.sm),
          Wrap(
            spacing: FudiSpacing.sm,
            children: _distanceOptions.map((km) {
              final isSelected = _filters.maxDistanceKm == km;
              return FilterChip(
                label: Text('${km.toInt()} km'),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _filters = _filters.copyWith(
                      maxDistanceKm: selected ? km : null,
                      clearMaxDistance: !selected,
                    );
                  });
                },
                selectedColor: FudiColors.secondary,
                checkmarkColor: FudiColors.primary,
                side: BorderSide(color: FudiColors.borderSolid),
              );
            }).toList(),
          ),
          const SizedBox(height: FudiSpacing.lg),
          Text('Precio máximo', style: FudiTypography.labelMedium),
          const SizedBox(height: FudiSpacing.sm),
          Wrap(
            spacing: FudiSpacing.sm,
            children: _priceOptions.map((price) {
              final isSelected = _filters.maxPrice == price;
              return FilterChip(
                label: Text('\$${price.toStringAsFixed(0)}'),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _filters = _filters.copyWith(
                      maxPrice: selected ? price : null,
                      clearMaxPrice: !selected,
                    );
                  });
                },
                selectedColor: FudiColors.secondary,
                checkmarkColor: FudiColors.primary,
                side: BorderSide(color: FudiColors.borderSolid),
              );
            }).toList(),
          ),
          const SizedBox(height: FudiSpacing.xl),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                widget.onApply(_filters);
                Navigator.of(context).pop();
              },
              style: FilledButton.styleFrom(
                backgroundColor: FudiColors.primary,
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(FudiRadius.lg),
                ),
              ),
              child: Text(
                'Aplicar filtros',
                style: FudiTypography.labelMedium.copyWith(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _clearAll() {
    setState(() {
      _filters = _filters.clear();
    });
  }
}
