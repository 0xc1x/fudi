import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/ui/fudi_colors.dart';
import '../../../../core/ui/fudi_pressable_scale.dart';
import '../../../../core/ui/fudi_search_bar.dart';
import '../../../../core/ui/fudi_spacing.dart';
import '../../../../core/ui/fudi_typography.dart';
import '../../../../core/ui/fudi_empty_state.dart';
import '../../../../core/ui/atoms/fudi_filter_chip.dart';
import '../../../../core/ui/atoms/icons/fudi_icons.dart';
import '../../../orders/domain/order_model.dart';
import '../../../orders/domain/order_status.dart';
import '../business_providers.dart';
import 'order_card.dart';
import 'order_stats_row.dart';
import 'orders_filters_sheet.dart';
import 'orders_sort_button.dart';
import 'tab_selector.dart';

class OrdersContent extends ConsumerStatefulWidget {
  const OrdersContent({
    super.key,
    required this.orders,
    required this.businessId,
  });

  final List<OrderModel> orders;
  final String businessId;

  @override
  ConsumerState<OrdersContent> createState() => _OrdersContentState();
}

class _OrdersContentState extends ConsumerState<OrdersContent> {
  static const _activeTab = 0;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  int _selectedTab = _activeTab;
  OrderStatus? _statusFilter;
  OrdersSort _sortOrder = OrdersSort.newest;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<OrderModel> _filteredOrders(String? branchId) {
    var orders = widget.orders.where((o) =>
      _selectedTab == _activeTab ? o.status.isActive : !o.status.isActive,
    ).toList();

    if (branchId != null) {
      orders = orders.where((o) => o.businessLocationId == branchId).toList();
    }

    if (_statusFilter != null) {
      orders = orders.where((o) => o.status == _statusFilter).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      orders = orders.where((o) =>
        o.orderNumber.toLowerCase().contains(q) ||
        o.offerTitle.toLowerCase().contains(q) ||
        (o.customerName?.toLowerCase().contains(q) ?? false),
      ).toList();
    }

    switch (_sortOrder) {
      case OrdersSort.newest:
        orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      case OrdersSort.oldest:
        orders.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    }

    return orders;
  }

  @visibleForTesting
  OrderStatus? get statusFilter => _statusFilter;

  @visibleForTesting
  OrdersSort get sortOrder => _sortOrder;

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

  List<Widget> _buildOrderList(String? branchId) {
    final orders = _filteredOrders(branchId);
    if (orders.isEmpty) {
      return [
        FudiEmptyState(
          icon: FudiIcons.shoppingBag,
          title: _selectedTab == _activeTab
              ? 'No hay pedidos activos'
              : 'No hay pedidos en el historial',
          description: '',
        ),
      ];
    }
    return orders
        .map(
          (order) => Padding(
            padding: const EdgeInsets.only(bottom: FudiSpacing.md),
            child: OrderCard(order: order, businessId: widget.businessId),
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final branchId = ref.watch(selectedBranchIdProvider);
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(FudiSpacing.md),
          sliver: SliverList.list(
            children: [
              OrderStatsRow(
                pendingCount: _pendingCount,
                readyCount: _readyCount,
                todayCompletedCount: _todayCompletedCount,
              ),
              const SizedBox(height: FudiSpacing.md),
              TabSelector(
                tabs: const [
                  TabData(label: 'Activos'),
                  TabData(label: 'Historial'),
                ],
                selectedIndex: _selectedTab,
                onTabChanged: (i) => setState(() => _selectedTab = i),
              ),
              const SizedBox(height: FudiSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: FudiSearchBar(
                      controller: _searchController,
                      hintText: 'Buscar pedidos...',
                      onChanged: (v) => setState(() => _searchQuery = v),
                    ),
                  ),
                  const SizedBox(width: FudiSpacing.sm),
                  _OrdersFilterButton(
                    hasActiveFilter: _statusFilter != null,
                    onTap: () async {
                      final result = await OrdersFiltersSheet.show(
                        context,
                        initial: _statusFilter,
                      );
                      if (result case final OrdersFilterResult r when mounted) {
                        setState(() => _statusFilter = r.status);
                      }
                    },
                  ),
                  const SizedBox(width: FudiSpacing.sm),
                  OrdersSortButton(
                    value: _sortOrder,
                    onChanged: (v) => setState(() => _sortOrder = v),
                  ),
                ],
              ),
              if (_statusFilter != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    FudiSpacing.lg,
                    FudiSpacing.sm,
                    FudiSpacing.lg,
                    FudiSpacing.sm,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: FudiFilterChip(
                            label: _statusFilter!.label,
                            onClear: () => setState(() => _statusFilter = null),
                          ),
                        ),
                      ),
                      FudiPressableScale(
                        onTap: () => setState(() => _statusFilter = null),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: FudiSpacing.sm,
                            vertical: FudiSpacing.xs,
                          ),
                          child: Text(
                            'Limpiar',
                            style: FudiTypography.bodySmall.copyWith(
                              color: FudiColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: FudiSpacing.md),
              ..._buildOrderList(branchId),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ],
    );
  }
}

class _OrdersFilterButton extends StatelessWidget {
  const _OrdersFilterButton({
    required this.hasActiveFilter,
    required this.onTap,
  });

  final bool hasActiveFilter;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FudiPressableScale(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: FudiSpacing.md,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: hasActiveFilter
              ? FudiColors.primary
              : FudiColors.background,
          borderRadius: BorderRadius.circular(FudiRadius.xl),
          border: Border.all(
            color: hasActiveFilter
                ? FudiColors.primary
                : FudiColors.borderSolid,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.filter_list_rounded,
              size: 18,
              color: hasActiveFilter ? Colors.white : FudiColors.foreground,
            ),
            const SizedBox(width: 4),
            Text(
              'Filtrar',
              style: FudiTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
                color: hasActiveFilter ? Colors.white : FudiColors.foreground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
