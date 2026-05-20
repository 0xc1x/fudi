import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/ui/fudi_colors.dart';
import '../../../../core/ui/fudi_spacing.dart';
import '../../../../core/ui/fudi_typography.dart';
import '../../../../core/ui/fudi_surface_card.dart';
import '../../../../core/ui/fudi_icons.dart';
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
      appBar: AppBar(
        title: const Text('Pedidos', style: FudiTypography.h2),
      ),
      body: businessAsync.when(
        data: (business) {
          if (business == null) return const NoBusinessPrompt();
          
          final ordersStream = ref.watch(businessOrdersStreamProvider(business.id));
          
          return ordersStream.when(
            data: (orders) => _OrdersList(orders: orders),
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

class _OrdersList extends StatefulWidget {
  const _OrdersList({required this.orders});

  final List<OrderModel> orders;

  @override
  State<_OrdersList> createState() => _OrdersListState();
}

class _OrdersListState extends State<_OrdersList> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pendingOrders = widget.orders.where((o) => o.status.isActive).toList();
    final completedOrders = widget.orders.where((o) => o.status.isTerminal).toList();

    return Column(
      children: [
        Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            labelColor: FudiColors.primary,
            unselectedLabelColor: FudiColors.mutedForeground,
            indicatorColor: FudiColors.primary,
            tabs: [
              Tab(text: 'Pendientes (${pendingOrders.length})'),
              Tab(text: 'Finalizados (${completedOrders.length})'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _OrdersListView(orders: pendingOrders, emptyMessage: 'No hay pedidos pendientes'),
              _OrdersListView(orders: completedOrders, emptyMessage: 'No hay pedidos finalizados'),
            ],
          ),
        ),
      ],
    );
  }
}

class _OrdersListView extends StatelessWidget {
  const _OrdersListView({required this.orders, required this.emptyMessage});

  final List<OrderModel> orders;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(FudiIcons.shoppingBag, size: 64, color: FudiColors.mutedForeground),
            const SizedBox(height: FudiSpacing.md),
            Text(emptyMessage, style: FudiTypography.h4),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(FudiSpacing.md),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return _OrderCard(order: order);
      },
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: FudiSpacing.md),
      child: FudiSurfaceCard(
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
                    'Pedido #${order.orderNumber}',
                    style: FudiTypography.h4.copyWith(fontWeight: FontWeight.bold),
                  ),
                  _StatusBadge(status: order.status),
                ],
              ),
              const SizedBox(height: FudiSpacing.sm),
              const Divider(),
              const SizedBox(height: FudiSpacing.sm),
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: FudiColors.muted,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: order.offerImageUrl != null
                          ? Image.network(order.offerImageUrl!, fit: BoxFit.cover)
                          : const Icon(FudiIcons.package_, size: 24),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(order.offerTitle, style: FudiTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
                        Text(
                          '${order.createdAt.hour}:${order.createdAt.minute.toString().padLeft(2, '0')}',
                          style: FudiTypography.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '\$${order.price.toStringAsFixed(0)}',
                    style: FudiTypography.h4.copyWith(color: FudiColors.primary),
                  ),
                ],
              ),
              if (order.status == OrderStatus.confirmed) ...[
                const SizedBox(height: FudiSpacing.md),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => context.push('/business/orders/${order.id}'),
                    child: const Text('Validar recogida'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case OrderStatus.pending:
        color = Colors.orange;
        break;
      case OrderStatus.confirmed:
        color = Colors.blue;
        break;
      case OrderStatus.readyForPickup:
        color = Colors.indigo;
        break;
      case OrderStatus.pickedUp:
      case OrderStatus.completed:
        color = Colors.green;
        break;
      case OrderStatus.cancelled:
      case OrderStatus.expired:
        color = Colors.red;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status.label.toUpperCase(),
        style: FudiTypography.bodySmall.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }
}
