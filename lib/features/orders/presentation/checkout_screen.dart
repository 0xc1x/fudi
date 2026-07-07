import 'dart:async';

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
  bool _priceBreakdownExpanded = true;

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
        _showErrorSnackBar(next.errorMessage!);
      }
    });

    return offerAsync.when(
      data: (offer) => _confirmed
          ? ConfirmationView(offer: offer, result: _confirmationResult!)
          : _buildCheckoutContent(context, offer, reservationState),
      loading: () => Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: const Center(
          child: CircularProgressIndicator(
            color: FudiColors.primary,
            strokeWidth: 2.5,
          ),
        ),
      ),
      error: (error, _) => Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: const FudiStickyPageHeader(title: 'Checkout'),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(FudiSpacing.xl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  size: 32,
                  color: FudiColors.destructive,
                ),
                const SizedBox(height: FudiSpacing.md),
                Text(
                  'No pudimos cargar la orden',
                  style: FudiTypography.h4.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: FudiSpacing.xs),
                Text(
                  userFriendlyMessage(error),
                  style: FudiTypography.bodyMedium.copyWith(
                    color: Theme.of(context).brightness == Brightness.dark
                      ? FudiColorsDark.mutedForeground
                      : FudiColors.mutedForeground,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
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

    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: const FudiStickyPageHeader(title: 'Confirmar reserva'),
      body: AbsorbPointer(
        absorbing: isProcessing,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.symmetric(
                horizontal: FudiSpacing.md,
                vertical: FudiSpacing.md,
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  ProductSummaryCard(offer: offer),
                  const SizedBox(height: FudiSpacing.sm),
                  PickupDetailsCard(offer: offer),
                  const SizedBox(height: FudiSpacing.sm),
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
                  const SizedBox(height: FudiSpacing.sm),
                  PaymentMethodSection(
                    selectedIndex: _selectedPaymentIndex,
                    onChanged: (i) => setState(() => _selectedPaymentIndex = i),
                  ),
                  const SizedBox(height: FudiSpacing.md),
                  Theme(
                    data: Theme.of(
                      context,
                    ).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      tilePadding: EdgeInsets.zero,
                      childrenPadding: EdgeInsets.zero,
                      initiallyExpanded: _priceBreakdownExpanded,
                      onExpansionChanged: (v) => setState(
                        () => _priceBreakdownExpanded = v,
                      ),
                      title: Text(
                        _priceBreakdownExpanded
                            ? 'Contraer'
                            : 'Ver desglose de precio',
                        style: FudiTypography.bodyMedium.copyWith(
                          color: isDark ? FudiColorsDark.mutedForeground : FudiColors.mutedForeground,
                          fontWeight: FontWeight.w500,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      iconColor: isDark ? FudiColorsDark.mutedForeground : FudiColors.mutedForeground,
                      collapsedIconColor: isDark ? FudiColorsDark.mutedForeground : FudiColors.mutedForeground,
                      children: [
                        PriceBreakdownCard(
                          offer: offer,
                          coupon: _appliedCoupon,
                          couponDiscount: discount,
                          serviceFee: serviceFee,
                          total: total,
                        ),
                        const SizedBox(height: FudiSpacing.md),
                      ],
                    ),
                  ),
                  FudiInfoBanner(
                    title: 'Política de Rescate Circular',
                    message:
                        'Asegúrate de retirar a tiempo. Al rescatar esta comida evitas desperdicios directos de CO₂ en el mercado local.',
                    icon: Icons.eco_rounded,
                    backgroundColor: isDark ? FudiColorsDark.surfaceSuccess : FudiColors.surfaceSuccess,
                    borderColor: isDark ? FudiColorsDark.surfaceSuccessBorder : FudiColors.surfaceSuccessBorder,
                    foregroundColor: FudiColors.successDark,
                  ),
                  const SizedBox(height: 160),
                ]),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: FudiBottomActionBar(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FudiPressableScale(
              onTap: offer.isAvailable && !isProcessing && !_validatingCoupon
                  ? () => _confirmAndPay(offer)
                  : null,
              child: Container(
                width: double.infinity,
                height: 58,
                padding: const EdgeInsets.symmetric(horizontal: FudiSpacing.md),
                decoration: BoxDecoration(
                  color: (offer.isAvailable && !isProcessing)
                      ? FudiColors.primary
                      : (isDark ? FudiColorsDark.muted : FudiColors.muted),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: isProcessing
                    ? const Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: FudiColors.primaryForeground,
                              ),
                            ),
                            SizedBox(width: FudiSpacing.md),
                            Text(
                              'Validando transacción...',
                              style: TextStyle(
                                color: FudiColors.primaryForeground,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'TOTAL A PAGAR',
                                style: TextStyle(
                                  color: FudiColors.primaryForeground.withValues(alpha: 0.7),
                                  fontSize: 9,
                                  letterSpacing: 1.1,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '\$${total > 0 ? total.toStringAsFixed(2) : '0.00'}',
                                style: FudiTypography.h4.copyWith(
                                  color: FudiColors.primaryForeground,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                'Reservar',
                                style: FudiTypography.labelMedium.copyWith(
                                  color: FudiColors.primaryForeground,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: FudiSpacing.xs),
                              const Icon(
                                Icons.arrow_forward_ios_rounded,
                                color: FudiColors.primaryForeground,
                                size: 14,
                              ),
                            ],
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: FudiSpacing.sm),
            Text(
              'Términos y condiciones de Economía Circular aplicados.',
              style: FudiTypography.bodySmall.copyWith(
                fontSize: 9,
                color: isDark ? FudiColorsDark.mutedForeground : FudiColors.mutedForeground,
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

      if (!mounted) return;

      if (coupon == null) {
        _showErrorSnackBar('Cupón no encontrado o inválido');
      } else if (!coupon.isValid) {
        _showErrorSnackBar('Este cupón ya no es válido');
      } else if (offer.discountedPrice < coupon.minOrderAmount) {
        _showErrorSnackBar(
          'Monto mínimo para este cupón: \$${coupon.minOrderAmount.toStringAsFixed(0)}',
        );
      } else {
        setState(() => _appliedCoupon = coupon);
      }
    } catch (e) {
      if (mounted) _showErrorSnackBar(userFriendlyMessage(e));
    } finally {
      if (mounted) setState(() => _validatingCoupon = false);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        backgroundColor: FudiColors.destructive,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(FudiSpacing.md),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _confirmAndPay(Offer offer) {
    unawaited(
      ref
          .read(reservationControllerProvider.notifier)
          .reserveAndPay(offerId: offer.id, couponId: _appliedCoupon?.id),
    );
  }
}
