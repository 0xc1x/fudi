import 'package:flutter/material.dart';
import '../../../../core/ui/atoms/icons/fudi_icons.dart';
import '../../../../core/ui/fudi_colors.dart';
import '../../../../core/ui/fudi_pressable_scale.dart';
import '../../../../core/ui/fudi_spacing.dart';
import '../../../../core/ui/fudi_typography.dart';

class CreateProductButton extends StatelessWidget {
  const CreateProductButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: FudiSpacing.lg),
      child: FudiPressableScale(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: FudiSpacing.lg,
            vertical: FudiSpacing.md,
          ),
          decoration: BoxDecoration(
            color: FudiColors.primary,
            borderRadius: BorderRadius.circular(FudiRadius.full),
            boxShadow: [
              BoxShadow(
                color: FudiColors.primary.withValues(alpha: 0.25),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  color: FudiColors.primaryForeground,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  FudiIcons.plus,
                  color: FudiColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: FudiSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Crear nuevo producto',
                      style: FudiTypography.h4.copyWith(
                        color: FudiColors.primaryForeground,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Agrega un nuevo producto a tu catálogo',
                      style: FudiTypography.bodySmall.copyWith(
                        color: FudiColors.primaryForeground,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                FudiIcons.chevronRight,
                color: FudiColors.primaryForeground,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
