import 'package:flutter/material.dart';
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
    return Padding(
      padding: const EdgeInsets.all(FudiSpacing.lg),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFF3F4F6), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
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
                  iconColor: const Color(0xFFEF4444),
                  bgColor: const Color(0xFFFFF1F2),
                  value: '$activeCount',
                  label: 'Activos',
                  actionLabel: 'Ver productos',
                  onTap: onTapActive,
                ),
              ),

              _buildDivider(),

              // 2. Vendidos Hoy
              Expanded(
                child: _buildStatItem(
                  icon: Icons.trending_up_rounded,
                  iconColor: const Color(0xFF22C55E),
                  bgColor: const Color(0xFFF0FDF4),
                  value: '$soldToday',
                  label: 'Total vendidos hoy',
                  actionLabel: 'Ver ventas',
                  onTap: onTapSold,
                ),
              ),

              _buildDivider(),

              // 3. Disponibles
              Expanded(
                child: _buildStatItem(
                  icon: Icons.inventory_2_outlined,
                  iconColor: const Color(0xFFF97316),
                  bgColor: const Color(0xFFFFF7ED),
                  value: '$availableCount',
                  label: 'Disponibles',
                  actionLabel: 'Ver inventario',
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
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: iconColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),

        // Etiqueta del medio
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFF6B7280),
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
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  actionLabel,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4B5563),
                  ),
                ),
                const SizedBox(width: 2),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 14,
                  color: Color(0xFF9CA3AF),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return VerticalDivider(
      color: Colors.grey.shade100,
      thickness: 1,
      width: 16,
      indent: 8,
      endIndent: 8,
    );
  }
}
