import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../core/ui/fudi_colors.dart';
import '../../../../core/ui/fudi_spacing.dart';
import '../../../../core/ui/fudi_surface_card.dart';
import '../../../../core/ui/fudi_typography.dart';
import '../../../offers/domain/offer.dart';

class ProductSummaryCard extends StatelessWidget {
  const ProductSummaryCard({required this.offer});

  final Offer offer;

  @override
  Widget build(BuildContext context) {
    return FudiSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Resumen del pedido', style: FudiTypography.labelMedium),
          const SizedBox(height: FudiSpacing.md),
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(FudiRadius.md),
                child: offer.imageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: offer.imageUrl!,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorWidget: (_, _, _) => Container(
                          width: 80,
                          height: 80,
                          color: FudiColors.muted,
                          child: const Icon(Icons.restaurant),
                        ),
                      )
                    : Container(
                        width: 80,
                        height: 80,
                        color: FudiColors.muted,
                        child: const Icon(Icons.restaurant),
                      ),
              ),
              const SizedBox(width: FudiSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      offer.business.name,
                      style: FudiTypography.labelMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(offer.business.type, style: FudiTypography.bodySmall),
                    const SizedBox(height: 4),
                    Text(offer.title, style: FudiTypography.bodyMedium),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${offer.discountedPrice.toStringAsFixed(2)}',
                    style: FudiTypography.labelMedium.copyWith(
                      color: FudiColors.primary,
                    ),
                  ),
                  Text(
                    '\$${offer.originalPrice.toStringAsFixed(2)}',
                    style: FudiTypography.bodySmall.copyWith(
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
