import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/ui/fudi_colors.dart';
import '../../../../core/ui/fudi_spacing.dart';
import '../../../../core/ui/fudi_surface_card.dart';
import '../../../../core/ui/fudi_typography.dart';
import '../../../../core/ui/atoms/icons/fudi_icons.dart';
import '../../../../core/routing/route_names.dart';

class QuickActionsGrid extends StatelessWidget {
  const QuickActionsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final items = const [
      _QuickActionData(
        icon: FudiIcons.trendingUp,
        title: 'Estadísticas',
        subtitle: 'Ver análisis',
        path: RouteNames.businessStatisticsPath,
      ),
      _QuickActionData(
        icon: FudiIcons.bell,
        title: 'Notificaciones',
        subtitle: 'Configurar',
        path: RouteNames.businessNotificationsPath,
      ),
      _QuickActionData(
        icon: FudiIcons.creditCard,
        title: 'Pagos',
        subtitle: 'Ver historial',
        path: RouteNames.businessPaymentsPath,
      ),
      _QuickActionData(
        icon: FudiIcons.tag,
        title: 'Cupones',
        subtitle: 'Gestionar',
        path: RouteNames.businessCouponsPath,
      ),
      _QuickActionData(
        icon: FudiIcons.helpCircle,
        title: 'Ayuda',
        subtitle: 'Centro de ayuda',
        path: RouteNames.businessHelpPath,
      ),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: FudiSpacing.md,
      mainAxisSpacing: FudiSpacing.md,
      childAspectRatio: 1.6,
      children: items.map((item) {
        return FudiSurfaceCard(
          padding: const EdgeInsets.all(FudiSpacing.md),
          child: InkWell(
            onTap: () => context.push(item.path),
            borderRadius: BorderRadius.circular(FudiRadius.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(item.icon, color: FudiColors.primary, size: 28),
                const SizedBox(height: FudiSpacing.sm),
                Text(
                  item.title,
                  style: FudiTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  item.subtitle,
                  style: FudiTypography.bodySmall.copyWith(
                    color: FudiColors.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _QuickActionData {
  const _QuickActionData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.path,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String path;
}
