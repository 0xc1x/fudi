import 'package:flutter/material.dart';

import '../../../../core/ui/fudi_colors.dart';
import '../../../../core/ui/fudi_pressable_scale.dart';
import '../../../../core/ui/fudi_spacing.dart';
import '../../../../core/ui/fudi_typography.dart';
import '../../../orders/domain/order_status.dart';

class OrdersFilterResult {
  const OrdersFilterResult(this.status);
  final OrderStatus? status;
}

class OrdersFiltersSheet extends StatefulWidget {
  const OrdersFiltersSheet({super.key, this.initialStatus});

  final OrderStatus? initialStatus;

  static Future<OrdersFilterResult?> show(
    BuildContext context, {
    OrderStatus? initial,
  }) {
    return showModalBottomSheet<OrdersFilterResult>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(FudiRadius.xl),
        ),
      ),
      builder: (_) => OrdersFiltersSheet(initialStatus: initial),
    );
  }

  @override
  State<OrdersFiltersSheet> createState() => _OrdersFiltersSheetState();
}

class _OrdersFiltersSheetState extends State<OrdersFiltersSheet> {
  OrderStatus? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.initialStatus;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        FudiSpacing.lg,
        FudiSpacing.lg,
        FudiSpacing.lg,
        MediaQuery.of(context).viewInsets.bottom + FudiSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: FudiColors.borderSolid,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: FudiSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Estado', style: FudiTypography.h2),
              if (_selectedStatus != null)
                FudiPressableScale(
                  onTap: () => setState(() => _selectedStatus = null),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
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
          const SizedBox(height: FudiSpacing.lg),
          Wrap(
            spacing: FudiSpacing.sm,
            runSpacing: FudiSpacing.sm,
            children: OrderStatus.values.map((status) {
              final isSelected = _selectedStatus == status;
              return FilterChip(
                label: Text(status.label),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _selectedStatus = selected ? status : null;
                  });
                },
                selectedColor: FudiColors.secondary,
                checkmarkColor: FudiColors.primary,
                side: BorderSide(color: FudiColors.borderSolid),
              );
            }).toList(),
          ),
          const SizedBox(height: FudiSpacing.xl),
          FudiPressableScale(
            onTap: () {
              Navigator.of(context).pop(OrdersFilterResult(_selectedStatus));
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: FudiColors.primary,
                borderRadius: BorderRadius.circular(FudiRadius.lg),
              ),
              child: Center(
                child: Text(
                  'Aplicar filtro',
                  style: FudiTypography.labelMedium.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
