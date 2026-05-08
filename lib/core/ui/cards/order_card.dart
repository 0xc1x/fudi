import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
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

  @override
  Widget build(BuildContext context) {
    Color color;
    Color textColor;
    String label;

    switch (status.toLowerCase()) {
      case 'completed':
        color = const Color(0xFFDCFCE7);
        textColor = const Color(0xFF166534);
        label = 'Completado';
        break;
      case 'ready':
        color = const Color(0xFFFEF9C3);
        textColor = const Color(0xFF854D0E);
        label = 'Listo';
        break;
      case 'cancelled':
        color = const Color(0xFFFEE2E2);
        textColor = const Color(0xFF991B1B);
        label = 'Cancelado';
        break;
      case 'pending':
        color = FudiColors.muted;
        textColor = FudiColors.mutedForeground;
        label = 'Pendiente';
        break;
      case 'confirmed':
        color = FudiColors.secondary;
        textColor = FudiColors.secondaryForeground;
        label = 'Confirmado';
        break;
      default:
        color = FudiColors.muted;
        textColor = FudiColors.mutedForeground;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(FudiRadius.sm),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
