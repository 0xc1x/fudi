import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/ui/atoms/pickup_code_qr.dart';
import '../../../core/ui/fudi_colors.dart';
import '../../../core/ui/fudi_bottom_action_bar.dart';
import '../../../core/ui/fudi_info_banner.dart';
import '../../../core/ui/fudi_spacing.dart';
import '../../../core/ui/fudi_sticky_page_header.dart';
import '../../../core/ui/fudi_surface_card.dart';
import '../../../core/ui/fudi_pressable_scale.dart';
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
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, _) => Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: FudiColors.destructive,
              ),
              const SizedBox(height: FudiSpacing.md),
              Text(
                'Error al cargar el pedido',
                style: FudiTypography.bodyMedium,
              ),
              const SizedBox(height: FudiSpacing.md),
              FudiPressableScale(
                onTap: () => ref.invalidate(orderDetailProvider(id)),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: FudiColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text('Reintentar', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
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
        actions: [_StatusBadge(status: order.status)],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(FudiSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isUpcoming) ...[
              _PickupCodeCard(orderId: order.id, code: order.pickupCode),
              const SizedBox(height: FudiSpacing.lg),
            ],
            _BusinessInfoCard(order: order),
            const SizedBox(height: FudiSpacing.lg),
            _OrderItemsCard(order: order),
            const SizedBox(height: FudiSpacing.lg),
            _PriceDetailsCard(order: order),
            const SizedBox(height: FudiSpacing.lg),
            _InstructionsCard(order: order),
            const SizedBox(height: FudiSpacing.lg),
            _StatusHistoryCard(order: order),
            const SizedBox(height: FudiSpacing.lg),

            if (order.status == OrderStatus.completed) ...[
              const FudiInfoBanner(
                title: 'Tu opinión importa',
                message:
                    'Cuéntanos cómo estuvo el producto y la experiencia con el negocio para ayudar a otros usuarios.',
                icon: Icons.rate_review_outlined,
              ),
            ],
            const SizedBox(height: FudiSpacing.xxl),
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
                      height: 56,
                      decoration: BoxDecoration(
                        color: FudiColors.primary,
                        borderRadius: BorderRadius.circular(FudiRadius.lg),
                      ),
                      child: Center(
                        child: Text(
                          'Volver a pedir',
                          style: FudiTypography.labelMedium.copyWith(
                            color: Colors.white,
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
                      height: 56,
                      decoration: BoxDecoration(
                        border: Border.all(color: FudiColors.primary),
                        borderRadius: BorderRadius.circular(FudiRadius.lg),
                      ),
                      child: Center(
                        child: Text(
                          'Dejar reseña',
                          style: FudiTypography.labelMedium.copyWith(color: FudiColors.primary),
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

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (status) {
      OrderStatus.completed => (
        const Color(0xFFDCFCE7),
        const Color(0xFF166534),
      ),
      OrderStatus.readyForPickup => (
        const Color(0xFFFEF9C3),
        const Color(0xFF854D0E),
      ),
      OrderStatus.cancelled ||
      OrderStatus.expired => (const Color(0xFFFEE2E2), const Color(0xFF991B1B)),
      OrderStatus.confirmed => (
        FudiColors.secondary,
        FudiColors.secondaryForeground,
      ),
      _ => (FudiColors.primary, Colors.white),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(FudiRadius.full),
      ),
      child: Text(
        status.label,
        style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w600),
      ),
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
      padding: const EdgeInsets.all(FudiSpacing.lg),
      decoration: BoxDecoration(
        color: FudiColors.background,
        border: Border.all(color: FudiColors.primary, width: 2),
        borderRadius: BorderRadius.circular(FudiRadius.xxl),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Código de recogida',
            style: FudiTypography.labelSmall.copyWith(
              color: FudiColors.mutedForeground,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: FudiSpacing.md),
          Container(
            padding: const EdgeInsets.all(FudiSpacing.xl),
            decoration: BoxDecoration(
              color: FudiColors.muted,
              borderRadius: BorderRadius.circular(FudiRadius.lg),
            ),
            child: PickupCodeQr(orderId: orderId, pickupCode: code),
          ),
          const SizedBox(height: FudiSpacing.md),
          Text(
            code,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              letterSpacing: 6,
              color: FudiColors.primary,
            ),
          ),
          const SizedBox(height: FudiSpacing.xs),
          Text(
            'Muestra este código al recoger tu pedido',
            style: FudiTypography.bodySmall.copyWith(fontSize: 10),
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
          Text(order.businessName, style: FudiTypography.h3),
          const SizedBox(height: FudiSpacing.lg),
          if (order.businessAddress != null)
            _infoRow(Icons.location_on, 'Dirección', order.businessAddress!),
          if (order.businessPhone != null) ...[
            const SizedBox(height: FudiSpacing.md),
            _infoRow(Icons.phone, 'Teléfono', order.businessPhone!),
          ],
          if (order.pickupTime != null) ...[
            const SizedBox(height: FudiSpacing.md),
            _infoRow(
              Icons.schedule,
              'Horario de recogida',
              _formatPickupTime(order.pickupTime!),
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
                    padding: const EdgeInsets.symmetric(
                      vertical: FudiSpacing.md,
                    ),
                    decoration: BoxDecoration(
                      color: FudiColors.primary,
                      borderRadius: BorderRadius.circular(FudiRadius.lg),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.store, size: 18, color: Colors.white),
                        SizedBox(width: 6),
                        Text(
                          'Ver negocio',
                          style: TextStyle(color: Colors.white),
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
                      padding: const EdgeInsets.symmetric(
                        vertical: FudiSpacing.md,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: FudiColors.primary),
                        borderRadius: BorderRadius.circular(FudiRadius.lg),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.directions, size: 18),
                          SizedBox(width: 6),
                          Text('Cómo llegar'),
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

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: FudiColors.primary),
        const SizedBox(width: FudiSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: FudiTypography.labelSmall),
              const SizedBox(height: 2),
              Text(value, style: FudiTypography.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }

  String _formatPickupTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
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
          Row(
            children: [
              const Icon(
                Icons.inventory_2_outlined,
                size: 20,
                color: FudiColors.primary,
              ),
              const SizedBox(width: FudiSpacing.sm),
              Text('Contenido del pedido', style: FudiTypography.labelMedium),
            ],
          ),
          const SizedBox(height: FudiSpacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '•',
                style: TextStyle(color: FudiColors.primary, fontSize: 14),
              ),
              const SizedBox(width: FudiSpacing.sm),
              Expanded(
                child: Text(
                  order.offerTitle,
                  style: FudiTypography.bodyMedium.copyWith(
                    color: FudiColors.mutedForeground,
                  ),
                ),
              ),
            ],
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
          Text('Detalles del precio', style: FudiTypography.labelMedium),
          const SizedBox(height: FudiSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Precio original',
                style: FudiTypography.bodyMedium.copyWith(
                  color: FudiColors.mutedForeground,
                ),
              ),
              Text(
                '\$${order.originalPrice.toStringAsFixed(2)}',
                style: FudiTypography.bodyMedium.copyWith(
                  decoration: TextDecoration.lineThrough,
                  color: FudiColors.mutedForeground,
                ),
              ),
            ],
          ),
          const SizedBox(height: FudiSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Descuento',
                style: FudiTypography.bodyMedium.copyWith(
                  color: const Color(0xFF16A34A),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '-\$${order.discount.toStringAsFixed(2)}',
                style: FudiTypography.bodyMedium.copyWith(
                  color: const Color(0xFF16A34A),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: FudiSpacing.md),
          const Divider(),
          const SizedBox(height: FudiSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total pagado', style: FudiTypography.labelMedium),
              Text(
                '\$${order.price.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
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
              color: const Color(0xFFF0FDF4),
              border: Border.all(color: const Color(0xFFBBF7D0)),
              borderRadius: BorderRadius.circular(FudiRadius.lg),
            ),
            child: Text(
              'Has ahorrado \$${order.discount.toStringAsFixed(2)} y evitado el desperdicio de alimentos',
              style: FudiTypography.bodySmall.copyWith(
                color: const Color(0xFF166534),
              ),
              textAlign: TextAlign.center,
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
    return FudiSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.chat_bubble_outline,
                size: 20,
                color: FudiColors.primary,
              ),
              const SizedBox(width: FudiSpacing.sm),
              Text('Instrucciones', style: FudiTypography.labelMedium),
            ],
          ),
          const SizedBox(height: FudiSpacing.md),
          Text(
            order.status == OrderStatus.completed
                ? 'Recogida completada exitosamente'
                : 'Por favor, preséntate con tu código de reserva. El pedido estará listo en el mostrador principal.',
            style: FudiTypography.bodyMedium.copyWith(
              color: FudiColors.mutedForeground,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusHistoryCard extends StatelessWidget {
  const _StatusHistoryCard({required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    final entries = _buildEntries();

    return FudiSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.calendar_today,
                size: 20,
                color: FudiColors.primary,
              ),
              const SizedBox(width: FudiSpacing.sm),
              Text('Historial del pedido', style: FudiTypography.labelMedium),
            ],
          ),
          const SizedBox(height: FudiSpacing.lg),
          ...List.generate(entries.length, (i) {
            final entry = entries[i];
            final isLast = i == entries.length - 1;
            return _TimelineEntry(entry: entry, isLast: isLast);
          }),
        ],
      ),
    );
  }

  List<_HistoryEntry> _buildEntries() {
    final entries = <_HistoryEntry>[];
    final created = order.createdAt;

    entries.add(
      _HistoryEntry(
        icon: Icons.receipt_long,
        title: 'Pedido confirmado',
        note: 'Pedido confirmado y pagado',
        timestamp: created,
        color: FudiColors.primary,
        bgColor: FudiColors.primary.withValues(alpha: 0.1),
      ),
    );

    if (order.status == OrderStatus.readyForPickup ||
        order.status == OrderStatus.pickedUp ||
        order.status == OrderStatus.completed) {
      entries.add(
        _HistoryEntry(
          icon: Icons.schedule,
          title: 'Listo para recoger',
          note: 'Tu pedido está listo para recoger',
          timestamp: order.pickupTime ?? created,
          color: FudiColors.primary,
          bgColor: FudiColors.primary.withValues(alpha: 0.1),
        ),
      );
    }

    if (order.status == OrderStatus.completed) {
      entries.add(
        _HistoryEntry(
          icon: Icons.check_circle,
          title: 'Completado',
          note: 'Pedido recogido exitosamente',
          timestamp: order.pickupTime ?? created,
          color: const Color(0xFF16A34A),
          bgColor: const Color(0xFFDCFCE7),
        ),
      );
    }

    if (order.status == OrderStatus.cancelled) {
      entries.add(
        _HistoryEntry(
          icon: Icons.cancel,
          title: 'Cancelado',
          note: 'Pedido cancelado',
          timestamp: created,
          color: FudiColors.destructive,
          bgColor: const Color(0xFFFEE2E2),
        ),
      );
    }

    if (order.status == OrderStatus.expired) {
      entries.add(
        _HistoryEntry(
          icon: Icons.timer_off,
          title: 'Expirado',
          note: 'El pedido expiró sin ser recogido',
          timestamp: created,
          color: FudiColors.destructive,
          bgColor: const Color(0xFFFEE2E2),
        ),
      );
    }

    return entries;
  }
}

class _HistoryEntry {
  const _HistoryEntry({
    required this.icon,
    required this.title,
    required this.note,
    required this.timestamp,
    required this.color,
    required this.bgColor,
  });

  final IconData icon;
  final String title;
  final String note;
  final DateTime timestamp;
  final Color color;
  final Color bgColor;
}

class _TimelineEntry extends StatelessWidget {
  const _TimelineEntry({required this.entry, required this.isLast});

  final _HistoryEntry entry;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final time =
        '${entry.timestamp.hour.toString().padLeft(2, '0')}:${entry.timestamp.minute.toString().padLeft(2, '0')}';
    final date =
        '${entry.timestamp.day.toString().padLeft(2, '0')}/${entry.timestamp.month.toString().padLeft(2, '0')}/${entry.timestamp.year}';

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: entry.bgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(entry.icon, size: 20, color: entry.color),
              ),
              if (!isLast)
                Container(width: 2, height: 32, color: FudiColors.borderSolid),
            ],
          ),
          const SizedBox(width: FudiSpacing.md),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: FudiSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(entry.title, style: FudiTypography.labelSmall),
                      Text(time, style: FudiTypography.bodySmall),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(entry.note, style: FudiTypography.bodySmall),
                  const SizedBox(height: 2),
                  Text(date, style: FudiTypography.bodySmall),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
