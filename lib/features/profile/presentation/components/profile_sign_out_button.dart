import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/ui/atoms/icons/fudi_icons.dart';
import '../../../../core/ui/fudi_colors.dart';
import '../../../../core/ui/fudi_pressable_scale.dart';
import '../../../../core/ui/fudi_spacing.dart';
import '../../../../core/ui/fudi_typography.dart';
import '../../../auth/presentation/auth_state_provider.dart';

class ProfileSignOutButton extends ConsumerWidget {
  const ProfileSignOutButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authController = ref.read(authControllerProvider.notifier);

    return FudiPressableScale(
      onTap: () => _showSignOutDialog(context, authController),
      child: Container(
        padding: const EdgeInsets.all(FudiSpacing.md),
        decoration: BoxDecoration(
          color: FudiColors.background,
          borderRadius: BorderRadius.circular(FudiRadius.xl),
          border: Border.all(color: FudiColors.borderSolid),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(FudiIcons.logOut, size: 20, color: FudiColors.destructive),
            const SizedBox(width: FudiSpacing.sm),
            Text(
              'Cerrar sesión',
              style: FudiTypography.labelSmall.copyWith(
                color: FudiColors.destructive,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSignOutDialog(BuildContext context, AuthController authController) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              authController.signOut();
            },
            style: FilledButton.styleFrom(
              backgroundColor: FudiColors.destructive,
            ),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
  }
}
