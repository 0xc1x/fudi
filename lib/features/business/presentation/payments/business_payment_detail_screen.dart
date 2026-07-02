import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/ui/fudi_colors.dart';
import '../../../../core/ui/fudi_pressable_scale.dart';
import '../../../../core/ui/atoms/icons/fudi_icons.dart';
import '../../../../core/ui/fudi_spacing.dart';
import '../../../../core/ui/fudi_surface_card.dart';
import '../../../../core/ui/fudi_typography.dart';
import '../../../../core/ui/atoms/fudi_status_badge.dart';
import '../../../../core/ui/atoms/fudi_button.dart';
import '../../domain/business_payout.dart';
import '../business_providers.dart';

class BusinessPaymentDetailScreen extends ConsumerStatefulWidget {
  const BusinessPaymentDetailScreen({required this.payoutId, super.key});

  final String payoutId;

  @override
  ConsumerState<BusinessPaymentDetailScreen> createState() =>
      _BusinessPaymentDetailScreenState();
}

class _BusinessPaymentDetailScreenState
    extends ConsumerState<BusinessPaymentDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final payoutAsync = ref.watch(businessPayoutProvider(widget.payoutId));
    return Scaffold(
      backgroundColor: FudiColors.background,
      appBar: _AppBar(
        period: payoutAsync.asData?.value != null
            ? _periodLabel(payoutAsync.asData!.value)
            : '',
        status:
            payoutAsync.asData?.value.status ?? BusinessPayoutStatus.processing,
      ),
      body: payoutAsync.when(
        data: (payout) => _Content(payout: payout),
        loading: () => const Center(
          child: CircularProgressIndicator(
            color: FudiColors.primary,
            strokeWidth: 2,
          ),
        ),
        error: (e, _) =>
            Center(child: Text('$e', style: FudiTypography.bodyMedium)),
      ),
    );
  }

  static String _periodLabel(BusinessPayout p) {
    const months = [
      '',
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre',
    ];
    return '${months[p.periodStart.month]} ${p.periodStart.day}-${p.periodEnd.day}, ${p.periodStart.year}';
  }
}

class _AppBar extends StatelessWidget implements PreferredSizeWidget {
  const _AppBar({required this.period, required this.status});
  final String period;
  final BusinessPayoutStatus status;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: Padding(
        padding: const EdgeInsets.only(left: FudiSpacing.sm),
        child: FudiPressableScale(
          onTap: () => context.pop(),
          child: const Center(
            child: Icon(
              FudiIcons.chevronLeft,
              size: 20,
              color: FudiColors.foreground,
            ),
          ),
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Detalle de Transferencia',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          if (period.isNotEmpty)
            Text(
              period,
              style: const TextStyle(
                fontSize: 11,
                color: FudiColors.mutedForeground,
              ),
            ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: FudiSpacing.md),
          child: FudiStatusBadge.fromPayoutStatus(
            status,
            size: FudiStatusBadgeSize.sm,
          ),
        ),
      ],
      backgroundColor: FudiColors.background,
      elevation: 0,
      shape: const Border(
        bottom: BorderSide(color: FudiColors.borderSolid),
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.payout});
  final BusinessPayout payout;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(FudiSpacing.md),
      children: [
        _AmountHero(payout: payout),
        const SizedBox(height: FudiSpacing.md),
        _BreakdownSection(payout: payout),
        const SizedBox(height: FudiSpacing.md),
        const _PaymentMethodSection(),
        const SizedBox(height: FudiSpacing.lg),
        if (payout.status == BusinessPayoutStatus.paid)
          FudiButton(
            text: 'Descargar comprobante (PDF)',
            icon: Icons.download_rounded,
            variant: FudiButtonVariant.outlined,
            fullWidth: true,
            onPressed: () {},
          ),
      ],
    );
  }
}

class _AmountHero extends StatelessWidget {
  const _AmountHero({required this.payout});
  final BusinessPayout payout;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(FudiSpacing.xl),
      decoration: BoxDecoration(
        color: FudiColors.foreground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            'MONTO TOTAL NETO',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: FudiSpacing.xs),
          Text(
            '\$${payout.netAmount.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 38,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          if (payout.status == BusinessPayoutStatus.paid &&
              payout.paidAt != null) ...[
            const SizedBox(height: FudiSpacing.sm),
            Text(
              'Liquidado el ${_formatDate(payout.paidAt!)}',
              style: const TextStyle(
                color: Color(0xFF4ADE80),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      '',
      'ene',
      'feb',
      'mar',
      'abr',
      'may',
      'jun',
      'jul',
      'ago',
      'sep',
      'oct',
      'nov',
      'dic',
    ];
    return '${date.day} de ${months[date.month]}. de ${date.year}';
  }
}

class _BreakdownSection extends StatelessWidget {
  const _BreakdownSection({required this.payout});
  final BusinessPayout payout;

  @override
  Widget build(BuildContext context) {
    final totalSales = payout.grossAmount;
    final taxes = totalSales - payout.platformFee - payout.netAmount;

    return FudiSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Conciliación contable',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: FudiSpacing.md),
          _buildRow(
            'Total ventas brutas',
            '\$${totalSales.toStringAsFixed(2)}',
          ),
          _buildRow(
            'Comisión plataforma (10%)',
            '-\$${payout.platformFee.toStringAsFixed(2)}',
            isNegative: true,
          ),
          _buildRow(
            'Retenciones bancarias / tasas',
            '-\$${taxes.toStringAsFixed(2)}',
            isNegative: true,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: FudiSpacing.sm),
            child: Divider(color: FudiColors.borderSolid, height: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Depósito neto',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              Text(
                '\$${payout.netAmount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF16A34A),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value, {bool isNegative = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: FudiColors.mutedForeground,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isNegative ? FontWeight.w500 : FontWeight.bold,
              color: isNegative
                  ? FudiColors.destructive
                  : FudiColors.foreground,
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentMethodSection extends StatelessWidget {
  const _PaymentMethodSection();
  @override
  Widget build(BuildContext context) {
    return const FudiSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Destino del depósito',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: FudiSpacing.sm),
          Row(
            children: [
              Icon(
                FudiIcons.creditCard,
                size: 16,
                color: FudiColors.mutedForeground,
              ),
              SizedBox(width: FudiSpacing.sm),
              Expanded(
                child: Text(
                  'Banco del Pacífico • Account •••• 4532',
                  style: TextStyle(
                    fontSize: 12,
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
