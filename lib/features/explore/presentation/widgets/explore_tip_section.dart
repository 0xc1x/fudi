import 'package:flutter/material.dart';
import '../../../../core/ui/fudi_colors.dart';
import '../../../../core/ui/fudi_spacing.dart';
import '../../../../core/ui/fudi_typography.dart';
import '../explore_screen_content.dart';

/// Banner de "Consejo del día" mostrado entre el grid de categorías
/// y la lista de ofertas.
class ExploreTipSection extends StatelessWidget {
  const ExploreTipSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: FudiSpacing.lg,
        vertical: FudiSpacing.md,
      ),
      child: Container(
        padding: const EdgeInsets.all(FudiSpacing.lg),
        decoration: BoxDecoration(
          color: FudiColors.yellowDark.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(FudiRadius.xl),
          border: Border.all(
            color: FudiColors.yellowDark.withValues(alpha: 0.1),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: FudiColors.yellow.withValues(alpha: 0.25),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.lightbulb_rounded,
                    color: FudiColors.yellow,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Consejo del día',
                    style: FudiTypography.h3.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: FudiSpacing.md),
            Text(
              ExploreScreenContent.tips.join(' '),
              style: FudiTypography.bodyMedium.copyWith(height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}
