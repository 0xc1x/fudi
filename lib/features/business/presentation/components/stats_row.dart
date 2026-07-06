import 'package:flutter/material.dart';
import '../../../../core/ui/fudi_colors.dart';
import '../../../../core/ui/fudi_spacing.dart';

class StatsRow extends StatelessWidget {
  const StatsRow({
    super.key,
    required this.activeCount,
    required this.soldToday,
    required this.availableCount,
    this.onTapActive,
    this.onTapSold,
    this.onTapAvailable,
  });

  final int activeCount;
  final int soldToday;
  final int availableCount;

  // Callbacks para las acciones de "Ver más" de abajo
  final VoidCallback? onTapActive;
  final VoidCallback? onTapSold;
  final VoidCallback? onTapAvailable;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(FudiSpacing.lg),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: colorScheme.outlineVariant, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: 0.03),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // 1. Activos
              Expanded(
                child: _buildStatItem(
                  icon: Icons.shopping_bag_outlined,
                  iconColor: FudiColors.destructiveVibrant,
                  bgColor: FudiColors.destructiveSurface,
                  value: '$activeCount',
                  label: 'Activos',
                  actionLabel: 'Ver productos',
                  colorScheme: colorScheme,
                  onTap: onTapActive,
                ),
              ),

              _buildDivider(context),

              // 2. Vendidos Hoy
              Expanded(
                child: _buildStatItem(
                  icon: Icons.trending_up_rounded,
                  iconColor: FudiColors.success,
                  bgColor: FudiColors.surfaceSuccess,
                  value: '$soldToday',
                  label: 'Total vendidos hoy',
                  actionLabel: 'Ver ventas',
                  colorScheme: colorScheme,
                  onTap: onTapSold,
                ),
              ),

              _buildDivider(context),

              // 3. Disponibles
              Expanded(
                child: _buildStatItem(
                  icon: Icons.inventory_2_outlined,
                  iconColor: FudiColors.warningOrange,
                  bgColor: FudiColors.surfaceWarning,
                  value: '$availableCount',
                  label: 'Disponibles',
                  actionLabel: 'Ver inventario',
                  colorScheme: colorScheme,
                  onTap: onTapAvailable,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String value,
    required String label,
    required String actionLabel,
    required ColorScheme colorScheme,
    VoidCallback? onTap,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Fila superior: Icono + Número
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: iconColor,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),

        // Etiqueta del medio
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 10),

        // Botón "Ver más >" de la parte inferior
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(4),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      actionLabel,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 2),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 14,
                  color: colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDivider(BuildContext context) {
    return VerticalDivider(
      color: Theme.of(context).colorScheme.outlineVariant,
      thickness: 1,
      width: 8,
      indent: 8,
      endIndent: 8,
    );
  }
}
