import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/ui/cards/deal_card.dart';
import '../../../../core/ui/fudi_colors.dart';
import '../../../../core/ui/fudi_spacing.dart';
import '../../../../core/ui/fudi_section_header.dart';
import '../../../../core/utils/geo_utils.dart';
import '../../../favorites/presentation/favorites_providers.dart';
import '../../../offers/domain/offer.dart';
import '../../../offers/presentation/offer_providers.dart';

class HomeDealCard extends ConsumerWidget {
  const HomeDealCard({super.key, required this.offer, this.fullWidth = false});

  final Offer offer;
  final bool fullWidth;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = ref.watch(selectedDiscoveryLocationProvider).asData?.value;
    final distance = GeoUtils.formatDistance(
      offer.business.latitude,
      offer.business.longitude,
      userLat: location?.latitude,
      userLng: location?.longitude,
    );
    final isFavorite = ref.watch(favoritedOfferIdsProvider).contains(offer.id);

    return DealCard(
      imageUrl: offer.imageUrl ?? offer.business.imageUrl ?? '',
      offerTitle: offer.title,
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
}

class DealCardSkeleton extends StatelessWidget {
  const DealCardSkeleton({super.key});

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
            Container(height: 200, color: FudiColors.muted),
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

class OfferRowSection extends StatelessWidget {
  const OfferRowSection({
    super.key,
    required this.title,
    required this.icon,
    required this.offers,
    this.onSeeAll,
  });

  final String title;
  final IconData icon;
  final List<Offer> offers;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FudiSectionHeader(title: title, icon: icon, onSeeAll: onSeeAll),
        SizedBox(
          height: 260,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: FudiSpacing.lg),
            itemCount: offers.length,
            separatorBuilder: (_, _) => const SizedBox(width: FudiSpacing.md),
            itemBuilder: (context, index) {
              final offer = offers[index];
              return SizedBox(width: 260, child: HomeDealCard(offer: offer));
            },
          ),
        ),
      ],
    );
  }
}

class OfferColumnSection extends StatelessWidget {
  const OfferColumnSection({
    super.key,
    required this.title,
    required this.offers,
    this.onSeeAll,
  });

  final String title;
  final List<Offer> offers;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FudiSectionHeader(title: title, onSeeAll: onSeeAll),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: FudiSpacing.lg),
          child: Column(
            children: offers.map((offer) {
              return Padding(
                padding: const EdgeInsets.only(bottom: FudiSpacing.md),
                child: HomeDealCard(offer: offer, fullWidth: true),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class PopularLoadingSkeleton extends StatelessWidget {
  const PopularLoadingSkeleton({super.key});

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
            const SizedBox(width: 260, child: DealCardSkeleton()),
      ),
    );
  }
}
