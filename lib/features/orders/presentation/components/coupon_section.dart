import 'package:flutter/material.dart';

import '../../../../core/ui/fudi_colors.dart';
import '../../../../core/ui/fudi_pressable_scale.dart';
import '../../../../core/ui/fudi_spacing.dart';
import '../../../../core/ui/fudi_surface_card.dart';
import '../../../../core/ui/fudi_typography.dart';
import '../../domain/coupon.dart';

class CouponSection extends StatelessWidget {
  const CouponSection({
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
                  FudiPressableScale(
                    onTap: onRemove,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(color: Colors.transparent, shape: BoxShape.circle),
                      child: const Icon(
                        Icons.close,
                        size: 16,
                        color: Color(0xFF15803D),
                      ),
                    ),
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
                FudiPressableScale(
                  onTap:
                      enabled && !validating && controller.text.trim().isNotEmpty
                          ? onApply
                          : null,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: FudiColors.primary,
                      borderRadius: BorderRadius.circular(FudiRadius.md),
                    ),
                    child: Center(
                      child: validating
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Aplicar', style: TextStyle(color: Colors.white)),
                    ),
                  ),
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
