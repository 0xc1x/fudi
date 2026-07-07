import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../core/ui/fudi_colors.dart';
import '../../../../core/ui/fudi_spacing.dart';
import '../../../../core/ui/fudi_surface_card.dart';
import '../../../../core/ui/fudi_typography.dart';
import '../../../offers/domain/offer.dart';

class ProductSummaryCard extends StatelessWidget {
  const ProductSummaryCard({super.key, required this.offer});

  final Offer offer;

  @override
  Widget build(BuildContext context) {
    final discountPercent =
        (((offer.originalPrice - offer.discountedPrice) / offer.originalPrice) *
                100)
            .toStringAsFixed(0);

    return FudiSurfaceCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 72,
              height: 72,
              child: offer.imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: offer.imageUrl!,
                      fit: BoxFit.cover,
                      errorWidget: (_, _, _) => const _FallbackImage(),
                    )
                  : const _FallbackImage(),
            ),
          ),
          const SizedBox(width: FudiSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  offer.business.name,
                  style: FudiTypography.labelSmall.copyWith(
                    color: FudiColors.mutedForeground,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  offer.title,
                  style: FudiTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: FudiSpacing.xs),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: FudiColors.primary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Salvaste -$discountPercent%',
                    style: const TextStyle(
                      color: FudiColors.primaryForeground,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: FudiSpacing.xs),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${offer.discountedPrice.toStringAsFixed(2)}',
                style: FudiTypography.labelMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: FudiColors.primary,
                ),
              ),
              Text(
                '\$${offer.originalPrice.toStringAsFixed(2)}',
                style: FudiTypography.bodySmall.copyWith(
                  decoration: TextDecoration.lineThrough,
                  color: FudiColors.mutedForeground,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FallbackImage extends StatelessWidget {
  const _FallbackImage();
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      color: isDark ? FudiColorsDark.muted : FudiColors.muted,
      child: const Icon(
        Icons.restaurant_rounded,
        size: 20,
        color: FudiColors.mutedForeground,
      ),
    );
  }
}
