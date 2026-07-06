import 'package:flutter/material.dart';
import '../fudi_spacing.dart';

class FudiDiscountBadge extends StatelessWidget {
  const FudiDiscountBadge({
    super.key,
    required this.percent,
    this.backgroundColor,
    this.textStyle,
    this.paddingGeometry,
    this.borderRadius = FudiRadius.full,
  });

  final int percent;
  final Color? backgroundColor;
  final TextStyle? textStyle;
  final EdgeInsetsGeometry? paddingGeometry;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveBgColor = backgroundColor ?? theme.colorScheme.primary;
    final effectiveTextColor = theme.colorScheme.onPrimary;

    return Container(
      padding: paddingGeometry ??
          const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: effectiveBgColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Text(
        '-$percent%',
        style: textStyle ??
            TextStyle(
              color: effectiveTextColor,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
      ),
    );
  }
}

