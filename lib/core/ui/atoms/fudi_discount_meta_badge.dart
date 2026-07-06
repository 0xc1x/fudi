import 'package:flutter/material.dart';
import '../fudi_colors.dart';
import '../fudi_spacing.dart';
import '../fudi_typography.dart';

class FudiDiscountMetaBadge extends StatelessWidget {
  const FudiDiscountMetaBadge({
    required this.percent,
    super.key,
  });

  final double percent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: FudiColors.ecoGreen.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(FudiRadius.lg),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.local_offer_rounded,
            size: 14,
            color: FudiColors.ecoGreen,
          ),
          const SizedBox(width: 6),
          Text(
            '${percent.round()}% de descuento para el cliente',
            style: FudiTypography.bodySmall.copyWith(
              color: FudiColors.ecoGreen,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}