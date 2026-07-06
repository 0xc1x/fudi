import 'package:flutter/material.dart';
import 'fudi_colors.dart';
import 'fudi_theme.dart';
import 'fudi_spacing.dart';
import 'fudi_typography.dart';

class FudiFormSection extends StatelessWidget {
  const FudiFormSection({
    required this.title,
    required this.children,
    this.icon,
    this.badge,
    super.key,
  });

  final String title;
  final List<Widget> children;
  final IconData? icon;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeExt = theme.extension<FudiThemeExtension>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 20, color: FudiColors.primary),
              const SizedBox(width: 8),
            ],
            Text(title, style: FudiTypography.h2),
            if (badge != null) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(FudiRadius.lg),
                  border: Border.all(color: FudiColors.borderSolid),
                ),
                child: Text(
                  badge!,
                  style: FudiTypography.bodySmall.copyWith(
                    color: FudiColors.mutedForeground,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: FudiSpacing.md),
        Container(
          padding: const EdgeInsets.all(FudiSpacing.md),
          decoration: BoxDecoration(
            color: themeExt?.cardBg ?? theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(FudiRadius.xl),
            border: Border.all(color: FudiColors.borderSolid),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}