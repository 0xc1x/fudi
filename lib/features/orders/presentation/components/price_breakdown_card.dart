import 'package:flutter/material.dart';

import '../../../../core/ui/fudi_colors.dart';
import '../../../../core/ui/fudi_spacing.dart';
import '../../../../core/ui/fudi_surface_card.dart';
import '../../../../core/ui/fudi_typography.dart';
import '../../../offers/domain/offer.dart';
import '../../domain/coupon.dart';

class PriceBreakdownCard extends StatelessWidget {
  const PriceBreakdownCard({
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
        Text(
          label,
          style: FudiTypography.bodyMedium.copyWith(
            color: FudiColors.mutedForeground,
          ),
        ),
        Text(value, style: FudiTypography.bodyMedium),
      ],
    );
  }
}
