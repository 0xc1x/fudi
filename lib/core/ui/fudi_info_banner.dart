import 'package:flutter/material.dart';

import 'fudi_colors.dart';
import 'fudi_spacing.dart';
import 'fudi_typography.dart';

class FudiInfoBanner extends StatelessWidget {
  const FudiInfoBanner({
    required this.message,
    super.key,
    this.title,
    this.icon,
    this.backgroundColor,
    this.borderColor,
    this.foregroundColor,
  });

  final String? title;
  final String message;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final effectiveForeground = foregroundColor ?? FudiColors.foreground;
    return Container(
      padding: const EdgeInsets.all(FudiSpacing.lg),
      decoration: BoxDecoration(
        color: backgroundColor ?? FudiColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(FudiRadius.xl),
        border: Border.all(
          color: borderColor ?? FudiColors.primary.withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, color: effectiveForeground),
            const SizedBox(width: FudiSpacing.md),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null) ...[
                  Text(
                    title!,
                    style: FudiTypography.labelSmall.copyWith(
                      color: effectiveForeground,
                    ),
                  ),
                  const SizedBox(height: FudiSpacing.xs),
                ],
                Text(
                  message,
                  style: FudiTypography.bodySmall.copyWith(
                    color: effectiveForeground,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
