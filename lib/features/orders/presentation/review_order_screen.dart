import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/route_names.dart';
import '../../../core/ui/fudi_colors.dart';
import '../../../core/ui/fudi_spacing.dart';
import '../../../core/ui/fudi_typography.dart';
import '../domain/order_model.dart';
import '../presentation/order_providers.dart';

class ReviewOrderScreen extends ConsumerStatefulWidget {
  const ReviewOrderScreen({required this.id, super.key});

  final String id;

  @override
  ConsumerState<ReviewOrderScreen> createState() => _ReviewOrderScreenState();
}

class _ReviewOrderScreenState extends ConsumerState<ReviewOrderScreen> {
  Timer? _countdownTimer;
  Duration _remaining = Duration.zero;

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orderAsync = ref.watch(orderDetailProvider(widget.id));

    return orderAsync.when(
      data: (order) {
        _startCountdown(order);
        return _buildContent(context, order);
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Error: $error')),
      ),
    );
  }

  void _startCountdown(OrderModel order) {
    final pickupEnd = order.createdAt.add(const Duration(hours: 22));
    _remaining = pickupEnd.difference(DateTime.now());
    if (_remaining.isNegative) _remaining = Duration.zero;

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (!mounted) return;
      setState(() {
        _remaining = pickupEnd.difference(DateTime.now());
        if (_remaining.isNegative) _remaining = Duration.zero;
      });
    });
  }

  Widget _buildContent(BuildContext context, OrderModel order) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(FudiSpacing.lg),
        child: Column(
          children: [
            const SizedBox(height: FudiSpacing.xl),
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: FudiColors.secondary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                color: FudiColors.primary,
                size: 48,
              ),
            ),
            const SizedBox(height: FudiSpacing.lg),
            Text(
              '¡Reserva confirmada!',
              style: FudiTypography.headlineMedium,
            ),
            const SizedBox(height: FudiSpacing.sm),
            Text(
              'Presenta este código en el negocio',
              style: FudiTypography.bodyMedium.copyWith(
                color: FudiColors.mutedForeground,
              ),
            ),
            const SizedBox(height: FudiSpacing.xl),
            _PickupCodeCard(code: order.pickupCode),
            const SizedBox(height: FudiSpacing.xl),
            if (_remaining > Duration.zero) ...[
              _CountdownCard(remaining: _remaining),
              const SizedBox(height: FudiSpacing.lg),
            ],
            _OrderSummaryCard(order: order),
            const SizedBox(height: FudiSpacing.xl),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => context.go(RouteNames.ordersPath),
                style: FilledButton.styleFrom(
                  backgroundColor: FudiColors.primary,
                  minimumSize: const Size.fromHeight(56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(FudiRadius.lg),
                  ),
                ),
                child: Text(
                  'Ver mis pedidos',
                  style: FudiTypography.labelMedium.copyWith(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: FudiSpacing.sm),
            TextButton(
              onPressed: () => context.go(RouteNames.homePath),
              child: Text(
                'Volver al inicio',
                style: FudiTypography.bodyMedium.copyWith(color: FudiColors.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PickupCodeCard extends StatelessWidget {
  const _PickupCodeCard({required this.code});

  final String code;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(FudiSpacing.xl),
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
                fontSize: 36,
                fontWeight: FontWeight.w800,
                letterSpacing: 8,
                color: FudiColors.primary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: FudiSpacing.md),
            OutlinedButton.icon(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: code));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Código copiado')),
                );
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

class _CountdownCard extends StatelessWidget {
  const _CountdownCard({required this.remaining});

  final Duration remaining;

  @override
  Widget build(BuildContext context) {
    final hours = remaining.inHours;
    final minutes = remaining.inMinutes.remainder(60);
    final isUrgent = remaining.inMinutes < 60;

    return Card(
      color: isUrgent ? FudiColors.destructive.withValues(alpha: 0.05) : null,
      child: Padding(
        padding: const EdgeInsets.all(FudiSpacing.md),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.access_time_rounded,
              color: isUrgent ? FudiColors.destructive : FudiColors.accent,
            ),
            const SizedBox(width: FudiSpacing.sm),
            Text(
              'Tiempo restante: ${hours}h ${minutes}m',
              style: FudiTypography.labelMedium.copyWith(
                color: isUrgent ? FudiColors.destructive : FudiColors.accent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderSummaryCard extends StatelessWidget {
  const _OrderSummaryCard({required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(FudiSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Resumen del pedido', style: FudiTypography.labelMedium),
            const Divider(),
            _SummaryRow(label: 'Pedido', value: '#${order.orderNumber}'),
            _SummaryRow(label: 'Oferta', value: order.offerTitle),
            _SummaryRow(label: 'Negocio', value: order.businessName),
            _SummaryRow(label: 'Estado', value: order.status.label),
            const Divider(),
            _SummaryRow(
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

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.isBold = false,
  });

  final String label;
  final String value;
  final bool isBold;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: FudiTypography.bodyMedium),
          Text(
            value,
            style: (isBold ? FudiTypography.labelMedium : FudiTypography.bodyMedium)
                .copyWith(
              color: isBold ? FudiColors.primary : null,
            ),
          ),
        ],
      ),
    );
  }
}
