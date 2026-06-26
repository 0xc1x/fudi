import 'package:flutter/material.dart';
import '../../../../core/ui/atoms/fudi_filter_chip.dart';
import '../../../../core/ui/fudi_colors.dart';
import '../../../../core/ui/fudi_pressable_scale.dart';
import '../../../../core/ui/fudi_spacing.dart';
import '../../../../core/ui/fudi_typography.dart';
import '../fudi_filters.dart';

/// Barra de chips activos que muestra los filtros aplicados con opción de
/// eliminarlos individualmente o limpiar todo.
class ExploreActiveFiltersBar extends StatelessWidget {
  const ExploreActiveFiltersBar({
    super.key,
    required this.filters,
    required this.onClear,
    required this.onClearAll,
  });

  final FudiFilterState filters;
  final ValueChanged<String> onClear;
  final VoidCallback onClearAll;

  @override
  Widget build(BuildContext context) {
    final chips = <Widget>[];

    if (filters.category != null) {
      chips.add(
        _ExploreFilterChip(
          label: filters.category!.dbValue,
          onClear: () => onClear('category'),
        ),
      );
    }
    if (filters.maxDistanceKm != null) {
      chips.add(
        _ExploreFilterChip(
          label: '${filters.maxDistanceKm!.toInt()} km',
          onClear: () => onClear('maxDistanceKm'),
        ),
      );
    }
    if (filters.maxPrice != null) {
      chips.add(
        _ExploreFilterChip(
          label: 'Max \$${filters.maxPrice!.toStringAsFixed(0)}',
          onClear: () => onClear('maxPrice'),
        ),
      );
    }
    if (filters.searchQuery != null && filters.searchQuery!.isNotEmpty) {
      chips.add(
        _ExploreFilterChip(
          label: '"${filters.searchQuery}"',
          onClear: () => onClear('searchQuery'),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: FudiSpacing.lg,
        vertical: FudiSpacing.sm,
      ),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: chips),
            ),
          ),
          FudiPressableScale(
            onTap: onClearAll,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: FudiSpacing.sm,
                vertical: FudiSpacing.xs,
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
    );
  }
}

class _ExploreFilterChip extends StatelessWidget {
  const _ExploreFilterChip({required this.label, required this.onClear});

  final String label;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return FudiFilterChip(label: label, onClear: onClear);
  }
}
