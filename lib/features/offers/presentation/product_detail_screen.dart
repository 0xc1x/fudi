import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/ui/fudi_colors.dart';
import '../../../core/ui/fudi_icons.dart';
import '../../../core/ui/fudi_spacing.dart';
import '../../../core/ui/fudi_surface_card.dart';
import '../../../core/ui/fudi_typography.dart';
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
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, _) => Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(FudiSpacing.xl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  FudiIcons.alertTriangle,
                  size: 64,
                  color: FudiColors.mutedForeground,
                ),
                const SizedBox(height: FudiSpacing.md),
                Text(
                  'Producto no encontrado',
                  style: FudiTypography.headlineSmall,
                ),
                const SizedBox(height: FudiSpacing.xs),
                Text(
                  'Este producto no está disponible',
                  style: FudiTypography.bodyMedium.copyWith(
                    color: FudiColors.mutedForeground,
                  ),
                ),
                const SizedBox(height: FudiSpacing.xl),
                FilledButton(
                  onPressed: () => context.go('/'),
                  style: FilledButton.styleFrom(
                    backgroundColor: FudiColors.primary,
                  ),
                  child: const Text('Volver al inicio'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OfferDetailContent extends ConsumerStatefulWidget {
  const _OfferDetailContent({required this.offer});

  final Offer offer;

  @override
  ConsumerState<_OfferDetailContent> createState() =>
      _OfferDetailContentState();
}

class _OfferDetailContentState extends ConsumerState<_OfferDetailContent> {
  bool _isFavorite = false;

  @override
  Widget build(BuildContext context) {
    final offer = widget.offer;
    final reservationState = ref.watch(reservationControllerProvider);
    final isReserving =
        reservationState.step == ReservationStep.reserving ||
        reservationState.step == ReservationStep.paying;
    final savings =
        ((1 - offer.discountedPrice / offer.originalPrice) * 100).round();

    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Stack(
                  children: [
                    SizedBox(
                      height: 288,
                      width: double.infinity,
                      child: offer.imageUrl != null
                          ? CachedNetworkImage(
                              imageUrl: offer.imageUrl!,
                              fit: BoxFit.cover,
                              errorWidget: (_, _, _) => Container(
                                color: FudiColors.muted,
                                child: const Icon(
                                  Icons.broken_image_outlined,
                                  size: 64,
                                ),
                              ),
                            )
                          : Container(
                              color: FudiColors.muted,
                              child: const Icon(
                                Icons.restaurant,
                                size: 64,
                                color: FudiColors.mutedForeground,
                              ),
                            ),
                    ),
                    Positioned(
                      top: MediaQuery.of(context).padding.top + 12,
                      left: 16,
                      child: _CircleButton(
                        onTap: () => context.pop(),
                        icon: FudiIcons.chevronLeft,
                      ),
                    ),
                    Positioned(
                      top: MediaQuery.of(context).padding.top + 12,
                      right: 16,
                      child: _CircleButton(
                        onTap: () =>
                            setState(() => _isFavorite = !_isFavorite),
                        icon: _isFavorite ? FudiIcons.heart : FudiIcons.heartOutline,
                        iconColor: _isFavorite
                            ? const Color(0xFFEF4444)
                            : FudiColors.foreground,
                      ),
                    ),
                    Positioned(
                      bottom: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(FudiRadius.full),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          '-$savings% OFF',
                          style: FudiTypography.labelSmall.copyWith(
                            color: FudiColors.primary,
                          ),
                        ),
                      ),
                    ),
                    if (offer.stock <= 3 && offer.stock > 0)
                      Positioned(
                        bottom: 16,
                        left: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: FudiColors.destructive,
                            borderRadius: BorderRadius.circular(FudiRadius.full),
                            boxShadow: [
                              BoxShadow(
                                color: FudiColors.destructive.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            '¡Solo quedan ${offer.stock}!',
                            style: FudiTypography.bodySmall.copyWith(
                              color: FudiColors.destructiveForeground,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              SliverToBoxAdapter(
                child: Transform.translate(
                  offset: const Offset(0, -16),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: FudiSpacing.lg,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FudiSurfaceCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          offer.business.name,
                                          style: FudiTypography.headlineSmall
                                              .copyWith(
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          offer.business.type,
                                          style: FudiTypography.bodyMedium
                                              .copyWith(
                                            color: FudiColors.mutedForeground,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.star_rounded,
                                            size: 16,
                                            color: Color(0xFFFACC15),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            offer.rating.toStringAsFixed(1),
                                            style: FudiTypography.labelSmall,
                                          ),
                                        ],
                                      ),
                                      Text(
                                        '(${offer.business.reviewCount} reseñas)',
                                        style: FudiTypography.bodySmall.copyWith(
                                          color: FudiColors.mutedForeground,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: FudiSpacing.md),
                              Row(
                                children: [
                                  Icon(
                                    FudiIcons.mapPin,
                                    size: 16,
                                    color: FudiColors.mutedForeground,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _formatDistance(offer),
                                    style: FudiTypography.bodySmall.copyWith(
                                      color: FudiColors.mutedForeground,
                                    ),
                                  ),
                                  const SizedBox(width: FudiSpacing.md),
                                  Icon(
                                    FudiIcons.clock,
                                    size: 16,
                                    color: FudiColors.mutedForeground,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Recoge antes de ${_formatTime(offer.pickupEnd)}',
                                    style: FudiTypography.bodySmall.copyWith(
                                      color: FudiColors.mutedForeground,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: FudiSpacing.md),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () => context.push(
                              '/business-profile/${offer.businessId}',
                            ),
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: FudiColors.muted,
                                    side: BorderSide.none,
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(FudiRadius.xl),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: FudiSpacing.md,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        FudiIcons.store,
                                        size: 20,
                                        color: FudiColors.foreground,
                                      ),
                                      const SizedBox(width: FudiSpacing.sm),
                                      Text(
                                        'Ver perfil del negocio',
                                        style: FudiTypography.labelSmall,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: FudiSpacing.md),
                        if (offer.description != null)
                          FudiSurfaceCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Descripción',
                                  style: FudiTypography.labelMedium,
                                ),
                                const SizedBox(height: FudiSpacing.sm),
                                Text(
                                  offer.description!,
                                  style: FudiTypography.bodyMedium.copyWith(
                                    color: FudiColors.mutedForeground,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: FudiSpacing.md),
                        FudiSurfaceCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '¿Qué incluye?',
                                style: FudiTypography.labelMedium,
                              ),
                              const SizedBox(height: FudiSpacing.sm),
                              Text(
                                'Bolsa sorpresa con una selección variada de productos frescos del día.',
                                style: FudiTypography.bodySmall.copyWith(
                                  color: FudiColors.mutedForeground,
                                ),
                              ),
                              const SizedBox(height: FudiSpacing.sm),
                              _InfoRow(
                                icon: FudiIcons.package_,
                                label: 'Disponibles',
                                value:
                                    '${offer.stock} de ${offer.initialStock}',
                                valueColor: offer.stock > 3
                                    ? FudiColors.success
                                    : offer.stock > 0
                                        ? FudiColors.warning
                                        : FudiColors.destructive,
                              ),
                              const SizedBox(height: FudiSpacing.sm),
                              _InfoRow(
                                icon: FudiIcons.clock,
                                label: 'Recogida',
                                value:
                                    '${_formatTime(offer.pickupStart)} - ${_formatTime(offer.pickupEnd)}',
                                valueColor: FudiColors.primary,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: FudiSpacing.md),
                        FudiSurfaceCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Instrucciones de recogida',
                                style: FudiTypography.labelMedium,
                              ),
                              const SizedBox(height: FudiSpacing.sm),
                              Text(
                                'Presenta tu código de reserva en el mostrador. El pedido estará listo en una bolsa con tu nombre.',
                                style: FudiTypography.bodyMedium.copyWith(
                                  color: FudiColors.mutedForeground,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: FudiSpacing.md),
                        Container(
                          padding: const EdgeInsets.all(FudiSpacing.lg),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0FDF4),
                            borderRadius:
                                BorderRadius.circular(FudiRadius.xl),
                            border: Border.all(
                              color: const Color(0xFFBBF7D0),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    FudiIcons.leaf,
                                    size: 20,
                                    color: const Color(0xFF166534),
                                  ),
                                  const SizedBox(width: FudiSpacing.sm),
                                  Text(
                                    'Impacto ambiental',
                                    style: FudiTypography.labelMedium.copyWith(
                                      color: const Color(0xFF166534),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: FudiSpacing.sm),
                              Text(
                                'Al rescatar este producto, ayudarás a evitar el desperdicio de alimentos y reducir las emisiones de CO₂.',
                                style: FudiTypography.bodySmall.copyWith(
                                  color: const Color(0xFF15803D),
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 120),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.only(
                left: FudiSpacing.lg,
                right: FudiSpacing.lg,
                top: FudiSpacing.md,
                bottom: FudiSpacing.md + MediaQuery.of(context).padding.bottom,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: FudiColors.borderSolid),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x1A000000),
                    blurRadius: 8,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '\$${offer.originalPrice.toStringAsFixed(2)}',
                        style: FudiTypography.bodySmall.copyWith(
                          decoration: TextDecoration.lineThrough,
                          color: FudiColors.mutedForeground,
                        ),
                      ),
                      Text(
                        '\$${offer.discountedPrice.toStringAsFixed(2)}',
                        style: FudiTypography.headlineSmall.copyWith(
                          color: FudiColors.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: FudiSpacing.md),
                  Expanded(
                    child: FilledButton(
                      onPressed: offer.isAvailable && !isReserving
                          ? () => context.push('/checkout/${offer.id}')
                          : null,
                      style: FilledButton.styleFrom(
                        backgroundColor: FudiColors.primary,
                        minimumSize: const Size.fromHeight(56),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(FudiRadius.xl),
                        ),
                      ),
                      child: isReserving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              offer.isOutOfStock
                                  ? 'Agotado'
                                  : offer.isExpired
                                      ? 'Ventana de pickup cerrada'
                                      : 'Reservar ahora',
                              style: FudiTypography.labelMedium.copyWith(
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _formatDistance(Offer offer) {
    if (offer.business.latitude == null) return 'Cerca de ti';
    return 'Cerca de ti';
  }

}

class _CircleButton extends StatelessWidget {
  const _CircleButton({
    required this.onTap,
    required this.icon,
    this.iconColor,
  });

  final VoidCallback onTap;
  final IconData icon;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, size: 20, color: iconColor ?? FudiColors.foreground),
      ),
    );
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
          style: FudiTypography.labelSmall.copyWith(
            color: valueColor ?? FudiColors.foreground,
          ),
        ),
      ],
    );
  }
}
