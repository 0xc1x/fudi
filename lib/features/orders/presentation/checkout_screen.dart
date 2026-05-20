import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/error/user_friendly_message.dart';
import '../../../core/ui/fudi_colors.dart';
import '../../../core/ui/fudi_spacing.dart';
import '../../../core/ui/fudi_typography.dart';
import '../../../core/ui/fudi_bottom_action_bar.dart';
import '../../../core/ui/fudi_sticky_page_header.dart';
import '../../../core/ui/fudi_surface_card.dart';
import '../../../core/ui/fudi_info_banner.dart';
import '../../offers/domain/offer.dart';
import '../../offers/presentation/offer_providers.dart';
import '../domain/coupon.dart';
import '../domain/reservation_result.dart';
import '../presentation/order_providers.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({required this.offerId, super.key});

  final String offerId;

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _couponController = TextEditingController();
  Coupon? _appliedCoupon;
  bool _validatingCoupon = false;
  int _selectedPaymentIndex = 0;

  bool _confirmed = false;
  ReservationSuccess? _confirmationResult;

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
      if (next.step == ReservationStep.success && next.result is ReservationSuccess) {
        final success = next.result as ReservationSuccess;
        setState(() {
          _confirmed = true;
          _confirmationResult = success;
        });
        ref.read(reservationControllerProvider.notifier).reset();
        ref.invalidate(userOrdersProvider);
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
      data: (offer) => _confirmed
          ? _ConfirmationView(offer: offer, result: _confirmationResult!)
          : _buildCheckoutContent(context, offer, reservationState),
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        appBar: const FudiStickyPageHeader(title: 'Checkout'),
        body: Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildCheckoutContent(
    BuildContext context,
    Offer offer,
    ReservationState state,
  ) {
    final isProcessing =
        state.step == ReservationStep.reserving || state.step == ReservationStep.paying;
    final discount = _appliedCoupon?.calculateDiscount(offer.discountedPrice) ?? 0;
    const serviceFee = 0.50;
    final total = offer.discountedPrice + serviceFee - discount;

    return Scaffold(
      appBar: const FudiStickyPageHeader(title: 'Confirmar reserva'),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(FudiSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ProductSummaryCard(offer: offer),
                const SizedBox(height: FudiSpacing.lg),
                _PickupDetailsCard(offer: offer),
                const SizedBox(height: FudiSpacing.lg),
                _CouponSection(
                  controller: _couponController,
                  appliedCoupon: _appliedCoupon,
                  validating: _validatingCoupon,
                  enabled: !isProcessing,
                  onApply: () => _validateCoupon(offer),
                  onRemove: () => setState(() {
                    _appliedCoupon = null;
                    _couponController.clear();
                  }),
                ),
                const SizedBox(height: FudiSpacing.lg),
                _PaymentMethodSection(
                  selectedIndex: _selectedPaymentIndex,
                  onChanged: (i) => setState(() => _selectedPaymentIndex = i),
                ),
                const SizedBox(height: FudiSpacing.lg),
                _PriceBreakdownCard(
                  offer: offer,
                  coupon: _appliedCoupon,
                  couponDiscount: discount,
                  serviceFee: serviceFee,
                  total: total,
                ),
                const SizedBox(height: FudiSpacing.lg),
                const FudiInfoBanner(
                  title: 'Importante',
                  message:
                      'Presenta tu código de reserva al recoger.\n'
                      'El contenido puede variar según disponibilidad.\n'
                      'La cancelación está disponible hasta 2 horas antes.',
                  icon: Icons.info_outline,
                  backgroundColor: Color(0xFFFFF7ED),
                  borderColor: Color(0xFFFED7AA),
                  foregroundColor: Color(0xFF9A3412),
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
      bottomNavigationBar: FudiBottomActionBar(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FilledButton(
              onPressed: offer.isAvailable && !isProcessing && !_validatingCoupon
                  ? () => _confirmAndPay(offer)
                  : null,
              style: FilledButton.styleFrom(
                backgroundColor: FudiColors.primary,
                minimumSize: const Size.fromHeight(56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(FudiRadius.lg),
                ),
              ),
              child: isProcessing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      'Confirmar y pagar \$${total > 0 ? total.toStringAsFixed(2) : '0.00'}',
                      style: FudiTypography.labelMedium.copyWith(color: Colors.white),
                    ),
            ),
            const SizedBox(height: FudiSpacing.xs),
            Text(
              'Al confirmar aceptas los términos y condiciones de Fudi',
              style: FudiTypography.bodySmall.copyWith(
                fontSize: 10,
                color: FudiColors.mutedForeground,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _validateCoupon(Offer offer) async {
    final code = _couponController.text.trim();
    if (code.isEmpty) return;

    setState(() => _validatingCoupon = true);

    try {
      final coupon = await ref.read(validateCouponProvider((
        code: code,
        businessId: offer.businessId,
      )).future);

      if (coupon == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cupón no encontrado o inválido'),
              backgroundColor: FudiColors.destructive,
            ),
          );
        }
      } else if (!coupon.isValid) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Este cupón ya no es válido'),
              backgroundColor: FudiColors.destructive,
            ),
          );
        }
      } else if (offer.discountedPrice < coupon.minOrderAmount) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Monto mínimo para este cupón: \$${coupon.minOrderAmount.toStringAsFixed(0)}',
              ),
              backgroundColor: FudiColors.destructive,
            ),
          );
        }
      } else {
        setState(() => _appliedCoupon = coupon);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(userFriendlyMessage(e))),
        );
      }
    } finally {
      if (mounted) setState(() => _validatingCoupon = false);
    }
  }

  void _confirmAndPay(Offer offer) {
    ref
        .read(reservationControllerProvider.notifier)
        .reserveAndPay(offerId: offer.id, couponId: _appliedCoupon?.id);
  }
}

class _ProductSummaryCard extends StatelessWidget {
  const _ProductSummaryCard({required this.offer});

  final Offer offer;

  @override
  Widget build(BuildContext context) {
    return FudiSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Resumen del pedido', style: FudiTypography.labelMedium),
          const SizedBox(height: FudiSpacing.md),
          Row(
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
                    Text(offer.business.name, style: FudiTypography.labelMedium),
                    const SizedBox(height: 2),
                    Text(offer.business.type, style: FudiTypography.bodySmall),
                    const SizedBox(height: 4),
                    Text(offer.title, style: FudiTypography.bodyMedium),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${offer.discountedPrice.toStringAsFixed(2)}',
                    style: FudiTypography.labelMedium.copyWith(
                      color: FudiColors.primary,
                    ),
                  ),
                  Text(
                    '\$${offer.originalPrice.toStringAsFixed(2)}',
                    style: FudiTypography.bodySmall.copyWith(
                      decoration: TextDecoration.lineThrough,
                    ),
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

class _PickupDetailsCard extends StatelessWidget {
  const _PickupDetailsCard({required this.offer});

  final Offer offer;

  @override
  Widget build(BuildContext context) {
    final timeFormat = MaterialLocalizations.of(context);
    final untilTime = timeFormat.formatTimeOfDay(offer.pickupUntilTimeOfDay);

    return FudiSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Detalles de recogida', style: FudiTypography.labelMedium),
          const SizedBox(height: FudiSpacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.location_on, size: 20, color: FudiColors.primary),
              const SizedBox(width: FudiSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Dirección de recogida', style: FudiTypography.labelSmall),
                    const SizedBox(height: 2),
                    Text(offer.business.address, style: FudiTypography.bodySmall),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: FudiSpacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.schedule, size: 20, color: FudiColors.primary),
              const SizedBox(width: FudiSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Horario de recogida', style: FudiTypography.labelSmall),
                    const SizedBox(height: 2),
                    Text('Hoy antes de $untilTime', style: FudiTypography.bodySmall),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CouponSection extends StatelessWidget {
  const _CouponSection({
    required this.controller,
    required this.appliedCoupon,
    required this.validating,
    required this.enabled,
    required this.onApply,
    required this.onRemove,
  });

  final TextEditingController controller;
  final Coupon? appliedCoupon;
  final bool validating;
  final bool enabled;
  final VoidCallback onApply;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return FudiSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.sell, size: 20, color: FudiColors.primary),
              const SizedBox(width: FudiSpacing.sm),
              Text('Cupón de descuento', style: FudiTypography.labelMedium),
            ],
          ),
          const SizedBox(height: FudiSpacing.md),
          if (appliedCoupon != null)
            Container(
              padding: const EdgeInsets.all(FudiSpacing.md),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                border: Border.all(color: const Color(0xFFBBF7D0)),
                borderRadius: BorderRadius.circular(FudiRadius.lg),
              ),
              child: Row(
                children: [
                  const Icon(Icons.sell, size: 16, color: Color(0xFF16A34A)),
                  const SizedBox(width: FudiSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appliedCoupon!.code,
                          style: FudiTypography.labelSmall.copyWith(
                            color: const Color(0xFF15803D),
                          ),
                        ),
                        Text(
                          appliedCoupon!.type == 'percentage'
                              ? '${appliedCoupon!.value}% de descuento'
                              : '\$${appliedCoupon!.value.toStringAsFixed(2)} de descuento',
                          style: FudiTypography.bodySmall.copyWith(
                            color: const Color(0xFF16A34A),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: onRemove,
                    icon: const Icon(Icons.close, size: 16, color: Color(0xFF15803D)),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            )
          else ...[
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    enabled: enabled && !validating,
                    textCapitalization: TextCapitalization.characters,
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
                    maxLength: 20,
                  ),
                ),
                const SizedBox(width: FudiSpacing.sm),
                FilledButton(
                  onPressed: enabled && !validating && controller.text.trim().isNotEmpty
                      ? onApply
                      : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: FudiColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(FudiRadius.md),
                    ),
                  ),
                  child: validating
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Aplicar'),
                ),
              ],
            ),
            const SizedBox(height: FudiSpacing.xs),
            Text(
              'Ejemplo: BIENVENIDO10, PRIMERAVEZ',
              style: FudiTypography.bodySmall,
            ),
          ],
        ],
      ),
    );
  }
}

class _PaymentMethodSection extends StatelessWidget {
  const _PaymentMethodSection({
    required this.selectedIndex,
    required this.onChanged,
  });

  final int selectedIndex;
  final ValueChanged<int> onChanged;

  static const _methods = [
    (Icons.credit_card, 'Tarjeta de crédito/débito', '•••• 4242'),
    (Icons.add_card, 'Agregar nueva tarjeta', null),
  ];

  @override
  Widget build(BuildContext context) {
    return FudiSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Método de pago', style: FudiTypography.labelMedium),
          const SizedBox(height: FudiSpacing.md),
          ...List.generate(_methods.length, (i) {
            final (icon, name, detail) = _methods[i];
            final selected = selectedIndex == i;
            return Padding(
              padding: EdgeInsets.only(top: i > 0 ? FudiSpacing.sm : 0),
              child: GestureDetector(
                onTap: () => onChanged(i),
                child: Container(
                  padding: const EdgeInsets.all(FudiSpacing.md),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: selected ? FudiColors.primary : FudiColors.borderSolid,
                      width: selected ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(FudiRadius.lg),
                    color: selected ? FudiColors.primary.withValues(alpha: 0.05) : null,
                  ),
                  child: Row(
                    children: [
                      Icon(icon, size: 20, color: FudiColors.primary),
                      const SizedBox(width: FudiSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(name, style: FudiTypography.labelSmall),
                            if (detail != null)
                              Text(detail, style: FudiTypography.bodySmall),
                          ],
                        ),
                      ),
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: selected ? FudiColors.primary : FudiColors.mutedForeground,
                            width: 2,
                          ),
                          color: selected ? FudiColors.primary : null,
                        ),
                        child: selected
                            ? const Icon(Icons.circle, size: 8, color: Colors.white)
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _PriceBreakdownCard extends StatelessWidget {
  const _PriceBreakdownCard({
    required this.offer,
    required this.coupon,
    required this.couponDiscount,
    required this.serviceFee,
    required this.total,
  });

  final Offer offer;
  final Coupon? coupon;
  final double couponDiscount;
  final double serviceFee;
  final double total;

  @override
  Widget build(BuildContext context) {
    return FudiSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Desglose de precio', style: FudiTypography.labelMedium),
          const SizedBox(height: FudiSpacing.md),
          _row('Producto', '\$${offer.discountedPrice.toStringAsFixed(2)}'),
          const SizedBox(height: FudiSpacing.sm),
          _row('Tarifa de servicio', '\$${serviceFee.toStringAsFixed(2)}'),
          if (coupon != null && couponDiscount > 0) ...[
            const SizedBox(height: FudiSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.sell, size: 12, color: Color(0xFF16A34A)),
                    const SizedBox(width: 4),
                    Text(
                      'Descuento (${coupon!.code})',
                      style: FudiTypography.bodyMedium.copyWith(
                        color: const Color(0xFF16A34A),
                      ),
                    ),
                  ],
                ),
                Text(
                  '-\$${couponDiscount.toStringAsFixed(2)}',
                  style: FudiTypography.bodyMedium.copyWith(
                    color: const Color(0xFF16A34A),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: FudiSpacing.md),
          const Divider(),
          const SizedBox(height: FudiSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total', style: FudiTypography.labelMedium),
              Text(
                '\$${total > 0 ? total.toStringAsFixed(2) : '0.00'}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: FudiColors.primary,
                ),
              ),
            ],
          ),
          if (coupon != null && couponDiscount > 0) ...[
            const SizedBox(height: FudiSpacing.sm),
            Container(
              padding: const EdgeInsets.all(FudiSpacing.sm),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(FudiRadius.md),
              ),
              child: Center(
                child: Text(
                  '¡Ahorraste \$${couponDiscount.toStringAsFixed(2)} con tu cupón!',
                  style: FudiTypography.bodySmall.copyWith(
                    color: const Color(0xFF15803D),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: FudiTypography.bodyMedium.copyWith(
          color: FudiColors.mutedForeground,
        )),
        Text(value, style: FudiTypography.bodyMedium),
      ],
    );
  }
}

class _ConfirmationView extends StatelessWidget {
  const _ConfirmationView({required this.offer, required this.result});

  final Offer offer;
  final ReservationSuccess result;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FudiColors.muted,
      body: SafeArea(
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(FudiSpacing.lg),
            padding: const EdgeInsets.all(FudiSpacing.xl),
            decoration: BoxDecoration(
              color: FudiColors.background,
              borderRadius: BorderRadius.circular(FudiRadius.xxl),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1A000000),
                  blurRadius: 24,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                      color: Color(0xFFDCFCE7),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle_rounded,
                      size: 48,
                      color: Color(0xFF16A34A),
                    ),
                  ),
                  const SizedBox(height: FudiSpacing.lg),
                  Text(
                    '¡Reserva confirmada!',
                    style: FudiTypography.h2.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: FudiSpacing.sm),
                  Text(
                    'Tu pedido ha sido procesado exitosamente',
                    style: FudiTypography.bodyMedium.copyWith(
                      color: FudiColors.mutedForeground,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: FudiSpacing.xl),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(FudiSpacing.md),
                    decoration: BoxDecoration(
                      color: FudiColors.muted,
                      borderRadius: BorderRadius.circular(FudiRadius.xl),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Número de pedido',
                          style: FudiTypography.bodySmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          result.orderNumber,
                          style: FudiTypography.labelMedium.copyWith(
                            color: FudiColors.primary,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: FudiSpacing.lg),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(FudiSpacing.lg),
                    decoration: BoxDecoration(
                      color: FudiColors.background,
                      border: Border.all(color: FudiColors.primary, width: 2),
                      borderRadius: BorderRadius.circular(FudiRadius.xxl),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Código de recogida',
                          style: FudiTypography.labelSmall.copyWith(
                            color: FudiColors.mutedForeground,
                          ),
                        ),
                        const SizedBox(height: FudiSpacing.md),
                        Container(
                          padding: const EdgeInsets.all(FudiSpacing.xl),
                          decoration: BoxDecoration(
                            color: FudiColors.muted,
                            borderRadius: BorderRadius.circular(FudiRadius.lg),
                          ),
                          child: _QrCodePlaceholder(code: result.pickupCode),
                        ),
                        const SizedBox(height: FudiSpacing.md),
                        Text(
                          result.pickupCode,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 6,
                            color: FudiColors.primary,
                          ),
                        ),
                        const SizedBox(height: FudiSpacing.sm),
                        Text(
                          'Muestra este código al recoger tu pedido',
                          style: FudiTypography.bodySmall.copyWith(fontSize: 10),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: FudiSpacing.lg),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(FudiSpacing.md),
                    decoration: BoxDecoration(
                      color: FudiColors.background,
                      border: Border.all(color: FudiColors.borderSolid),
                      borderRadius: BorderRadius.circular(FudiRadius.xxl),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.location_on, size: 20, color: FudiColors.primary),
                const SizedBox(width: FudiSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Recoger en', style: FudiTypography.labelSmall),
                                  Text(offer.business.name, style: FudiTypography.bodyMedium),
                                  Text(offer.business.address, style: FudiTypography.bodySmall),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: FudiSpacing.md),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.schedule, size: 20, color: FudiColors.primary),
                            const SizedBox(width: FudiSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Horario de recogida', style: FudiTypography.labelSmall),
                                  Text(
                                    'Antes de ${MaterialLocalizations.of(context).formatTimeOfDay(offer.pickupUntilTimeOfDay)}',
                                    style: FudiTypography.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: FudiSpacing.lg),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(FudiSpacing.md),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      border: Border.all(color: const Color(0xFFBBF7D0)),
                      borderRadius: BorderRadius.circular(FudiRadius.lg),
                    ),
                    child: Text(
                      'Recibirás un correo con los detalles de tu pedido. Presenta el código de reserva al recoger.',
                      style: FudiTypography.bodySmall.copyWith(
                        color: const Color(0xFF15803D),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: FudiSpacing.xl),
                  FilledButton(
                    onPressed: () => context.go('/orders'),
                    style: FilledButton.styleFrom(
                      backgroundColor: FudiColors.primary,
                      minimumSize: const Size.fromHeight(56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(FudiRadius.lg),
                      ),
                    ),
                    child: Text(
                      'Ver mis pedidos',
                      style: FudiTypography.labelMedium.copyWith(color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: FudiSpacing.sm),
                  OutlinedButton(
                    onPressed: () => context.go('/'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(FudiRadius.lg),
                      ),
                    ),
                    child: Text(
                      'Buscar más ofertas',
                      style: FudiTypography.labelMedium,
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

class _QrCodePlaceholder extends StatelessWidget {
  const _QrCodePlaceholder({required this.code});

  final String code;

  @override
  Widget build(BuildContext context) {
    final seed = code.isNotEmpty ? code.codeUnitAt(0) : 42;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 3,
        crossAxisSpacing: 3,
      ),
      itemCount: 49,
      itemBuilder: (context, i) {
        final isCorner = (i < 2 || (i >= 5 && i < 7)) ||
            (i >= 42 && i < 44) || (i >= 45 && i < 47) ||
            (i % 7 < 2 && i < 14) ||
            (i % 7 >= 5 && i < 14) ||
            (i % 7 < 2 && i >= 35) ||
            (i % 7 >= 5 && i >= 35);
        final isFilled = isCorner || ((i + seed) % 3 == 0);
        return Container(
          decoration: BoxDecoration(
            color: isFilled ? FudiColors.foreground : FudiColors.background,
            borderRadius: BorderRadius.circular(2),
          ),
        );
      },
    );
  }
}
