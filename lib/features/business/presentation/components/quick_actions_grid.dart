import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/route_names.dart';
import '../../../../core/ui/atoms/icons/fudi_icons.dart';
import '../../../../core/ui/fudi_colors.dart';
import '../../../../core/ui/fudi_pressable_scale.dart';
import '../../../../core/ui/fudi_spacing.dart';
import '../../../../core/ui/fudi_surface_card.dart';

class QuickActionsGrid extends StatelessWidget {
  const QuickActionsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    const items = [
      _QuickActionData(
        icon: FudiIcons.trendingUp,
        title: 'Estadísticas',
        subtitle: 'Análisis de rendimiento',
        path: RouteNames.businessStatisticsPath,
        isLarge: true, // Tarjeta destacada de ancho completo
      ),
      _QuickActionData(
        icon: FudiIcons.creditCard,
        title: 'Pagos',
        subtitle: 'Historial',
        path: RouteNames.businessPaymentsPath,
      ),
      _QuickActionData(
        icon: FudiIcons.tag,
        title: 'Cupones',
        subtitle: 'Gestionar',
        path: RouteNames.businessCouponsPath,
      ),
      _QuickActionData(
        icon: FudiIcons.bell,
        title: 'Alertas',
        subtitle: 'Configurar',
        path: RouteNames.businessNotificationsPath,
      ),
      _QuickActionData(
        icon: FudiIcons.helpCircle,
        title: 'Soporte',
        subtitle: 'Ayuda',
        path: RouteNames.businessHelpPath,
      ),
    ];

    return Column(
      children: [
        // Primer bloque: Tarjeta destacada asimétrica
        _buildTile(context, items[0]),
        const SizedBox(height: FudiSpacing.sm),

        // Segundo bloque: Grid de 2x2 ultra-compacto y plano
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length - 1,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: FudiSpacing.sm,
            mainAxisSpacing: FudiSpacing.sm,
            childAspectRatio: 2.1,
          ),
          itemBuilder: (context, index) {
            // Saltamos el primer elemento que ya renderizamos arriba
            return _buildTile(context, items[index + 1]);
          },
        ),
      ],
    );
  }

  Widget _buildTile(BuildContext context, _QuickActionData item) {
    return FudiPressableScale(
      onTap: () => context.push(item.path),
      child: FudiSurfaceCard(
        padding: const EdgeInsets.all(FudiSpacing.md),
        child: Row(
          crossAxisAlignment: item.isLarge
              ? CrossAxisAlignment.center
              : CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    item.title,
                    style: TextStyle(
                      fontSize: item.isLarge ? 15 : 13,
                      fontWeight: FontWeight.bold,
                      color: FudiColors.foreground,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: FudiColors.mutedForeground,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: FudiSpacing.xs),
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: item.isLarge
                    ? FudiColors.primary.withValues(alpha: 0.08)
                    : FudiColors.background,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: item.isLarge
                      ? FudiColors.primary.withValues(alpha: 0.1)
                      : FudiColors.borderSolid,
                ),
              ),
              child: Icon(
                item.icon,
                color: item.isLarge
                    ? FudiColors.primary
                    : FudiColors.foreground,
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionData {
  const _QuickActionData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.path,
    this.isLarge = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String path;
  final bool isLarge;
}
