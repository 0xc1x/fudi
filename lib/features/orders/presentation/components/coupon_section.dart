import 'package:flutter/material.dart';

import '../../../../core/ui/fudi_colors.dart';
import '../../../../core/ui/fudi_pressable_scale.dart';
import '../../../../core/ui/fudi_spacing.dart';
import '../../../../core/ui/fudi_surface_card.dart';
import '../../../../core/ui/fudi_typography.dart';
import '../../domain/coupon.dart';

class CouponSection extends StatelessWidget {
  const CouponSection({
    super.key,
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
          const Text('Cupón de descuento', style: FudiTypography.labelMedium),
          const SizedBox(height: FudiSpacing.sm),
          if (appliedCoupon != null)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: FudiSpacing.md,
                vertical: FudiSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                border: Border.all(color: const Color(0xFFDCFCE7)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.confirmation_number_rounded,
                    size: 16,
                    color: Color(0xFF16A34A),
                  ),
                  const SizedBox(width: FudiSpacing.sm),
                  Expanded(
                    child: Text(
                      '${appliedCoupon!.code} (${appliedCoupon!.type == 'percentage' ? '${appliedCoupon!.value}%' : '\$${appliedCoupon!.value.toStringAsFixed(2)}'})',
                      style: FudiTypography.labelSmall.copyWith(
                        color: const Color(0xFF15803D),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  FudiPressableScale(
                    onTap: onRemove,
                    child: const Icon(
                      Icons.cancel_rounded,
                      size: 18,
                      color: Color(0xFF16A34A),
                    ),
                  ),
                ],
              ),
            )
          else
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: TextField(
                      controller: controller,
                      enabled: enabled && !validating,
                      textCapitalization: TextCapitalization.characters,
                      style: FudiTypography.bodyMedium,
                      maxLength: 20,
                      buildCounter:
                          (
                            _, {
                            required currentLength,
                            required isFocused,
                            maxLength,
                          }) => const SizedBox.shrink(),
                      decoration: InputDecoration(
                        hintText: 'Código (Ej: REVOLUCION)',
                        hintStyle: TextStyle(
                          color: FudiColors.mutedForeground.withValues(
                            alpha: 0.6,
                          ),
                          fontSize: 13,
                        ),
                        filled: true,
                        fillColor: FudiColors.background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: FudiColors.borderSolid,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: FudiColors.borderSolid,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: FudiColors.primary,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: FudiSpacing.md,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: FudiSpacing.sm),
                FudiPressableScale(
                  onTap:
                      enabled &&
                          !validating &&
                          controller.text.trim().isNotEmpty
                      ? onApply
                      : null,
                  child: Container(
                    height: 44,
                    padding: const EdgeInsets.symmetric(
                      horizontal: FudiSpacing.lg,
                    ),
                    decoration: BoxDecoration(
                      color: controller.text.trim().isNotEmpty
                          ? const Color(0xFF16A34A)
                          : const Color(0xFF16A34A).withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: validating
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              'Aplicar',
                              style: FudiTypography.labelSmall.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
