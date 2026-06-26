import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/ui/fudi_colors.dart';
import '../../../../core/ui/fudi_pressable_scale.dart';
import '../../../../core/ui/fudi_spacing.dart';
import '../../../../core/ui/fudi_typography.dart';
import '../../../../core/ui/fudi_surface_card.dart';
import '../../../../core/ui/atoms/icons/fudi_icons.dart';
import '../../../../core/ui/atoms/fudi_info_row.dart';
import '../../../../core/ui/atoms/fudi_status_badge.dart';
import '../../../../core/ui/fudi_order_timeline.dart';
import '../business_providers.dart';
import '../../../orders/domain/order_model.dart';
import '../../../orders/domain/order_status.dart';
import 'pickup_scanner_sheet.dart';

class BusinessOrderDetailScreen extends ConsumerWidget {
  const BusinessOrderDetailScreen({required this.orderId, super.key});

  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final businessAsync = ref.watch(currentBusinessProvider);

    return Scaffold(
      backgroundColor: FudiColors.background,
      body: businessAsync.when(
        data: (business) {
          if (business == null) {
            return const Center(child: Text('No se encontró el negocio'));
          }

          final ordersStream = ref.watch(
            businessOrdersStreamProvider(business.id),
          );

          return ordersStream.when(
            data: (orders) {
              final order = orders.firstWhere(
                (o) => o.id == orderId,
                orElse: () => throw Exception('Pedido no encontrado'),
              );
              return _OrderDetailScaffold(order: order);
            },
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

class _OrderDetailScaffold extends ConsumerWidget {
  const _OrderDetailScaffold({required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    return Scaffold(
      backgroundColor: FudiColors.background,
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(FudiSpacing.sm),
          child: InkWell(
            onTap: () => context.pop(),
            borderRadius: BorderRadius.circular(FudiRadius.full),
            child: Container(
              decoration: BoxDecoration(
                color: FudiColors.muted,
                shape: BoxShape.circle,
              ),
              child: const Icon(FudiIcons.chevronLeft, size: 20),
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Detalle del pedido', style: FudiTypography.h4),
            Text(
              '#${order.id.substring(0, 8)}',
              style: FudiTypography.bodySmall.copyWith(
                color: FudiColors.mutedForeground,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: FudiStatusBadge.fromOrderStatus(order.status),
          ),
          const SizedBox(width: FudiSpacing.md),
        ],
      ),
      body: _OrderDetailContent(order: order),
    );
  }
}

class _OrderDetailContent extends ConsumerWidget {
  const _OrderDetailContent({required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(FudiSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ProductCard(order: order),
              const SizedBox(height: FudiSpacing.md),
              _CustomerInfoCard(order: order),
              const SizedBox(height: FudiSpacing.md),
              _PickupInfoCard(order: order),
              const SizedBox(height: FudiSpacing.md),
              FudiOrderTimeline(order: order, isBusiness: true),
              const SizedBox(height: FudiSpacing.md),
              _OrderInfoCard(order: order),
              if (!order.status.isTerminal) const SizedBox(height: 120),
            ],
          ),
        ),
        if (!order.status.isTerminal)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _ActionBottomBar(order: order, businessId: order.businessId),
          ),
      ],
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    return FudiSurfaceCard(
      padding: const EdgeInsets.all(FudiSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Producto', style: FudiTypography.h4),
          const SizedBox(height: FudiSpacing.sm),
          Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: FudiColors.muted,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: order.offerImageUrl != null
                      ? Image.network(order.offerImageUrl!, fit: BoxFit.cover)
                      : const Icon(FudiIcons.package_, size: 32),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.offerTitle,
                      style: FudiTypography.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${order.price.toStringAsFixed(2)}',
                      style: FudiTypography.h2.copyWith(
                        color: FudiColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CustomerInfoCard extends StatelessWidget {
  const _CustomerInfoCard({required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    return FudiSurfaceCard(
      padding: const EdgeInsets.all(FudiSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Información del cliente', style: FudiTypography.h4),
          const SizedBox(height: FudiSpacing.sm),
          FudiInfoRow(
            icon: FudiIcons.user,
            label: 'Nombre',
            text: order.customerName ?? 'Sin nombre',
            useIconBackground: true,
            iconSize: 20,
            spacing: 12,
          ),
          const SizedBox(height: FudiSpacing.sm),
          FudiInfoRow(
            icon: FudiIcons.phone,
            label: 'Teléfono',
            text: order.customerPhone ?? 'Sin teléfono',
            isPrimary: order.customerPhone != null,
            useIconBackground: true,
            iconSize: 20,
            spacing: 12,
          ),
          const SizedBox(height: FudiSpacing.sm),
          FudiInfoRow(
            icon: FudiIcons.mail,
            label: 'Email',
            text: order.customerEmail ?? 'Sin email',
            isPrimary: order.customerEmail != null,
            useIconBackground: true,
            iconSize: 20,
            spacing: 12,
          ),
        ],
      ),
    );
  }
}

class _PickupInfoCard extends StatelessWidget {
  const _PickupInfoCard({required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    final pickupTimeStr = order.pickupTime != null
        ? '${order.pickupTime!.hour.toString().padLeft(2, '0')}:${order.pickupTime!.minute.toString().padLeft(2, '0')}'
        : 'Pendiente';
    return FudiSurfaceCard(
      padding: const EdgeInsets.all(FudiSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Información de recogida', style: FudiTypography.h4),
          const SizedBox(height: FudiSpacing.sm),
          FudiInfoRow(
            icon: FudiIcons.clock,
            label: 'Horario de recogida',
            text: pickupTimeStr,
            iconSize: 20,
            spacing: 12,
          ),
          const SizedBox(height: FudiSpacing.sm),
          FudiInfoRow(
            icon: FudiIcons.mapPin,
            label: 'Lugar de recogida',
            text: order.businessAddress ?? 'Sin dirección',
            iconSize: 20,
            spacing: 12,
          ),
        ],
      ),
    );
  }
}



class _OrderInfoCard extends StatelessWidget {
  const _OrderInfoCard({required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(FudiSpacing.md),
      decoration: BoxDecoration(
        color: FudiColors.muted.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: FudiColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Número de pedido',
                  style: FudiTypography.bodySmall.copyWith(
                    color: FudiColors.mutedForeground,
                  ),
                ),
                Text(
                  '#${order.id.substring(0, 8)}',
                  style: FudiTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Fecha de creación',
                  style: FudiTypography.bodySmall.copyWith(
                    color: FudiColors.mutedForeground,
                  ),
                ),
                Text(
                  '${order.createdAt.day.toString().padLeft(2, '0')}/${order.createdAt.month.toString().padLeft(2, '0')}/${order.createdAt.year}',
                  style: FudiTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionBottomBar extends ConsumerWidget {
  const _ActionBottomBar({required this.order, required this.businessId});

  final OrderModel order;
  final String businessId;

  void _invalidateOrders(WidgetRef ref) {
    ref.invalidate(businessOrdersStreamProvider(businessId));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(FudiSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: FudiColors.border)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (order.status == OrderStatus.pending ||
              order.status == OrderStatus.confirmed) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await ref
                      .read(businessOrderRepositoryProvider)
                      .updateOrderStatus(order.id, OrderStatus.readyForPickup);
                  _invalidateOrders(ref);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Pedido marcado como listo'),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.check_circle_outline, size: 20),
                label: const Text('Marcar como listo'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: FudiColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: FudiSpacing.sm),
          ],
          if (order.status == OrderStatus.readyForPickup) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showValidateDialog(context, ref),
                icon: const Icon(FudiIcons.package_, size: 20),
                label: const Text('Validar entrega'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: FudiSpacing.sm),
          ],
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _confirmCancel(context, ref),
              icon: Icon(
                Icons.cancel_outlined,
                size: 20,
                color: FudiColors.destructive,
              ),
              label: const Text(
                'Cancelar pedido',
                style: TextStyle(color: FudiColors.destructive),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: FudiColors.destructive, width: 2),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showValidateDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Validar código de recogida'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Scan QR button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  Navigator.of(ctx).pop();
                  final scanned = await showPickupScannerSheet(
                    context,
                    ref,
                    expectedOrderId: order.id,
                  );
                  if (!context.mounted) return;
                  if (scanned) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Entrega completada con éxito'),
                      ),
                    );
                  }
                },
                icon: const Icon(FudiIcons.qrCode, size: 20),
                label: const Text('Escanear código QR'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      'o ingresa manualmente',
                      style: TextStyle(
                        color: FudiColors.mutedForeground,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Expanded(child: Divider()),
                ],
              ),
            ),
            Text(
              'Código de 6 dígitos del cliente',
              style: FudiTypography.bodySmall.copyWith(
                color: FudiColors.mutedForeground,
              ),
            ),
            const SizedBox(height: FudiSpacing.md),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: '000000',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              maxLength: 6,
              textAlign: TextAlign.center,
              style: FudiTypography.h3.copyWith(
                letterSpacing: 4,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          FudiPressableScale(
            onTap: () => ctx.pop(),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Text('Cancelar'),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final repo = ref.read(businessOrderRepositoryProvider);
              final result = await repo.validatePickupCode(
                orderId: order.id,
                pickupCode: controller.text,
              );
              if (!ctx.mounted) return;
              if (result.success) {
                _invalidateOrders(ref);
                ctx.pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Entrega completada con éxito')),
                );
              } else {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(content: Text('Código inválido')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade600,
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  void _confirmCancel(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Cancelar pedido'),
        content: const Text(
          '¿Estás seguro de que deseas cancelar este pedido?',
        ),
        actions: [
          FudiPressableScale(
            onTap: () => ctx.pop(),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Text('No'),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              await ref
                  .read(businessOrderRepositoryProvider)
                  .updateOrderStatus(order.id, OrderStatus.cancelled);
              _invalidateOrders(ref);
              if (!ctx.mounted) return;
              ctx.pop();
              if (context.mounted) context.pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: FudiColors.destructive,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sí, cancelar'),
          ),
        ],
      ),
    );
  }
}


