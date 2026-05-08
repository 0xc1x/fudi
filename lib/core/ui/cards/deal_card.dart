import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../fudi_colors.dart';
import '../fudi_spacing.dart';
import '../fudi_typography.dart';
import '../fudi_star_rating.dart';

/// Tarjeta de oferta (Deal/Offer) utilizada en Home y Explorar.
/// 
/// Refleja fielmente el diseño del mockup React (rounded-2xl, shadow-sm).
class DealCard extends StatelessWidget {
  const DealCard({
    super.key,
    required this.imageUrl,
    required this.businessName,
    required this.businessType,
    required this.originalPrice,
    required this.discountedPrice,
    required this.rating,
    required this.distance,
    required this.availableQuantity,
    required this.pickupUntil,
    this.categoryLabel,
    this.onTap,
  });

  final String imageUrl;
  final String businessName;
  final String businessType;
  final double originalPrice;
  final double discountedPrice;
  final double rating;
  final String distance;
  final int availableQuantity;
  final TimeOfDay pickupUntil;
  final String? categoryLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Imagen y Badge ─────────────────────────────────────
            Stack(
              children: [
                CachedNetworkImage(
                  imageUrl: imageUrl,
                  height: 140,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Shimmer.fromColors(
                    baseColor: FudiColors.muted,
                    highlightColor: Colors.white,
                    child: Container(color: FudiColors.muted),
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: 140,
                    color: FudiColors.muted,
                    child: const Icon(Icons.broken_image_outlined, color: FudiColors.mutedForeground),
                  ),
                ),
                if (categoryLabel != null)
                  Positioned(
                    top: FudiSpacing.sm,
                    left: FudiSpacing.sm,
                    child: _CategoryBadge(label: categoryLabel!),
                  ),
                Positioned(
                  bottom: FudiSpacing.sm,
                  right: FudiSpacing.sm,
                  child: _QuantityBadge(count: availableQuantity),
                ),
              ],
            ),

            // ─── Contenido ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(FudiSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          businessName,
                          style: FudiTypography.labelMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      FudiStarRating(rating: rating, showText: true),
                    ],
                  ),
                  const SizedBox(height: FudiSpacing.xs),
                  Text(
                    businessType,
                    style: FudiTypography.bodySmall,
                  ),
                  const SizedBox(height: FudiSpacing.md),
                  
                  // Precios y Distancia
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '\$${originalPrice.toStringAsFixed(2)}',
                            style: FudiTypography.priceOriginal,
                          ),
                          Text(
                            '\$${discountedPrice.toStringAsFixed(2)}',
                            style: FudiTypography.price,
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined, size: 14, color: FudiColors.mutedForeground),
                          const SizedBox(width: 4),
                          Text(distance, style: FudiTypography.bodySmall),
                        ],
                      ),
                    ],
                  ),
                  
                  const Divider(height: FudiSpacing.xl),
                  
                  // Pickup info
                  Row(
                    children: [
                      const Icon(Icons.access_time_rounded, size: 14, color: FudiColors.accent),
                      const SizedBox(width: 6),
                      Text(
                        'Recogida hasta ${pickupUntil.format(context)}',
                        style: FudiTypography.bodySmall.copyWith(
                          color: FudiColors.accent,
                          fontWeight: FontWeight.w600,
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

class _CategoryBadge extends StatelessWidget {
  const _CategoryBadge({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: FudiColors.primary.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(FudiRadius.sm),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _QuantityBadge extends StatelessWidget {
  const _QuantityBadge({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: FudiColors.secondary,
        borderRadius: BorderRadius.circular(FudiRadius.full),
        border: Border.all(color: FudiColors.primary.withValues(alpha: 0.1)),
      ),
      child: Text(
        '$count disponibles',
        style: FudiTypography.bodySmall.copyWith(
          color: FudiColors.secondaryForeground,
          fontWeight: FontWeight.w700,
          fontSize: 10,
        ),
      ),
    );
  }
}
