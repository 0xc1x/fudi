import 'dart:async';

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

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final destructiveColor = isDark ? FudiColorsDark.destructiveVibrant : FudiColors.destructive;

    return FudiPressableScale(
      onTap: () => _showSignOutDialog(context, authController),
      child: Container(
        padding: const EdgeInsets.all(FudiSpacing.md),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(FudiRadius.xl),
          border: Border.all(
            color: destructiveColor.withValues(alpha: isDark ? 0.5 : 1.0),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              FudiIcons.logOut,
              size: 20,
              color: destructiveColor,
            ),
            const SizedBox(width: FudiSpacing.sm),
            Text(
              'Cerrar sesión',
              style: FudiTypography.labelSmall.copyWith(
                color: destructiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSignOutDialog(BuildContext context, AuthController authController) {
    unawaited(showDialog(
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
              unawaited(authController.signOut());
            },
            style: FilledButton.styleFrom(
              backgroundColor: FudiColors.destructive,
            ),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    ));
  }
}
