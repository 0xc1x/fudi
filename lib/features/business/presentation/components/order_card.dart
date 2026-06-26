import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../core/ui/fudi_colors.dart';
import '../../../../core/ui/fudi_spacing.dart';
import '../../../../core/ui/fudi_surface_card.dart';
import '../../../../core/ui/fudi_typography.dart';
import '../../../../core/ui/atoms/fudi_status_badge.dart';
import '../../../../core/ui/atoms/icons/fudi_icons.dart';
import '../../../orders/domain/order_model.dart';
import 'order_action_buttons.dart';

class OrderCard extends ConsumerWidget {
  const OrderCard({super.key, required this.order, required this.businessId});

  final OrderModel order;
  final String businessId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FudiSurfaceCard(
      padding: const EdgeInsets.only(right: FudiSpacing.md),
      child: InkWell(
        onTap: () => context.push('/business/orders/${order.id}'),
        borderRadius: BorderRadius.circular(FudiRadius.lg),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final imageWidth = constraints.maxWidth * 0.25;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: constraints.maxWidth,
                  child: Stack(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                          left: imageWidth + FudiSpacing.md,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: FudiSpacing.md,
                          ),
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              _buildContent(),
                              Positioned(
                                right: 0,
                                top: 0,
                                bottom: 0,
                                width: 60,
                                child: Center(
                                  child: _buildPriceText(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 0,
                        top: 0,
                        bottom: 0,
                        width: imageWidth,
                        child: _buildImage(),
                      ),
                    ],
                  ),
                ),
                if (order.status.isActive) ...[
                  const Divider(height: 1, color: FudiColors.borderSolid),
                  const SizedBox(height: FudiSpacing.md),
                  Padding(
                    padding: const EdgeInsets.only(bottom: FudiSpacing.md),
                    child:
                        OrderActionButtons(order: order, businessId: businessId),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildImage() {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(FudiRadius.lg),
        bottomLeft: Radius.circular(FudiRadius.lg),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: FudiColors.muted,
          image: DecorationImage(
            image: order.offerImageUrl != null
                ? CachedNetworkImageProvider(order.offerImageUrl!)
                : const AssetImage('assets/images/placeholder_food.png'),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          order.offerTitle,
          style: FudiTypography.h4,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: FudiSpacing.xs),
        Text(
          'Pedido • ${order.orderNumber}',
          style: FudiTypography.bodySmall,
        ),
        const SizedBox(height: 2),
        _buildCustomerRow(),
        const SizedBox(height: FudiSpacing.xs),
        Text(
          _formatCreatedAt(order.createdAt),
          style: FudiTypography.bodySmall,
        ),
        const SizedBox(height: FudiSpacing.sm),
        FudiStatusBadge.fromOrderStatus(order.status),
      ],
    );
  }

  Widget _buildCustomerRow() {
    return Row(
      children: [
        Flexible(
          child: Text(
            order.customerName ?? 'Cliente',
            style: FudiTypography.labelSmall.copyWith(
              color: FudiColors.foreground,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (order.customerPhone != null) ...[
          const SizedBox(width: 6),
          const Icon(
            FudiIcons.phone,
            size: 12,
            color: FudiColors.mutedForeground,
          ),
          const SizedBox(width: 2),
          Flexible(
            child: Text(
              order.customerPhone!,
              style: FudiTypography.bodySmall,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPriceText() {
    return Text(
      '\$${order.price.toStringAsFixed(0)}',
      style: FudiTypography.price,
      textAlign: TextAlign.center,
    );
  }

  String _formatCreatedAt(DateTime dateTime) {
    final dateStr = DateFormat('dd MMM yyyy', 'es').format(dateTime);
    final timeStr = DateFormat('HH:mm').format(dateTime);
    return '$dateStr a las $timeStr';
  }
}
