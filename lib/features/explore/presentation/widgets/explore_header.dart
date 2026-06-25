import 'package:flutter/material.dart';
import '../../../../core/ui/fudi_colors.dart';
import '../../../../core/ui/fudi_logo.dart';
import '../../../../core/ui/fudi_search_bar.dart';
import '../../../../core/ui/fudi_spacing.dart';
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
    return Container(
      color: FudiColors.primary,
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
                color: FudiColors.primaryForeground,
              ),
            ),
            const SizedBox(height: FudiSpacing.md),
            FudiSearchBar(
              controller: searchController,
              hintText: 'Buscar restaurantes, productos...',
              onChanged: onSearchChanged,
              onSubmitted: onSubmitSearch,
              fillColor: FudiColors.background,
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
/// Botón píldora semitransparente con animación de toque
class ExploreHeaderPillButton extends StatefulWidget {
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
  State<ExploreHeaderPillButton> createState() =>
      _ExploreHeaderPillButtonState();
}

class _ExploreHeaderPillButtonState extends State<ExploreHeaderPillButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onTap();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Opacity(
              opacity: _scaleAnimation.value < 1.0 ? 0.85 : 1.0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: FudiSpacing.md,
                  vertical: FudiSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(FudiRadius.md),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      widget.icon,
                      size: 16,
                      color: FudiColors.primaryForeground,
                    ),
                    const SizedBox(width: FudiSpacing.xs),
                    Text(
                      widget.label,
                      style: FudiTypography.bodySmall.copyWith(
                        color: FudiColors.primaryForeground,
                      ),
                    ),
                    if (widget.hasIndicator) ...[
                      const SizedBox(width: 4),
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: FudiColors.ring,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
