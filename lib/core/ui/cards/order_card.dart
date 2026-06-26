import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../atoms/fudi_status_badge.dart';
import '../../../features/orders/domain/order_status.dart';
import '../fudi_colors.dart';
import '../fudi_spacing.dart';
import '../fudi_typography.dart';
import '../atoms/icons/fudi_icons.dart';

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
    return Container(
      decoration: BoxDecoration(
        color: FudiColors.background,
        borderRadius: BorderRadius.circular(FudiRadius.lg),
        border: Border.all(color: FudiColors.borderSolid),
      ),
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
                    child: const Icon(FudiIcons.orders),
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
                        FudiStatusBadge.fromOrderStatus(orderStatus),
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


