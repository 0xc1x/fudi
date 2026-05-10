import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/ui/cards/deal_card.dart';
import '../../../core/ui/fudi_colors.dart';
import '../../../core/ui/fudi_spacing.dart';
import '../../../core/ui/fudi_typography.dart';
import '../../offers/domain/offer.dart';
import '../../offers/presentation/offer_providers.dart';
import 'fudi_filters.dart';

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  final _searchController = TextEditingController();
  FudiFilterState _filters = const FudiFilterState();
  bool _searchActive = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final offersAsync = ref.watch(filteredOffersProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            pinned: true,
            title: _searchActive
                ? TextField(
                    controller: _searchController,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'Buscar ofertas...',
                      border: InputBorder.none,
                      hintStyle: FudiTypography.bodyMedium.copyWith(
                        color: FudiColors.mutedForeground,
                      ),
                    ),
                    style: FudiTypography.bodyMedium,
                    onSubmitted: _submitSearch,
                  )
                : Text('Explorar', style: FudiTypography.headlineMedium),
            centerTitle: !_searchActive,
            backgroundColor: FudiColors.background,
            surfaceTintColor: Colors.transparent,
            actions: [
              IconButton(
                icon: Icon(_searchActive ? Icons.close : Icons.search),
                onPressed: _toggleSearch,
              ),
              IconButton(
                icon: Badge(
                  isLabelVisible: _filters.hasActiveFilters,
                  child: const Icon(Icons.tune),
                ),
                onPressed: () => FudiFiltersSheet.show(
                  context,
                  currentFilters: _filters,
                  onApply: _applyFilters,
                ),
              ),
            ],
          ),
          if (_filters.hasActiveFilters)
            SliverToBoxAdapter(
              child: _ActiveFiltersBar(
                filters: _filters,
                onClear: _clearFilter,
                onClearAll: _clearAllFilters,
              ),
            ),
          offersAsync.when(
            data: (offers) => offers.isEmpty
                ? const SliverFillRemaining(
                    child: _EmptyExploreState(),
                  )
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
                  (_, __) => const Padding(
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
          const SliverToBoxAdapter(
            child: SizedBox(height: FudiSpacing.xxl),
          ),
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
      categoryLabel: offer.categoryLabel.isNotEmpty ? offer.categoryLabel : null,
      onTap: () => context.go('/product/${offer.id}'),
    );
  }

  String _formatDistance(Offer offer) {
    if (offer.business.latitude == null || offer.business.longitude == null) {
      return '';
    }
    return '${offer.business.latitude!.toStringAsFixed(1)}km';
  }

  void _toggleSearch() {
    setState(() {
      _searchActive = !_searchActive;
      if (!_searchActive) {
        _searchController.clear();
        if (_filters.searchQuery != null && _filters.searchQuery!.isNotEmpty) {
          _filters = _filters.copyWith(clearSearchQuery: true);
          _loadOffers();
        }
      }
    });
  }

  void _submitSearch(String query) {
    _filters = _filters.copyWith(searchQuery: query);
    _loadOffers();
  }

  void _applyFilters(FudiFilterState filters) {
    setState(() {
      _filters = filters;
    });
    _loadOffers();
  }

  void _clearFilter(String key) {
    setState(() {
      switch (key) {
        case 'category':
          _filters = _filters.copyWith(clearCategory: true);
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
    });
    _loadOffers();
  }

  void _loadOffers() {
    ref.read(filteredOffersProvider.notifier).applyFilters(
          category: _filters.category,
          maxPrice: _filters.maxPrice,
          maxDistanceKm: _filters.maxDistanceKm,
          searchQuery: _filters.searchQuery,
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
      chips.add(_FilterChip(
        label: filters.category!,
        onClear: () => onClear('category'),
      ));
    }
    if (filters.maxDistanceKm != null) {
      chips.add(_FilterChip(
        label: '${filters.maxDistanceKm!.toInt()} km',
        onClear: () => onClear('maxDistanceKm'),
      ));
    }
    if (filters.maxPrice != null) {
      chips.add(_FilterChip(
        label: 'Max \$${filters.maxPrice!.toStringAsFixed(0)}',
        onClear: () => onClear('maxPrice'),
      ));
    }
    if (filters.searchQuery != null && filters.searchQuery!.isNotEmpty) {
      chips.add(_FilterChip(
        label: '"${filters.searchQuery}"',
        onClear: () => onClear('searchQuery'),
      ));
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
  const _FilterChip({
    required this.label,
    required this.onClear,
  });

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
            Icon(Icons.search_off, size: 48, color: FudiColors.mutedForeground),
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
            const Icon(Icons.error_outline, size: 48, color: FudiColors.destructive),
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
    return const Card(
      child: SizedBox(
        height: 120,
        child: Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }
}
