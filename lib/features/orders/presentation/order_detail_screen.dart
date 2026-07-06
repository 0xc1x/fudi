import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/ui/atoms/fudi_info_row.dart';
import '../../../core/ui/atoms/fudi_status_badge.dart';
import '../../../core/ui/atoms/pickup_code_qr.dart';
import '../../../core/ui/fudi_bottom_action_bar.dart';
import '../../../core/ui/fudi_colors.dart';
import '../../../core/ui/fudi_info_banner.dart';
import '../../../core/ui/fudi_order_timeline.dart';
import '../../../core/ui/fudi_pressable_scale.dart';
import '../../../core/ui/fudi_spacing.dart';
import '../../../core/ui/fudi_sticky_page_header.dart';
import '../../../core/ui/fudi_surface_card.dart';
import '../../../core/ui/fudi_typography.dart';
import '../domain/order_model.dart';
import '../domain/order_status.dart';
import 'order_providers.dart';

class OrderDetailScreen extends ConsumerWidget {
  const OrderDetailScreen({required this.id, super.key});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(orderDetailProvider(id));

    return orderAsync.when(
      data: (order) => _OrderDetailContent(order: order),
      loading: () => Scaffold(
        body: const Center(
          child: CircularProgressIndicator(
            color: FudiColors.primary,
            strokeWidth: 3,
          ),
        ),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Theme.of(context).colorScheme.onSurface,
              size: 20,
            ),
            onPressed: () => context.pop(),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(FudiSpacing.xl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(FudiSpacing.md),
                  decoration: BoxDecoration(
                    color: FudiColors.destructive.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.error_outline_rounded,
                    size: 40,
                    color: FudiColors.destructive,
                  ),
                ),
                const SizedBox(height: FudiSpacing.lg),
                Text(
                  'No pudimos cargar los detalles',
                  style: FudiTypography.h3.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: FudiSpacing.xs),
                Text(
                  'Por favor verifica tu conexión de red e inténtalo de nuevo.',
                  style: FudiTypography.bodyMedium.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: FudiSpacing.xl),
                FudiPressableScale(
                  onTap: () => ref.invalidate(orderDetailProvider(id)),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Reintentar',
                    style: FudiTypography.labelSmall.copyWith(
                      color: FudiColors.primaryForeground,
                      fontWeight: FontWeight.bold,
                    ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OrderDetailContent extends ConsumerStatefulWidget {
  const _OrderDetailContent({required this.order});

  final OrderModel order;

  @override
  ConsumerState<_OrderDetailContent> createState() =>
      _OrderDetailContentState();
}

class _OrderDetailContentState extends ConsumerState<_OrderDetailContent> {
  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final isUpcoming = order.status.isActive;

    return Scaffold(
      appBar: FudiStickyPageHeader(
        title: 'Detalle del pedido',
        subtitle: order.orderNumber,
        actions: [FudiStatusBadge.fromOrderStatus(order.status)],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(FudiSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isUpcoming) ...[
              _PickupCodeCard(orderId: order.id, code: order.pickupCode),
              const SizedBox(height: FudiSpacing.md),
            ],
            _BusinessInfoCard(order: order),
            const SizedBox(height: FudiSpacing.md),
            _OrderItemsCard(order: order),
            const SizedBox(height: FudiSpacing.md),
            _PriceDetailsCard(order: order),
            const SizedBox(height: FudiSpacing.md),
            _InstructionsCard(order: order),
            const SizedBox(height: FudiSpacing.md),

            FudiSurfaceCard(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: FudiSpacing.xs),
                child: FudiOrderTimeline(order: order),
              ),
            ),

            if (order.status == OrderStatus.completed) ...[
              const SizedBox(height: FudiSpacing.md),
              const FudiInfoBanner(
                title: '¿Qué tal estuvo todo?',
                message:
                    'Tu opinión ayuda a la comunidad a rescatar deliciosa comida y apoya a locales cercanos.',
                icon: Icons.chat_bubble_outline_rounded,
              ),
            ],
            const SizedBox(height: 140),
          ],
        ),
      ),
      bottomNavigationBar: order.status == OrderStatus.completed
          ? FudiBottomActionBar(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FudiPressableScale(
                    onTap: () {},
                    child: Container(
                      width: double.infinity,
                      height: 52,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                      child: Center(
                    child: Text(
                      'Volver a pedir',
                      style: FudiTypography.labelMedium.copyWith(
                        color: FudiColors.primaryForeground,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: FudiSpacing.sm),
                  FudiPressableScale(
                    onTap: () => context.push('/review-order/${order.id}'),
                    child: Container(
                      width: double.infinity,
                      height: 52,
                      decoration: BoxDecoration(
                        border: Border.all(color: FudiColors.border),
                        borderRadius: BorderRadius.circular(12),
                        color: Theme.of(context).colorScheme.surfaceContainerLow,
                      ),
                      child: Center(
                        child: Text(
                          'Dejar reseña',
                          style: FudiTypography.labelMedium.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          : null,
    );
  }
}

class _PickupCodeCard extends StatelessWidget {
  const _PickupCodeCard({required this.orderId, required this.code});

  final String orderId;
  final String code;

  @override
  Widget build(BuildContext context) {
    if (code.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(FudiSpacing.xl),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(
          color: FudiColors.primary.withValues(alpha: 0.3),
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: FudiColors.primary.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'CÓDIGO DE RECOGIDA',
            style: FudiTypography.labelSmall.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              letterSpacing: 1.2,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: FudiSpacing.xs),
          Text(
            code,
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              letterSpacing: 6,
              color: FudiColors.primary,
            ),
          ),
          const SizedBox(height: FudiSpacing.lg),
          Container(
            padding: const EdgeInsets.all(FudiSpacing.md),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: FudiColors.border, width: 0.5),
            ),
            child: SizedBox(
              width: 250,
              height: 250,
              child: PickupCodeQr(
                orderId: orderId,
                pickupCode: code,
                size: 250,
              ),
            ),
          ),
          const SizedBox(height: FudiSpacing.md),
          Text(
            'Presenta este código QR o el identificador de texto en el mostrador para retirar tu pack.',
            style: FudiTypography.bodySmall.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _BusinessInfoCard extends StatelessWidget {
  const _BusinessInfoCard({required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    return FudiSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            order.businessName,
            style: FudiTypography.h4.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: FudiSpacing.md),
          if (order.businessAddress != null)
            FudiInfoRow(
              icon: Icons.location_on_outlined,
              label: 'Dirección',
              text: order.businessAddress!,
            ),
          if (order.businessPhone != null) ...[
            const SizedBox(height: FudiSpacing.sm),
            FudiInfoRow(
              icon: Icons.phone_outlined,
              label: 'Teléfono',
              text: order.businessPhone!,
            ),
          ],
          if (order.pickupTime != null) ...[
            const SizedBox(height: FudiSpacing.sm),
            FudiInfoRow(
              icon: Icons.schedule_rounded,
              label: 'Horario de entrega',
              text: _formatPickupTime(order.pickupTime!),
            ),
          ],
          const SizedBox(height: FudiSpacing.lg),
          Row(
            children: [
              Expanded(
                child: FudiPressableScale(
                  onTap: () =>
                      context.push('/business-profile/${order.businessId}'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.storefront_rounded,
                          size: 16,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Ver comercio',
                          style: FudiTypography.bodyMedium.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (order.status.isActive) ...[
                const SizedBox(width: FudiSpacing.sm),
                Expanded(
                  child: FudiPressableScale(
                    onTap: () {},
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      decoration: BoxDecoration(
                        border: Border.all(color: FudiColors.border),
                        borderRadius: BorderRadius.circular(12),
                        color: Theme.of(context).colorScheme.surfaceContainerLow,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.near_me_outlined,
                            size: 16,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Cómo llegar',
                            style: FudiTypography.bodyMedium.copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  String _formatPickupTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m hs';
  }
}

class _OrderItemsCard extends StatelessWidget {
  const _OrderItemsCard({required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    return FudiSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Productos contratados',
            style: FudiTypography.labelSmall.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: FudiSpacing.sm),
          Container(
            padding: const EdgeInsets.all(FudiSpacing.md),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: FudiColors.border, width: 0.5),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '1x',
                  style: FudiTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: FudiColors.primary,
                  ),
                ),
                const SizedBox(width: FudiSpacing.md),
                Expanded(
                  child: Text(
                    order.offerTitle,
                    style: FudiTypography.bodyMedium.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
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

class _PriceDetailsCard extends StatelessWidget {
  const _PriceDetailsCard({required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    return FudiSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Resumen económico',
            style: FudiTypography.labelSmall.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: FudiSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Precio original establecido',
                style: FudiTypography.bodyMedium.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              Text(
                '\$${order.originalPrice.toStringAsFixed(2)}',
                style: FudiTypography.bodyMedium.copyWith(
                  decoration: TextDecoration.lineThrough,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: FudiSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Descuento circular aplicado',
                style: FudiTypography.bodyMedium.copyWith(color: FudiColors.ecoGreen),
              ),
              Text(
                '-\$${order.discount.toStringAsFixed(2)}',
                style: FudiTypography.bodyMedium.copyWith(
                  color: FudiColors.ecoGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: FudiSpacing.sm),
          const Divider(color: FudiColors.border, thickness: 0.5),
          const SizedBox(height: FudiSpacing.xs),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Monto total abonado',
                style: FudiTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '\$${order.price.toStringAsFixed(2)}',
                style: FudiTypography.h3.copyWith(
                  fontWeight: FontWeight.bold,
                  color: FudiColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: FudiSpacing.md),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(FudiSpacing.md),
            decoration: BoxDecoration(
              color: FudiColors.ecoGreen.withValues(alpha: 0.05),
              border: Border.all(color: FudiColors.ecoGreen.withValues(alpha: 0.15)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.eco_rounded, size: 18, color: FudiColors.ecoGreen),
                const SizedBox(width: FudiSpacing.sm),
                Expanded(
                  child: Text(
                    'Evitaste el desperdicio de alimentos y ahorraste \$${order.discount.toStringAsFixed(2)}.',
                    style: FudiTypography.bodySmall.copyWith(
                      color: FudiColors.ecoGreen,
                      fontWeight: FontWeight.w600,
                    ),
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

class _InstructionsCard extends StatelessWidget {
  const _InstructionsCard({required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    final isCompleted = order.status == OrderStatus.completed;

    return FudiSurfaceCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isCompleted
                ? Icons.check_circle_outline_rounded
                : Icons.info_outline_rounded,
            size: 20,
            color: isCompleted ? FudiColors.ecoGreen : FudiColors.primary,
          ),
          const SizedBox(width: FudiSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isCompleted ? 'Entrega completada' : 'Pasos para retirar',
                  style: FudiTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isCompleted
                      ? 'Este bolso de comida fue entregado y validado de manera exitosa.'
                      : 'Acércate al local comercial dentro del rango horario indicado. Menciona que vienes de parte de Fudi y presenta tu pantalla.',
                  style: FudiTypography.bodyMedium.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    height: 1.4,
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
