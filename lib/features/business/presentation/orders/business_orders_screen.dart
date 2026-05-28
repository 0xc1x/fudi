import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/ui/fudi_colors.dart';
import '../../../../core/ui/fudi_spacing.dart';
import '../../../../core/ui/fudi_typography.dart';
import '../../../../core/ui/fudi_surface_card.dart';
import '../../../../core/ui/atoms/icons/fudi_icons.dart';
import '../business_providers.dart';
import '../components/no_business_prompt.dart';
import '../../../orders/domain/order_model.dart';
import '../../../orders/domain/order_status.dart';

class BusinessOrdersScreen extends ConsumerWidget {
  const BusinessOrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final businessAsync = ref.watch(currentBusinessProvider);

    return Scaffold(
      backgroundColor: FudiColors.background,
      body: businessAsync.when(
        data: (business) {
          if (business == null) return const NoBusinessPrompt();

          final ordersStream = ref.watch(
            businessOrdersStreamProvider(business.id),
          );

          return ordersStream.when(
            data: (orders) => _OrdersContent(orders: orders),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _OrdersContent extends StatefulWidget {
  const _OrdersContent({required this.orders});

  final List<OrderModel> orders;

  @override
  State<_OrdersContent> createState() => _OrdersContentState();
}

class _OrdersContentState extends State<_OrdersContent> {
  bool _showToday = true;

  List<OrderModel> get _todayOrders => widget.orders
      .where((o) => _isToday(o.createdAt) && o.status.isActive)
      .toList();

  List<OrderModel> get _completedOrders => widget.orders
      .where((o) => o.status.isTerminal)
      .toList();

  int get _pendingCount =>
      widget.orders.where((o) => o.status == OrderStatus.pending).length;

  int get _readyCount =>
      widget.orders.where((o) => o.status == OrderStatus.readyForPickup).length;

  int get _todayCompletedCount => widget.orders
      .where((o) => o.status == OrderStatus.completed && _isToday(o.createdAt))
      .length;

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  List<Widget> _buildOrderList() {
    final orders = _showToday ? _todayOrders : _completedOrders;
    if (orders.isEmpty) {
      return [
        _EmptyState(
          message: _showToday
              ? 'No hay pedidos pendientes'
              : 'No hay pedidos finalizados',
        ),
      ];
    }
    return orders
        .map(
          (order) => Padding(
            padding: const EdgeInsets.only(bottom: FudiSpacing.md),
            child: _OrderCard(order: order),
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          backgroundColor: FudiColors.background,
          title: const Text('Pedidos', style: FudiTypography.h2),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(FudiSpacing.md),
          sliver: SliverList.list(
            children: [
              _StatsRow(
                pendingCount: _pendingCount,
                readyCount: _readyCount,
                todayCompletedCount: _todayCompletedCount,
              ),
              const SizedBox(height: FudiSpacing.md),
              _TabSelector(
                showToday: _showToday,
                todayCount: _todayOrders.length,
                completedCount: _completedOrders.length,
                onTabChanged: (isToday) =>
                    setState(() => _showToday = isToday),
              ),
              const SizedBox(height: FudiSpacing.md),
              ..._buildOrderList(),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({
    required this.pendingCount,
    required this.readyCount,
    required this.todayCompletedCount,
  });

  final int pendingCount;
  final int readyCount;
  final int todayCompletedCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            count: pendingCount,
            label: 'Pendientes',
            color: Colors.orange,
          ),
        ),
        const SizedBox(width: FudiSpacing.sm),
        Expanded(
          child: _StatCard(
            count: readyCount,
            label: 'Listos',
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: FudiSpacing.sm),
        Expanded(
          child: _StatCard(
            count: todayCompletedCount,
            label: 'Hoy',
            color: Colors.green,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.count,
    required this.label,
    required this.color,
  });

  final int count;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return FudiSurfaceCard(
      padding: const EdgeInsets.all(FudiSpacing.md),
      child: Column(
        children: [
          Text(
            '$count',
            style: FudiTypography.h2.copyWith(color: color),
          ),
          const SizedBox(height: 2),
          Text(label, style: FudiTypography.bodySmall),
        ],
      ),
    );
  }
}

class _TabSelector extends StatelessWidget {
  const _TabSelector({
    required this.showToday,
    required this.todayCount,
    required this.completedCount,
    required this.onTabChanged,
  });

  final bool showToday;
  final int todayCount;
  final int completedCount;
  final ValueChanged<bool> onTabChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(FudiRadius.xl),
        border: Border.all(color: FudiColors.borderSolid),
      ),
      child: Row(
        children: [
          Expanded(
            child: _TabButton(
              label: 'Hoy ($todayCount)',
              isActive: showToday,
              onTap: () => onTabChanged(true),
            ),
          ),
          Expanded(
            child: _TabButton(
              label: 'Historial ($completedCount)',
              isActive: !showToday,
              onTap: () => onTabChanged(false),
            ),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? FudiColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(FudiRadius.lg),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: FudiTypography.labelSmall.copyWith(
            color: isActive ? Colors.white : FudiColors.mutedForeground,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

class _OrderCard extends ConsumerWidget {
  const _OrderCard({required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FudiSurfaceCard(
      padding: const EdgeInsets.all(FudiSpacing.md),
      child: InkWell(
        onTap: () => context.push('/business/orders/${order.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  order.orderNumber,
                  style: FudiTypography.h4.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _StatusBadge(status: order.status),
              ],
            ),
            const SizedBox(height: FudiSpacing.md),
            _InfoRow(
              icon: FudiIcons.user,
              text: order.customerName ?? 'Cliente',
            ),
            if (order.customerPhone != null) ...[
              const SizedBox(height: FudiSpacing.sm),
              _InfoRow(
                icon: FudiIcons.phone,
                text: order.customerPhone!,
              ),
            ],
            const SizedBox(height: FudiSpacing.sm),
            _InfoRow(
              icon: FudiIcons.package_,
              text: order.offerTitle,
            ),
            const SizedBox(height: FudiSpacing.sm),
            _InfoRow(
              icon: FudiIcons.clock,
              text: _formatPickupTime(order),
            ),
                if (order.status.isActive) ...[
              const SizedBox(height: FudiSpacing.md),
              const Divider(height: 1),
              const SizedBox(height: FudiSpacing.md),
              _ActionButtons(order: order),
            ],
          ],
        ),
      ),
    );
  }

  String _formatPickupTime(OrderModel o) {
    if (o.pickupTime != null) {
      final h = o.pickupTime!.hour.toString().padLeft(2, '0');
      final m = o.pickupTime!.minute.toString().padLeft(2, '0');
      return 'Recogida: $h:$m';
    }
    final h = o.createdAt.hour.toString().padLeft(2, '0');
    final m = o.createdAt.minute.toString().padLeft(2, '0');
    return 'Creado: $h:$m';
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: FudiColors.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text, style: FudiTypography.bodyMedium),
        ),
      ],
    );
  }
}

class _ActionButtons extends ConsumerWidget {
  const _ActionButtons({required this.order});

  final OrderModel order;

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
            },
            icon: Icon(FudiIcons.xCircle,
                size: 20, color: FudiColors.destructive),
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

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    final config = _statusConfig[status] ??
        _StatusConfig(color: FudiColors.mutedForeground, label: status.label);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: config.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(FudiRadius.full),
        border: Border.all(color: config.color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: config.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            config.label,
            style: FudiTypography.bodySmall.copyWith(
              color: config.color,
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusConfig {
  final Color color;
  final String label;
  const _StatusConfig({required this.color, required this.label});
}

const _statusConfig = <OrderStatus, _StatusConfig>{
  OrderStatus.pending: _StatusConfig(color: Colors.orange, label: 'Pendiente'),
  OrderStatus.confirmed: _StatusConfig(color: Colors.blue, label: 'Confirmado'),
  OrderStatus.readyForPickup: _StatusConfig(color: Colors.indigo, label: 'Listo'),
  OrderStatus.pickedUp: _StatusConfig(color: Colors.green, label: 'Recogido'),
  OrderStatus.completed: _StatusConfig(color: Colors.green, label: 'Completado'),
  OrderStatus.cancelled: _StatusConfig(color: Colors.red, label: 'Cancelado'),
  OrderStatus.expired: _StatusConfig(color: Colors.red, label: 'Expirado'),
};

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return FudiSurfaceCard(
      padding: const EdgeInsets.all(FudiSpacing.xxl),
      child: Column(
        children: [
          const Icon(
            FudiIcons.shoppingBag,
            size: 48,
            color: FudiColors.mutedForeground,
          ),
          const SizedBox(height: FudiSpacing.md),
          Text(message, style: FudiTypography.bodyMedium),
        ],
      ),
    );
  }
}
