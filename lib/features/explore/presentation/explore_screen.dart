import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/ui/app_logo.dart';
import '../../../core/ui/cards/deal_card.dart';
import '../../../core/ui/fudi_colors.dart';
import '../../../core/ui/fudi_icons.dart';
import '../../../core/ui/fudi_spacing.dart';
import '../../../core/ui/fudi_typography.dart';
import '../../offers/domain/offer.dart';
import '../../offers/presentation/offer_providers.dart';
import 'fudi_filters.dart';
import 'map_view.dart';

const _categories = [
  (id: 'bakery', name: 'Panadería', count: 24, emoji: '🥖'),
  (id: 'restaurant', name: 'Restaurantes', count: 45, emoji: '🍽️'),
  (id: 'cafe', name: 'Cafeterías', count: 18, emoji: '☕'),
  (id: 'grocery', name: 'Supermercados', count: 12, emoji: '🛒'),
  (id: 'pastry', name: 'Pastelería', count: 15, emoji: '🍰'),
  (id: 'asian', name: 'Comida Asiática', count: 22, emoji: '🍜'),
];

const _popularAreas = [
  (name: 'Chapinero', deals: 32),
  (name: 'Zona Rosa', deals: 28),
  (name: 'La Candelaria', deals: 41),
  (name: 'Usaquén', deals: 19),
];

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  final _searchController = TextEditingController();
  FudiFilterState _filters = const FudiFilterState();
  bool _viewModeMap = false;
  String? _selectedCategory;
  String? _selectedArea;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_viewModeMap) {
      return ExploreMapView(
        onBack: _toggleViewMode,
        filters: _filters,
        onFiltersChanged: _applyFilters,
      );
    }

    final offersAsync = ref.watch(filteredOffersProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _ExploreHeader(
              searchController: _searchController,
              onSubmitSearch: _submitSearch,
              onToggleMap: _toggleViewMode,
              onFilterTap: () => FudiFiltersSheet.show(
                context,
                currentFilters: _filters,
                onApply: _applyFilters,
              ),
              hasActiveFilters: _filters.hasActiveFilters,
            ),
          ),
          if (_filters.hasActiveFilters)
            SliverToBoxAdapter(
              child: _ActiveFiltersBar(
                filters: _filters,
                onClear: _clearFilter,
                onClearAll: _clearAllFilters,
              ),
            ),
          SliverToBoxAdapter(
            child: _CategoryGrid(
              selectedCategory: _selectedCategory,
              onCategoryTap: _handleCategoryTap,
            ),
          ),
          SliverToBoxAdapter(
            child: _PopularAreasSection(
              selectedArea: _selectedArea,
              onAreaTap: _handleAreaTap,
            ),
          ),
          const SliverToBoxAdapter(child: _TipSection()),
          SliverToBoxAdapter(
            child: _SectionHeader(title: 'Ofertas disponibles', onSeeAll: null),
          ),
          offersAsync.when(
            data: (offers) => offers.isEmpty
                ? const SliverFillRemaining(child: _EmptyExploreState())
                : SliverPadding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: FudiSpacing.lg,
                      vertical: FudiSpacing.sm,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => Padding(
                          padding: const EdgeInsets.only(
                            bottom: FudiSpacing.md,
                          ),
                          child: _buildDealCard(context, offers[index]),
                        ),
                        childCount: offers.length,
                      ),
                    ),
                  ),
            loading: () => SliverPadding(
              padding: const EdgeInsets.symmetric(
                horizontal: FudiSpacing.lg,
                vertical: FudiSpacing.sm,
              ),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, _) => const Padding(
                    padding: EdgeInsets.only(bottom: FudiSpacing.md),
                    child: _DealCardSkeleton(),
                  ),
                  childCount: 5,
                ),
              ),
            ),
            error: (error, _) => SliverFillRemaining(
              child: _ErrorState(message: error.toString()),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: FudiSpacing.xxl)),
        ],
      ),
    );
  }

  Widget _buildDealCard(BuildContext context, Offer offer) {
    final distance = _formatDistance(offer);
    return DealCard(
      imageUrl: offer.imageUrl ?? '',
      businessName: offer.business.name,
      businessType: offer.business.type,
      originalPrice: offer.originalPrice,
      discountedPrice: offer.discountedPrice,
      rating: offer.rating,
      distance: distance,
      availableQuantity: offer.stock,
      pickupUntil: offer.pickupUntilTimeOfDay,
      categoryLabel: offer.categoryLabel.isNotEmpty
          ? offer.categoryLabel
          : null,
      onTap: () => context.go('/product/${offer.id}'),
    );
  }

  String _formatDistance(Offer offer) {
    if (offer.business.latitude == null || offer.business.longitude == null) {
      return '';
    }
    return '${offer.business.latitude!.toStringAsFixed(1)}km';
  }

  void _toggleViewMode() {
    setState(() => _viewModeMap = !_viewModeMap);
  }

  void _submitSearch(String query) {
    _filters = _filters.copyWith(searchQuery: query);
    _loadOffers();
  }

  void _applyFilters(FudiFilterState filters) {
    setState(() => _filters = filters);
    _loadOffers();
  }

  void _handleCategoryTap(String categoryId) {
    setState(() {
      _selectedCategory = _selectedCategory == categoryId ? null : categoryId;
      if (_selectedCategory != null) {
        _filters = _filters.copyWith(category: _selectedCategory);
        _viewModeMap = true;
      } else {
        _filters = _filters.copyWith(clearCategory: true);
      }
    });
    _loadOffers();
  }

  void _handleAreaTap(String areaName) {
    setState(() {
      _selectedArea = _selectedArea == areaName ? null : areaName;
      if (_selectedArea != null) {
        _viewModeMap = true;
      }
    });
  }

  void _clearFilter(String key) {
    setState(() {
      switch (key) {
        case 'category':
          _filters = _filters.copyWith(clearCategory: true);
          _selectedCategory = null;
          break;
        case 'maxPrice':
          _filters = _filters.copyWith(clearMaxPrice: true);
          break;
        case 'maxDistanceKm':
          _filters = _filters.copyWith(clearMaxDistance: true);
          break;
        case 'searchQuery':
          _filters = _filters.copyWith(clearSearchQuery: true);
          _searchController.clear();
          break;
      }
    });
    _loadOffers();
  }

  void _clearAllFilters() {
    setState(() {
      _filters = _filters.clear();
      _searchController.clear();
      _selectedCategory = null;
      _selectedArea = null;
    });
    _loadOffers();
  }

  void _loadOffers() {
    ref
        .read(filteredOffersProvider.notifier)
        .applyFilters(
          category: _filters.category,
          maxPrice: _filters.maxPrice,
          maxDistanceKm: _filters.maxDistanceKm,
          searchQuery: _filters.searchQuery,
        );
  }
}

class _ExploreHeader extends StatelessWidget {
  const _ExploreHeader({
    required this.searchController,
    required this.onSubmitSearch,
    required this.onToggleMap,
    required this.onFilterTap,
    required this.hasActiveFilters,
  });

  final TextEditingController searchController;
  final ValueChanged<String> onSubmitSearch;
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
            const AppLogo(size: AppLogoSize.lg, variant: AppLogoVariant.light),
            const SizedBox(height: FudiSpacing.md),
            Text(
              'Explorar',
              style: FudiTypography.h1.copyWith(
                color: FudiColors.primaryForeground,
              ),
            ),
            const SizedBox(height: FudiSpacing.md),
            TextField(
              controller: searchController,
              onSubmitted: onSubmitSearch,
              decoration: InputDecoration(
                hintText: 'Buscar restaurantes, productos...',
                hintStyle: FudiTypography.bodyMedium.copyWith(
                  color: FudiColors.mutedForeground,
                ),
                prefixIcon: const Icon(
                  FudiIcons.search,
                  color: FudiColors.mutedForeground,
                ),
                filled: true,
                fillColor: FudiColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(FudiRadius.lg),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: FudiSpacing.lg,
                  vertical: FudiSpacing.md,
                ),
              ),
              style: FudiTypography.bodyMedium,
            ),
            const SizedBox(height: FudiSpacing.md),
            Row(
              children: [
                _HeaderPillButton(
                  icon: FudiIcons.mapPin,
                  label: 'Ver mapa',
                  onTap: onToggleMap,
                ),
                const SizedBox(width: FudiSpacing.sm),
                _HeaderPillButton(
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

class _HeaderPillButton extends StatelessWidget {
  const _HeaderPillButton({
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
    return GestureDetector(
      onTap: onTap,
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
            Icon(icon, size: 16, color: FudiColors.primaryForeground),
            const SizedBox(width: FudiSpacing.xs),
            Text(
              label,
              style: FudiTypography.bodySmall.copyWith(
                color: FudiColors.primaryForeground,
              ),
            ),
            if (hasIndicator) ...[
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
    );
  }
}

class _CategoryGrid extends StatelessWidget {
  const _CategoryGrid({
    required this.selectedCategory,
    required this.onCategoryTap,
  });

  final String? selectedCategory;
  final ValueChanged<String> onCategoryTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        FudiSpacing.lg,
        FudiSpacing.lg,
        FudiSpacing.lg,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Categorías', style: FudiTypography.headlineSmall),
          const SizedBox(height: FudiSpacing.md),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: FudiSpacing.sm,
            crossAxisSpacing: FudiSpacing.sm,
            childAspectRatio: 1.35,
            children: _categories.map((cat) {
              final isSelected = selectedCategory == cat.id;
              return _CategoryCard(
                emoji: cat.emoji,
                name: cat.name,
                count: cat.count,
                isSelected: isSelected,
                onTap: () => onCategoryTap(cat.id),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.emoji,
    required this.name,
    required this.count,
    required this.isSelected,
    required this.onTap,
  });

  final String emoji;
  final String name;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(FudiSpacing.md),
        decoration: BoxDecoration(
          color: isSelected
              ? FudiColors.primary.withValues(alpha: 0.05)
              : FudiColors.background,
          borderRadius: BorderRadius.circular(FudiRadius.lg),
          border: Border.all(
            color: isSelected ? FudiColors.primary : FudiColors.borderSolid,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: FudiColors.primary.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: FudiSpacing.sm),
            Text(
              name,
              style: FudiTypography.labelSmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text('$count lugares', style: FudiTypography.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _PopularAreasSection extends StatelessWidget {
  const _PopularAreasSection({
    required this.selectedArea,
    required this.onAreaTap,
  });

  final String? selectedArea;
  final ValueChanged<String> onAreaTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(FudiSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Zonas populares', style: FudiTypography.headlineSmall),
          const SizedBox(height: FudiSpacing.md),
          ..._popularAreas.map((area) {
            final isSelected = selectedArea == area.name;
            return Padding(
              padding: const EdgeInsets.only(bottom: FudiSpacing.sm),
              child: _AreaCard(
                name: area.name,
                deals: area.deals,
                isSelected: isSelected,
                onTap: () => onAreaTap(area.name),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _AreaCard extends StatelessWidget {
  const _AreaCard({
    required this.name,
    required this.deals,
    required this.isSelected,
    required this.onTap,
  });

  final String name;
  final int deals;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(FudiSpacing.md),
        decoration: BoxDecoration(
          color: isSelected
              ? FudiColors.primary.withValues(alpha: 0.05)
              : FudiColors.background,
          borderRadius: BorderRadius.circular(FudiRadius.lg),
          border: Border.all(
            color: isSelected ? FudiColors.primary : FudiColors.borderSolid,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: FudiColors.primary.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected ? FudiColors.primary : FudiColors.secondary,
                shape: BoxShape.circle,
              ),
              child: Icon(
                FudiIcons.mapPin,
                size: 20,
                color: isSelected
                    ? FudiColors.primaryForeground
                    : FudiColors.primary,
              ),
            ),
            const SizedBox(width: FudiSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: FudiTypography.labelSmall),
                  Text(
                    '$deals ofertas disponibles',
                    style: FudiTypography.bodySmall,
                  ),
                ],
              ),
            ),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isSelected ? FudiColors.primary : FudiColors.secondary,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_forward_rounded,
                size: 16,
                color: isSelected
                    ? FudiColors.primaryForeground
                    : FudiColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TipSection extends StatelessWidget {
  const _TipSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: FudiSpacing.lg),
      child: Container(
        padding: const EdgeInsets.all(FudiSpacing.lg),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              FudiColors.primary.withValues(alpha: 0.1),
              FudiColors.accent.withValues(alpha: 0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(FudiRadius.xl),
          border: Border.all(color: FudiColors.primary.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Consejo', style: FudiTypography.h3),
            const SizedBox(height: FudiSpacing.sm),
            Text(
              'Las mejores ofertas suelen aparecer entre las 18:00 y 20:00. '
              '¡Activa las notificaciones para no perderte ninguna!',
              style: FudiTypography.bodyMedium.copyWith(
                color: FudiColors.mutedForeground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.onSeeAll});

  final String title;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        FudiSpacing.lg,
        FudiSpacing.lg,
        FudiSpacing.lg,
        FudiSpacing.sm,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: FudiTypography.headlineSmall),
          if (onSeeAll != null)
            TextButton(
              onPressed: onSeeAll,
              child: Text(
                'Ver todo',
                style: FudiTypography.bodySmall.copyWith(
                  color: FudiColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ActiveFiltersBar extends StatelessWidget {
  const _ActiveFiltersBar({
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
        _FilterChip(
          label: filters.category!,
          onClear: () => onClear('category'),
        ),
      );
    }
    if (filters.maxDistanceKm != null) {
      chips.add(
        _FilterChip(
          label: '${filters.maxDistanceKm!.toInt()} km',
          onClear: () => onClear('maxDistanceKm'),
        ),
      );
    }
    if (filters.maxPrice != null) {
      chips.add(
        _FilterChip(
          label: 'Max \$${filters.maxPrice!.toStringAsFixed(0)}',
          onClear: () => onClear('maxPrice'),
        ),
      );
    }
    if (filters.searchQuery != null && filters.searchQuery!.isNotEmpty) {
      chips.add(
        _FilterChip(
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
          TextButton(
            onPressed: onClearAll,
            child: Text(
              'Limpiar',
              style: FudiTypography.bodySmall.copyWith(
                color: FudiColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.onClear});

  final String label;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: FudiSpacing.xs),
      child: Chip(
        label: Text(label),
        onDeleted: onClear,
        deleteIconColor: FudiColors.mutedForeground,
        backgroundColor: FudiColors.secondary.withValues(alpha: 0.3),
        side: BorderSide(color: FudiColors.primary.withValues(alpha: 0.2)),
        labelStyle: FudiTypography.bodySmall.copyWith(
          color: FudiColors.primary,
          fontWeight: FontWeight.w600,
        ),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}

class _EmptyExploreState extends StatelessWidget {
  const _EmptyExploreState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(FudiSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(FudiIcons.search, size: 48, color: FudiColors.mutedForeground),
            SizedBox(height: FudiSpacing.md),
            Text('No se encontraron ofertas', style: FudiTypography.bodyMedium),
            SizedBox(height: FudiSpacing.xs),
            Text(
              'Intenta cambiar los filtros o la búsqueda',
              style: FudiTypography.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(FudiSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              FudiIcons.error,
              size: 48,
              color: FudiColors.destructive,
            ),
            const SizedBox(height: FudiSpacing.sm),
            Text('Error al cargar', style: FudiTypography.bodyMedium),
          ],
        ),
      ),
    );
  }
}

class _DealCardSkeleton extends StatelessWidget {
  const _DealCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: FudiColors.muted,
      highlightColor: Colors.white,
      child: Material(
        color: FudiColors.muted,
        borderRadius: BorderRadius.circular(FudiRadius.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(height: 180, color: FudiColors.muted),
            const Padding(
              padding: EdgeInsets.all(FudiSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 14,
                    width: 160,
                    child: DecoratedBox(
                      decoration: BoxDecoration(color: FudiColors.muted),
                    ),
                  ),
                  SizedBox(height: 8),
                  SizedBox(
                    height: 10,
                    width: 100,
                    child: DecoratedBox(
                      decoration: BoxDecoration(color: FudiColors.muted),
                    ),
                  ),
                  SizedBox(height: 12),
                  SizedBox(
                    height: 10,
                    width: 200,
                    child: DecoratedBox(
                      decoration: BoxDecoration(color: FudiColors.muted),
                    ),
                  ),
                  SizedBox(height: 12),
                  SizedBox(
                    height: 1,
                    child: DecoratedBox(
                      decoration: BoxDecoration(color: FudiColors.muted),
                    ),
                  ),
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        height: 14,
                        width: 80,
                        child: DecoratedBox(
                          decoration: BoxDecoration(color: FudiColors.muted),
                        ),
                      ),
                      SizedBox(
                        height: 32,
                        width: 90,
                        child: DecoratedBox(
                          decoration: BoxDecoration(color: FudiColors.muted),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
