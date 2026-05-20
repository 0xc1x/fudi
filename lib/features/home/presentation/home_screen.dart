import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/routing/route_names.dart';
import '../../../core/ui/app_logo.dart';
import '../../../core/ui/cards/deal_card.dart';
import '../../../core/ui/fudi_colors.dart';
import '../../../core/ui/fudi_icons.dart';
import '../../../core/ui/fudi_spacing.dart';
import '../../../core/ui/fudi_typography.dart';
import '../../offers/domain/offer.dart';
import '../../offers/domain/offer_repository.dart';
import '../../offers/presentation/offer_providers.dart';
import '../../profile/domain/saved_address_model.dart';
import '../../profile/presentation/profile_providers.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String? _selectedCategoryId;


  void _onCategorySelected(String? categoryId) {
    setState(() => _selectedCategoryId = categoryId);
    ref.read(popularOffersProvider.notifier).filterByCategory(categoryId);
    ref.read(nearbyOffersProvider.notifier).filterByCategory(categoryId);
  }

  @override
  Widget build(BuildContext context) {
    final popularAsync = ref.watch(popularOffersProvider);
    final nearbyAsync = ref.watch(nearbyOffersProvider);
    final locationAsync = ref.watch(userLocationProvider);
    final statsAsync = ref.watch(categoryStatsProvider);

    final hasLocation =
        locationAsync.whenOrNull(
          data: (position) => position != null,
          error: (_, _) => false,
        ) ??
        false;

    final selectedAddress = ref.watch(userSelectedAddressProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: RefreshIndicator(
        onRefresh: () async {
          if (_selectedCategoryId != null) {
            ref.read(popularOffersProvider.notifier).filterByCategory(_selectedCategoryId);
            ref.read(nearbyOffersProvider.notifier).filterByCategory(_selectedCategoryId);
          } else {
            await ref.read(popularOffersProvider.notifier).refresh();
            await ref.read(nearbyOffersProvider.notifier).refresh();
          }
          ref.invalidate(categoryStatsProvider);
        },
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _HomeHeader(
                selectedLocation: selectedAddress,
                onLocationTap: () => context.push('/profile/addresses'),
              ),
            ),
        statsAsync.when(
          data: (stats) => SliverToBoxAdapter(
            child: _CategoryChips(
              stats: stats,
              selectedCategoryId: _selectedCategoryId,
              onSelected: _onCategorySelected,
            ),
          ),
          loading: () => const SliverToBoxAdapter(child: SizedBox(height: 40)),
          error: (_, _) => const SliverToBoxAdapter(child: SizedBox.shrink()),
        ),
            SliverToBoxAdapter(
              child: _SectionHeader(
                title: 'Ofertas Populares',
                onSeeAll: () => context.go(RouteNames.explorePath),
              ),
            ),
            popularAsync.when(
              data: (offers) => offers.isEmpty
                  ? const SliverToBoxAdapter(child: _EmptyPopularState())
                  : SliverToBoxAdapter(
                      child: SizedBox(
                        height: 360,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(
                            horizontal: FudiSpacing.lg,
                          ),
                          itemCount: offers.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(width: FudiSpacing.md),
                          itemBuilder: (context, index) {
                            final offer = offers[index];
                            return SizedBox(
                              width: 260,
                              child: _buildDealCard(context, offer),
                            );
                          },
                        ),
                      ),
                    ),
              loading: () =>
                  const SliverToBoxAdapter(child: _PopularLoadingSkeleton()),
              error: (error, _) => SliverToBoxAdapter(
                child: _ErrorState(message: error.toString()),
              ),
            ),
            if (!hasLocation)
              const SliverToBoxAdapter(child: _LocationPrompt()),
            if (hasLocation) ...[
              SliverToBoxAdapter(
                child: _SectionHeader(
                  title: 'Cerca de Ti',
                  onSeeAll: () => context.go(RouteNames.explorePath),
                ),
              ),
              nearbyAsync.when(
                data: (offers) => offers.isEmpty
                    ? const SliverToBoxAdapter(child: _EmptyNearbyState())
                    : SliverPadding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: FudiSpacing.lg,
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
                  ),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, _) => const _DealCardSkeleton(),
                      childCount: 3,
                    ),
                  ),
                ),
                error: (error, _) => SliverToBoxAdapter(
                  child: _ErrorState(message: error.toString()),
                ),
              ),
            ],
            const SliverToBoxAdapter(child: SizedBox(height: FudiSpacing.xxl)),
          ],
        ),
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
      onTap: () => context.push('/product/${offer.id}'),
    );
  }

  String _formatDistance(Offer offer) {
    if (offer.business.latitude == null || offer.business.longitude == null) {
      return '';
    }
    return '${offer.business.latitude!.toStringAsFixed(1)}km';
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.selectedLocation, required this.onLocationTap});

  final SavedAddressModel? selectedLocation;
  final VoidCallback onLocationTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: FudiColors.ring,
      padding: const EdgeInsets.symmetric(horizontal: FudiSpacing.lg, vertical: FudiSpacing.md),
      child: SafeArea(
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _LocationSelector(
              selectedLocation: selectedLocation,
              onTap: onLocationTap,
            ),
            const AppLogo(
              size: AppLogoSize.lg,
              variant: AppLogoVariant.light,
            ),
          ],
        ),
      ),
    );
  }
}

class _LocationSelector extends StatelessWidget {
  const _LocationSelector({required this.selectedLocation, required this.onTap});

  final SavedAddressModel? selectedLocation;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.location_on, size: 18, color: FudiColors.primary),
          const SizedBox(width: 4),
          Text(
            selectedLocation?.label ?? 'Seleccionar ubicación',
            style: const TextStyle(
              color: FudiColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const Icon(Icons.keyboard_arrow_down, size: 18, color: FudiColors.primary),
        ],
      ),
    );
  }
}


class _CategoryChips extends StatelessWidget {
  const _CategoryChips({
    required this.stats,
    required this.selectedCategoryId,
    required this.onSelected,
  });

  final List<CategoryStat> stats;
  final String? selectedCategoryId;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    // Add "All" option
    final allStats = [
      const CategoryStat(id: 'all', name: 'Todos', count: 0, emoji: '✨'),
      ...stats,
    ];

    return Container(
      color: FudiColors.background,
      padding: const EdgeInsets.symmetric(vertical: FudiSpacing.md),
      child: SizedBox(
        height: 40,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: FudiSpacing.lg),
          itemCount: allStats.length,
          separatorBuilder: (_, _) => const SizedBox(width: FudiSpacing.sm),
          itemBuilder: (context, index) {
            final cat = allStats[index];
            final catId = cat.id == 'all' ? null : cat.id;
            final isActive = catId == selectedCategoryId;
            return _CategoryChip(
              label: cat.name,
              isActive: isActive,
              onTap: () => onSelected(catId),
            );
          },
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: FudiSpacing.md,
          vertical: FudiSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isActive ? FudiColors.primary : FudiColors.secondary,
          borderRadius: BorderRadius.circular(FudiRadius.full),
        ),
        child: Text(
          label,
          style: FudiTypography.bodySmall.copyWith(
            color: isActive
                ? FudiColors.primaryForeground
                : FudiColors.secondaryForeground,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
          ),
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

class _EmptyPopularState extends StatelessWidget {
  const _EmptyPopularState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(FudiSpacing.xl),
      child: Center(
        child: Column(
          children: [
            Icon(FudiIcons.store, size: 48, color: FudiColors.mutedForeground),
            SizedBox(height: FudiSpacing.md),
            Text(
              'No hay ofertas disponibles ahora',
              style: FudiTypography.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyNearbyState extends StatelessWidget {
  const _EmptyNearbyState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(FudiSpacing.xl),
      child: Center(
        child: Column(
          children: [
            Icon(
              FudiIcons.mapPinOutline,
              size: 48,
              color: FudiColors.mutedForeground,
            ),
            SizedBox(height: FudiSpacing.md),
            Text(
              'No hay ofertas cerca de ti',
              style: FudiTypography.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _LocationPrompt extends StatelessWidget {
  const _LocationPrompt();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(FudiSpacing.lg),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(FudiSpacing.md),
          child: Row(
            children: [
              const Icon(FudiIcons.mapPin, color: FudiColors.primary),
              const SizedBox(width: FudiSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Activa tu ubicación',
                      style: FudiTypography.labelMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Para ver ofertas cerca de ti',
                      style: FudiTypography.bodySmall,
                    ),
                  ],
                ),
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
    return Padding(
      padding: const EdgeInsets.all(FudiSpacing.lg),
      child: Center(
        child: Column(
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

class _PopularLoadingSkeleton extends StatelessWidget {
  const _PopularLoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 360,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: FudiSpacing.lg),
        itemCount: 3,
        separatorBuilder: (_, _) => const SizedBox(width: FudiSpacing.md),
        itemBuilder: (_, _) =>
            const SizedBox(width: 260, child: _DealCardSkeleton()),
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
