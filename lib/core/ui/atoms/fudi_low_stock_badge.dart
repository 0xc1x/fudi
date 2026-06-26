import 'package:flutter/material.dart';
import '../fudi_colors.dart';
import '../fudi_spacing.dart';

class FudiLowStockBadge extends StatelessWidget {
  const FudiLowStockBadge({
    super.key,
    required this.label,
    this.backgroundColor = FudiColors.destructive,
    this.textStyle,
    this.paddingGeometry,
    this.borderRadius = FudiRadius.full,
  });

  final String label;
  final Color backgroundColor;
  final TextStyle? textStyle;
  final EdgeInsetsGeometry? paddingGeometry;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: paddingGeometry ??
          const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Text(
        label,
        style: textStyle ??
            const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
