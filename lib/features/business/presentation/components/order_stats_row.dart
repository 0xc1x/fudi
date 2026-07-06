import 'package:flutter/material.dart';
import '../../../../core/ui/fudi_colors.dart';
import '../../../../core/ui/fudi_spacing.dart';
import '../../../../core/ui/fudi_theme.dart';

class OrderStatsRow extends StatelessWidget {
  const OrderStatsRow({
    super.key,
    required this.pendingCount,
    required this.readyCount,
    required this.todayCompletedCount,
  });

  final int pendingCount;
  final int readyCount;
  final int todayCompletedCount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: FudiSpacing.lg),
      child: Row(
        children: [
          // 1. Tarjeta Pendientes (Naranja)
          Expanded(
            child: _buildOrderStatCard(
              context: context,
              icon: Icons.schedule_rounded,
              color: FudiColors.warning,
              value: '$pendingCount',
              label: 'Pendientes',
            ),
          ),
          const SizedBox(width: 12),

          // 2. Tarjeta Listos (Azul)
          Expanded(
            child: _buildOrderStatCard(
              context: context,
              icon: Icons.local_mall_outlined,
              color: FudiColors.info,
              value: '$readyCount',
              label: 'Listos',
            ),
          ),
          const SizedBox(width: 12),

          // 3. Tarjeta Hoy (Verde)
          Expanded(
            child: _buildOrderStatCard(
              context: context,
              icon: Icons.check_circle_outline_rounded,
              color: FudiColors.success,
              value: '$todayCompletedCount',
              label: 'Hoy',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderStatCard({
    required BuildContext context,
    required IconData icon,
    required Color color,
    required String value,
    required String label,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final themeExt = theme.extension<FudiThemeExtension>();
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(
          20,
        ), // Bordes idénticos a image_9dad6b.png
        border: Border.all(
          color: themeExt?.mutedBackground ?? FudiColors.surfaceMuted,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.onSurface.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icono con diseño circular minimalista
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(
                alpha: 0.05,
              ), // Fondo ultra tenue del color del icono
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 10),

          // Valor numérico imponente en el centro
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900, // Extra bold según la referencia
              color: color,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 6),

          // Etiqueta descriptiva en la parte inferior
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
