import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/ui/cards/order_card.dart';
import '../../../core/ui/fudi_colors.dart';
import '../../../core/ui/fudi_spacing.dart';
import '../../../core/ui/fudi_typography.dart';
import '../../orders/domain/order_model.dart';
import 'order_providers.dart';

class OrderHistoryScreen extends ConsumerWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(userOrdersProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Mis Pedidos', style: FudiTypography.headlineMedium),
          backgroundColor: FudiColors.background,
          surfaceTintColor: Colors.transparent,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Activos'),
              Tab(text: 'Pasados'),
            ],
            labelColor: FudiColors.primary,
            unselectedLabelColor: FudiColors.mutedForeground,
            indicatorColor: FudiColors.primary,
          ),
        ),
        body: ordersAsync.when(
          data: (orders) {
            final active = orders.where((o) => o.status.isActive).toList();
            final past = orders.where((o) => o.status.isTerminal).toList();
            return TabBarView(
              children: [
                _OrderList(orders: active, emptyIcon: Icons.shopping_bag_outlined, emptyMessage: 'No tienes pedidos activos'),
                _OrderList(orders: past, emptyIcon: Icons.history, emptyMessage: 'No tienes pedidos pasados'),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48, color: FudiColors.destructive),
                const SizedBox(height: FudiSpacing.md),
                Text('Error al cargar pedidos', style: FudiTypography.bodyMedium),
                const SizedBox(height: FudiSpacing.md),
                FilledButton(
                  onPressed: () => ref.read(userOrdersProvider.notifier).refresh(),
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OrderList extends ConsumerWidget {
  const _OrderList({
    required this.orders,
    required this.emptyIcon,
    required this.emptyMessage,
  });

  final List<OrderModel> orders;
  final IconData emptyIcon;
  final String emptyMessage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(emptyIcon, size: 48, color: FudiColors.mutedForeground),
            const SizedBox(height: FudiSpacing.md),
            Text(emptyMessage, style: FudiTypography.bodyMedium),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(userOrdersProvider.notifier).refresh(),
      child: ListView.separated(
        padding: const EdgeInsets.all(FudiSpacing.lg),
        itemCount: orders.length,
        separatorBuilder: (_, __) => const SizedBox(height: FudiSpacing.md),
        itemBuilder: (context, index) {
          final order = orders[index];
          return OrderCard(
            orderNumber: order.orderNumber,
            businessName: order.businessName,
            status: order.status.dbValue,
            date: order.createdAt,
            totalPrice: order.price,
            imageUrl: order.offerImageUrl ?? '',
            onTap: () => context.go('/orders/${order.id}'),
          );
        },
      ),
    );
  }
}
