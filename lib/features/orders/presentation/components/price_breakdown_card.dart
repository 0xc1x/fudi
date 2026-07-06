import 'package:flutter/material.dart';

import '../../../../core/ui/fudi_colors.dart';
import '../../../../core/ui/fudi_spacing.dart';
import '../../../../core/ui/fudi_surface_card.dart';
import '../../../../core/ui/fudi_typography.dart';
import '../../../offers/domain/offer.dart';
import '../../domain/coupon.dart';

class PriceBreakdownCard extends StatelessWidget {
  const PriceBreakdownCard({
    super.key,
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
          const Text('Resumen de costos', style: FudiTypography.labelMedium),
          const SizedBox(height: FudiSpacing.md),
          _buildRow(
            'Precio original de rescate',
            '\$${offer.discountedPrice.toStringAsFixed(2)}',
          ),
          const SizedBox(height: FudiSpacing.xs),
          _buildRow(
            'Tarifa tecnológica de servicio',
            '\$${serviceFee.toStringAsFixed(2)}',
          ),
          if (coupon != null && couponDiscount > 0) ...[
            const SizedBox(height: FudiSpacing.xs),
            _buildRow(
              'Descuento aplicado (${coupon!.code})',
              '-\$${couponDiscount.toStringAsFixed(2)}',
              isDiscount: true,
            ),
          ],
          const Padding(
            padding: EdgeInsets.symmetric(vertical: FudiSpacing.sm),
            child: Divider(color: FudiColors.borderSolid, height: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total a debitar',
                style: FudiTypography.labelMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '\$${total > 0 ? total.toStringAsFixed(2) : '0.00'}',
                style: FudiTypography.h3.copyWith(
                  fontWeight: FontWeight.bold,
                  color: FudiColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value, {bool isDiscount = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: FudiTypography.bodyMedium.copyWith(
            color: isDiscount
                ? FudiColors.ecoGreen
                : FudiColors.mutedForeground,
            fontSize: 13,
          ),
        ),
        Text(
          value,
          style: FudiTypography.bodyMedium.copyWith(
            fontWeight: isDiscount ? FontWeight.bold : FontWeight.normal,
            color: isDiscount ? FudiColors.ecoGreen : null,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
