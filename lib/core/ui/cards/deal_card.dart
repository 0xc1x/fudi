import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../fudi_colors.dart';
import '../fudi_spacing.dart';
import '../fudi_typography.dart';
import '../atoms/icons/fudi_icons.dart';

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
    this.isFavorite = false,
    this.onFavoriteToggle,
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
  final bool isFavorite;
  final VoidCallback? onFavoriteToggle;

  int get _discountPercent => originalPrice > 0
      ? ((1 - discountedPrice / originalPrice) * 100).round()
      : 0;

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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [_buildImage(), _buildContent(context)],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    return Stack(
      children: [
        CachedNetworkImage(
          imageUrl: imageUrl,
          height: 180,
          width: double.infinity,
          fit: BoxFit.cover,
          placeholder: (context, url) => Shimmer.fromColors(
            baseColor: FudiColors.muted,
            highlightColor: Colors.white,
            child: Container(height: 180, color: FudiColors.muted),
          ),
          errorWidget: (context, url, error) => Container(
            height: 180,
            color: FudiColors.muted,
            child: const Icon(
              FudiIcons.imageOff,
              color: FudiColors.mutedForeground,
            ),
          ),
        ),
        if (_discountPercent > 0)
          Positioned(
            top: FudiSpacing.sm,
            right: FudiSpacing.sm,
            child: _DiscountBadge(percent: _discountPercent),
          ),
        if (availableQuantity <= 3)
          Positioned(
            bottom: FudiSpacing.sm,
            left: FudiSpacing.sm,
            child: _LowStockBadge(count: availableQuantity),
          ),
        Positioned(
          top: FudiSpacing.sm,
          left: FudiSpacing.sm,
          child: _FavoriteButton(
            isFavorite: isFavorite,
            onToggle: onFavoriteToggle,
          ),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(FudiSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  businessName,
                  style: FudiTypography.h3.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (rating > 0) ...[
                const SizedBox(width: FudiSpacing.sm),
                _RatingPill(rating: rating),
              ],
            ],
          ),
          const SizedBox(height: 2),
          Text(businessType, style: FudiTypography.bodySmall),
          const SizedBox(height: FudiSpacing.sm),
          Row(
            children: [
              const Icon(
                FudiIcons.mapPin,
                size: 14,
                color: FudiColors.mutedForeground,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  distance,
                  style: FudiTypography.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: FudiSpacing.sm),
          Divider(
            height: 1,
            color: FudiColors.borderSolid.withValues(alpha: 0.5),
          ),
          const SizedBox(height: FudiSpacing.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      FudiIcons.clock,
                      size: 14,
                      color: FudiColors.primary,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        'Recoge antes de ${pickupUntil.format(context)}',
                        style: FudiTypography.bodySmall.copyWith(
                          fontWeight: FontWeight.w600,
                          color: FudiColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: FudiSpacing.sm),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '\$${originalPrice.toStringAsFixed(2)}',
                    style: FudiTypography.priceOriginal,
                  ),
                  Text(
                    '\$${discountedPrice.toStringAsFixed(2)}',
                    style: FudiTypography.priceLarge,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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

class _DiscountBadge extends StatelessWidget {
  const _DiscountBadge({required this.percent});
  final int percent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(FudiRadius.full),
      ),
      child: Text(
        '-$percent%',
        style: const TextStyle(
          color: FudiColors.primary,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _LowStockBadge extends StatelessWidget {
  const _LowStockBadge({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: FudiColors.destructive,
        borderRadius: BorderRadius.circular(FudiRadius.full),
      ),
      child: Text(
        'Solo quedan $count!',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _RatingPill extends StatelessWidget {
  const _RatingPill({required this.rating});
  final double rating;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: FudiColors.secondary,
        borderRadius: BorderRadius.circular(FudiRadius.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(FudiIcons.star, size: 14, color: FudiColors.primary),
          const SizedBox(width: 2),
          Text(
            rating.toStringAsFixed(1),
            style: FudiTypography.bodySmall.copyWith(
              color: FudiColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _FavoriteButton extends StatelessWidget {
  const _FavoriteButton({required this.isFavorite, this.onToggle});

  final bool isFavorite;
  final VoidCallback? onToggle;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          isFavorite ? FudiIcons.favorites : FudiIcons.heartOutline,
          size: 18,
          color: isFavorite
              ? FudiColors.destructive
              : FudiColors.mutedForeground,
        ),
      ),
    );
  }
}
