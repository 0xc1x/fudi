import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/ui/fudi_colors.dart';
import '../../../core/ui/fudi_pressable_scale.dart';
import '../../../core/ui/atoms/icons/fudi_icons.dart';
import '../../../core/ui/atoms/fudi_heart_button.dart';
import '../../../core/ui/atoms/fudi_discount_badge.dart';
import '../../../core/ui/atoms/fudi_low_stock_badge.dart';
import '../../../core/ui/atoms/fudi_circle_button.dart';
import '../../../core/ui/atoms/fudi_stagger_item.dart';
import '../../../core/ui/atoms/fudi_key_value_row.dart';
import '../../../core/ui/fudi_star_rating.dart';
import '../../../core/ui/fudi_bottom_action_bar.dart';
import '../../../core/ui/fudi_spacing.dart';
import '../../../core/ui/fudi_surface_card.dart';
import '../../../core/ui/fudi_typography.dart';
import '../../../core/utils/geo_utils.dart';
import '../../favorites/presentation/favorites_providers.dart';
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
                FudiPressableScale(
                  onTap: () => context.go('/'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: FudiSpacing.lg,
                      vertical: FudiSpacing.md,
                    ),
                    decoration: BoxDecoration(
                      color: FudiColors.primary,
                      borderRadius: BorderRadius.circular(FudiRadius.full),
                    ),
                    child: const Text(
                      'Volver al inicio',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Contenido principal con animaciones de entrada ────────────────────────────

class _OfferDetailContent extends ConsumerStatefulWidget {
  const _OfferDetailContent({required this.offer});
  final Offer offer;

  @override
  ConsumerState<_OfferDetailContent> createState() =>
      _OfferDetailContentState();
}

class _OfferDetailContentState extends ConsumerState<_OfferDetailContent>
    with SingleTickerProviderStateMixin {
  // Controla el fade+slide de entrada de toda la pantalla
  late final AnimationController _enterController;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _enterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _fadeAnim = CurvedAnimation(
      parent: _enterController,
      curve: Curves.easeOut,
    );
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.04), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _enterController, curve: Curves.easeOutCubic),
        );

    _enterController.forward();
  }

  @override
  void dispose() {
    _enterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final offer = widget.offer;
    final isFavorite = ref.watch(favoritedOfferIdsProvider).contains(offer.id);
    final reservationState = ref.watch(reservationControllerProvider);
    final isReserving =
        reservationState.step == ReservationStep.reserving ||
        reservationState.step == ReservationStep.paying;
    final savings = ((1 - offer.discountedPrice / offer.originalPrice) * 100)
        .round();

    return Scaffold(
      body: Stack(
        children: [
          FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: _slideAnim,
              child: CustomScrollView(
                slivers: [
                  // ── Hero imagen ─────────────────────────────────────────
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
                          child: FudiCircleButton(
                            onTap: () => context.pop(),
                            icon: FudiIcons.chevronLeft,
                          ),
                        ),
                        Positioned(
                          top: MediaQuery.of(context).padding.top + 12,
                          right: 16,
                          child: FudiHeartButton(
                            isFavorite: isFavorite,
                            onTap: () => ref
                                .read(favoritedOfferIdsProvider.notifier)
                                .toggleFavorite(offer.id),
                          ),
                        ),
                        Positioned(
                          bottom: 16,
                          right: 16,
                          child: FudiDiscountBadge(
                            percent: savings,
                            backgroundColor: Colors.white,
                            textStyle: FudiTypography.labelSmall.copyWith(
                              color: FudiColors.primary,
                            ),
                          ),
                        ),
                        if (offer.stock <= 3 && offer.stock > 0)
                          Positioned(
                            bottom: 16,
                            left: 16,
                            child: FudiLowStockBadge(
                              label: '¡Solo quedan ${offer.stock}!',
                              paddingGeometry: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              textStyle: FudiTypography.bodySmall.copyWith(
                                color: FudiColors.destructiveForeground,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // ── Contenido con stagger ───────────────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: FudiSpacing.xxl,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: FudiSpacing.md),

                          // Card negocio — stagger 0
                          FudiStaggerItem(
                            index: 0,
                            child: FudiSurfaceCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              offer.business.name,
                                              style: FudiTypography
                                                  .headlineSmall
                                                  .copyWith(
                                                    fontWeight: FontWeight.w800,
                                                  ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              offer.business.type,
                                              style: FudiTypography.bodyMedium
                                                  .copyWith(
                                                    color: FudiColors
                                                        .mutedForeground,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          if (offer.rating > 0) ...[
                                            FudiStarRating(
                                              rating: offer.rating,
                                              showText: true,
                                            ),
                                            Text(
                                              '(${offer.reviewCount} reseñas)',
                                              style: FudiTypography.bodySmall
                                                  .copyWith(
                                                    color: FudiColors
                                                        .mutedForeground,
                                                  ),
                                            ),
                                          ],
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
                                        style: FudiTypography.bodySmall
                                            .copyWith(
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
                                        style: FudiTypography.bodySmall
                                            .copyWith(
                                              color: FudiColors.mutedForeground,
                                            ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: FudiSpacing.md),
                                  SizedBox(
                                    width: double.infinity,
                                    child: FudiPressableScale(
                                      onTap: () => context.push(
                                        '/business-profile/${offer.businessId}',
                                      ),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: FudiSpacing.md,
                                        ),
                                        decoration: BoxDecoration(
                                          color: FudiColors.muted,
                                          borderRadius: BorderRadius.circular(
                                            FudiRadius.xl,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              FudiIcons.store,
                                              size: 20,
                                              color: FudiColors.foreground,
                                            ),
                                            const SizedBox(
                                              width: FudiSpacing.sm,
                                            ),
                                            Text(
                                              'Ver perfil del negocio',
                                              style: FudiTypography.labelSmall,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: FudiSpacing.md),

                          // Descripción — stagger 1
                          if (offer.description != null)
                            FudiStaggerItem(
                              index: 1,
                              child: SizedBox(
                                width: double.infinity,
                                child: FudiSurfaceCard(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Descripción',
                                        style: FudiTypography.labelMedium,
                                      ),
                                      const SizedBox(height: FudiSpacing.sm),
                                      Text(
                                        offer.description!,
                                        style: FudiTypography.bodyMedium
                                            .copyWith(
                                              color: FudiColors.mutedForeground,
                                              height: 1.5,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                          const SizedBox(height: FudiSpacing.md),

                          // Qué incluye — stagger 2
                          FudiStaggerItem(
                            index: 2,
                            child: FudiSurfaceCard(
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
                                  FudiKeyValueRow(
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
                                  FudiKeyValueRow(
                                    icon: FudiIcons.clock,
                                    label: 'Recogida',
                                    value:
                                        '${_formatTime(offer.pickupStart)} - ${_formatTime(offer.pickupEnd)}',
                                    valueColor: FudiColors.primary,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: FudiSpacing.md),

                          // Instrucciones — stagger 3
                          FudiStaggerItem(
                            index: 3,
                            child: FudiSurfaceCard(
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
                          ),

                          const SizedBox(height: FudiSpacing.md),

                          // Impacto ambiental — stagger 4
                          FudiStaggerItem(
                            index: 4,
                            child: Container(
                              padding: const EdgeInsets.all(FudiSpacing.lg),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF0FDF4),
                                borderRadius: BorderRadius.circular(
                                  FudiRadius.xl,
                                ),
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
                                        style: FudiTypography.labelMedium
                                            .copyWith(
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
                          ),

                          const SizedBox(height: 120),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Barra inferior con botón de reserva ──────────────────────────
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: FudiBottomActionBar(
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
                    child: _ReserveButton(
                      offer: offer,
                      isReserving: isReserving,
                      onTap: offer.isAvailable && !isReserving
                          ? () => context.push('/checkout/${offer.id}')
                          : null,
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
    final pos = ref.read(userLocationProvider).asData?.value;
    return GeoUtils.formatDistance(
      offer.business.latitude,
      offer.business.longitude,
      userLat: pos?.latitude,
      userLng: pos?.longitude,
    );
  }
}

// ── Botón reservar ───────────────────────────────────────────────────────────

class _ReserveButton extends StatelessWidget {
  const _ReserveButton({
    required this.offer,
    required this.isReserving,
    required this.onTap,
  });
  final Offer offer;
  final bool isReserving;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDisabled = onTap == null;

    return FudiPressableScale(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 56,
        decoration: BoxDecoration(
          color: isDisabled
              ? FudiColors.primary.withValues(alpha: 0.4)
              : FudiColors.primary,
          borderRadius: BorderRadius.circular(FudiRadius.xl),
          boxShadow: isDisabled
              ? []
              : [
                  BoxShadow(
                    color: FudiColors.primary.withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Center(
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
    );
  }
}

