import 'package:flutter/material.dart';

import 'fudi_colors.dart';
import 'fudi_spacing.dart';

class FudiBottomActionBar extends StatelessWidget {
  const FudiBottomActionBar({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final effectiveBorder = isDark ? FudiColorsDark.borderSolid : FudiColors.borderSolid;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(top: BorderSide(color: effectiveBorder)),
        boxShadow: const [
          BoxShadow(
            color: FudiColors.shadow,
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(
        FudiSpacing.lg,
        FudiSpacing.md,
        FudiSpacing.lg,
        FudiSpacing.lg,
      ),
      child: SafeArea(top: false, child: child),
    );
  }
}
