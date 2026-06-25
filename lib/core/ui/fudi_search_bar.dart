import 'package:flutter/material.dart';
import 'fudi_colors.dart';
import 'fudi_pressable_scale.dart';
import 'fudi_spacing.dart';
import 'fudi_typography.dart';
import 'atoms/icons/fudi_icons.dart';

class FudiSearchBar extends StatelessWidget {
  const FudiSearchBar({
    super.key,
    required this.controller,
    this.hintText = 'Buscar...',
    this.onChanged,
    this.onSubmitted,
    this.fillColor = FudiColors.card,
    this.borderRadius = 12.0,
    this.borderSide = const BorderSide(color: FudiColors.borderSolid),
  });

  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final Color fillColor;
  final double borderRadius;
  final BorderSide borderSide;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) => TextField(
        controller: controller,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: FudiTypography.bodyMedium.copyWith(
            color: FudiColors.mutedForeground,
          ),
          prefixIcon: const Icon(
            FudiIcons.search,
            color: FudiColors.mutedForeground,
          ),
          suffixIcon: value.text.isNotEmpty
              ? FudiPressableScale(
                  onTap: () {
                    controller.clear();
                    onChanged?.call('');
                    onSubmitted?.call('');
                  },
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: FudiColors.muted,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      FudiIcons.x,
                      size: 18,
                      color: FudiColors.mutedForeground,
                    ),
                  ),
                )
              : null,
          filled: true,
          fillColor: fillColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: borderSide,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: FudiSpacing.lg,
            vertical: FudiSpacing.md,
          ),
        ),
        style: FudiTypography.bodyMedium,
      ),
    );
  }
}
