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
        color: FudiColors.background,
        borderRadius: BorderRadius.circular(FudiRadius.xl),
        border: Border.all(color: FudiColors.borderSolid),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        type: MaterialType.transparency,
        borderRadius: BorderRadius.circular(FudiRadius.xl),
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}
