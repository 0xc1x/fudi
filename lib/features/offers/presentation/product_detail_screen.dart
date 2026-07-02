import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/ui/fudi_colors.dart';
import '../../../core/ui/fudi_pressable_scale.dart';
import '../../../core/ui/atoms/icons/fudi_icons.dart';
import '../../../core/ui/atoms/fudi_heart_button.dart';
import '../../../core/ui/atoms/fudi_circle_button.dart';
import '../../../core/ui/atoms/fudi_stagger_item.dart';
import '../../../core/ui/fudi_spacing.dart';
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
      data: (offer) => _OfferDetailContentMinimal(offer: offer),
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator.adaptive()),
      ),
      error: (error, _) => Scaffold(
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
                const Text(
                  'Algo salió mal',
                  style: FudiTypography.headlineSmall,
                ),
                const SizedBox(height: FudiSpacing.xl),
                FudiPressableScale(
                  onTap: () => context.go('/'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: FudiColors.foreground,
                      borderRadius: BorderRadius.circular(12),
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

class _OfferDetailContentMinimal extends ConsumerStatefulWidget {
  const _OfferDetailContentMinimal({required this.offer});
  final Offer offer;

  @override
  ConsumerState<_OfferDetailContentMinimal> createState() =>
      _OfferDetailContentMinimalState();
}

class _OfferDetailContentMinimalState
    extends ConsumerState<_OfferDetailContentMinimal> {
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
      backgroundColor: FudiColors.surfaceBackground,
      body: Stack(
        children: [
          // ── Cuerpo de Scroll Principal ─────────────────────────────────────
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Header con Imagen Expandible
              SliverAppBar(
                expandedHeight: 320,
                pinned: true,
                elevation: 0,
                backgroundColor: FudiColors.surfaceBackground,
                automaticallyImplyLeading: false,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      offer.imageUrl != null
                          ? CachedNetworkImage(
                              imageUrl: offer.imageUrl!,
                              fit: BoxFit.cover,
                            )
                          : Container(color: FudiColors.muted),
                      const Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black45,
                                Colors.transparent,
                                FudiColors.surfaceBackground,
                              ],
                              stops: [0.0, 0.5, 1.0],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Contenido Desglosado en Bloques Limpios
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: FudiSpacing.xl,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Categoría o tipo de comida en Badge minimalista
                      FudiStaggerItem(
                        index: 0,
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: FudiColors.primary.withValues(
                                  alpha: 0.1,
                                ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                offer.business.type.toUpperCase(),
                                style: FudiTypography.labelSmall.copyWith(
                                  color: FudiColors.primary,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ),
                            const Spacer(),
                            if (offer.rating > 0) ...[
                              const Icon(
                                Icons.star_rounded,
                                color: FudiColors.yellow,
                                size: 18,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                offer.rating.toStringAsFixed(1),
                                style: FudiTypography.bodyMedium.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                ' (${offer.reviewCount})',
                                style: FudiTypography.bodySmall.copyWith(
                                  color: FudiColors.mutedForeground,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: FudiSpacing.sm),

                      // Título del Negocio
                      FudiStaggerItem(
                        index: 1,
                        child: Text(
                          offer.business.name,
                          style: FudiTypography.headlineMedium.copyWith(
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.8,
                          ),
                        ),
                      ),
                      const SizedBox(height: FudiSpacing.md),

                      // Badges Activos Internos (Descuento y Stock Línea de flotación)
                      FudiStaggerItem(
                        index: 2,
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: FudiColors.foreground,
                                borderRadius: BorderRadius.circular(
                                  FudiRadius.full,
                                ),
                              ),
                              child: Text(
                                'Ahorras el $savings%',
                                style: FudiTypography.bodySmall.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (offer.stock <= 3 && offer.stock > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: FudiColors.destructiveSurface,
                                  border: Border.all(
                                    color: FudiColors.destructiveBorder,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    FudiRadius.full,
                                  ),
                                ),
                                child: Text(
                                  '¡Solo quedan ${offer.stock}!',
                                  style: FudiTypography.bodySmall.copyWith(
                                    color: FudiColors.destructiveVibrant,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: FudiSpacing.xl),

                      // ── Timeline Líquido Mejorado con Datos Completos ───────────────────────

                      // Paso 1: Negocio / Perfil
                      FudiStaggerItem(
                        index: 3,
                        child: _buildTimelineStep(
                          icon: FudiIcons.store,
                          title: 'Establecimiento',
                          subtitle: offer.business.name,
                          trailing: FudiPressableScale(
                            onTap: () => context.push(
                              '/business-profile/${offer.businessId}',
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: FudiColors.primary.withValues(
                                  alpha: 0.1,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Ver local',
                                style: FudiTypography.labelSmall.copyWith(
                                  color: FudiColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      _buildTimelineDivider(),

                      // Paso 2: Ubicación / Distancia
                      FudiStaggerItem(
                        index: 4,
                        child: _buildTimelineStep(
                          icon: FudiIcons.mapPin,
                          title: 'Ubicación',
                          subtitle:
                              'A una distancia de ${_formatDistance(offer)} de ti.',
                        ),
                      ),
                      _buildTimelineDivider(),

                      // Paso 3: Horario de Recogida
                      FudiStaggerItem(
                        index: 5,
                        child: _buildTimelineStep(
                          icon: FudiIcons.clock,
                          title: 'Horario de recogida',
                          subtitle:
                              'Pasa por tu pack hoy de ${_formatTime(offer.pickupStart)} a ${_formatTime(offer.pickupEnd)}',
                        ),
                      ),
                      _buildTimelineDivider(),

                      // Paso 4: Unidades Restantes / Disponibilidad
                      FudiStaggerItem(
                        index: 6,
                        child: _buildTimelineStep(
                          icon: FudiIcons.package_,
                          title: 'Packs disponibles',
                          subtitle:
                              'Quedan libres ${offer.stock} de los ${offer.initialStock} publicados inicialmente.',
                        ),
                      ),
                      _buildTimelineDivider(),

                      // Paso 5: Instrucciones específicas de Recogida
                      FudiStaggerItem(
                        index: 7,
                        child: _buildTimelineStep(
                          icon: FudiIcons.checkCircle,
                          title: 'Instrucciones en mostrador',
                          subtitle:
                              'Presenta tu código de reserva digital al personal antes del cierre de la ventana de tiempo. Ellos te entregarán el pack listo.',
                        ),
                      ),
                      _buildTimelineDivider(),

                      // Paso 6: Contenido del Pack
                      FudiStaggerItem(
                        index: 8,
                        child: _buildTimelineStep(
                          icon: Icons.restaurant_menu_rounded,
                          title: '¿Qué incluye este pack?',
                          subtitle:
                              offer.description ??
                              'Una bolsa sorpresa con excedentes de producción deliciosos y en perfecto estado higiénico del día.',
                        ),
                      ),

                      const SizedBox(height: FudiSpacing.xl),

                      // Card Ecológico de Impacto
                      FudiStaggerItem(
                        index: 9,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(FudiSpacing.xl),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.02),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              const Icon(
                                FudiIcons.leaf,
                                color: FudiColors.success,
                                size: 28,
                              ),
                              const SizedBox(height: FudiSpacing.sm),
                              Text(
                                'Héroe del desperdicio',
                                style: FudiTypography.labelMedium.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Al salvar esta comida evitas que se desperdicien recursos valiosos y disminuyes de inmediato la emisión directa de CO₂.',
                                textAlign: TextAlign.center,
                                style: FudiTypography.bodySmall.copyWith(
                                  color: FudiColors.mutedForeground,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 140),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ── Barra Flotante Superior (Back & Fav) ───────────────────────────
          Positioned(
            top: MediaQuery.of(context).padding.top + 6,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                FudiCircleButton(
                  onTap: () => context.pop(),
                  icon: FudiIcons.chevronLeft,
                ),
                FudiHeartButton(
                  isFavorite: isFavorite,
                  onTap: () => ref
                      .read(favoritedOfferIdsProvider.notifier)
                      .toggleFavorite(offer.id),
                ),
              ],
            ),
          ),

          // ── Barra de Compra Flotante Inferior ──────────────────────────────
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
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
                            color: FudiColors.foreground,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: FudiPressableScale(
                        onTap: offer.isAvailable && !isReserving
                            ? () => context.push('/checkout/${offer.id}')
                            : null,
                        child: Container(
                          height: 52,
                          decoration: BoxDecoration(
                            color: !offer.isAvailable
                                ? FudiColors.mutedForeground.withValues(
                                    alpha: 0.3,
                                  )
                                : FudiColors.primary,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: isReserving
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    offer.isOutOfStock
                                        ? 'Agotado'
                                        : 'Salvar Pack',
                                    style: FudiTypography.labelMedium.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Métodos Helper de UI para el Timeline
  Widget _buildTimelineStep({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 18, color: FudiColors.foreground),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: FudiTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: FudiColors.foreground,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: FudiTypography.bodyMedium.copyWith(
                  color: FudiColors.mutedForeground,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
        if (trailing != null) ...[const SizedBox(width: 12), trailing],
      ],
    );
  }

  Widget _buildTimelineDivider() {
    return Padding(
      padding: const EdgeInsets.only(left: 19),
      child: Container(width: 2, height: 24, color: FudiColors.muted),
    );
  }

  String _formatTime(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

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
