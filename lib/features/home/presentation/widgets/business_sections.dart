import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/route_names.dart';
import '../../../../core/ui/cards/business_card.dart';
import '../../../../core/ui/fudi_spacing.dart';
import '../../../../core/ui/atoms/icons/fudi_icons.dart';
import '../../../../core/utils/geo_utils.dart';
import '../../../offers/domain/offer.dart';
import '../../../offers/presentation/offer_providers.dart';
import '../../../../core/ui/fudi_section_header.dart';

class HomeBusinessCard extends ConsumerWidget {
  const HomeBusinessCard({
    super.key,
    required this.business,
  });

  final BusinessSummary business;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pos = ref.read(userLocationProvider).asData?.value;
    final distance = GeoUtils.formatDistance(
      business.latitude,
      business.longitude,
      userLat: pos?.latitude,
      userLng: pos?.longitude,
    );

    return BusinessCard(
      imageUrl: business.imageUrl ?? '',
      name: business.name,
      type: business.type,
      rating: business.rating,
      distance: distance,
      onTap: () => context.push(
        RouteNames.businessProfileViewPath.replaceAll(':id', business.id),
      ),
    );
  }
}

class BusinessesRowSection extends StatelessWidget {
  const BusinessesRowSection({
    super.key,
    required this.businesses,
    this.onSeeAll,
  });

  final List<BusinessSummary> businesses;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FudiSectionHeader(
          title: 'Negocios Cerca',
          icon: FudiIcons.store,
          onSeeAll: onSeeAll,
        ),
        SizedBox(
          height: 240,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: FudiSpacing.lg),
            itemCount: businesses.length,
            separatorBuilder: (_, _) => const SizedBox(width: FudiSpacing.md),
            itemBuilder: (context, index) {
              final business = businesses[index];
              return SizedBox(
                width: 140,
                child: HomeBusinessCard(business: business),
              );
            },
          ),
        ),
      ],
    );
  }
}
