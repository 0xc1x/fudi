import 'package:flutter/material.dart';

import 'atoms/icons/fudi_icons.dart';
import 'fudi_colors.dart';
import 'fudi_pressable_scale.dart';
import 'fudi_spacing.dart';
import 'fudi_typography.dart';

class FudiSettingsItem extends StatelessWidget {
  const FudiSettingsItem({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FudiPressableScale(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(FudiSpacing.md),
        child: Row(
          children: [
            Icon(icon, size: 20, color: FudiColors.mutedForeground),
            const SizedBox(width: FudiSpacing.md),
            Expanded(child: Text(label, style: FudiTypography.labelSmall)),
            Icon(
              FudiIcons.chevronRight,
              size: 20,
              color: FudiColors.mutedForeground,
            ),
          ],
        ),
      ),
    );
  }
}
