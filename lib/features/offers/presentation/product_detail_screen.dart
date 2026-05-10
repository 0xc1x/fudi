import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/ui/fudi_colors.dart';
import '../../../core/ui/fudi_spacing.dart';
import '../../../core/ui/fudi_typography.dart';
import '../../../core/ui/fudi_star_rating.dart';
import '../../orders/presentation/order_providers.dart';
import '../domain/offer.dart';
import '../presentation/offer_providers.dart';

class ProductDetailScreen extends ConsumerWidget {
  const ProductDetailScreen({required this.id, super.key});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offerAsync = ref.watch(offerDetailProvider(id));

    return offerAsync.when(
      data: (offer) => _OfferDetailContent(offer: offer),
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: FudiColors.destructive),
              const SizedBox(height: FudiSpacing.md),
              Text('Error al cargar la oferta', style: FudiTypography.bodyMedium),
              const SizedBox(height: FudiSpacing.md),
              FilledButton(
                onPressed: () => ref.invalidate(offerDetailProvider(id)),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OfferDetailContent extends ConsumerWidget {
  const _OfferDetailContent({required this.offer});

  final Offer offer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reservationState = ref.watch(reservationControllerProvider);
    final isReserving = reservationState.step == ReservationStep.reserving ||
        reservationState.step == ReservationStep.paying;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: offer.imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: offer.imageUrl!,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => Container(
                        color: FudiColors.muted,
                        child: const Icon(Icons.broken_image_outlined, size: 64),
                      ),
                    )
                  : Container(
                      color: FudiColors.muted,
                      child: const Icon(Icons.restaurant, size: 64, color: FudiColors.mutedForeground),
                    ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(FudiSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (offer.categoryLabel.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: FudiColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        offer.categoryLabel,
                        style: FudiTypography.bodySmall.copyWith(
                          color: FudiColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  const SizedBox(height: FudiSpacing.sm),
                  Text(offer.title, style: FudiTypography.headlineMedium),
                  const SizedBox(height: FudiSpacing.sm),
                  Row(
                    children: [
                      Icon(Icons.store_outlined, size: 16, color: FudiColors.mutedForeground),
                      const SizedBox(width: 4),
                      Text(offer.business.name, style: FudiTypography.bodyMedium),
                      const SizedBox(width: FudiSpacing.md),
                      FudiStarRating(rating: offer.business.rating, showText: true),
                    ],
                  ),
                  const SizedBox(height: FudiSpacing.lg),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '\$${offer.discountedPrice.toStringAsFixed(0)}',
                        style: FudiTypography.headlineMedium.copyWith(
                          color: FudiColors.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(width: FudiSpacing.sm),
                      Text(
                        '\$${offer.originalPrice.toStringAsFixed(0)}',
                        style: FudiTypography.bodyMedium.copyWith(
                          decoration: TextDecoration.lineThrough,
                          color: FudiColors.mutedForeground,
                        ),
                      ),
                      const SizedBox(width: FudiSpacing.sm),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: FudiColors.secondary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '-${offer.discountPercentage.toStringAsFixed(0)}%',
                          style: FudiTypography.bodySmall.copyWith(
                            color: FudiColors.secondaryForeground,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: FudiSpacing.lg),
                  if (offer.description != null) ...[
                    Text('Descripción', style: FudiTypography.labelMedium),
                    const SizedBox(height: FudiSpacing.xs),
                    Text(offer.description!, style: FudiTypography.bodyMedium),
                    const SizedBox(height: FudiSpacing.lg),
                  ],
                  _InfoRow(
                    icon: Icons.inventory_2_outlined,
                    label: 'Disponibles',
                    value: '${offer.stock} de ${offer.initialStock}',
                    valueColor: offer.stock > 3
                        ? FudiColors.success
                        : offer.stock > 0
                            ? FudiColors.warning
                            : FudiColors.destructive,
                  ),
                  const SizedBox(height: FudiSpacing.sm),
                  _InfoRow(
                    icon: Icons.access_time_rounded,
                    label: 'Recogida',
                    value:
                        '${_formatTime(offer.pickupStart)} - ${_formatTime(offer.pickupEnd)}',
                    valueColor: FudiColors.accent,
                  ),
                  const SizedBox(height: FudiSpacing.lg),
                  Container(
                    padding: const EdgeInsets.all(FudiSpacing.md),
                    decoration: BoxDecoration(
                      color: FudiColors.muted,
                      borderRadius: BorderRadius.circular(FudiRadius.lg),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.location_on_outlined, color: FudiColors.primary),
                        const SizedBox(width: FudiSpacing.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(offer.business.name, style: FudiTypography.labelMedium),
                              const SizedBox(height: 2),
                              Text(offer.business.address, style: FudiTypography.bodySmall),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(FudiSpacing.lg),
          child: FilledButton(
            onPressed: offer.isAvailable && !isReserving
                ? () => context.go('/checkout/${offer.id}')
                : null,
            style: FilledButton.styleFrom(
              backgroundColor: FudiColors.primary,
              minimumSize: const Size.fromHeight(56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(FudiRadius.lg),
              ),
            ),
            child: isReserving
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : Text(
                    offer.isOutOfStock
                        ? 'Agotado'
                        : offer.isExpired
                            ? 'Ventana de pickup cerrada'
                            : 'Reservar por \$${offer.discountedPrice.toStringAsFixed(0)}',
                    style: FudiTypography.labelMedium.copyWith(
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: valueColor ?? FudiColors.mutedForeground),
        const SizedBox(width: FudiSpacing.sm),
        Text(label, style: FudiTypography.bodyMedium),
        const Spacer(),
        Text(
          value,
          style: FudiTypography.labelMedium.copyWith(
            color: valueColor ?? FudiColors.foreground,
          ),
        ),
      ],
    );
  }
}
