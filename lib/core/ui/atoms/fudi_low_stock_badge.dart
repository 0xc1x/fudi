import 'package:flutter/material.dart';
import '../fudi_spacing.dart';

class FudiLowStockBadge extends StatelessWidget {
  const FudiLowStockBadge({
    super.key,
    required this.label,
    this.backgroundColor,
    this.textStyle,
    this.paddingGeometry,
    this.borderRadius = FudiRadius.full,
  });

  final String label;
  final Color? backgroundColor;
  final TextStyle? textStyle;
  final EdgeInsetsGeometry? paddingGeometry;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveBgColor = backgroundColor ?? theme.colorScheme.error;
    final effectiveTextColor = theme.colorScheme.onError;

    return Container(
      padding: paddingGeometry ??
          const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: effectiveBgColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Text(
        label,
        style: textStyle ??
            TextStyle(
              color: effectiveTextColor,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

