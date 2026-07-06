import 'package:flutter/material.dart';
import '../../../../core/ui/fudi_colors.dart';
import '../../../../core/ui/fudi_logo.dart';
import '../../../../core/ui/fudi_pressable_scale.dart';
import '../../../../core/ui/fudi_search_bar.dart';
import '../../../../core/ui/fudi_spacing.dart';
import '../../../../core/ui/fudi_theme.dart';
import '../../../../core/ui/fudi_typography.dart';
import '../../../../core/ui/atoms/icons/fudi_icons.dart';

/// Header principal de la pantalla de explorar:
/// logo, título, barra de búsqueda y botones de mapa/filtros.
class ExploreHeader extends StatelessWidget {
  const ExploreHeader({
    super.key,
    required this.searchController,
    required this.onSubmitSearch,
    this.onSearchChanged,
    required this.onToggleMap,
    required this.onFilterTap,
    required this.hasActiveFilters,
  });

  final TextEditingController searchController;
  final ValueChanged<String> onSubmitSearch;
  final ValueChanged<String>? onSearchChanged;
  final VoidCallback onToggleMap;
  final VoidCallback onFilterTap;
  final bool hasActiveFilters;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeExt = theme.extension<FudiThemeExtension>();
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      color: isDark ? theme.colorScheme.surface : FudiColors.primary,
      padding: const EdgeInsets.fromLTRB(
        FudiSpacing.lg,
        FudiSpacing.lg + 8,
        FudiSpacing.lg,
        FudiSpacing.xl,
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const FudiLogo(
              variant: FudiLogoVariant.icon,
              size: FudiLogoSize.lg,
            ),
            const SizedBox(height: FudiSpacing.md),
            Text(
              'Explorar',
              style: FudiTypography.h1.copyWith(
                color: isDark ? theme.colorScheme.onSurface : FudiColors.primaryForeground,
              ),
            ),
            const SizedBox(height: FudiSpacing.md),
            FudiSearchBar(
              controller: searchController,
              hintText: 'Buscar restaurantes, productos...',
              onChanged: onSearchChanged,
              onSubmitted: onSubmitSearch,
              fillColor: isDark
                  ? (themeExt?.mutedBackground ?? theme.colorScheme.surfaceContainerLow)
                  : FudiColors.background,
              borderSide: BorderSide.none,
            ),
            const SizedBox(height: FudiSpacing.md),
            Row(
              children: [
                ExploreHeaderPillButton(
                  icon: FudiIcons.mapPin,
                  label: 'Ver mapa',
                  onTap: onToggleMap,
                ),
                const SizedBox(width: FudiSpacing.sm),
                ExploreHeaderPillButton(
                  icon: FudiIcons.slidersHorizontal,
                  label: 'Filtros',
                  onTap: onFilterTap,
                  hasIndicator: hasActiveFilters,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Botón píldora semitransparente usado en [ExploreHeader].
class ExploreHeaderPillButton extends StatelessWidget {
  const ExploreHeaderPillButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.hasIndicator = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool hasIndicator;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return FudiPressableScale(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: FudiSpacing.md,
          vertical: FudiSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isDark
              ? theme.colorScheme.onSurface.withValues(alpha: 0.08)
              : FudiColors.card.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(FudiRadius.md),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isDark ? theme.colorScheme.onSurface : FudiColors.primaryForeground,
            ),
            const SizedBox(width: FudiSpacing.xs),
            Text(
              label,
              style: FudiTypography.bodySmall.copyWith(
                color: isDark ? theme.colorScheme.onSurface : FudiColors.primaryForeground,
              ),
            ),
            if (hasIndicator) ...[
              const SizedBox(width: 4),
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: isDark ? theme.colorScheme.primary : FudiColors.ring,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
