import 'package:flutter/material.dart';
import 'fudi_colors.dart';
import 'fudi_pressable_scale.dart';
import 'fudi_spacing.dart';
import 'fudi_typography.dart';

class FudiSectionHeader extends StatelessWidget {
  const FudiSectionHeader({
    super.key,
    required this.title,
    this.icon,
    this.onSeeAll,
    this.padding = const EdgeInsets.fromLTRB(
      FudiSpacing.lg,
      FudiSpacing.lg,
      FudiSpacing.lg,
      FudiSpacing.sm,
    ),
  });

  final String title;
  final IconData? icon;
  final VoidCallback? onSeeAll;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: FudiColors.primary),
                const SizedBox(width: 6),
              ],
              Text(title, style: FudiTypography.headlineSmall),
            ],
          ),
          if (onSeeAll != null)
            FudiPressableScale(
              onTap: onSeeAll,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: FudiSpacing.sm,
                  vertical: FudiSpacing.xs,
                ),
                child: Text(
                  'Ver todo',
                  style: FudiTypography.bodySmall.copyWith(
                    color: FudiColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
