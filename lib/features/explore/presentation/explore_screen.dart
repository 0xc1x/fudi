import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/error/user_friendly_message.dart';
import '../../../core/ui/fudi_logo.dart';
import '../../../core/ui/cards/deal_card.dart';
import '../../../core/ui/fudi_colors.dart';
import '../../../core/ui/atoms/icons/fudi_icons.dart';
import '../../../core/ui/fudi_spacing.dart';
import '../../../core/ui/fudi_typography.dart';
import '../../../core/utils/geo_utils.dart';
import '../../../core/routing/route_names.dart';
import '../../offers/domain/offer.dart';
import '../../offers/domain/offer_category.dart';
import '../../offers/domain/offer_repository.dart';
import '../../offers/presentation/offer_providers.dart';
import 'explore_screen_content.dart';
import 'fudi_filters.dart';
import 'map_view.dart';
import '../../favorites/presentation/favorites_providers.dart';

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  final _searchController = TextEditingController();
  FudiFilterState _filters = const FudiFilterState();
  bool _viewModeMap = false;
  OfferCategory? _selectedCategory;
  Timer? _searchDebounce;

  @override
  void dispose() {
    _searchDebounce?.cancel();
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
    final statsAsync = ref.watch(categoryStatsProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _ExploreHeader(
              searchController: _searchController,
              onSubmitSearch: _submitSearch,
              onSearchChanged: _onSearchChanged,
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
          statsAsync.when(
            data: (stats) => SliverToBoxAdapter(
              child: _CategoryGrid(
                stats: stats,
                selectedCategory: _selectedCategory,
                onCategoryTap: _handleCategoryTap,
              ),
            ),
            loading: () => const SliverToBoxAdapter(
              child: SizedBox(
                height: 100,
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
            error: (_, _) => const SliverToBoxAdapter(child: SizedBox.shrink()),
          ),
          const SliverToBoxAdapter(child: _TipSection()),
          SliverToBoxAdapter(
            child: _SectionHeader(
              title: 'Ofertas disponibles',
              onSeeAll: () => context.push(RouteNames.allOffersPath, extra: AllOffersView.nearby),
            ),
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
              child: _ErrorState(message: userFriendlyMessage(error)),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: FudiSpacing.xxl)),
        ],
      ),
    );
  }

  Widget _buildDealCard(BuildContext context, Offer offer) {
    final distance = _formatDistance(offer);
    final isFavorite = ref.watch(favoritedOfferIdsProvider).contains(offer.id);

    return DealCard(
      imageUrl: offer.imageUrl ?? offer.business.imageUrl ?? '',
      businessName: offer.business.name,
      businessType: offer.business.type,
      originalPrice: offer.originalPrice,
      discountedPrice: offer.discountedPrice,
      rating: offer.rating,
      distance: distance,
      availableQuantity: offer.stock,
      pickupUntil: offer.pickupUntilTimeOfDay,
      categoryLabel: offer.categoryLabel,
      isFavorite: isFavorite,
      onFavoriteToggle: () =>
          ref.read(favoritedOfferIdsProvider.notifier).toggleFavorite(offer.id),
      onTap: () => context.push('/product/${offer.id}'),
    );
  }

  String _formatDistance(Offer offer) {
    final pos = ref.read(userLocationProvider).asData?.value;
    return GeoUtils.formatDistance(
      offer.business.latitude,
      offer.business.longitude,
      userLat: pos?.latitude,
      userLng: pos?.longitude,
    );
  }

  void _toggleViewMode() {
    setState(() => _viewModeMap = !_viewModeMap);
  }

  void _onSearchChanged(String query) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      _submitSearch(query);
    });
  }

  void _submitSearch(String query) {
    _searchDebounce?.cancel();
    _filters = _filters.copyWith(searchQuery: query);
    _loadOffers();
  }

  void _applyFilters(FudiFilterState filters) {
    setState(() => _filters = filters);
    _loadOffers();
  }

  void _handleCategoryTap(String categoryId) {
    final category = OfferCategory.fromDb(categoryId);
    setState(() {
      _selectedCategory = _selectedCategory == category ? null : category;
      if (_selectedCategory != null) {
        _filters = _filters.copyWith(category: _selectedCategory);
        _viewModeMap = true;
      } else {
        _filters = _filters.copyWith(clearCategory: true);
      }
    });
    _loadOffers();
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
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: searchController,
              builder: (context, value, _) => TextField(
                controller: searchController,
                onChanged: (query) => onSearchChanged?.call(query),
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
                  suffixIcon: value.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(
                            FudiIcons.x,
                            color: FudiColors.mutedForeground,
                          ),
                          onPressed: () {
                            searchController.clear();
                            onSubmitSearch('');
                          },
                        )
                      : null,
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

class _CategoryGrid extends ConsumerStatefulWidget {
  const _CategoryGrid({
    required this.stats,
    required this.selectedCategory,
    required this.onCategoryTap,
  });

  final List<CategoryStat> stats;
  final OfferCategory? selectedCategory;
  final ValueChanged<String> onCategoryTap;

  @override
  ConsumerState<_CategoryGrid> createState() => _CategoryGridState();
}

class _CategoryGridState extends ConsumerState<_CategoryGrid> {
  bool _showAll = false;
  static const _initialCount = 5;

  @override
  Widget build(BuildContext context) {
    if (widget.stats.isEmpty) return const SizedBox.shrink();

    final display = _showAll
        ? widget.stats
        : widget.stats.take(_initialCount).toList();
    final remaining = widget.stats.length - _initialCount;

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
          // ── Popular Areas ─────────────────────────────────────────
          const _PopularAreasSection(),
          const SizedBox(height: FudiSpacing.lg),
          Text('Categorías', style: FudiTypography.headlineSmall),
          const SizedBox(height: FudiSpacing.md),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: FudiSpacing.sm,
            crossAxisSpacing: FudiSpacing.sm,
            childAspectRatio: 4.0,
            children: [
              ...display.map((cat) {
                final isSelected =
                    widget.selectedCategory?.dbValue == cat.id;
                return _CategoryCard(
                  emoji: cat.emoji,
                  name: cat.name,
                  count: cat.count,
                  isSelected: isSelected,
                  onTap: () => widget.onCategoryTap(cat.id),
                );
              }),
              if (!_showAll && remaining > 0)
                _ExpandCard(
                  remaining: remaining,
                  icon: FudiIcons.chevronDown,
                  label: '+$remaining',
                  onTap: () => setState(() => _showAll = true),
                ),
              if (_showAll && widget.stats.length > _initialCount)
                _ExpandCard(
                  remaining: 0,
                  icon: FudiIcons.chevronUp,
                  label: 'Ver menos',
                  onTap: () => setState(() => _showAll = false),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PopularAreasSection extends ConsumerWidget {
  const _PopularAreasSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final areasAsync = ref.watch(popularAreasProvider);

    return areasAsync.when(
      data: (areas) {
        if (areas.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Áreas Populares', style: FudiTypography.headlineSmall),
            const SizedBox(height: FudiSpacing.md),
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: areas.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final area = areas[index];
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: FudiSpacing.md,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: FudiColors.secondary.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(FudiRadius.full),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          FudiIcons.mapPin,
                          size: 14,
                          color: FudiColors.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          area.name,
                          style: FudiTypography.bodySmall.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: FudiColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(
                              FudiRadius.sm,
                            ),
                          ),
                          child: Text(
                            '${area.deals}',
                            style: FudiTypography.bodySmall.copyWith(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: FudiColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
      error: (_, _) => const SizedBox.shrink(),
      loading: () => const SizedBox.shrink(),
    );
  }
}

class _ExpandCard extends StatelessWidget {
  const _ExpandCard({
    required this.remaining,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final int remaining;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: FudiColors.muted.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(FudiRadius.lg),
          border: Border.all(
            color: FudiColors.borderSolid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24, color: FudiColors.mutedForeground),
            const SizedBox(height: 4),
            Text(
              label,
              style: FudiTypography.bodySmall.copyWith(
                fontWeight: FontWeight.w700,
                color: FudiColors.mutedForeground,
              ),
            ),
          ],
        ),
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
        padding: const EdgeInsets.symmetric(
          horizontal: FudiSpacing.sm,
          vertical: FudiSpacing.xs,
        ),
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
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: FudiSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
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
              ExploreScreenContent.tips.join(' '),
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
          label: filters.category!.dbValue,
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(FudiSpacing.xl),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                FudiIcons.search,
                size: 48,
                color: FudiColors.mutedForeground,
              ),
              const SizedBox(height: FudiSpacing.md),
              Text(
                'No se encontraron ofertas',
                style: FudiTypography.bodyMedium,
              ),
              const SizedBox(height: FudiSpacing.xs),
              Text(
                'Intenta cambiar los filtros o la búsqueda',
                style: FudiTypography.bodySmall,
              ),
            ],
          ),
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
