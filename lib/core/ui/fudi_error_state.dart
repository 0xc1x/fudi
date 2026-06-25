import 'package:flutter/material.dart';
import 'fudi_colors.dart';
import 'fudi_pressable_scale.dart';
import 'fudi_spacing.dart';
import 'fudi_typography.dart';
import 'atoms/icons/fudi_icons.dart';

class FudiErrorState extends StatelessWidget {
  const FudiErrorState({
    super.key,
    required this.message,
    this.onRetry,
    this.padding = const EdgeInsets.all(FudiSpacing.lg),
  });

  final String message;
  final VoidCallback? onRetry;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              FudiIcons.error,
              size: 48,
              color: FudiColors.destructive,
            ),
            const SizedBox(height: FudiSpacing.sm),
            Text(
              'Error al cargar',
              style: FudiTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: FudiSpacing.xs),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: FudiSpacing.md),
              child: Text(
                message,
                style: FudiTypography.bodySmall.copyWith(
                  color: FudiColors.mutedForeground,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: FudiSpacing.md),
              FudiPressableScale(
                onTap: onRetry,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: FudiSpacing.lg,
                    vertical: FudiSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: FudiColors.primary,
                    borderRadius: BorderRadius.circular(FudiRadius.md),
                  ),
                  child: Text(
                    'Reintentar',
                    style: FudiTypography.labelSmall.copyWith(
                      color: FudiColors.primaryForeground,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
