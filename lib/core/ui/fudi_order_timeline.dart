import 'package:flutter/material.dart';
import 'package:fudi/features/orders/domain/order_model.dart';
import 'package:fudi/features/orders/domain/order_status.dart';
import 'fudi_colors.dart';
import 'fudi_spacing.dart';
import 'fudi_typography.dart';
import 'fudi_surface_card.dart';
import 'atoms/icons/fudi_icons.dart';

class FudiOrderTimeline extends StatelessWidget {
  const FudiOrderTimeline({
    required this.order,
    this.isBusiness = false,
    super.key,
  });

  final OrderModel order;
  final bool isBusiness;

  @override
  Widget build(BuildContext context) {
    final entries = isBusiness ? _buildBusinessEntries() : _buildConsumerEntries();

    return FudiSurfaceCard(
      padding: const EdgeInsets.all(FudiSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.calendar_today,
                size: 20,
                color: FudiColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                isBusiness ? 'Historial de cambios' : 'Historial del pedido',
                style: FudiTypography.h4,
              ),
            ],
          ),
          const SizedBox(height: FudiSpacing.md),
          ...List.generate(entries.length, (i) {
            final entry = entries[i];
            final isLast = i == entries.length - 1;
            return _FudiTimelineEntryWidget(entry: entry, isLast: isLast);
          }),
        ],
      ),
    );
  }

  List<_FudiTimelineEntryData> _buildConsumerEntries() {
    final entries = <_FudiTimelineEntryData>[];
    final created = order.createdAt;

    entries.add(
      _FudiTimelineEntryData(
        icon: Icons.receipt_long,
        title: 'Pedido confirmado',
        note: 'Pedido confirmado y pagado',
        timestamp: created,
        color: FudiColors.primary,
        bgColor: FudiColors.primary.withValues(alpha: 0.1),
      ),
    );

    if (order.status == OrderStatus.readyForPickup ||
        order.status == OrderStatus.pickedUp ||
        order.status == OrderStatus.completed) {
      entries.add(
        _FudiTimelineEntryData(
          icon: Icons.schedule,
          title: 'Listo para recoger',
          note: 'Tu pedido está listo para recoger',
          timestamp: order.pickupTime ?? created,
          color: FudiColors.primary,
          bgColor: FudiColors.primary.withValues(alpha: 0.1),
        ),
      );
    }

    if (order.status == OrderStatus.completed) {
      entries.add(
        _FudiTimelineEntryData(
          icon: Icons.check_circle,
          title: 'Completado',
          note: 'Pedido recogido exitosamente',
          timestamp: order.pickupTime ?? created,
          color: const Color(0xFF16A34A),
          bgColor: const Color(0xFFDCFCE7),
        ),
      );
    }

    if (order.status == OrderStatus.cancelled) {
      entries.add(
        _FudiTimelineEntryData(
          icon: Icons.cancel,
          title: 'Cancelado',
          note: 'Pedido cancelado',
          timestamp: created,
          color: FudiColors.destructive,
          bgColor: const Color(0xFFFEE2E2),
        ),
      );
    }

    if (order.status == OrderStatus.expired) {
      entries.add(
        _FudiTimelineEntryData(
          icon: Icons.timer_off,
          title: 'Expirado',
          note: 'El pedido expiró sin ser recogido',
          timestamp: created,
          color: FudiColors.destructive,
          bgColor: const Color(0xFFFEE2E2),
        ),
      );
    }

    return entries;
  }

  List<_FudiTimelineEntryData> _buildBusinessEntries() {
    final entries = <_FudiTimelineEntryData>[];
    final created = order.createdAt;

    final pendingConfig = _statusConfig(OrderStatus.pending);
    entries.add(
      _FudiTimelineEntryData(
        icon: pendingConfig.icon,
        title: 'Pendiente',
        note: 'Pedido recibido',
        timestamp: created,
        color: pendingConfig.iconColor,
        bgColor: pendingConfig.backgroundColor,
      ),
    );

    final confirmedStatuses = [
      OrderStatus.confirmed,
      OrderStatus.readyForPickup,
      OrderStatus.pickedUp,
      OrderStatus.completed,
    ];
    if (confirmedStatuses.contains(order.status)) {
      final c = _statusConfig(OrderStatus.confirmed);
      entries.add(
        _FudiTimelineEntryData(
          icon: c.icon,
          title: 'Confirmado',
          note: 'Pedido confirmado por el negocio',
          timestamp: null,
          color: c.iconColor,
          bgColor: c.backgroundColor,
        ),
      );
    }

    final readyStatuses = [
      OrderStatus.readyForPickup,
      OrderStatus.pickedUp,
      OrderStatus.completed,
    ];
    if (readyStatuses.contains(order.status)) {
      final c = _statusConfig(OrderStatus.readyForPickup);
      entries.add(
        _FudiTimelineEntryData(
          icon: c.icon,
          title: 'Listo para recoger',
          note: 'Pedido preparado y listo para recoger',
          timestamp: null,
          color: c.iconColor,
          bgColor: c.backgroundColor,
        ),
      );
    }

    if (order.status == OrderStatus.completed) {
      final c = _statusConfig(OrderStatus.completed);
      entries.add(
        _FudiTimelineEntryData(
          icon: c.icon,
          title: 'Completado',
          note: 'Pedido entregado al cliente',
          timestamp: null,
          color: c.iconColor,
          bgColor: c.backgroundColor,
        ),
      );
    }

    if (order.status == OrderStatus.cancelled) {
      final c = _statusConfig(OrderStatus.cancelled);
      entries.add(
        _FudiTimelineEntryData(
          icon: c.icon,
          title: 'Cancelado',
          note: 'Pedido cancelado',
          timestamp: null,
          color: c.iconColor,
          bgColor: c.backgroundColor,
        ),
      );
    }

    if (order.status == OrderStatus.expired) {
      final c = _statusConfig(OrderStatus.expired);
      entries.add(
        _FudiTimelineEntryData(
          icon: c.icon,
          title: 'Expirado',
          note: 'El tiempo de recogida expiró',
          timestamp: null,
          color: c.iconColor,
          bgColor: c.backgroundColor,
        ),
      );
    }

    return entries;
  }

  _StatusConfig _statusConfig(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return _StatusConfig(
          icon: FudiIcons.clock,
          iconColor: Colors.orange.shade700,
          backgroundColor: Colors.orange.shade100,
        );
      case OrderStatus.confirmed:
        return _StatusConfig(
          icon: Icons.check_circle_outline,
          iconColor: FudiColors.primary,
          backgroundColor: FudiColors.primary.withValues(alpha: 0.1),
        );
      case OrderStatus.readyForPickup:
        return _StatusConfig(
          icon: Icons.check_circle,
          iconColor: FudiColors.primary,
          backgroundColor: FudiColors.primary.withValues(alpha: 0.1),
        );
      case OrderStatus.pickedUp:
        return _StatusConfig(
          icon: Icons.shopping_bag_outlined,
          iconColor: Colors.blue.shade700,
          backgroundColor: Colors.blue.shade100,
        );
      case OrderStatus.completed:
        return _StatusConfig(
          icon: Icons.check_circle,
          iconColor: Colors.green.shade600,
          backgroundColor: Colors.green.shade100,
        );
      case OrderStatus.cancelled:
        return _StatusConfig(
          icon: Icons.cancel,
          iconColor: FudiColors.destructive,
          backgroundColor: FudiColors.destructive.withValues(alpha: 0.1),
        );
      case OrderStatus.expired:
        return _StatusConfig(
          icon: Icons.timer_off,
          iconColor: Colors.grey.shade700,
          backgroundColor: Colors.grey.shade200,
        );
    }
  }
}

class _StatusConfig {
  const _StatusConfig({
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
  });

  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
}

class _FudiTimelineEntryData {
  const _FudiTimelineEntryData({
    required this.icon,
    required this.title,
    required this.note,
    this.timestamp,
    required this.color,
    required this.bgColor,
  });

  final IconData icon;
  final String title;
  final String note;
  final DateTime? timestamp;
  final Color color;
  final Color bgColor;
}

class _FudiTimelineEntryWidget extends StatelessWidget {
  const _FudiTimelineEntryWidget({
    required this.entry,
    required this.isLast,
  });

  final _FudiTimelineEntryData entry;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final String timeStr = entry.timestamp != null
        ? '${entry.timestamp!.hour.toString().padLeft(2, '0')}:${entry.timestamp!.minute.toString().padLeft(2, '0')}'
        : '';
    final String dateStr = entry.timestamp != null
        ? '${entry.timestamp!.day.toString().padLeft(2, '0')}/${entry.timestamp!.month.toString().padLeft(2, '0')}/${entry.timestamp!.year}'
        : '';

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: entry.bgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(entry.icon, size: 20, color: entry.color),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 32,
                  color: FudiColors.borderSolid,
                ),
            ],
          ),
          const SizedBox(width: FudiSpacing.md),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: FudiSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        entry.title,
                        style: FudiTypography.labelSmall.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (timeStr.isNotEmpty)
                        Text(
                          timeStr,
                          style: FudiTypography.bodySmall.copyWith(
                            color: FudiColors.mutedForeground,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    entry.note,
                    style: FudiTypography.bodySmall.copyWith(
                      color: FudiColors.mutedForeground,
                    ),
                  ),
                  if (dateStr.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      dateStr,
                      style: FudiTypography.bodySmall.copyWith(
                        color: FudiColors.mutedForeground,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
