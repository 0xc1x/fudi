import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/ui/fudi_colors.dart';
import '../../../core/ui/fudi_pressable_scale.dart';
import '../../../core/ui/atoms/icons/fudi_icons.dart';
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
                          child: FudiPressableScale(
                            onTap: () => context.pop(),
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
                              child: const Icon(
                                FudiIcons.chevronLeft,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: MediaQuery.of(context).padding.top + 12,
                          right: 16,
                          child: _FavoriteCircleButton(
                            isFavorite: isFavorite,
                            onTap: () => ref
                                .read(favoritedOfferIdsProvider.notifier)
                                .toggleFavorite(offer.id),
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
                              borderRadius: BorderRadius.circular(
                                FudiRadius.full,
                              ),
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
                                borderRadius: BorderRadius.circular(
                                  FudiRadius.full,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: FudiColors.destructive.withValues(
                                      alpha: 0.3,
                                    ),
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
                          _StaggerItem(
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
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.star_rounded,
                                                  size: 16,
                                                  color: Color(0xFFFACC15),
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  offer.rating.toStringAsFixed(
                                                    1,
                                                  ),
                                                  style:
                                                      FudiTypography.labelSmall,
                                                ),
                                              ],
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
                            _StaggerItem(
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
                          _StaggerItem(
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
                          ),

                          const SizedBox(height: FudiSpacing.md),

                          // Instrucciones — stagger 3
                          _StaggerItem(
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
                          _StaggerItem(
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
            child: Container(
              padding: EdgeInsets.only(
                left: FudiSpacing.lg,
                right: FudiSpacing.lg,
                top: FudiSpacing.md,
                bottom: FudiSpacing.md + MediaQuery.of(context).padding.bottom,
              ),
              decoration: const BoxDecoration(
                color: FudiColors.background,
                border: Border(top: BorderSide(color: FudiColors.borderSolid)),
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

// ── Stagger item: cada sección entra con un delay incremental ────────────────

class _StaggerItem extends StatefulWidget {
  const _StaggerItem({required this.index, required this.child});
  final int index;
  final Widget child;

  @override
  State<_StaggerItem> createState() => _StaggerItemState();
}

class _StaggerItemState extends State<_StaggerItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _opacity = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    Future.delayed(Duration(milliseconds: 80 + widget.index * 60), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}

// ── Botón circular favorito con latido ───────────────────────────────────────

class _FavoriteCircleButton extends StatefulWidget {
  const _FavoriteCircleButton({required this.isFavorite, required this.onTap});
  final bool isFavorite;
  final VoidCallback onTap;

  @override
  State<_FavoriteCircleButton> createState() => _FavoriteCircleButtonState();
}

class _FavoriteCircleButtonState extends State<_FavoriteCircleButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _scale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 1.0,
          end: 0.65,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 28,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 0.65,
          end: 1.4,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 44,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.4,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.elasticOut)),
        weight: 28,
      ),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(_FavoriteCircleButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isFavorite != widget.isFavorite) {
      _controller.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, child) =>
            Transform.scale(scale: _scale.value, child: child),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: widget.isFavorite
                ? const Color(0xFFEF4444).withValues(alpha: 0.15)
                : Colors.white.withValues(alpha: 0.9),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            widget.isFavorite ? FudiIcons.heart : FudiIcons.heartOutline,
            size: 20,
            color: widget.isFavorite
                ? const Color(0xFFEF4444)
                : FudiColors.foreground,
          ),
        ),
      ),
    );
  }
}

// ── Botón reservar con press scale ───────────────────────────────────────────

class _ReserveButton extends StatefulWidget {
  const _ReserveButton({
    required this.offer,
    required this.isReserving,
    required this.onTap,
  });
  final Offer offer;
  final bool isReserving;
  final VoidCallback? onTap;

  @override
  State<_ReserveButton> createState() => _ReserveButtonState();
}

class _ReserveButtonState extends State<_ReserveButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 200),
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: 0.96,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.onTap == null;

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: isDisabled ? null : (_) => _controller.forward(),
      onTapUp: isDisabled ? null : (_) => _controller.reverse(),
      onTapCancel: isDisabled ? null : () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, child) =>
            Transform.scale(scale: _scale.value, child: child),
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
            child: widget.isReserving
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    widget.offer.isOutOfStock
                        ? 'Agotado'
                        : widget.offer.isExpired
                        ? 'Ventana de pickup cerrada'
                        : 'Reservar ahora',
                    style: FudiTypography.labelMedium.copyWith(
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

// ── Widgets sin cambios ───────────────────────────────────────────────────────

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
