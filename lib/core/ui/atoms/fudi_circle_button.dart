import 'package:flutter/material.dart';
import '../fudi_colors.dart';
import '../fudi_pressable_scale.dart';

class FudiCircleButton extends StatelessWidget {
  const FudiCircleButton({
    super.key,
    required this.onTap,
    required this.icon,
    this.size = 40,
    this.iconSize = 20,
    this.backgroundColor,
    this.iconColor,
  });

  final VoidCallback onTap;
  final IconData icon;
  final double size;
  final double iconSize;
  final Color? backgroundColor;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultBgColor = theme.brightness == Brightness.dark
        ? theme.colorScheme.surface.withValues(alpha: 0.9)
        : FudiColors.card.withValues(alpha: 0.9);
    final defaultIconColor = theme.colorScheme.onSurface;

    return FudiPressableScale(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: backgroundColor ?? defaultBgColor,
          shape: BoxShape.circle,
          boxShadow: const [
            BoxShadow(
              color: FudiColors.shadow,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          size: iconSize,
          color: iconColor ?? defaultIconColor,
        ),
      ),
    );
  }
}
