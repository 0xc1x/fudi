import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/ui/fudi_colors.dart';
import '../../../../core/ui/fudi_theme.dart';
import '../../../../core/ui/fudi_pressable_scale.dart';
import '../../../../core/ui/atoms/icons/fudi_icons.dart';
import '../../../../core/ui/fudi_spacing.dart';
import '../../../../core/ui/fudi_surface_card.dart';
import '../../../../core/ui/fudi_typography.dart';
import '../../../../core/ui/atoms/fudi_status_badge.dart';
import '../../../../core/ui/fudi_empty_state.dart';
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: const _AppBar(),
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
            loading: () => const Center(
              child: CircularProgressIndicator(
                color: FudiColors.primary,
                strokeWidth: 2,
              ),
            ),
            error: (e, _) =>
                Center(child: Text('$e', style: FudiTypography.bodyMedium)),
          );
        },
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
}

enum _PayoutFilter { all, completed, processing }

class _AppBar extends StatelessWidget implements PreferredSizeWidget {
  const _AppBar();
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return AppBar(
      leading: Padding(
        padding: const EdgeInsets.only(left: FudiSpacing.sm),
        child: FudiPressableScale(
          onTap: () => context.pop(),
          child: Center(
            child: Icon(
              FudiIcons.chevronLeft,
              size: 20,
              color: colorScheme.onSurface,
            ),
          ),
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Balance y Cobros',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          Text(
            'Historial financiero del comercio',
            style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
      backgroundColor: colorScheme.surface,
      elevation: 0,
      scrolledUnderElevation: 0,
      shape: Border(
        bottom: BorderSide(color: colorScheme.outlineVariant),
      ),
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
    final paidCount = payouts
        .where((p) => p.status == BusinessPayoutStatus.paid)
        .length;
    final pending = payouts
        .where(
          (p) =>
              p.status == BusinessPayoutStatus.pending ||
              p.status == BusinessPayoutStatus.processing,
        )
        .fold<double>(0, (sum, p) => sum + p.netAmount);

    final filtered = switch (filter) {
      _PayoutFilter.all => payouts,
      _PayoutFilter.completed =>
        payouts.where((p) => p.status == BusinessPayoutStatus.paid).toList(),
      _PayoutFilter.processing =>
        payouts
            .where((p) => p.status == BusinessPayoutStatus.processing)
            .toList(),
    };

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(FudiSpacing.md),
      children: [
        // Bento Grid Layout para balances
        Row(
          children: [
            Expanded(
              child: _BalanceCard(
                label: 'Total cobrado',
                value: paid,
                subtitle: '$paidCount transferencias',
                color: FudiColors.surfaceSuccess,
                textColor: FudiColors.successDark,
              ),
            ),
            const SizedBox(width: FudiSpacing.sm),
            Expanded(
              child: _BalanceCard(
                label: 'Por procesar',
                value: pending,
                subtitle: 'Corte automático en 3d',
                color: FudiColors.infoSurface,
                textColor: FudiColors.infoForeground,
              ),
            ),
          ],
        ),
        const SizedBox(height: FudiSpacing.md),
        const _PaymentMethodCard(),
        const SizedBox(height: FudiSpacing.lg),
        _FilterBar(filter: filter, onSelected: onFilterChanged),
        const SizedBox(height: FudiSpacing.md),
        if (filtered.isEmpty)
          const FudiSurfaceCard(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: FudiSpacing.xl),
              child: FudiEmptyState(
                title: 'Sin movimientos',
                description: 'No encontramos transacciones bajo este filtro.',
                icon: Icons.receipt_long_rounded,
              ),
            ),
          )
        else
          ...filtered.map((p) => _PayoutCard(payout: p)),
        const SizedBox(height: FudiSpacing.md),
        const _CycleInfoCard(),
      ],
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({
    required this.label,
    required this.value,
    required this.subtitle,
    required this.color,
    required this.textColor,
  });

  final String label;
  final double value;
  final String subtitle;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(FudiSpacing.md),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: textColor.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: textColor.withValues(alpha: 0.8),
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: FudiSpacing.xs),
          Text(
            '\$${value.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 10,
              color: textColor.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentMethodCard extends StatelessWidget {
  const _PaymentMethodCard();
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return FudiSurfaceCard(
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: colorScheme.onSurface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text(
                'BP',
                style: TextStyle(
                  color: FudiColors.primaryForeground,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          const SizedBox(width: FudiSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Banco del Pacífico',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Cuenta corriente •••• 4532',
                  style: TextStyle(
                    fontSize: 11,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          FudiPressableScale(
            onTap: () {},
            child: Text(
              'Editar',
              style: FudiTypography.bodySmall.copyWith(
                color: FudiColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.filter, required this.onSelected});
  final _PayoutFilter filter;
  final ValueChanged<_PayoutFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        _buildChip(
          'Todos',
          filter == _PayoutFilter.all,
          () => onSelected(_PayoutFilter.all),
          colorScheme,
        ),
        const SizedBox(width: FudiSpacing.xs),
        _buildChip(
          'Completados',
          filter == _PayoutFilter.completed,
          () => onSelected(_PayoutFilter.completed),
          colorScheme,
        ),
        const SizedBox(width: FudiSpacing.xs),
        _buildChip(
          'En proceso',
          filter == _PayoutFilter.processing,
          () => onSelected(_PayoutFilter.processing),
          colorScheme,
        ),
      ],
    );
  }

  Widget _buildChip(
    String label,
    bool isSelected,
    VoidCallback onTap,
    ColorScheme colorScheme,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(
          horizontal: FudiSpacing.md,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.onSurface : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? colorScheme.onSurface : colorScheme.outlineVariant,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? FudiColors.primaryForeground : colorScheme.onSurfaceVariant,
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
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: FudiSpacing.xs),
      child: FudiSurfaceCard(
        child: InkWell(
          onTap: () => context.push('/business/payments/${payout.id}'),
          borderRadius: BorderRadius.circular(8),
          child: Row(
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
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: FudiSpacing.sm),
                        FudiStatusBadge.fromPayoutStatus(
                          payout.status,
                          size: FudiStatusBadgeSize.sm,
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _periodLabel(payout),
                      style: TextStyle(
                        fontSize: 11,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                FudiIcons.chevronRight,
                size: 16,
                color: colorScheme.onSurfaceVariant,
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
      '',
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic',
    ];
    return '${months[start.month]} ${start.day} - ${end.day}, ${start.year}';
  }
}

class _CycleInfoCard extends StatelessWidget {
  const _CycleInfoCard();
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final themeExt = Theme.of(context).extension<FudiThemeExtension>();
    final mutedBg = themeExt?.mutedBackground ?? FudiColors.muted;
    return Container(
      padding: const EdgeInsets.all(FudiSpacing.md),
      decoration: BoxDecoration(
        color: mutedBg.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 16,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: FudiSpacing.sm),
          Expanded(
            child: Text(
              'Ciclo automático: Transferencias directas quincenales (días 5 y 20). Los depósitos toman de 48 a 72 horas hábiles.',
              style: TextStyle(
                fontSize: 11,
                color: colorScheme.onSurfaceVariant,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
