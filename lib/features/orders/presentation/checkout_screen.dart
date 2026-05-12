import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/ui/fudi_colors.dart';
import '../../../core/ui/fudi_spacing.dart';
import '../../../core/ui/fudi_typography.dart';
import '../../offers/domain/offer.dart';
import '../../offers/presentation/offer_providers.dart';
import '../presentation/order_providers.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({required this.offerId, super.key});

  final String offerId;

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _couponController = TextEditingController();
  String? _couponId;
  double _couponDiscount = 0;

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final offerAsync = ref.watch(offerDetailProvider(widget.offerId));
    final reservationState = ref.watch(reservationControllerProvider);

    ref.listen<ReservationState>(reservationControllerProvider, (prev, next) {
      if (next.step == ReservationStep.success && next.orderId != null) {
        ref.read(reservationControllerProvider.notifier).reset();
        context.go('/review-order/${next.orderId}');
      }
      if (next.step == ReservationStep.error && next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: FudiColors.destructive,
          ),
        );
      }
    });

    return offerAsync.when(
      data: (offer) => _buildContent(context, offer, reservationState),
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
        appBar: null,
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(title: const Text('Checkout')),
        body: Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    Offer offer,
    ReservationState state,
  ) {
    final isProcessing =
        state.step == ReservationStep.reserving ||
        state.step == ReservationStep.paying;
    final total = offer.discountedPrice - _couponDiscount;

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(FudiSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _OfferSummary(offer: offer),
                const SizedBox(height: FudiSpacing.xl),
                Text('Cupón de descuento', style: FudiTypography.labelMedium),
                const SizedBox(height: FudiSpacing.sm),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _couponController,
                        decoration: InputDecoration(
                          hintText: 'Ingresa tu código',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(FudiRadius.md),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: FudiSpacing.md,
                            vertical: FudiSpacing.sm,
                          ),
                        ),
                        enabled: !isProcessing,
                      ),
                    ),
                    const SizedBox(width: FudiSpacing.sm),
                    FilledButton(
                      onPressed: _couponId != null ? null : _applyCoupon,
                      style: FilledButton.styleFrom(
                        backgroundColor: FudiColors.primary,
                      ),
                      child: const Text('Aplicar'),
                    ),
                  ],
                ),
                if (_couponDiscount > 0) ...[
                  const SizedBox(height: FudiSpacing.xs),
                  Text(
                    'Cupón aplicado: -\$${_couponDiscount.toStringAsFixed(0)}',
                    style: FudiTypography.bodySmall.copyWith(
                      color: FudiColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                const SizedBox(height: FudiSpacing.xl),
                const Divider(),
                const SizedBox(height: FudiSpacing.md),
                _PriceRow(label: 'Precio original', value: offer.originalPrice),
                const SizedBox(height: FudiSpacing.xs),
                _PriceRow(
                  label: 'Descuento de oferta',
                  value: -(offer.originalPrice - offer.discountedPrice),
                  color: FudiColors.success,
                ),
                if (_couponDiscount > 0) ...[
                  const SizedBox(height: FudiSpacing.xs),
                  _PriceRow(
                    label: 'Cupón',
                    value: -_couponDiscount,
                    color: FudiColors.success,
                  ),
                ],
                const SizedBox(height: FudiSpacing.sm),
                const Divider(),
                const SizedBox(height: FudiSpacing.sm),
                _PriceRow(
                  label: 'Total',
                  value: total > 0 ? total : 0,
                  isBold: true,
                ),
                const SizedBox(height: 120),
              ],
            ),
          ),
          if (isProcessing)
            Container(
              color: Colors.black26,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: FudiSpacing.md),
                    Text(
                      'Procesando reserva...',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
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
            onPressed: offer.isAvailable && !isProcessing
                ? () => _confirmAndPay(offer)
                : null,
            style: FilledButton.styleFrom(
              backgroundColor: FudiColors.primary,
              minimumSize: const Size.fromHeight(56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(FudiRadius.lg),
              ),
            ),
            child: Text(
              'Confirmar y pagar \$${(total > 0 ? total : 0).toStringAsFixed(0)}',
              style: FudiTypography.labelMedium.copyWith(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  void _applyCoupon() {
    final code = _couponController.text.trim();
    if (code.isEmpty) return;

    setState(() {
      _couponDiscount = 2000;
      _couponId = 'mock-coupon-id';
    });
  }

  void _confirmAndPay(Offer offer) {
    ref
        .read(reservationControllerProvider.notifier)
        .reserveAndPay(offerId: offer.id, couponId: _couponId);
  }
}

class _OfferSummary extends StatelessWidget {
  const _OfferSummary({required this.offer});

  final Offer offer;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(FudiSpacing.md),
        child: Row(
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
                  Text(offer.title, style: FudiTypography.labelMedium),
                  const SizedBox(height: 4),
                  Text(offer.business.name, style: FudiTypography.bodySmall),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        '\$${offer.discountedPrice.toStringAsFixed(0)}',
                        style: FudiTypography.labelMedium.copyWith(
                          color: FudiColors.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '\$${offer.originalPrice.toStringAsFixed(0)}',
                        style: FudiTypography.bodySmall.copyWith(
                          decoration: TextDecoration.lineThrough,
                          color: FudiColors.mutedForeground,
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

class _PriceRow extends StatelessWidget {
  const _PriceRow({
    required this.label,
    required this.value,
    this.isBold = false,
    this.color,
  });

  final String label;
  final double value;
  final bool isBold;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final style = isBold
        ? FudiTypography.labelMedium
        : FudiTypography.bodyMedium;
    final effectiveColor =
        color ?? (isBold ? FudiColors.primary : FudiColors.foreground);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        Text(
          '${value < 0 ? "" : ""}\$${value.abs().toStringAsFixed(0)}',
          style: style.copyWith(color: effectiveColor),
        ),
      ],
    );
  }
}
