import 'package:flutter/material.dart';

import '../../../../core/ui/fudi_colors.dart';
import '../../../../core/ui/fudi_spacing.dart';
import '../../../../core/ui/fudi_surface_card.dart';
import '../../../../core/ui/fudi_typography.dart';

class PaymentMethodSection extends StatelessWidget {
  const PaymentMethodSection({
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
                      color: selected
                          ? FudiColors.primary
                          : FudiColors.borderSolid,
                      width: selected ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(FudiRadius.lg),
                    color: selected
                        ? FudiColors.primary.withValues(alpha: 0.05)
                        : null,
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
                            color: selected
                                ? FudiColors.primary
                                : FudiColors.mutedForeground,
                            width: 2,
                          ),
                          color: selected ? FudiColors.primary : null,
                        ),
                        child: selected
                            ? const Icon(
                                Icons.circle,
                                size: 8,
                                color: Colors.white,
                              )
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
