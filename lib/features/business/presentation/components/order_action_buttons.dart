import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/ui/fudi_colors.dart';
import '../../../../core/ui/fudi_spacing.dart';
import '../../../../core/ui/atoms/icons/fudi_icons.dart';
import '../business_providers.dart';
import '../../../orders/domain/order_model.dart';
import '../../../orders/domain/order_status.dart';

class OrderActionButtons extends ConsumerWidget {
  const OrderActionButtons({
    super.key,
    required this.order,
    required this.businessId,
  });

  final OrderModel order;
  final String businessId;

  void _invalidateOrders(WidgetRef ref) {
    ref.invalidate(businessOrdersStreamProvider(businessId));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (order.status == OrderStatus.pending) {
      return Row(
        children: [
          Expanded(
            child: FilledButton.icon(
              onPressed: () async {
                await ref
                    .read(businessOrderRepositoryProvider)
                    .updateOrderStatus(order.id, OrderStatus.readyForPickup);
                _invalidateOrders(ref);
              },
              icon: const Icon(FudiIcons.checkCircle, size: 18),
              label: const Text('Marcar listo'),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          const SizedBox(width: FudiSpacing.sm),
          IconButton.outlined(
            onPressed: () async {
              await ref
                  .read(businessOrderRepositoryProvider)
                  .updateOrderStatus(order.id, OrderStatus.cancelled);
              _invalidateOrders(ref);
            },
            icon: Icon(
              FudiIcons.xCircle,
              size: 20,
              color: FudiColors.destructive,
            ),
            style: IconButton.styleFrom(
              side: BorderSide(color: FudiColors.borderSolid),
              padding: const EdgeInsets.all(10),
            ),
          ),
        ],
      );
    }

    if (order.status == OrderStatus.readyForPickup) {
      return SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: () => context.push('/business/orders/${order.id}'),
          icon: const Icon(FudiIcons.qrCode, size: 18),
          label: const Text('Validar y entregar'),
          style: FilledButton.styleFrom(
            backgroundColor: Colors.green,
            padding: const EdgeInsets.symmetric(vertical: 10),
          ),
        ),
      );
    }

    if (order.status == OrderStatus.confirmed) {
      return SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: () async {
            await ref
                .read(businessOrderRepositoryProvider)
                .updateOrderStatus(order.id, OrderStatus.readyForPickup);
            _invalidateOrders(ref);
          },
          icon: const Icon(FudiIcons.checkCircle, size: 18),
          label: const Text('Marcar listo'),
          style: FilledButton.styleFrom(
            backgroundColor: Colors.blue,
            padding: const EdgeInsets.symmetric(vertical: 10),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
