import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/routing/route_names.dart';
import '../../../core/ui/cards/deal_card.dart';
import '../../../core/ui/fudi_colors.dart';
import '../../../core/ui/fudi_spacing.dart';
import '../../../core/ui/fudi_typography.dart';
import '../../offers/domain/offer.dart';
import '../../offers/presentation/offer_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final popularAsync = ref.watch(popularOffersProvider);
    final nearbyAsync = ref.watch(nearbyOffersProvider);
    final locationAsync = ref.watch(userLocationProvider);

  final hasLocation = locationAsync.whenOrNull(
    data: (position) => position != null,
    error: (_, __) => false,
  ) ??
        false;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          ref.read(popularOffersProvider.notifier).refresh();
          ref.read(nearbyOffersProvider.notifier).refresh();
        },
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.restaurant_menu, color: FudiColors.primary, size: 24),
                  const SizedBox(width: 8),
                  Text('Fudi', style: FudiTypography.headlineMedium),
                ],
              ),
              centerTitle: true,
              backgroundColor: FudiColors.background,
              surfaceTintColor: Colors.transparent,
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
                        height: 310,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(
                            horizontal: FudiSpacing.lg,
                          ),
                          itemCount: offers.length,
                          separatorBuilder: (_, __) =>
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
              loading: () => const SliverToBoxAdapter(
                child: _PopularLoadingSkeleton(),
              ),
              error: (error, _) => SliverToBoxAdapter(
                child: _ErrorState(message: error.toString()),
              ),
            ),
            if (!hasLocation)
              const SliverToBoxAdapter(
                child: _LocationPrompt(),
              ),
            if (hasLocation) ...[
              SliverToBoxAdapter(
                child: _SectionHeader(
                  title: 'Cerca de Ti',
                  onSeeAll: () => context.go(RouteNames.explorePath),
                ),
              ),
              nearbyAsync.when(
                data: (offers) => offers.isEmpty
                    ? const SliverToBoxAdapter(
                        child: _EmptyNearbyState(),
                      )
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
                      (_, __) => const _DealCardSkeleton(),
                      childCount: 3,
                    ),
                  ),
                ),
                error: (error, _) => SliverToBoxAdapter(
                  child: _ErrorState(message: error.toString()),
                ),
              ),
            ],
            const SliverToBoxAdapter(
              child: SizedBox(height: FudiSpacing.xxl),
            ),
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
            Icon(Icons.storefront_outlined, size: 48, color: FudiColors.mutedForeground),
            SizedBox(height: FudiSpacing.md),
            Text('No hay ofertas disponibles ahora', style: FudiTypography.bodyMedium),
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
            Icon(Icons.location_on_outlined, size: 48, color: FudiColors.mutedForeground),
            SizedBox(height: FudiSpacing.md),
            Text('No hay ofertas cerca de ti', style: FudiTypography.bodyMedium),
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
              const Icon(Icons.location_on_outlined, color: FudiColors.primary),
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
            const Icon(Icons.error_outline, size: 48, color: FudiColors.destructive),
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
      height: 310,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: FudiSpacing.lg),
        itemCount: 3,
        separatorBuilder: (_, __) => const SizedBox(width: FudiSpacing.md),
        itemBuilder: (_, __) => const SizedBox(width: 260, child: _DealCardSkeleton()),
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
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(height: 140, color: FudiColors.muted),
            const Padding(
              padding: EdgeInsets.all(FudiSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 12, width: 150, child: DecoratedBox(decoration: BoxDecoration(color: FudiColors.muted))),
                  SizedBox(height: 8),
                  SizedBox(height: 10, width: 80, child: DecoratedBox(decoration: BoxDecoration(color: FudiColors.muted))),
                  SizedBox(height: 16),
                  SizedBox(height: 14, width: 100, child: DecoratedBox(decoration: BoxDecoration(color: FudiColors.muted))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
