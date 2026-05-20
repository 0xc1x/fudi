import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/ui/fudi_colors.dart';
import '../../../../core/ui/fudi_spacing.dart';
import '../../../../core/ui/fudi_typography.dart';
import '../../../../core/ui/fudi_surface_card.dart';
import '../../../../core/ui/fudi_icons.dart';
import '../business_providers.dart';
import '../../../orders/domain/order_model.dart';
import '../../../orders/domain/order_status.dart';

class BusinessOrderDetailScreen extends ConsumerWidget {
  const BusinessOrderDetailScreen({required this.orderId, super.key});

  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // We can use a simple future provider for detail or watch the stream and find by ID
    // For simplicity, let's just find in the current business orders list
    final businessAsync = ref.watch(currentBusinessProvider);

    return Scaffold(
      backgroundColor: FudiColors.background,
      appBar: AppBar(
        title: Text('Pedido #$orderId'.substring(0, 15)),
      ),
      body: businessAsync.when(
        data: (business) {
          if (business == null) return const Center(child: Text('No se encontró el negocio'));
          
          final ordersStream = ref.watch(businessOrdersStreamProvider(business.id));
          
          return ordersStream.when(
            data: (orders) {
              final order = orders.firstWhere((o) => o.id == orderId, orElse: () => throw Exception('Order not found'));
              return _OrderDetailContent(order: order);
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

class _OrderDetailContent extends ConsumerWidget {
  const _OrderDetailContent({required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(FudiSpacing.md),
      child: Column(
        children: [
          _StatusCard(order: order),
          const SizedBox(height: FudiSpacing.md),
          _OfferInfoCard(order: order),
          const SizedBox(height: FudiSpacing.md),
          _CustomerInfoCard(order: order),
          const SizedBox(height: FudiSpacing.xl),
          if (order.status == OrderStatus.confirmed)
            _ActionButtons(order: order),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    return FudiSurfaceCard(
      padding: const EdgeInsets.all(FudiSpacing.md),
      child: Row(
        children: [
          const Icon(FudiIcons.shoppingBag, color: FudiColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Estado del pedido', style: FudiTypography.bodySmall),
                Text(order.status.label.toUpperCase(), style: FudiTypography.h4.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          if (order.status == OrderStatus.confirmed)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: FudiColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                order.pickupCode,
                style: FudiTypography.h2
                    .copyWith(color: FudiColors.primary, letterSpacing: 2),
              ),
            ),
        ],
      ),
    );
  }
}

class _OfferInfoCard extends StatelessWidget {
  const _OfferInfoCard({required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    return FudiSurfaceCard(
      padding: const EdgeInsets.all(FudiSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Información de la oferta', style: FudiTypography.h4),
          const SizedBox(height: FudiSpacing.md),
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: FudiColors.muted,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: order.offerImageUrl != null
                      ? Image.network(order.offerImageUrl!, fit: BoxFit.cover)
                      : const Icon(FudiIcons.package_),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(order.offerTitle, style: FudiTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
                    Text('Precio: \$${order.price.toStringAsFixed(0)}', style: FudiTypography.bodyMedium),
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
          const SizedBox(height: FudiSpacing.md),
          const Row(
            children: [
              CircleAvatar(radius: 20, child: Icon(FudiIcons.user)),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Cliente Fudi', style: FudiTypography.bodyLarge),
                    Text('ID: #8273', style: FudiTypography.bodySmall),
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

class _ActionButtons extends ConsumerWidget {
  const _ActionButtons({required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => _showVerifyCodeDialog(context, ref),
            style: ElevatedButton.styleFrom(
              backgroundColor: FudiColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Completar entrega (Validar código)'),
          ),
        ),
        const SizedBox(height: FudiSpacing.md),
        TextButton(
          onPressed: () async {
            await ref.read(businessOrderRepositoryProvider).updateOrderStatus(order.id, OrderStatus.cancelled);
            if (context.mounted) context.pop();
          },
          child: const Text('Cancelar pedido', style: TextStyle(color: Colors.red)),
        ),
      ],
    );
  }

  void _showVerifyCodeDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Validar código de recogida'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Ingresa el código de 6 dígitos',
            border: OutlineInputBorder(),
          ),
          maxLength: 6,
          textAlign: TextAlign.center,
          style: FudiTypography.h4.copyWith(letterSpacing: 4),
        ),
        actions: [
          TextButton(onPressed: () => context.pop(), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              final code = order.pickupCode;
              if (controller.text.toUpperCase() == code.toUpperCase()) {
                await ref.read(businessOrderRepositoryProvider).updateOrderStatus(order.id, OrderStatus.completed);
                if (!context.mounted) return;
                context.pop(); // dialog
                context.pop(); // detail screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Entrega completada con éxito')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Código inválido')),
                );
              }
            },
            child: const Text('Validar'),
          ),
        ],
      ),
    );
  }
}
