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
    return FudiPressableScale(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.white.withValues(alpha: 0.9),
          shape: BoxShape.circle,
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          size: iconSize,
          color: iconColor ?? FudiColors.foreground,
        ),
      ),
    );
  }
}
