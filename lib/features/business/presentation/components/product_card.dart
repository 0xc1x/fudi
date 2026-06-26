import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/ui/atoms/icons/fudi_icons.dart';
import '../../../../core/ui/fudi_colors.dart';
import '../../../../core/ui/fudi_pressable_scale.dart';
import '../../../../core/ui/fudi_spacing.dart';
import '../../../../core/ui/fudi_surface_card.dart';
import '../../../../core/ui/fudi_typography.dart';
import '../../../../core/ui/atoms/fudi_status_badge.dart';
import '../../../offers/domain/offer.dart';
import 'product_image.dart';
import 'product_menu.dart';

class ProductCard extends ConsumerWidget {
  const ProductCard({super.key, required this.offer});

  final Offer offer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isActive = offer.isActive;
    final soldCount = offer.initialStock - offer.stock;

    // The card padding is lg (16) on all sides, so the image needs to
    // escape that padding on the left, top, and bottom using negative margins.
    final card = ClipRRect(
      borderRadius: BorderRadius.circular(FudiRadius.lg),
      child: FudiSurfaceCard(
        padding: EdgeInsets.zero,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 115,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Image: bleeds to left/top/bottom card edges ──
                  SizedBox(
                    width: 110,
                    child: ProductImage(
                      offer: offer,
                      width: 110,
                      height: 115,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(FudiRadius.lg),
                        // bottomLeft: Radius.circular(FudiRadius.lg),
                      ),
                    ),
                  ),
                  const SizedBox(width: FudiSpacing.md),
                  // ── Center: badge row + title + info chips ──
                  Expanded(
                    flex: 55,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: FudiSpacing.md,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Status badge + sold count on the same row
                          Row(
                            children: [
                              FudiStatusBadge.active(
                                isActive: isActive,
                                size: FudiStatusBadgeSize.sm,
                              ),
                              const Spacer(),
                              if (soldCount > 0) _SoldChip(count: soldCount),
                            ],
                          ),
                          const SizedBox(height: FudiSpacing.sm),
                          Text(
                            offer.title,
                            style: FudiTypography.h4.copyWith(
                              fontWeight: FontWeight.bold,
                              color: FudiColors.foreground,
                              fontSize: 15,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const Spacer(),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _InfoChip(
                                  icon: Icons.access_time,
                                  label: 'Hasta ${_formatPickupEnd(offer)}',
                                ),
                                const SizedBox(width: FudiSpacing.xs),
                                _InfoChip(
                                  icon: Icons.inventory_2_outlined,
                                  label: 'Stock: ${offer.stock}',
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: FudiSpacing.sm),
                  // ── Price: discounted (large) + original (striked) ──
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: FudiSpacing.md,
                      horizontal: FudiSpacing.md,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '\$${offer.discountedPrice.toStringAsFixed(2)}',
                          style: FudiTypography.priceLarge.copyWith(
                            fontSize: 20,
                            height: 1.1,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '\$${offer.originalPrice.toStringAsFixed(2)}',
                          style: FudiTypography.priceOriginal.copyWith(
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Divider(
              height: 1,
              color: FudiColors.borderSolid.withValues(alpha: 0.5),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: FudiSpacing.sm,
                vertical: 0,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _ActionButton(
                      label: 'Ver detalles',
                      icon: Icons.visibility_outlined,
                      onTap: () =>
                          context.push('/business/products/${offer.id}'),
                    ),
                  ),
                  const SizedBox(width: FudiSpacing.sm),
                  Expanded(
                    child: _ActionButton(
                      label: 'Editar',
                      icon: Icons.edit_outlined,
                      onTap: () =>
                          context.push('/business/products/edit/${offer.id}'),
                    ),
                  ),
                  const SizedBox(width: FudiSpacing.sm),
                  Expanded(
                    child: ProductMenu(
                      offer: offer,
                      child: _buildMenuTrigger(context),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    return FudiPressableScale(
      onTap: () => context.push('/business/products/${offer.id}'),
      child: card,
    );
  }

  Widget _buildMenuTrigger(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: FudiColors.destructive.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(FudiRadius.xs),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Más acciones',
            style: FudiTypography.bodySmall.copyWith(
              color: FudiColors.destructive,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            Icons.keyboard_arrow_down_rounded,
            color: FudiColors.destructive,
            size: 18,
          ),
        ],
      ),
    );
  }

  String _formatPickupEnd(Offer offer) {
    final hour = offer.pickupEnd.hour.toString().padLeft(2, '0');
    final minute = offer.pickupEnd.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: FudiSpacing.sm,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: FudiColors.muted,
        borderRadius: BorderRadius.circular(FudiRadius.xs),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: FudiColors.mutedForeground),
          const SizedBox(width: 4),
          Text(
            label,
            style: FudiTypography.bodySmall.copyWith(
              fontWeight: FontWeight.w500,
              color: FudiColors.foreground,
            ),
          ),
        ],
      ),
    );
  }
}

class _SoldChip extends StatelessWidget {
  const _SoldChip({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final hasSales = count > 0;
    final chipColor = hasSales
        ? FudiColors.success
        : FudiColors.mutedForeground;
    final bgColor = hasSales
        ? FudiColors.success.withValues(alpha: 0.12)
        : FudiColors.muted;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: FudiSpacing.sm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(FudiRadius.xs),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(FudiIcons.trendingUp, size: 12, color: chipColor),
          const SizedBox(width: 4),
          Text(
            '$count vendidos',
            style: FudiTypography.bodySmall.copyWith(
              fontWeight: FontWeight.bold,
              color: chipColor,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FudiPressableScale(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: FudiColors.muted,
          borderRadius: BorderRadius.circular(FudiRadius.xs),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: FudiColors.mutedForeground),
            const SizedBox(width: 6),
            Text(
              label,
              style: FudiTypography.bodySmall.copyWith(
                color: FudiColors.foreground,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
