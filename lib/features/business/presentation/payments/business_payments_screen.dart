import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/ui/fudi_colors.dart';
import '../../../../core/ui/fudi_icons.dart';
import '../../../../core/ui/fudi_spacing.dart';
import '../../../../core/ui/fudi_surface_card.dart';
import '../../../../core/ui/fudi_typography.dart';
import '../../domain/business_payout.dart';
import '../business_providers.dart';
import '../components/no_business_prompt.dart';

class BusinessPaymentsScreen extends ConsumerStatefulWidget {
  const BusinessPaymentsScreen({super.key});

  @override
  ConsumerState<BusinessPaymentsScreen> createState() =>
      _BusinessPaymentsScreenState();
}

class _BusinessPaymentsScreenState
    extends ConsumerState<BusinessPaymentsScreen> {
  _PayoutFilter _filter = _PayoutFilter.all;

  @override
  Widget build(BuildContext context) {
    final businessAsync = ref.watch(currentBusinessProvider);
    return Scaffold(
      backgroundColor: FudiColors.muted,
      appBar: _AppBar(),
      body: businessAsync.when(
        data: (business) {
          if (business == null) return const NoBusinessPrompt();
          final payoutsAsync = ref.watch(businessPayoutsProvider(business.id));
          return payoutsAsync.when(
            data: (payouts) => _Content(
              payouts: payouts,
              filter: _filter,
              onFilterChanged: (f) => setState(() => _filter = f),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('$e')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
      ),
    );
  }
}

enum _PayoutFilter { all, completed, processing }

class _AppBar extends StatelessWidget implements PreferredSizeWidget {
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
          Text('Pagos', style: FudiTypography.h4),
          Text('Historial de cobros', style: FudiTypography.bodySmall),
        ],
      ),
      backgroundColor: FudiColors.background,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 1,
      shadowColor: Colors.black12,
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({
    required this.payouts,
    required this.filter,
    required this.onFilterChanged,
  });

  final List<BusinessPayout> payouts;
  final _PayoutFilter filter;
  final ValueChanged<_PayoutFilter> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    final paid = payouts
        .where((p) => p.status == BusinessPayoutStatus.paid)
        .fold<double>(0, (sum, p) => sum + p.netAmount);
    final paidCount =
        payouts.where((p) => p.status == BusinessPayoutStatus.paid).length;
    final pending = payouts
        .where((p) =>
            p.status == BusinessPayoutStatus.pending ||
            p.status == BusinessPayoutStatus.processing)
        .fold<double>(0, (sum, p) => sum + p.netAmount);

    final filtered = switch (filter) {
      _PayoutFilter.all => payouts,
      _PayoutFilter.completed =>
        payouts.where((p) => p.status == BusinessPayoutStatus.paid).toList(),
      _PayoutFilter.processing => payouts
          .where((p) => p.status == BusinessPayoutStatus.processing)
          .toList(),
    };

    return ListView(
      padding: const EdgeInsets.all(FudiSpacing.lg),
      children: [
        Row(
          children: [
            Expanded(
              child: _BalanceCard(
                icon: Icons.attach_money_rounded,
                label: 'Total cobrado',
                value: paid,
                subtitle: '$paidCount pagos completados',
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF16A34A), Color(0xFF15803D)],
                ),
              ),
            ),
            const SizedBox(width: FudiSpacing.md),
            Expanded(
              child: _BalanceCard(
                icon: FudiIcons.clock,
                label: 'Pendiente',
                value: pending,
                subtitle: 'Próximo pago en 3 días',
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    FudiColors.primary,
                    FudiColors.primary.withValues(alpha: 0.8),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: FudiSpacing.lg),
        _PaymentMethodCard(),
        const SizedBox(height: FudiSpacing.lg),
        _FilterBar(filter: filter, onSelected: onFilterChanged),
        const SizedBox(height: FudiSpacing.lg),
        Text('Historial de pagos', style: FudiTypography.h4),
        const SizedBox(height: FudiSpacing.sm),
        if (filtered.isEmpty)
          const _EmptyPayouts()
        else
          ...filtered.map((p) => _PayoutCard(payout: p)),
        const SizedBox(height: FudiSpacing.lg),
        _CycleInfoCard(),
      ],
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.subtitle,
    required this.gradient,
  });

  final IconData icon;
  final String label;
  final double value;
  final String subtitle;
  final Gradient gradient;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(FudiRadius.xxl),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(FudiSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: Colors.white.withValues(alpha: 0.9)),
              const SizedBox(width: FudiSpacing.xs),
              Text(
                label,
                style: FudiTypography.bodySmall.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
          const SizedBox(height: FudiSpacing.sm),
          Text(
            '\$${value.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: FudiSpacing.xs),
          Text(
            subtitle,
            style: FudiTypography.bodySmall.copyWith(
              color: Colors.white.withValues(alpha: 0.75),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentMethodCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FudiSurfaceCard(
      padding: const EdgeInsets.all(FudiSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('Método de cobro', style: FudiTypography.labelSmall),
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  'Editar',
                  style: FudiTypography.bodyMedium.copyWith(
                    color: FudiColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: FudiSpacing.sm),
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
                      Text('Banco del Pacífico', style: FudiTypography.labelSmall),
                      Text(
                        '**** **** **** 4532',
                        style: FudiTypography.bodySmall,
                      ),
                    ],
                  ),
                ),
                Icon(FudiIcons.creditCard, color: FudiColors.mutedForeground, size: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({
    required this.filter,
    required this.onSelected,
  });

  final _PayoutFilter filter;
  final ValueChanged<_PayoutFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _FilterChip(
            label: 'Todos',
            selected: filter == _PayoutFilter.all,
            selectedColor: FudiColors.primary,
            onTap: () => onSelected(_PayoutFilter.all),
          ),
          const SizedBox(width: FudiSpacing.sm),
          _FilterChip(
            label: 'Pagados',
            selected: filter == _PayoutFilter.completed,
            selectedColor: const Color(0xFF16A34A),
            onTap: () => onSelected(_PayoutFilter.completed),
          ),
          const SizedBox(width: FudiSpacing.sm),
          _FilterChip(
            label: 'Procesando',
            selected: filter == _PayoutFilter.processing,
            selectedColor: const Color(0xFFEA580C),
            onTap: () => onSelected(_PayoutFilter.processing),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.selectedColor,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color selectedColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: FudiSpacing.lg,
          vertical: FudiSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: selected ? selectedColor : FudiColors.background,
          borderRadius: BorderRadius.circular(FudiRadius.md),
          border: selected
              ? null
              : Border.all(color: FudiColors.borderSolid),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: selectedColor.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: FudiTypography.bodyMedium.copyWith(
            color: selected ? Colors.white : FudiColors.foreground,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _PayoutCard extends StatelessWidget {
  const _PayoutCard({required this.payout});
  final BusinessPayout payout;

  @override
  Widget build(BuildContext context) {
    final config = _statusConfig(payout.status);
    return Padding(
      padding: const EdgeInsets.only(bottom: FudiSpacing.md),
      child: FudiSurfaceCard(
        padding: const EdgeInsets.all(FudiSpacing.lg),
        child: InkWell(
          onTap: () => context.push('/business/payments/${payout.id}'),
          borderRadius: BorderRadius.circular(FudiRadius.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              '\$${payout.netAmount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF16A34A),
                              ),
                            ),
                            const SizedBox(width: FudiSpacing.sm),
                            _StatusBadge(config: config),
                          ],
                        ),
                        const SizedBox(height: FudiSpacing.xs),
                        Text(_periodLabel(payout), style: FudiTypography.bodySmall),
                      ],
                    ),
                  ),
                  if (payout.status == BusinessPayoutStatus.paid)
                    IconButton(
                      onPressed: () {},
                      icon: Icon(
                        Icons.download_rounded,
                        color: FudiColors.primary,
                        size: 20,
                      ),
                      style: IconButton.styleFrom(
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: FudiSpacing.md),
              Divider(color: FudiColors.borderSolid, height: 1),
              const SizedBox(height: FudiSpacing.sm),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 12, color: FudiColors.mutedForeground),
                  const SizedBox(width: FudiSpacing.xs),
                  Text(
                    payout.status == BusinessPayoutStatus.paid
                        ? 'Pagado el ${_formatDate(payout.paidAt ?? payout.createdAt)}'
                        : 'Estimado para ${_formatDate(payout.createdAt)}',
                    style: FudiTypography.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _periodLabel(BusinessPayout p) {
    final start = p.periodStart;
    final end = p.periodEnd;
    const months = [
      '', 'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre',
    ];
    return '${months[start.month]} ${start.day}-${end.day}, ${start.year}';
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    const months = [
      '', 'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
      'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre',
    ];
    return '${date.day} de ${months[date.month]} de ${date.year}';
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.config});
  final _StatusConfig config;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: FudiSpacing.sm,
        vertical: 2,
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

class _CycleInfoCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(FudiSpacing.lg),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(FudiRadius.xxl),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(FudiIcons.trendingUp, size: 20, color: const Color(0xFF2563EB)),
          const SizedBox(width: FudiSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ciclo de pagos',
                  style: FudiTypography.labelSmall.copyWith(
                    color: const Color(0xFF1E3A5F),
                  ),
                ),
                const SizedBox(height: FudiSpacing.xs),
                Text(
                  'Los pagos se procesan dos veces al mes (días 5 y 20). '
                  'El dinero de tus ventas se transfiere a tu cuenta bancaria '
                  'en un plazo de 2-3 días hábiles.',
                  style: FudiTypography.bodySmall.copyWith(
                    color: const Color(0xFF1D4ED8),
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

class _EmptyPayouts extends StatelessWidget {
  const _EmptyPayouts();
  @override
  Widget build(BuildContext context) => const FudiSurfaceCard(
        padding: EdgeInsets.all(FudiSpacing.xl),
        child: Center(child: Text('Aún no hay pagos registrados')),
      );
}
