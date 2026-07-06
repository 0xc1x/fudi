import 'package:flutter/material.dart';

import 'fudi_colors.dart';
import 'fudi_spacing.dart';
import 'fudi_theme.dart';

class FudiSurfaceCard extends StatelessWidget {
  const FudiSurfaceCard({
    required this.child,
    super.key,
    this.padding = const EdgeInsets.all(FudiSpacing.lg),
    this.margin,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeExt = theme.extension<FudiThemeExtension>();

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: themeExt?.cardBg ?? theme.cardTheme.color ?? FudiColors.card,
        borderRadius: BorderRadius.circular(FudiRadius.lg),
        border: Border.all(
          color: themeExt?.border ?? FudiColors.border.withValues(alpha: 0.09),
        ),
        boxShadow: themeExt?.surfaceShadow != null && themeExt!.surfaceShadow != Colors.transparent
            ? [
                BoxShadow(
                  color: themeExt.surfaceShadow,
                  blurRadius: 16,
                  spreadRadius: -2,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Material(
        type: MaterialType.transparency,
        borderRadius: BorderRadius.circular(FudiRadius.lg),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}
