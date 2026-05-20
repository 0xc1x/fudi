import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/ui/fudi_colors.dart';
import '../../../../core/ui/fudi_icons.dart';
import '../../../../core/ui/fudi_spacing.dart';
import '../../../../core/ui/fudi_typography.dart';
import '../../../../core/routing/route_names.dart';

class NoBusinessPrompt extends StatelessWidget {
  const NoBusinessPrompt({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(FudiSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: FudiColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(FudiIcons.storefront, size: 64, color: FudiColors.primary),
            ),
            const SizedBox(height: 32),
            const Text(
              '¡Bienvenido a Fudi!',
              style: FudiTypography.h2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'Para comenzar a rescatar comida, primero necesitas configurar tu primer local.',
              style: FudiTypography.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.pushNamed(RouteNames.businessLocationCreate),
                style: ElevatedButton.styleFrom(
                  backgroundColor: FudiColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Configurar mi primer local', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
