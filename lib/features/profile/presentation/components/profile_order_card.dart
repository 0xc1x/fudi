import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/ui/atoms/fudi_status_badge.dart';
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

  final String id;
  final String orderNumber;
  final String businessName;
  final String? offerImageUrl;
  final OrderStatus status;
  final double price;
  final DateTime createdAt;
  final DateTime? pickupTime;

  @override
  Widget build(BuildContext context) {
    final bool isUpcoming = status.isUpcoming;

    return FudiPressableScale(
      onTap: () => context.push('/orders/$id'),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(FudiRadius.xl),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border.all(
              color: FudiColors.border.withValues(alpha: 0.04),
            ),
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: 100,
                  child: Image.network(
                    offerImageUrl ?? '',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Theme.of(context).colorScheme.surfaceContainerLow,
                      child: Icon(
                        Icons.storefront,
                        color: FudiColors.foreground.withValues(alpha: 0.24),
                        size: 28,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Pedido $orderNumber',
                          style: TextStyle(
                            color: FudiColors.mutedForeground.withValues(
                              alpha: 0.6,
                            ),
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
                            color: FudiColors.mutedForeground.withValues(
                              alpha: 0.8,
                            ),
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: FudiStatusBadge.fromOrderStatus(
                            status,
                            size: FudiStatusBadgeSize.sm,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 12, 16, 12),
                  child: Center(
                    child: Text(
                      '\$${price.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: isUpcoming
                            ? FudiColors.primary
                            : FudiColors.green,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
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
