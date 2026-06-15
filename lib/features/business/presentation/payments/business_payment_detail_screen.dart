import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/ui/fudi_colors.dart';
import '../../../../core/ui/atoms/icons/fudi_icons.dart';
import '../../../../core/ui/fudi_spacing.dart';
import '../../../../core/ui/fudi_surface_card.dart';
import '../../../../core/ui/fudi_typography.dart';
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
      backgroundColor: FudiColors.muted,
      appBar: _AppBar(
        period: payoutAsync.asData?.value != null
            ? _periodLabel(payoutAsync.asData!.value)
            : '',
        status:
            payoutAsync.asData?.value.status ?? BusinessPayoutStatus.pending,
      ),
      body: payoutAsync.when(
        data: (payout) => _Content(payout: payout),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
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
        child: IconButton(
          onPressed: () => context.pop(),
          icon: Container(
            width: 40,
            height: 40,
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
          Text('Detalle del pago', style: FudiTypography.h4),
          if (period.isNotEmpty) Text(period, style: FudiTypography.bodySmall),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: FudiSpacing.lg),
          child: _AppBarStatusBadge(status: status),
        ),
      ],
      backgroundColor: FudiColors.background,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 1,
      shadowColor: Colors.black12,
    );
  }
}

class _AppBarStatusBadge extends StatelessWidget {
  const _AppBarStatusBadge({required this.status});
  final BusinessPayoutStatus status;

  @override
  Widget build(BuildContext context) {
    final config = _statusConfig(status);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: FudiSpacing.md,
        vertical: FudiSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: config.bgColor,
        borderRadius: BorderRadius.circular(FudiRadius.full),
        border: Border.all(color: config.borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(config.icon, size: 12, color: config.iconColor),
          const SizedBox(width: 4),
          Text(
            config.label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: config.textColor,
            ),
          ),
        ],
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
      padding: const EdgeInsets.all(FudiSpacing.lg),
      children: [
        _AmountHero(payout: payout),
        const SizedBox(height: FudiSpacing.lg),
        if (payout.status == BusinessPayoutStatus.paid && payout.paidAt != null)
          _CompletedStatusCard(paidAt: payout.paidAt!),
        if (payout.status == BusinessPayoutStatus.paid && payout.paidAt != null)
          const SizedBox(height: FudiSpacing.lg),
        _PaymentMethodSection(),
        const SizedBox(height: FudiSpacing.lg),
        _BreakdownSection(payout: payout),
        const SizedBox(height: FudiSpacing.lg),
        _InfoCard(),
        if (payout.status == BusinessPayoutStatus.paid) ...[
          const SizedBox(height: FudiSpacing.lg),
          _DownloadReceiptButton(),
        ],
        const SizedBox(height: FudiSpacing.lg),
      ],
    );
  }
}

class _AmountHero extends StatelessWidget {
  const _AmountHero({required this.payout});
  final BusinessPayout payout;

  @override
  Widget build(BuildContext context) {
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
    final period =
        '${months[payout.periodStart.month]} ${payout.periodStart.day}-${payout.periodEnd.day}, ${payout.periodStart.year}';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF16A34A), Color(0xFF15803D)],
        ),
        borderRadius: BorderRadius.circular(FudiRadius.xxl),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(FudiSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.attach_money_rounded,
                size: 20,
                color: Colors.white.withValues(alpha: 0.9),
              ),
              const SizedBox(width: FudiSpacing.xs),
              Text(
                'Monto total',
                style: FudiTypography.bodySmall.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
          const SizedBox(height: FudiSpacing.sm),
          Text(
            '\$${payout.netAmount.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: FudiSpacing.md),
          Row(
            children: [
              Text(
                'Período: $period',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
              const Spacer(),
              if (payout.status == BusinessPayoutStatus.paid &&
                  payout.paidAt != null)
                Text(
                  'Pagado el ${_formatDate(payout.paidAt!)}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      '',
      'enero',
      'febrero',
      'marzo',
      'abril',
      'mayo',
      'junio',
      'julio',
      'agosto',
      'septiembre',
      'octubre',
      'noviembre',
      'diciembre',
    ];
    return '${date.day} de ${months[date.month]} de ${date.year}';
  }
}

class _CompletedStatusCard extends StatelessWidget {
  const _CompletedStatusCard({required this.paidAt});
  final DateTime paidAt;

  @override
  Widget build(BuildContext context) {
    return FudiSurfaceCard(
      padding: const EdgeInsets.all(FudiSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Color(0xFFDCFCE7),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_outline_rounded,
              color: Color(0xFF16A34A),
              size: 20,
            ),
          ),
          const SizedBox(width: FudiSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Pago completado', style: FudiTypography.labelSmall),
                const SizedBox(height: FudiSpacing.xs),
                Text(
                  'Procesado el ${_formatDateTime(paidAt)}',
                  style: FudiTypography.bodySmall,
                ),
                const SizedBox(height: FudiSpacing.xs),
                Text(
                  'Los fondos fueron transferidos a tu cuenta bancaria',
                  style: FudiTypography.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime date) {
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
    final time =
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    return '${date.day} ${months[date.month]} ${date.year} $time';
  }
}

class _PaymentMethodSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FudiSurfaceCard(
      padding: const EdgeInsets.all(FudiSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(FudiIcons.creditCard, size: 20, color: FudiColors.primary),
              const SizedBox(width: FudiSpacing.sm),
              Text('Método de pago', style: FudiTypography.labelSmall),
            ],
          ),
          const SizedBox(height: FudiSpacing.md),
          Container(
            padding: const EdgeInsets.all(FudiSpacing.md),
            decoration: BoxDecoration(
              color: FudiColors.muted,
              borderRadius: BorderRadius.circular(FudiRadius.xl),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(FudiRadius.md),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF2563EB), Color(0xFF9333EA)],
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      'BC',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: FudiSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Banco del Pacífico',
                        style: FudiTypography.labelSmall,
                      ),
                      Text(
                        'Cuenta bancaria •••• 4532',
                        style: FudiTypography.bodySmall,
                      ),
                    ],
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

class _BreakdownSection extends StatelessWidget {
  const _BreakdownSection({required this.payout});
  final BusinessPayout payout;

  @override
  Widget build(BuildContext context) {
    final totalSales = payout.grossAmount;
    final taxes = totalSales - payout.platformFee - payout.netAmount;

    return FudiSurfaceCard(
      padding: const EdgeInsets.all(FudiSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(FudiIcons.trendingUp, size: 20, color: FudiColors.primary),
              const SizedBox(width: FudiSpacing.sm),
              Text('Desglose del pago', style: FudiTypography.labelSmall),
            ],
          ),
          const SizedBox(height: FudiSpacing.md),
          _BreakdownRow(
            icon: FudiIcons.package_,
            label: 'Total de ventas',
            value: '\$${totalSales.toStringAsFixed(2)}',
          ),
          Divider(color: FudiColors.borderSolid, height: 1),
          _BreakdownRow(
            label: 'Comisión de la plataforma (10%)',
            value: '-\$${payout.platformFee.toStringAsFixed(2)}',
            valueColor: FudiColors.destructive,
          ),
          _BreakdownRow(
            label: 'Impuestos y tasas',
            value: '-\$${taxes.toStringAsFixed(2)}',
            valueColor: FudiColors.destructive,
          ),
          Divider(color: FudiColors.borderSolid, height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: FudiSpacing.sm),
            child: Row(
              children: [
                Expanded(
                  child: Text('Monto neto', style: FudiTypography.labelSmall),
                ),
                Text(
                  '\$${payout.netAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF16A34A),
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

class _BreakdownRow extends StatelessWidget {
  const _BreakdownRow({
    this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final IconData? icon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: FudiSpacing.sm),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: FudiColors.mutedForeground),
            const SizedBox(width: FudiSpacing.xs),
          ],
          Expanded(child: Text(label, style: FudiTypography.bodySmall)),
          Text(
            value,
            style: FudiTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.w500,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(FudiSpacing.lg),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(FudiRadius.xxl),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ℹ️ Información',
            style: FudiTypography.labelSmall.copyWith(
              color: const Color(0xFF1E3A5F),
            ),
          ),
          const SizedBox(height: FudiSpacing.sm),
          _infoBullet('Los pagos se procesan automáticamente dos veces al mes'),
          _infoBullet(
            'La comisión de la plataforma es del 10% sobre cada venta',
          ),
          _infoBullet('Los fondos se transfieren en 2-3 días hábiles'),
          _infoBullet(
            'Puedes descargar el comprobante para tus registros contables',
          ),
        ],
      ),
    );
  }

  Widget _infoBullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: FudiSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: FudiTypography.bodySmall.copyWith(
              color: const Color(0xFF1D4ED8),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: FudiTypography.bodySmall.copyWith(
                color: const Color(0xFF1D4ED8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DownloadReceiptButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () {},
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: FudiSpacing.lg),
          side: BorderSide(color: FudiColors.borderSolid),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(FudiRadius.xl),
          ),
          backgroundColor: FudiColors.background,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.download_rounded,
              size: 20,
              color: FudiColors.foreground,
            ),
            const SizedBox(width: FudiSpacing.sm),
            Text(
              'Descargar comprobante',
              style: FudiTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusConfig {
  const _StatusConfig({
    required this.label,
    required this.icon,
    required this.bgColor,
    required this.borderColor,
    required this.textColor,
    required this.iconColor,
  });
  final String label;
  final IconData icon;
  final Color bgColor;
  final Color borderColor;
  final Color textColor;
  final Color iconColor;
}

_StatusConfig _statusConfig(BusinessPayoutStatus status) => switch (status) {
  BusinessPayoutStatus.paid => const _StatusConfig(
    label: 'Pagado',
    icon: Icons.check_circle_outline_rounded,
    bgColor: Color(0xFFDCFCE7),
    borderColor: Color(0xFFBBF7D0),
    textColor: Color(0xFF15803D),
    iconColor: Color(0xFF16A34A),
  ),
  BusinessPayoutStatus.processing => const _StatusConfig(
    label: 'Procesando',
    icon: Icons.schedule_rounded,
    bgColor: Color(0xFFFFEDD5),
    borderColor: Color(0xFFFED7AA),
    textColor: Color(0xFFC2410C),
    iconColor: Color(0xFFEA580C),
  ),
  BusinessPayoutStatus.pending => _StatusConfig(
    label: 'Pendiente',
    icon: Icons.schedule_rounded,
    bgColor: FudiColors.primary.withValues(alpha: 0.1),
    borderColor: FudiColors.primary.withValues(alpha: 0.2),
    textColor: FudiColors.primary,
    iconColor: FudiColors.primary,
  ),
  BusinessPayoutStatus.failed => const _StatusConfig(
    label: 'Fallido',
    icon: Icons.error_outline_rounded,
    bgColor: Color(0xFFFEE2E2),
    borderColor: Color(0xFFFECACA),
    textColor: Color(0xFFDC2626),
    iconColor: Color(0xFFEF4444),
  ),
};
