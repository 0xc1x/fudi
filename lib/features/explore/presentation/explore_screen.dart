import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/error/user_friendly_message.dart';
import '../../../core/ui/cards/deal_card.dart';
import '../../../core/ui/fudi_empty_state.dart';
import '../../../core/ui/fudi_error_state.dart';
import '../../../core/ui/fudi_section_header.dart';
import '../../../core/ui/fudi_spacing.dart';
import '../../../core/routing/route_names.dart';
import '../../../core/utils/geo_utils.dart';
import '../../favorites/presentation/favorites_providers.dart';
import '../../offers/domain/offer.dart';
import '../../offers/domain/offer_category.dart';
import '../../offers/presentation/offer_providers.dart';
import 'fudi_filters.dart';
import 'map_view.dart';
import 'widgets/widgets.dart';

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
    final categoriesAsync = ref.watch(categoryStatsProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: ExploreHeader(
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
              child: ExploreActiveFiltersBar(
                filters: _filters,
                onClear: _clearFilter,
                onClearAll: _clearAllFilters,
              ),
            ),
          categoriesAsync.when(
            data: (stats) => SliverToBoxAdapter(
              child: ExploreCategoryGrid(
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
          const SliverToBoxAdapter(child: ExploreTipSection()),
          SliverToBoxAdapter(
            child: FudiSectionHeader(
              title: 'Ofertas disponibles',
              onSeeAll: () => context.push(
                RouteNames.allOffersPath,
                extra: AllOffersView.nearby,
              ),
            ),
          ),
          offersAsync.when(
            data: (offers) => offers.isEmpty
                ? const SliverFillRemaining(
                    child: FudiEmptyState(
                      title: 'No se encontraron ofertas',
                      description: 'Intenta cambiar los filtros o la búsqueda',
                    ),
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
                  (_, _) => const Padding(
                    padding: EdgeInsets.only(bottom: FudiSpacing.md),
                    child: ExploreDealCardSkeleton(),
                  ),
                  childCount: 5,
                ),
              ),
            ),
            error: (error, _) => SliverFillRemaining(
              child: FudiErrorState(message: userFriendlyMessage(error)),
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

  void _toggleViewMode() => setState(() => _viewModeMap = !_viewModeMap);

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
        case 'maxPrice':
          _filters = _filters.copyWith(clearMaxPrice: true);
        case 'maxDistanceKm':
          _filters = _filters.copyWith(clearMaxDistance: true);
        case 'searchQuery':
          _filters = _filters.copyWith(clearSearchQuery: true);
          _searchController.clear();
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
