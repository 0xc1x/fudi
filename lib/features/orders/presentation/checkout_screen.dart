import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/user_friendly_message.dart';
import '../../../core/ui/fudi_bottom_action_bar.dart';
import '../../../core/ui/fudi_colors.dart';
import '../../../core/ui/fudi_info_banner.dart';
import '../../../core/ui/fudi_pressable_scale.dart';
import '../../../core/ui/fudi_spacing.dart';
import '../../../core/ui/fudi_sticky_page_header.dart';
import '../../../core/ui/fudi_typography.dart';
import '../../offers/domain/offer.dart';
import '../../offers/presentation/offer_providers.dart';
import '../domain/coupon.dart';
import '../domain/reservation_result.dart';
import 'components/confirmation_view.dart';
import 'components/coupon_section.dart';
import 'components/payment_method_section.dart';
import 'components/pickup_details_card.dart';
import 'components/price_breakdown_card.dart';
import 'components/product_summary_card.dart';
import 'order_providers.dart';

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
      if (next.step == ReservationStep.success &&
          next.result is ReservationSuccess) {
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
          ? ConfirmationView(offer: offer, result: _confirmationResult!)
          : _buildCheckoutContent(context, offer, reservationState),
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
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
        state.step == ReservationStep.reserving ||
        state.step == ReservationStep.paying;
    final discount =
        _appliedCoupon?.calculateDiscount(offer.discountedPrice) ?? 0;
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
                ProductSummaryCard(offer: offer),
                const SizedBox(height: FudiSpacing.lg),
                PickupDetailsCard(offer: offer),
                const SizedBox(height: FudiSpacing.lg),
                CouponSection(
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
                PaymentMethodSection(
                  selectedIndex: _selectedPaymentIndex,
                  onChanged: (i) => setState(() => _selectedPaymentIndex = i),
                ),
                const SizedBox(height: FudiSpacing.lg),
                PriceBreakdownCard(
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
            FudiPressableScale(
              onTap:
                  offer.isAvailable && !isProcessing && !_validatingCoupon
                  ? () => _confirmAndPay(offer)
                  : null,
              child: Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  color: FudiColors.primary,
                  borderRadius: BorderRadius.circular(FudiRadius.lg),
                ),
                child: Center(
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
                          style: FudiTypography.labelMedium.copyWith(
                            color: Colors.white,
                          ),
                        ),
                ),
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
      final coupon = await ref.read(
        validateCouponProvider((
          code: code,
          businessId: offer.businessId,
        )).future,
      );

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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(userFriendlyMessage(e))));
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
