import 'package:flutter/material.dart';

import '../../../../core/ui/fudi_colors.dart';
import '../../../../core/ui/fudi_pressable_scale.dart';
import '../../../../core/ui/fudi_spacing.dart';
import '../../../../core/ui/fudi_surface_card.dart';
import '../../../../core/ui/fudi_typography.dart';

class PaymentMethodSection extends StatelessWidget {
  const PaymentMethodSection({
    super.key,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return FudiSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Método de pago', style: FudiTypography.labelMedium),
          const SizedBox(height: FudiSpacing.sm),
          ...List.generate(_methods.length, (i) {
            final (icon, name, detail) = _methods[i];
            final selected = selectedIndex == i;
            return Padding(
              padding: const EdgeInsets.only(top: FudiSpacing.xs),
              child: FudiPressableScale(
                onTap: () => onChanged(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: FudiSpacing.md,
                    vertical: FudiSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: selected
                          ? FudiColors.primary
                          : (isDark ? FudiColorsDark.borderSolid : FudiColors.borderSolid),
                      width: selected ? 1.5 : 1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    color: selected
                        ? FudiColors.primary.withValues(alpha: 0.04)
                        : Colors.transparent,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        icon,
                        size: 18,
                        color: selected
                            ? FudiColors.primary
                            : (isDark ? FudiColorsDark.mutedForeground : FudiColors.mutedForeground),
                      ),
                      const SizedBox(width: FudiSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: FudiTypography.labelSmall.copyWith(
                                fontWeight: selected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                            if (detail != null)
                              Text(
                                detail,
                                style: FudiTypography.bodySmall.copyWith(
                                  color: isDark ? FudiColorsDark.mutedForeground : FudiColors.mutedForeground,
                                ),
                              ),
                          ],
                        ),
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: selected
                                  ? FudiColors.primary
                                  : (isDark ? FudiColorsDark.borderSolid : FudiColors.borderSolid),
                              width: selected ? 5 : 1.5,
                          ),
                          color: isDark ? FudiColorsDark.background : FudiColors.background,
                        ),
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
