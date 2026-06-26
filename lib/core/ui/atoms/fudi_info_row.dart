import 'package:flutter/material.dart';
import '../fudi_colors.dart';
import '../fudi_pressable_scale.dart';
import '../fudi_spacing.dart';
import '../fudi_typography.dart';

class FudiInfoRow extends StatelessWidget {
  const FudiInfoRow({
    super.key,
    required this.icon,
    required this.text,
    this.label,
    this.iconColor = FudiColors.primary,
    this.iconSize = 16,
    this.textStyle,
    this.spacing = FudiSpacing.sm,
    this.useIconBackground = false,
    this.isPrimary = false,
    this.isLink = false,
    this.onTap,
    this.trailing,
  });

  final IconData icon;
  final String text;
  final String? label;
  final Color iconColor;
  final double iconSize;
  final TextStyle? textStyle;
  final double spacing;
  final bool useIconBackground;
  final bool isPrimary;
  final bool isLink;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    Widget iconWidget = Icon(icon, size: iconSize, color: iconColor);
    
    if (useIconBackground) {
      iconWidget = Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Icon(icon, size: iconSize, color: iconColor),
        ),
      );
    } else {
      iconWidget = Padding(
        padding: const EdgeInsets.only(top: 2),
        child: iconWidget,
      );
    }

    final TextStyle resolvedTextStyle = textStyle ?? 
        FudiTypography.bodyMedium.copyWith(
          color: isLink 
              ? FudiColors.primary 
              : (isPrimary ? FudiColors.primary : FudiColors.foreground),
          fontWeight: isPrimary ? FontWeight.w500 : null,
        );

    Widget textWidget = Text(
      text,
      style: resolvedTextStyle,
    );

    if (isLink && onTap != null) {
      textWidget = FudiPressableScale(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: textWidget,
        ),
      );
    }

    return Row(
      crossAxisAlignment: useIconBackground ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        iconWidget,
        SizedBox(width: spacing),
        Expanded(
          child: label != null
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label!, 
                      style: FudiTypography.bodySmall.copyWith(
                        color: FudiColors.mutedForeground,
                      ),
                    ),
                    const SizedBox(height: 2),
                    textWidget,
                    if (trailing != null) ...[
                      const SizedBox(height: 4),
                      trailing!,
                    ],
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    textWidget,
                    if (trailing != null) ...[
                      const SizedBox(height: 4),
                      trailing!,
                    ],
                  ],
                ),
        ),
      ],
    );
  }
}
