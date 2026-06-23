import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../fudi_colors.dart';
import '../fudi_spacing.dart';
import '../fudi_typography.dart';
import '../fudi_star_rating.dart';
import '../atoms/icons/fudi_icons.dart';

/// Tarjeta de negocio utilizada en listas de búsqueda o exploración.
class BusinessCard extends StatelessWidget {
  const BusinessCard({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.type,
    required this.rating,
    required this.distance,
    required this.activeDealsCount,
    this.onTap,
  });

  final String imageUrl;
  final String name;
  final String type;
  final double rating;
  final String distance;
  final int activeDealsCount;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: FudiColors.card,
        borderRadius: BorderRadius.circular(FudiRadius.lg),
        border: Border.all(
          color: FudiColors.border.withValues(alpha: 0.09),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: FudiColors.primary.withValues(alpha: 0.03),
            blurRadius: 12,
            spreadRadius: -2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(FudiRadius.lg - 1),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(FudiSpacing.md),
              child: Row(
                children: [
                  // ─── Logo / Imagen ──────────────────────────────────
                  ClipRRect(
                    borderRadius: BorderRadius.circular(FudiRadius.md),
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      width: 64,
                      height: 64,
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) => Container(
                        width: 64,
                        height: 64,
                        color: FudiColors.muted,
                        child: const Icon(FudiIcons.store),
                      ),
                    ),
                  ),
                  const SizedBox(width: FudiSpacing.md),

                  // ─── Información ────────────────────────────────────
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: FudiTypography.labelMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(type, style: FudiTypography.bodySmall),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            if (rating > 0) ...[
                              FudiStarRating(rating: rating, size: 12),
                              const SizedBox(width: 8),
                            ],
                            const Icon(
                              FudiIcons.mapPin,
                              size: 12,
                              color: FudiColors.mutedForeground,
                            ),
                            const SizedBox(width: 2),
                            Text(distance, style: FudiTypography.bodySmall),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // ─── Deals Count ────────────────────────────────────
                  if (activeDealsCount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: FudiColors.secondary,
                        borderRadius: BorderRadius.circular(FudiRadius.sm),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            activeDealsCount.toString(),
                            style: FudiTypography.labelSmall.copyWith(
                              color: FudiColors.secondaryForeground,
                              height: 1,
                            ),
                          ),
                          const Text(
                            'ofertas',
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.w600,
                              color: FudiColors.secondaryForeground,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
