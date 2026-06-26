import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/ui/fudi_colors.dart';
import '../../../../core/ui/fudi_pressable_scale.dart';
import '../../../../core/ui/fudi_spacing.dart';
import '../../../../core/ui/atoms/icons/fudi_icons.dart';
import '../../../auth/presentation/auth_state_provider.dart';

class LogoutButton extends ConsumerWidget {
  const LogoutButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FudiPressableScale(
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
        padding: const EdgeInsets.symmetric(vertical: FudiSpacing.md),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(FudiRadius.xl),
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
    );
  }
}
