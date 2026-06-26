import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/ui/fudi_spacing.dart';
import '../../../../core/ui/fudi_settings_item.dart';
import '../../../../core/ui/fudi_surface_card.dart';
import '../../../../core/ui/fudi_typography.dart';
import '../../../../core/ui/atoms/icons/fudi_icons.dart';

class SettingsSection extends StatelessWidget {
  const SettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return FudiSurfaceCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              FudiSpacing.md,
              FudiSpacing.md,
              FudiSpacing.md,
              FudiSpacing.sm,
            ),
            child: Text('Configuración', style: FudiTypography.h4),
          ),
          const Divider(height: 1),
          FudiSettingsItem(
            icon: FudiIcons.settings,
            label: 'Configuración general',
            onTap: () => context.push('/profile/settings'),
          ),
          const Divider(height: 1, indent: FudiSpacing.lg + 20 + FudiSpacing.md),
          FudiSettingsItem(
            icon: FudiIcons.bell,
            label: 'Notificaciones',
            onTap: () => context.push(RouteNames.businessNotificationsPath),
          ),
          const Divider(height: 1, indent: FudiSpacing.lg + 20 + FudiSpacing.md),
          FudiSettingsItem(
            icon: FudiIcons.creditCard,
            label: 'Métodos de cobro',
            onTap: () => context.push(RouteNames.businessPaymentsPath),
          ),
          const Divider(height: 1, indent: FudiSpacing.lg + 20 + FudiSpacing.md),
          FudiSettingsItem(
            icon: FudiIcons.helpCircle,
            label: 'Centro de ayuda',
            onTap: () => context.push(RouteNames.businessHelpPath),
          ),
        ],
      ),
    );
  }
}
