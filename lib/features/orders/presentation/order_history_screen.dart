import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/ui/cards/order_card.dart';
import '../../../core/ui/fudi_colors.dart';
import '../../../core/ui/atoms/icons/fudi_icons.dart';
import '../../../core/ui/fudi_spacing.dart';
import '../../../core/ui/fudi_typography.dart';
import '../../orders/domain/order_model.dart';
import 'order_providers.dart';

class OrderHistoryScreen extends ConsumerStatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  ConsumerState<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends ConsumerState<OrderHistoryScreen> {
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(userOrdersProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Mis Pedidos', style: FudiTypography.headlineMedium),
        backgroundColor: FudiColors.background,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(FudiIcons.chevronLeft),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              FudiSpacing.lg,
              FudiSpacing.sm,
              FudiSpacing.lg,
              FudiSpacing.sm,
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
              decoration: InputDecoration(
                hintText: 'Buscar pedidos...',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: FudiColors.muted,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: FudiSpacing.md,
                  vertical: FudiSpacing.sm,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(FudiRadius.xl),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: ordersAsync.when(
              data: (orders) {
                final filtered = _searchQuery.isNotEmpty
                    ? orders.where((o) =>
                        o.businessName.toLowerCase().contains(_searchQuery) ||
                        o.offerTitle.toLowerCase().contains(_searchQuery) ||
                        o.orderNumber.toLowerCase().contains(_searchQuery))
                    : orders;

                final active = filtered.where((o) => o.status.isActive).toList();
                final past = filtered.where((o) => o.status.isTerminal).toList();
                return DefaultTabController(
                  length: 2,
                  child: Column(
                    children: [
                      TabBar(
                        tabs: [
                          Tab(text: 'Activos (${active.length})'),
                          Tab(text: 'Pasados (${past.length})'),
                        ],
                        labelColor: FudiColors.primary,
                        unselectedLabelColor: FudiColors.mutedForeground,
                        indicatorColor: FudiColors.primary,
                      ),
                      Expanded(
                        child: TabBarView(
                          children: [
                            _OrderList(
                              orders: active,
                              emptyIcon: Icons.shopping_bag_outlined,
                              emptyMessage: 'No tienes pedidos activos',
                            ),
                            _OrderList(
                              orders: past,
                              emptyIcon: Icons.history,
                              emptyMessage: 'No tienes pedidos pasados',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: FudiColors.destructive,
                    ),
                    const SizedBox(height: FudiSpacing.md),
                    Text(
                      'Error al cargar pedidos',
                      style: FudiTypography.bodyMedium,
                    ),
                    const SizedBox(height: FudiSpacing.md),
                    FilledButton(
                      onPressed: () =>
                          ref.read(userOrdersProvider.notifier).refresh(),
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
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
        separatorBuilder: (_, _) => const SizedBox(height: FudiSpacing.md),
        itemBuilder: (context, index) {
          final order = orders[index];
          return OrderCard(
            orderNumber: order.orderNumber,
            businessName: order.businessName,
            status: order.status.dbValue,
            date: order.createdAt,
            totalPrice: order.price,
            imageUrl: order.offerImageUrl ?? '',
            onTap: () => context.push('/orders/${order.id}'),
          );
        },
      ),
    );
  }
}
