import 'package:flutter/material.dart';
import '../fudi_colors.dart';
import '../fudi_spacing.dart';
import '../../../features/business/domain/business_payout.dart';

enum StatusBadgeStyle {
  simple,
  order,
}

class FudiStatusBadge extends StatelessWidget {
  const FudiStatusBadge({
    super.key,
    required this.label,
    required this.color,
    this.backgroundColor,
    this.borderColor,
    this.icon,
    this.style = StatusBadgeStyle.simple,
    this.size = FudiStatusBadgeSize.md,
  });

  factory FudiStatusBadge.active({
    Key? key,
    bool isActive = true,
    FudiStatusBadgeSize size = FudiStatusBadgeSize.md,
    StatusBadgeStyle style = StatusBadgeStyle.simple,
  }) {
    return FudiStatusBadge(
      key: key,
      label: isActive ? 'Activo' : 'Inactivo',
      color: isActive ? const Color(0xFF16A34A) : FudiColors.mutedForeground,
      backgroundColor:
          isActive ? const Color(0xFFDCFCE7) : FudiColors.muted,
      icon: isActive ? Icons.circle : Icons.circle,
      size: size,
      style: style,
    );
  }

  factory FudiStatusBadge.fromPayoutStatus(
    BusinessPayoutStatus status, {
    Key? key,
    FudiStatusBadgeSize size = FudiStatusBadgeSize.md,
  }) {
    return switch (status) {
      BusinessPayoutStatus.paid => FudiStatusBadge(
          key: key,
          label: 'Pagado',
          icon: Icons.check_circle_outline_rounded,
          color: const Color(0xFF15803D),
          backgroundColor: const Color(0xFFDCFCE7),
          borderColor: const Color(0xFFBBF7D0),
          size: size,
        ),
      BusinessPayoutStatus.processing => FudiStatusBadge(
          key: key,
          label: 'Procesando',
          icon: Icons.schedule_rounded,
          color: const Color(0xFFC2410C),
          backgroundColor: const Color(0xFFFFEDD5),
          borderColor: const Color(0xFFFED7AA),
          size: size,
        ),
      BusinessPayoutStatus.pending => FudiStatusBadge(
          key: key,
          label: 'Pendiente',
          icon: Icons.schedule_rounded,
          color: FudiColors.primary,
          backgroundColor: FudiColors.primary.withValues(alpha: 0.1),
          borderColor: FudiColors.primary.withValues(alpha: 0.2),
          size: size,
        ),
      BusinessPayoutStatus.failed => FudiStatusBadge(
          key: key,
          label: 'Fallido',
          icon: Icons.error_outline_rounded,
          color: const Color(0xFFDC2626),
          backgroundColor: const Color(0xFFFEE2E2),
          borderColor: const Color(0xFFFECACA),
          size: size,
        ),
    };
  }

  static const Map<dynamic, FudiOrderStatusConfig> _orderDefaults = {
    'pending': FudiOrderStatusConfig(
      color: Colors.orange,
      label: 'Pendiente',
    ),
    'confirmed': FudiOrderStatusConfig(
      color: Colors.blue,
      label: 'Confirmado',
    ),
    'ready_for_pickup': FudiOrderStatusConfig(
      color: Colors.indigo,
      label: 'Listo',
    ),
    'readyForPickup': FudiOrderStatusConfig(
      color: Colors.indigo,
      label: 'Listo',
    ),
    'picked_up': FudiOrderStatusConfig(
      color: Colors.green,
      label: 'Recogido',
    ),
    'pickedUp': FudiOrderStatusConfig(
      color: Colors.green,
      label: 'Recogido',
    ),
    'completed': FudiOrderStatusConfig(
      color: Colors.green,
      label: 'Completado',
    ),
    'cancelled': FudiOrderStatusConfig(
      color: Colors.red,
      label: 'Cancelado',
    ),
    'expired': FudiOrderStatusConfig(
      color: Colors.red,
      label: 'Expirado',
    ),
  };

  factory FudiStatusBadge.fromOrderStatus(
    Object status, {
    Key? key,
    FudiStatusBadgeSize size = FudiStatusBadgeSize.md,
    Map<Object, FudiOrderStatusConfig>? overrides,
  }) {
    final config = overrides?[status] ??
        _orderDefaults[status] ??
        _orderDefaults[(status is Enum) ? status.name : '$status'];
    if (config == null) {
      return FudiStatusBadge(
        key: key,
        label: '$status',
        color: FudiColors.mutedForeground,
        size: size,
        style: StatusBadgeStyle.order,
      );
    }
    return FudiStatusBadge(
      key: key,
      label: config.label,
      color: config.color,
      backgroundColor: config.color.withValues(alpha: 0.1),
      borderColor: config.color.withValues(alpha: 0.3),
      size: size,
      style: StatusBadgeStyle.order,
    );
  }

  final String label;
  final Color color;
  final Color? backgroundColor;
  final Color? borderColor;
  final IconData? icon;
  final StatusBadgeStyle style;
  final FudiStatusBadgeSize size;

  @override
  Widget build(BuildContext context) {
    final resolvedBg = backgroundColor ??
        (style == StatusBadgeStyle.order
            ? color.withValues(alpha: 0.1)
            : color.withValues(alpha: 0.15));
    final resolvedBorder = borderColor;
    final vPad = size.verticalPadding;
    final hPad = size.horizontalPadding;
    final fontSize = size.fontSize;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
      decoration: BoxDecoration(
        color: resolvedBg,
        borderRadius: BorderRadius.circular(FudiRadius.full),
        border: resolvedBorder != null
            ? Border.all(color: resolvedBorder)
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            if (icon == Icons.circle)
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color,
                ),
              )
            else
              Icon(icon, size: fontSize + 1, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class FudiOrderStatusConfig {
  final Color color;
  final String label;
  const FudiOrderStatusConfig({required this.color, required this.label});
}

enum FudiStatusBadgeSize {
  sm,
  md,
  lg;

  double get fontSize {
    return switch (this) {
      FudiStatusBadgeSize.sm => 10,
      FudiStatusBadgeSize.md => 12,
      FudiStatusBadgeSize.lg => 14,
    };
  }

  double get verticalPadding {
    return switch (this) {
      FudiStatusBadgeSize.sm => 2,
      FudiStatusBadgeSize.md => 4,
      FudiStatusBadgeSize.lg => 6,
    };
  }

  double get horizontalPadding {
    return switch (this) {
      FudiStatusBadgeSize.sm => 6,
      FudiStatusBadgeSize.md => 8,
      FudiStatusBadgeSize.lg => 12,
    };
  }
}
