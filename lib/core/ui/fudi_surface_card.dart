import 'package:flutter/material.dart';

import 'fudi_colors.dart';
import 'fudi_spacing.dart';

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
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: FudiColors.card,
        borderRadius: BorderRadius.circular(FudiRadius.lg),
        border: Border.all(
          color: FudiColors.border.withValues(alpha: 0.09),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: FudiColors.primary.withValues(alpha: 0.04),
            blurRadius: 16,
            spreadRadius: -2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        type: MaterialType.transparency,
        borderRadius: BorderRadius.circular(FudiRadius.lg),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}
