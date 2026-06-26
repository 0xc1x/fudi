import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/ui/fudi_colors.dart';
import '../../../core/ui/fudi_pressable_scale.dart';
import '../../../core/ui/atoms/icons/fudi_icons.dart';
import '../../../core/ui/fudi_spacing.dart';
import '../../../core/ui/fudi_typography.dart';
import '../../../core/ui/fudi_empty_state.dart';
import '../../../core/ui/fudi_error_state.dart';
import '../../../features/profile/domain/user_order.dart' as profile;
import '../../../features/profile/presentation/components/profile_order_card.dart';
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
        leading: FudiPressableScale(
          onTap: () => context.pop(),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: FudiColors.muted,
              shape: BoxShape.circle,
            ),
            child: const Icon(FudiIcons.chevronLeft, size: 24),
          ),
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
                    ? FudiPressableScale(
                        onTap: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: FudiColors.muted,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.clear, size: 18),
                        ),
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
              error: (error, _) => FudiErrorState(
                message: 'Error al cargar pedidos',
                onRetry: () => ref.read(userOrdersProvider.notifier).refresh(),
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
      return FudiEmptyState(
        title: emptyMessage,
        description: 'Vuelve más tarde o realiza una búsqueda diferente',
        icon: emptyIcon,
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
          return ProfileOrderCard(
            id: order.id,
            orderNumber: order.orderNumber,
            businessName: order.businessName,
            status: profile.OrderStatus.fromString(order.status.dbValue),
            price: order.price,
            createdAt: order.createdAt,
            offerImageUrl: order.offerImageUrl,
            pickupTime: order.pickupTime,
          );
        },
      ),
    );
  }
}
