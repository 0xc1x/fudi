import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/error/user_friendly_message.dart';
import '../../../core/ui/fudi_colors.dart';
import '../../../core/ui/fudi_pressable_scale.dart';
import '../../../core/ui/fudi_spacing.dart';
import '../../../core/ui/fudi_typography.dart';
import '../../../core/ui/atoms/icons/fudi_icons.dart';
import '../../../core/ui/fudi_search_bar.dart';
import '../../../core/ui/fudi_empty_state.dart';
import '../../../core/ui/fudi_error_state.dart';
import '../../../core/utils/geo_utils.dart';
import '../../offers/domain/offer.dart';
import '../../offers/presentation/offer_providers.dart';
import '../../explore/presentation/fudi_filters.dart';

class AllOffersScreen extends ConsumerStatefulWidget {
  const AllOffersScreen({super.key});

  @override
  ConsumerState<AllOffersScreen> createState() => _AllOffersScreenState();
}

class _AllOffersScreenState extends ConsumerState<AllOffersScreen> {
  final _searchController = TextEditingController();
  FudiFilterState _filters = const FudiFilterState();
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadInitialView());
  }

  void _loadInitialView() {
    final extra = GoRouterState.of(context).extra;
    if (extra is AllOffersView && extra != AllOffersView.all) {
      ref.read(allActiveOffersProvider.notifier).loadView(extra);
    }
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final offersAsync = ref.watch(allActiveOffersProvider);

    return Scaffold(
      backgroundColor: FudiColors.background,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _AllOffersHeader(
              searchController: _searchController,
              onSearchChanged: _onSearchChanged,
              onSubmitSearch: _submitSearch,
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
          offersAsync.when(
            data: (offers) => offers.isEmpty
                ? const SliverFillRemaining(
                    child: FudiEmptyState(
                      title: 'No se encontraron ofertas',
                      description: 'Intenta cambiar los filtros o la búsqueda',
                    ),
                  )
                : SliverPadding(
                    padding: const EdgeInsets.all(FudiSpacing.lg),
                    sliver: SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: FudiSpacing.md,
                        crossAxisSpacing: FudiSpacing.md,
                        childAspectRatio: 0.80,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) =>
                            _buildGridCard(context, offers[index]),
                        childCount: offers.length,
                      ),
                    ),
                  ),
            loading: () => SliverPadding(
              padding: const EdgeInsets.all(FudiSpacing.lg),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: FudiSpacing.md,
                  crossAxisSpacing: FudiSpacing.md,
                  childAspectRatio: 0.80,
                ),
                delegate: SliverChildBuilderDelegate(
                  (_, _) => const _GridCardSkeleton(),
                  childCount: 6,
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

  Widget _buildGridCard(BuildContext context, Offer offer) {
    final distance = _formatDistance(offer);

    return FudiPressableScale(
      onTap: () => context.push('/product/${offer.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: FudiColors.card,
          borderRadius: BorderRadius.circular(FudiRadius.lg),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1.25,
              child: Stack(
                children: [
                  _OfferImage(offer: offer),
                  if (offer.discountPercentage >= 10)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: FudiColors.primary,
                          borderRadius: BorderRadius.circular(FudiRadius.sm),
                        ),
                        child: Text(
                          '-${offer.discountPercentage.round()}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  if (offer.stock <= 3 && offer.stock > 0)
                    Positioned(
                      bottom: 8,
                      left: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: FudiColors.destructive,
                          borderRadius: BorderRadius.circular(FudiRadius.sm),
                        ),
                        child: Text(
                          'Solo ${offer.stock}!',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(FudiSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    offer.business.name,
                    style: FudiTypography.labelSmall.copyWith(
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    offer.title,
                    style: FudiTypography.bodySmall.copyWith(
                      fontSize: 11,
                      color: FudiColors.mutedForeground,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '\$${offer.discountedPrice.toStringAsFixed(0)}',
                        style: FudiTypography.price.copyWith(fontSize: 16),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '\$${offer.originalPrice.toStringAsFixed(0)}',
                        style: FudiTypography.priceOriginal.copyWith(
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  if (distance.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(
                          FudiIcons.mapPin,
                          size: 10,
                          color: FudiColors.mutedForeground,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          distance,
                          style: FudiTypography.bodySmall.copyWith(
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
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
    ref
        .read(allActiveOffersProvider.notifier)
        .applyFilters(
          category: _filters.category,
          maxPrice: _filters.maxPrice,
          maxDistanceKm: _filters.maxDistanceKm,
          searchQuery: _filters.searchQuery,
        );
  }
}

class _AllOffersHeader extends StatelessWidget {
  const _AllOffersHeader({
    required this.searchController,
    this.onSearchChanged,
    required this.onSubmitSearch,
    required this.onFilterTap,
    required this.hasActiveFilters,
  });

  final TextEditingController searchController;
  final ValueChanged<String>? onSearchChanged;
  final ValueChanged<String> onSubmitSearch;
  final VoidCallback onFilterTap;
  final bool hasActiveFilters;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: FudiColors.background,
      padding: const EdgeInsets.fromLTRB(
        FudiSpacing.lg,
        FudiSpacing.lg + 8,
        FudiSpacing.lg,
        FudiSpacing.lg,
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                FudiPressableScale(
                  onTap: () => context.pop(),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: FudiColors.muted,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(FudiIcons.chevronLeft, size: 24),
                  ),
                ),
                Text(
                  'Todas las ofertas',
                  style: FudiTypography.h1,
                ),
              ],
            ),
            const SizedBox(height: FudiSpacing.md),
            FudiSearchBar(
              controller: searchController,
              hintText: 'Buscar ofertas, restaurantes...',
              onChanged: onSearchChanged,
              onSubmitted: onSubmitSearch,
            ),
            const SizedBox(height: FudiSpacing.sm),
            FudiPressableScale(
              onTap: onFilterTap,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: FudiSpacing.md,
                  vertical: FudiSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: FudiColors.card,
                  borderRadius: BorderRadius.circular(FudiRadius.md),
                  border: Border.all(color: FudiColors.borderSolid),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      FudiIcons.slidersHorizontal,
                      size: 16,
                      color: FudiColors.foreground,
                    ),
                    const SizedBox(width: FudiSpacing.xs),
                    Text(
                      'Filtros',
                      style: FudiTypography.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (hasActiveFilters) ...[
                      const SizedBox(width: 4),
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: FudiColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
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
      chips.add(_FilterChip(
        label: filters.category!.dbValue,
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



class _OfferImage extends StatelessWidget {
  const _OfferImage({required this.offer});
  final Offer offer;

  @override
  Widget build(BuildContext context) {
    final url = offer.imageUrl ?? offer.business.imageUrl;
    if (url == null || url.isEmpty) {
      return Container(
        color: FudiColors.muted,
        child: const Center(
          child: Icon(FudiIcons.store, color: FudiColors.mutedForeground),
        ),
      );
    }
    return CachedNetworkImage(
      imageUrl: url,
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
      errorWidget: (_, _, _) => Container(
        color: FudiColors.muted,
        child: const Icon(FudiIcons.store, color: FudiColors.mutedForeground),
      ),
    );
  }
}

class _GridCardSkeleton extends StatelessWidget {
  const _GridCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: FudiColors.muted,
      highlightColor: Colors.white,
      child: Container(
        decoration: BoxDecoration(
          color: FudiColors.muted,
          borderRadius: BorderRadius.circular(FudiRadius.lg),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: Container(color: FudiColors.muted)),
            Padding(
              padding: const EdgeInsets.all(FudiSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 10,
                    width: 120,
                    color: FudiColors.muted,
                  ),
                  const SizedBox(height: 6),
                  Container(
                    height: 8,
                    width: 80,
                    color: FudiColors.muted,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 14,
                    width: 60,
                    color: FudiColors.muted,
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
