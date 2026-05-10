import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../features/orders/domain/order_status.dart';
import '../fudi_colors.dart';
import '../fudi_spacing.dart';
import '../fudi_typography.dart';

/// Tarjeta de pedido utilizada en el Historial de Pedidos.
class OrderCard extends StatelessWidget {
  const OrderCard({
    super.key,
    required this.orderNumber,
    required this.businessName,
    required this.status,
    required this.date,
    required this.totalPrice,
    required this.imageUrl,
    this.onTap,
  });

  final String orderNumber;
  final String businessName;
  final String status;
  final DateTime date;
  final double totalPrice;
  final String imageUrl;
  final VoidCallback? onTap;

  OrderStatus get orderStatus => OrderStatus.fromString(status);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(FudiRadius.lg),
        child: Padding(
          padding: const EdgeInsets.all(FudiSpacing.md),
          child: Row(
            children: [
              // ─── Miniatura ──────────────────────────────────────────
              ClipRRect(
                borderRadius: BorderRadius.circular(FudiRadius.md),
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) => Container(
                    width: 80,
                    height: 80,
                    color: FudiColors.muted,
                    child: const Icon(Icons.shopping_bag_outlined),
                  ),
                ),
              ),
              const SizedBox(width: FudiSpacing.md),

              // ─── Información ────────────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Pedido $orderNumber',
                          style: FudiTypography.bodySmall,
                        ),
                        _StatusBadge(status: status),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      businessName,
                      style: FudiTypography.labelMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('dd MMM yyyy, HH:mm').format(date),
                      style: FudiTypography.bodySmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '\$${totalPrice.toStringAsFixed(2)}',
                      style: FudiTypography.labelSmall.copyWith(
                        color: FudiColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final String status;

  OrderStatus get _orderStatus => OrderStatus.fromString(status);

  @override
  Widget build(BuildContext context) {
    final (color, textColor) = switch (_orderStatus) {
      OrderStatus.completed => (const Color(0xFFDCFCE7), const Color(0xFF166534)),
      OrderStatus.readyForPickup => (const Color(0xFFFEF9C3), const Color(0xFF854D0E)),
      OrderStatus.cancelled || OrderStatus.expired => (const Color(0xFFFEE2E2), const Color(0xFF991B1B)),
      OrderStatus.confirmed => (FudiColors.secondary, FudiColors.secondaryForeground),
      _ => (FudiColors.muted, FudiColors.mutedForeground),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(FudiRadius.sm),
      ),
      child: Text(
        _orderStatus.label,
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
