import 'package:flutter/material.dart';
import 'fudi_colors.dart';
import 'fudi_spacing.dart';
import 'fudi_typography.dart';
import 'atoms/icons/fudi_icons.dart';

class FudiEmptyState extends StatelessWidget {
  const FudiEmptyState({
    super.key,
    required this.title,
    required this.description,
    this.icon = FudiIcons.search,
    this.iconSize = 48,
    this.padding = const EdgeInsets.all(FudiSpacing.xl),
  });

  final String title;
  final String description;
  final IconData icon;
  final double iconSize;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: padding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: iconSize,
              color: FudiColors.mutedForeground,
            ),
            const SizedBox(height: FudiSpacing.md),
            Text(
              title,
              style: FudiTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: FudiSpacing.xs),
            Text(
              description,
              style: FudiTypography.bodySmall.copyWith(
                color: FudiColors.mutedForeground,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
