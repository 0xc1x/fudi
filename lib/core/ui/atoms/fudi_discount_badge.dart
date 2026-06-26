import 'package:flutter/material.dart';
import '../fudi_colors.dart';
import '../fudi_spacing.dart';

class FudiDiscountBadge extends StatelessWidget {
  const FudiDiscountBadge({
    super.key,
    required this.percent,
    this.backgroundColor = FudiColors.primary,
    this.textStyle,
    this.paddingGeometry,
    this.borderRadius = FudiRadius.full,
  });

  final int percent;
  final Color backgroundColor;
  final TextStyle? textStyle;
  final EdgeInsetsGeometry? paddingGeometry;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: paddingGeometry ??
          const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Text(
        '-$percent%',
        style: textStyle ??
            const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
      ),
    );
  }
}
