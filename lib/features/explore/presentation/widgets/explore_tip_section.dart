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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: FudiSpacing.lg,
        vertical: FudiSpacing.md,
      ),
      child: Container(
        padding: const EdgeInsets.all(FudiSpacing.lg),
        decoration: BoxDecoration(
          color: isDark
              ? FudiColors.surfaceWarning.withValues(alpha: 0.2)
              : FudiColors.surfaceWarning,
          borderRadius: BorderRadius.circular(FudiRadius.xl),
          border: Border.all(
            color: isDark
                ? FudiColors.yellowDark.withValues(alpha: 0.3)
                : FudiColors.yellowDark.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: isDark
                            ? FudiColors.yellow.withValues(alpha: 0.2)
                            : FudiColors.yellow.withValues(alpha: 0.3),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.lightbulb_rounded,
                    color: isDark ? FudiColors.yellow : FudiColors.yellowDark,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Consejo del día',
                    style: FudiTypography.h3.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? FudiColorsDark.foreground
                          : FudiColors.foreground,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: FudiSpacing.md),
            Text(
              ExploreScreenContent.tips.join(' '),
              style: FudiTypography.bodyMedium.copyWith(
                height: 1.4,
                color: isDark
                    ? FudiColorsDark.mutedForeground
                    : FudiColors.foreground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
