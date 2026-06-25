import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/ui/fudi_colors.dart';
import '../../../../core/ui/fudi_pressable_scale.dart';
import '../../../../core/ui/atoms/icons/fudi_icons.dart';
import '../../../../core/ui/fudi_spacing.dart';
import '../../../../core/ui/fudi_typography.dart';
import '../../../../core/routing/route_names.dart';
import '../../../auth/presentation/auth_state_provider.dart';

class NoBusinessPrompt extends ConsumerWidget {
  const NoBusinessPrompt({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: SingleChildScrollView(
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
              child: const Icon(
                FudiIcons.storefront,
                size: 64,
                color: FudiColors.primary,
              ),
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
                onPressed: () =>
                    context.pushNamed(RouteNames.businessLocationCreate),
                style: ElevatedButton.styleFrom(
                  backgroundColor: FudiColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Configurar mi primer local',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 24),
            FudiPressableScale(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Cerrar sesión'),
                    content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
                    actions: [
                      FudiPressableScale(
                        onTap: () => Navigator.of(ctx).pop(),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          child: Text('Cancelar'),
                        ),
                      ),
                      FudiPressableScale(
                        onTap: () {
                          Navigator.of(ctx).pop();
                          ref.read(authControllerProvider.notifier).signOut();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          decoration: BoxDecoration(
                            color: FudiColors.destructive,
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: const Text('Cerrar sesión', style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: FudiColors.destructive),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(FudiIcons.logOut, size: 20, color: FudiColors.destructive),
                    SizedBox(width: FudiSpacing.sm),
                    Text('Cerrar sesión', style: TextStyle(color: FudiColors.destructive)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
