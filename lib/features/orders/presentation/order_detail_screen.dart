import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/ui/fudi_colors.dart';
import '../../../core/ui/fudi_spacing.dart';
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
              FilledButton(
                onPressed: () => ref.invalidate(orderDetailProvider(id)),
                child: const Text('Reintentar'),
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
    final cancelAsync = ref.watch(orderCancelProvider);
    final cancelState = cancelAsync.value ?? const CancelOrderState();
    final isCanceling = cancelAsync.isLoading || cancelState.isCanceling;

    return Scaffold(
      appBar: AppBar(
        title: Text('Pedido #${widget.order.orderNumber}'),
        backgroundColor: FudiColors.background,
        surfaceTintColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(FudiSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _StatusTimelineCard(status: widget.order.status),
            const SizedBox(height: FudiSpacing.lg),
            _PickupCodeSection(code: widget.order.pickupCode),
            const SizedBox(height: FudiSpacing.lg),
            _OrderInfoCard(order: widget.order),
            const SizedBox(height: FudiSpacing.lg),
            if (widget.order.status.isActive)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: isCanceling
                      ? null
                      : () => _showCancelDialog(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: FudiColors.destructive,
                    side: const BorderSide(color: FudiColors.destructive),
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(FudiRadius.lg),
                    ),
                  ),
                  child: Text(
                    'Cancelar pedido',
                    style: FudiTypography.labelMedium.copyWith(
                      color: FudiColors.destructive,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: FudiSpacing.xxl),
          ],
        ),
      ),
    );
  }

  void _showCancelDialog(BuildContext context) {
    ref.read(orderCancelProvider.notifier).reset();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Consumer(
        builder: (ctx, ref, _) {
          final cancelAsync = ref.watch(orderCancelProvider);
          final cancelState = cancelAsync.value ?? const CancelOrderState();
          final isCanceling = cancelAsync.isLoading || cancelState.isCanceling;

          if (cancelState.result?.success == true) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Pedido cancelado exitosamente')),
              );
            });
          }

          return AlertDialog(
            title: const Text('Cancelar pedido'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '¿Estás seguro de que deseas cancelar el pedido #${widget.order.orderNumber}? Esta acción no se puede deshacer.',
                ),
                if (cancelState.errorMessage != null) ...[
                  const SizedBox(height: FudiSpacing.sm),
                  Text(
                    cancelState.errorMessage!,
                    style: FudiTypography.bodySmall.copyWith(
                      color: FudiColors.destructive,
                    ),
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: isCanceling
                    ? null
                    : () {
                        Navigator.of(ctx).pop();
                        ref.read(orderCancelProvider.notifier).reset();
                      },
                child: const Text('No, mantener'),
              ),
              FilledButton(
                onPressed: isCanceling
                    ? null
                    : () {
                        ref
                            .read(orderCancelProvider.notifier)
                            .cancelOrder(widget.order.id);
                      },
                style: FilledButton.styleFrom(
                  backgroundColor: FudiColors.destructive,
                ),
                child: isCanceling
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Sí, cancelar'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StatusTimelineCard extends StatelessWidget {
  const _StatusTimelineCard({required this.status});

  final OrderStatus status;

  static const _timeline = [
    OrderStatus.pending,
    OrderStatus.confirmed,
    OrderStatus.readyForPickup,
    OrderStatus.pickedUp,
    OrderStatus.completed,
  ];

  @override
  Widget build(BuildContext context) {
    final currentIdx = _timeline.indexOf(status);
    final isCancelled = status == OrderStatus.cancelled;
    final isExpired = status == OrderStatus.expired;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(FudiSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Estado del pedido', style: FudiTypography.labelMedium),
                _StatusChip(status: status),
              ],
            ),
            const SizedBox(height: FudiSpacing.lg),
            if (isCancelled || isExpired)
              Text(
                isCancelled
                    ? 'Este pedido fue cancelado'
                    : 'Este pedido expiró',
                style: FudiTypography.bodyMedium.copyWith(
                  color: FudiColors.destructive,
                ),
              )
            else
              _TimelineProgress(currentIndex: currentIdx),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    final (color, textColor) = switch (status) {
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
      _ => (FudiColors.muted, FudiColors.mutedForeground),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(FudiRadius.sm),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _TimelineProgress extends StatelessWidget {
  const _TimelineProgress({required this.currentIndex});

  final int currentIndex;

  static const _labels = [
    'Pendiente',
    'Confirmado',
    'Listo',
    'Recogido',
    'Completado',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(_labels.length, (i) {
        final isCompleted = i <= currentIndex;
        final isCurrent = i == currentIndex;
        final isLast = i == _labels.length - 1;

        return IntrinsicHeight(
          child: Row(
            children: [
              Column(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? FudiColors.primary
                          : FudiColors.muted,
                      shape: BoxShape.circle,
                    ),
                    child: isCompleted
                        ? const Icon(Icons.check, size: 14, color: Colors.white)
                        : null,
                  ),
                  if (!isLast)
                    Container(
                      width: 2,
                      height: 24,
                      color: isCompleted
                          ? FudiColors.primary
                          : FudiColors.borderSolid,
                    ),
                ],
              ),
              const SizedBox(width: FudiSpacing.md),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    _labels[i],
                    style: FudiTypography.bodyMedium.copyWith(
                      color: isCurrent
                          ? FudiColors.primary
                          : isCompleted
                          ? FudiColors.foreground
                          : FudiColors.mutedForeground,
                      fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _PickupCodeSection extends StatelessWidget {
  const _PickupCodeSection({required this.code});

  final String code;

  @override
  Widget build(BuildContext context) {
    if (code.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(FudiSpacing.md),
        child: Column(
          children: [
            Text(
              'Código de recogida',
              style: FudiTypography.bodyMedium.copyWith(
                color: FudiColors.mutedForeground,
              ),
            ),
            const SizedBox(height: FudiSpacing.md),
            SelectableText(
              code,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                letterSpacing: 6,
                color: FudiColors.primary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: FudiSpacing.md),
            OutlinedButton.icon(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: code));
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Código copiado')));
              },
              icon: const Icon(Icons.copy_rounded, size: 16),
              label: const Text('Copiar código'),
              style: OutlinedButton.styleFrom(
                foregroundColor: FudiColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderInfoCard extends StatelessWidget {
  const _OrderInfoCard({required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(FudiSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Detalles del pedido', style: FudiTypography.labelMedium),
            const Divider(),
            if (order.offerImageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(FudiRadius.md),
                child: CachedNetworkImage(
                  imageUrl: order.offerImageUrl!,
                  height: 140,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => Container(
                    height: 140,
                    color: FudiColors.muted,
                    child: const Icon(
                      Icons.restaurant,
                      color: FudiColors.mutedForeground,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: FudiSpacing.md),
            _InfoRow(label: 'Oferta', value: order.offerTitle),
            _InfoRow(label: 'Negocio', value: order.businessName),
            _InfoRow(label: 'Pedido', value: '#${order.orderNumber}'),
            const Divider(),
            _InfoRow(
              label: 'Precio original',
              value: '\$${order.originalPrice.toStringAsFixed(0)}',
            ),
            if (order.discount > 0)
              _InfoRow(
                label: 'Descuento',
                value: '-\$${order.discount.toStringAsFixed(0)}',
                valueColor: FudiColors.success,
              ),
            const Divider(),
            _InfoRow(
              label: 'Total pagado',
              value: '\$${order.price.toStringAsFixed(0)}',
              isBold: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.isBold = false,
    this.valueColor,
  });

  final String label;
  final String value;
  final bool isBold;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final style = isBold
        ? FudiTypography.labelMedium
        : FudiTypography.bodyMedium;
    final effectiveColor = valueColor ?? (isBold ? FudiColors.primary : null);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text(value, style: style.copyWith(color: effectiveColor)),
        ],
      ),
    );
  }
}
