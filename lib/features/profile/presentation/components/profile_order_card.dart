import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/ui/fudi_colors.dart';
import '../../../../core/ui/fudi_pressable_scale.dart';
import '../../../../core/ui/fudi_spacing.dart';
import '../../domain/user_order.dart';

class ProfileOrderCard extends StatelessWidget {
  const ProfileOrderCard({
    super.key,
    required this.id,
    required this.orderNumber,
    required this.businessName,
    required this.status,
    required this.price,
    required this.createdAt,
    this.offerImageUrl,
    this.pickupTime,
  });

  final String id;
  final String orderNumber;
  final String businessName;
  final String? offerImageUrl;
  final OrderStatus status;
  final double price;
  final DateTime createdAt;
  final DateTime? pickupTime;

  factory ProfileOrderCard.fromUserOrder(UserOrder order) {
    return ProfileOrderCard(
      id: order.id,
      orderNumber: order.orderNumber,
      businessName: order.businessName,
      status: order.status,
      price: order.price,
      createdAt: order.createdAt,
      offerImageUrl: order.offerImageUrl,
      pickupTime: order.pickupTime,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isUpcoming = status.isUpcoming;

    return FudiPressableScale(
      onTap: () => context.push('/orders/$id'),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: FudiColors.card,
          borderRadius: BorderRadius.circular(FudiRadius.xl),
          border: Border.all(color: FudiColors.border.withValues(alpha: 0.04)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(FudiRadius.lg),
              child: Image.network(
                offerImageUrl ?? '',
                width: 72,
                height: 72,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 72,
                  height: 72,
                  color: FudiColors.muted,
                  child: const Icon(
                    Icons.storefront,
                    color: Colors.white24,
                    size: 28,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Pedido $orderNumber',
                    style: TextStyle(
                      color: FudiColors.mutedForeground.withValues(alpha: 0.6),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    businessName,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formattedDateRange,
                    style: TextStyle(
                      color: FudiColors.mutedForeground.withValues(alpha: 0.8),
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  _StatusIndicator(status: status),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '\$${price.toStringAsFixed(2)}',
              style: TextStyle(
                color: isUpcoming ? FudiColors.primary : FudiColors.green,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String get _formattedDateRange {
    const months = [
      '',
      'ene',
      'feb',
      'mar',
      'abr',
      'may',
      'jun',
      'jul',
      'ago',
      'sep',
      'oct',
      'nov',
      'dic',
    ];
    final day = createdAt.day;
    final month = months[createdAt.month];
    final year = createdAt.year;

    if (pickupTime != null) {
      final hour = pickupTime!.hour.toString().padLeft(2, '0');
      final minute = pickupTime!.minute.toString().padLeft(2, '0');
      return '$day $month $year • $hour:$minute';
    }

    return '$day $month $year';
  }
}

class _StatusIndicator extends StatelessWidget {
  const _StatusIndicator({required this.status});

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    final config = _statusConfig[status]!;

    if (config.isPill) {
      return Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: config.backgroundColor,
            borderRadius: BorderRadius.circular(FudiRadius.sm),
          ),
          child: Text(
            config.label,
            style: TextStyle(
              color: config.foregroundColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        '• ${config.label}',
        style: TextStyle(
          color: FudiColors.mutedForeground.withValues(alpha: 0.5),
          fontSize: 12,
        ),
      ),
    );
  }
}

class _StatusConfig {
  const _StatusConfig({
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.isPill,
  });

  final String label;
  final Color backgroundColor;
  final Color foregroundColor;
  final bool isPill;
}

const _statusConfig = <OrderStatus, _StatusConfig>{
  OrderStatus.pending: _StatusConfig(
    label: 'Pendiente • Por confirmar',
    backgroundColor: FudiColors.statusPendingBackground,
    foregroundColor: FudiColors.statusPending,
    isPill: true,
  ),
  OrderStatus.confirmed: _StatusConfig(
    label: 'Confirmado',
    backgroundColor: FudiColors.statusConfirmedBackground,
    foregroundColor: FudiColors.statusConfirmed,
    isPill: true,
  ),
  OrderStatus.readyForPickup: _StatusConfig(
    label: 'Listo para recoger',
    backgroundColor: FudiColors.statusReadyBackground,
    foregroundColor: FudiColors.statusReady,
    isPill: true,
  ),
  OrderStatus.pickedUp: _StatusConfig(
    label: 'Recogido',
    backgroundColor: FudiColors.statusPickedUpBackground,
    foregroundColor: FudiColors.statusPickedUp,
    isPill: true,
  ),
  OrderStatus.completed: _StatusConfig(
    label: 'Completado',
    backgroundColor: FudiColors.statusCompletedBackground,
    foregroundColor: FudiColors.statusCompleted,
    isPill: true,
  ),
  OrderStatus.cancelled: _StatusConfig(
    label: 'Cancelado',
    backgroundColor: FudiColors.statusCancelledBackground,
    foregroundColor: FudiColors.statusCancelled,
    isPill: true,
  ),
  OrderStatus.expired: _StatusConfig(
    label: 'Expirado',
    backgroundColor: FudiColors.statusExpiredBackground,
    foregroundColor: FudiColors.statusExpired,
    isPill: true,
  ),
};
