import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/ui/fudi_colors.dart';
import '../../../../core/ui/fudi_theme.dart';
import '../../../../core/ui/fudi_spacing.dart';
import '../../../../core/ui/fudi_typography.dart';
import '../../../../core/ui/fudi_surface_card.dart';
import '../../../../core/ui/atoms/icons/fudi_icons.dart';
import '../business_providers.dart';
import '../../domain/business_stats.dart';
import '../components/no_business_prompt.dart';
import '../../domain/business_profile.dart';

const _monthNames = [
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

const _monthAbbr = [
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

String _rangeLabel(DashboardPeriod period, DateTimeRange? customRange) {
  final now = DateTime.now();
  switch (period) {
    case DashboardPeriod.week:
      final start = now.subtract(const Duration(days: 6));
      return '${start.day} – ${now.day} ${_monthAbbr[now.month - 1]}';
    case DashboardPeriod.month:
      return '${_monthNames[now.month - 1][0].toUpperCase()}${_monthNames[now.month - 1].substring(1)} ${now.year}';
    case DashboardPeriod.year:
      return '${now.year}';
    case DashboardPeriod.custom:
      if (customRange == null) return 'Selecciona un rango';
      final s = customRange.start;
      final e = customRange.end;
      return '${s.day} ${_monthAbbr[s.month - 1]} – ${e.day} ${_monthAbbr[e.month - 1]} ${e.year}';
  }
}

// ── Pantalla ──────────────────────────────────────────────────────────────────

class BusinessDashboardScreen extends ConsumerWidget {
  const BusinessDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final businessAsync = ref.watch(currentBusinessProvider);
    final allBusinessesAsync = ref.watch(userBusinessesProvider);

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: businessAsync.when(
        data: (business) {
          if (business == null) {
            return const NoBusinessPrompt();
          }

          // Escuchamos los filtros aquí arriba para pasárselos al provider de estadísticas
          final period = ref.watch(selectedPeriodProvider);
          final customRange = ref.watch(customDateRangeProvider);

          // Pasamos los filtros como parámetros para que el fetch se reactive automáticamente.
          // NOTA: Si tu backend o provider requiere una familia de records/clases,
          // asegúrate de que tu businessStatsProvider acepte estos parámetros.
          final statsAsync = ref.watch(businessStatsProvider(business.id));

          return statsAsync.when(
            data: (stats) => RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(businessStatsProvider(business.id));
                ref.invalidate(currentBusinessProvider);
              },
              child: _DashboardContent(
                business: business,
                allBusinesses: allBusinessesAsync.asData?.value ?? [business],
                stats: stats,
                period: period,
                customRange: customRange,
              ),
            ),
            loading: () => const _DashboardSkeleton(),
            error: (e, _) => _DashboardError(
              message: 'No pudimos cargar tus estadísticas',
              onRetry: () => ref.invalidate(businessStatsProvider(business.id)),
            ),
          );
        },
        loading: () => const _DashboardSkeleton(),
        error: (e, _) => _DashboardError(
          message: 'No pudimos identificar tu negocio',
          onRetry: () => ref.invalidate(currentBusinessProvider),
        ),
      ),
    );
  }
}

// ── Contenido principal ────────────────────────────────────────────────────────

class _DashboardContent extends ConsumerWidget {
  const _DashboardContent({
    required this.business,
    required this.allBusinesses,
    required this.stats,
    required this.period,
    required this.customRange,
  });

  final BusinessProfile business;
  final List<BusinessProfile> allBusinesses;
  final BusinessStats stats;
  final DashboardPeriod period;
  final DateTimeRange? customRange;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final themeExt = theme.extension<FudiThemeExtension>();
    final mutedBg = themeExt?.mutedBackground ?? FudiColors.muted;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          elevation: 0,
          backgroundColor: colorScheme.surface,
          leading: Padding(
            padding: const EdgeInsets.all(FudiSpacing.sm),
            child: Semantics(
              label: 'Volver',
              button: true,
              child: InkWell(
                onTap: () => context.pop(),
                borderRadius: BorderRadius.circular(FudiSpacing.md),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: mutedBg,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(FudiIcons.arrowLeft, size: 20),
                ),
              ),
            ),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Estadísticas', style: FudiTypography.h3),
              Text(
                'Análisis de rendimiento',
                style: FudiTypography.bodySmall.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(FudiSpacing.md),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _PeriodSelector(period: period, customRange: customRange),
              const SizedBox(height: FudiSpacing.md),
              _MainKPIs(stats: stats),
              const SizedBox(height: FudiSpacing.md),
              _DailyRevenueChart(dailyStats: stats.dailyStats),
              const SizedBox(height: FudiSpacing.md),
              _TopProducts(products: stats.topProducts),
              const SizedBox(height: FudiSpacing.md),
              _PeriodSummary(stats: stats, period: period),
              const SizedBox(height: 80),
            ]),
          ),
        ),
      ],
    );
  }
}

// ── Selector de período ────────────────────────────────────────────────────────

class _PeriodSelector extends ConsumerWidget {
  const _PeriodSelector({required this.period, required this.customRange});

  final DashboardPeriod period;
  final DateTimeRange? customRange;

  Future<void> _pickCustomRange(BuildContext context, WidgetRef ref) async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 2),
      lastDate: now,
      initialDateRange:
          customRange ??
          DateTimeRange(start: now.subtract(const Duration(days: 6)), end: now),
      helpText: 'Selecciona un rango de fechas',
      cancelText: 'Cancelar',
      confirmText: 'Aplicar',
      saveText: 'Aplicar',
    );
    if (picked != null) {
      ref.read(customDateRangeProvider.notifier).select(picked);
      ref.read(selectedPeriodProvider.notifier).select(DashboardPeriod.custom);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    const options = [
      DashboardPeriod.week,
      DashboardPeriod.month,
      DashboardPeriod.year,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ...options.map((p) {
              final isActive = period == p;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Semantics(
                    label:
                        '${p.label}, ${isActive ? "seleccionado" : "no seleccionado"}',
                    button: true,
                    child: InkWell(
                      onTap: () =>
                          ref.read(selectedPeriodProvider.notifier).select(p),
                      borderRadius: BorderRadius.circular(FudiSpacing.md),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(vertical: 12),
decoration: BoxDecoration(
                            color: isActive ? FudiColors.primary : colorScheme.surface,
                            borderRadius: BorderRadius.circular(FudiSpacing.md),
                            border: Border.all(
                              color: isActive
                                  ? FudiColors.primary
                                  : colorScheme.outlineVariant,
                          ),
                        ),
                        child: Text(
                          p.label,
                          textAlign: TextAlign.center,
                          style: FudiTypography.labelSmall.copyWith(
                            color: isActive
                                ? FudiColors.primaryForeground
                                : colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
            Semantics(
              label: 'Seleccionar rango de fechas personalizado',
              button: true,
              child: InkWell(
                onTap: () => _pickCustomRange(context, ref),
                borderRadius: BorderRadius.circular(FudiSpacing.md),
                child: Container(
                  padding: const EdgeInsets.all(12),
decoration: BoxDecoration(
                        color: period == DashboardPeriod.custom
                            ? FudiColors.primary
                            : colorScheme.surface,
                          borderRadius: BorderRadius.circular(FudiSpacing.md),
                        border: Border.all(
                          color: period == DashboardPeriod.custom
                              ? FudiColors.primary
                              : colorScheme.outlineVariant,
                    ),
                  ),
                  child: Icon(
                    Icons.calendar_month_rounded,
                    size: 18,
                    color: period == DashboardPeriod.custom
                        ? FudiColors.primaryForeground
                        : colorScheme.onSurface,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: FudiSpacing.sm),
        Row(
          children: [
            Icon(
              Icons.schedule_rounded,
              size: 14,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 4),
            Text(
              _rangeLabel(period, customRange),
              style: FudiTypography.bodySmall.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (period == DashboardPeriod.custom) ...[
              const SizedBox(width: 8),
              InkWell(
                onTap: () {
                  ref
                      .read(selectedPeriodProvider.notifier)
                      .select(DashboardPeriod.month);
                  ref.read(customDateRangeProvider.notifier).clear();
                },
                child: Row(
                  children: [
                    const Icon(
                      Icons.close_rounded,
                      size: 14,
                      color: FudiColors.primary,
                    ),
                    Text(
                      ' Quitar filtro',
                      style: FudiTypography.bodySmall.copyWith(
                        color: FudiColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

// ── KPIs principales ────────────────────────────────────────────────────────────

class _MainKPIs extends StatelessWidget {
  const _MainKPIs({required this.stats});

  final BusinessStats stats;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: FudiSpacing.md,
      mainAxisSpacing: FudiSpacing.md,
      childAspectRatio: 1.5,
      children: [
        _KPIWidget(
          label: 'Ingresos',
          value: '\$${stats.revenue.toStringAsFixed(0)}',
          change: stats.revenueChange,
          icon: Icons.account_balance_wallet_rounded,
          color: FudiColors.success,
        ),
        _KPIWidget(
          label: 'Pedidos',
          value: stats.ordersCount.toString(),
          change: stats.ordersChange,
          icon: FudiIcons.shoppingBag,
          color: FudiColors.primary,
        ),
        _KPIWidget(
          label: 'Rescatadas',
          value: stats.rescuedCount.toString(),
          change: stats.rescuedChange,
          icon: FudiIcons.package_,
          color: FudiColors.warning,
        ),
        _KPIWidget(
          label: 'Rating',
          value: stats.avgRating.toStringAsFixed(1),
          change: stats.ratingChange,
          icon: FudiIcons.star,
          color: FudiColors.info,
        ),
      ],
    );
  }
}

class _KPIWidget extends StatelessWidget {
  const _KPIWidget({
    required this.label,
    required this.value,
    required this.change,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final double change;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isPositive = change >= 0;
    final trendColor = isPositive ? FudiColors.success : FudiColors.destructive;

    return FudiSurfaceCard(
      padding: const EdgeInsets.all(FudiSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: FudiTypography.bodySmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Text(
            value,
            style: FudiTypography.h3.copyWith(color: color),
            overflow: TextOverflow.ellipsis,
          ),
          Row(
            children: [
              Icon(
                isPositive ? Icons.trending_up : Icons.trending_down,
                size: 14,
                color: trendColor,
              ),
              const SizedBox(width: 4),
              Text(
                '${isPositive ? '+' : ''}${change.toStringAsFixed(1)}%',
                style: FudiTypography.bodySmall.copyWith(
                  color: trendColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  'vs anterior',
                  style: FudiTypography.bodySmall.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Gráfico de ventas diarias ───────────────────────────────────────────────────

class _DailyRevenueChart extends StatelessWidget {
  const _DailyRevenueChart({required this.dailyStats});

  final List<DailyStat> dailyStats;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final themeExt = Theme.of(context).extension<FudiThemeExtension>();
    final mutedBg = themeExt?.mutedBackground ?? FudiColors.muted;
    if (dailyStats.isEmpty) {
      return FudiSurfaceCard(
        child: Column(
          children: [
            Icon(
              Icons.bar_chart_rounded,
              size: 40,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: FudiSpacing.sm),
            Text(
              'Sin datos de ventas en este período',
              style: FudiTypography.bodySmall.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    final maxRevenue = dailyStats.fold<double>(
      0,
      (max, stat) => stat.revenue > max ? stat.revenue : max,
    );

    return FudiSurfaceCard(
      padding: const EdgeInsets.all(FudiSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.calendar_today_rounded,
                size: 20,
                color: FudiColors.primary,
              ),
              SizedBox(width: 8),
              Text('Ventas diarias', style: FudiTypography.h4),
            ],
          ),
          const SizedBox(height: FudiSpacing.md),
          ...dailyStats.map(
            (stat) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        stat.day,
                        style: FudiTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            '\$${stat.revenue.toStringAsFixed(0)}',
                            style: FudiTypography.bodyMedium.copyWith(
                              color: FudiColors.success,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '(${stat.orders} pedidos)',
                            style: FudiTypography.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeOutCubic,
                      tween: Tween(
                        begin: 0,
                        end: maxRevenue > 0 ? stat.revenue / maxRevenue : 0,
                      ),
                      builder: (context, value, _) => LinearProgressIndicator(
                        value: value,
                        backgroundColor: mutedBg,
                        valueColor: const AlwaysStoppedAnimation(
                          FudiColors.primary,
                        ),
                        minHeight: 8,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Productos más vendidos ──────────────────────────────────────────────────────

class _TopProducts extends StatelessWidget {
  const _TopProducts({required this.products});

  final List<TopProductStat> products;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return FudiSurfaceCard(
      padding: const EdgeInsets.all(FudiSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Productos más vendidos', style: FudiTypography.h4),
          const SizedBox(height: FudiSpacing.md),
          if (products.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: FudiSpacing.md),
              child: Column(
                children: [
                  Icon(
                    FudiIcons.package_,
                    size: 32,
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: FudiSpacing.xs),
                  Text(
                    'Aún no hay ventas en este período',
                    style: FudiTypography.bodySmall.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            )
          else
            ...products.asMap().entries.map((entry) {
              final index = entry.key;
              final product = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: FudiSpacing.sm),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: FudiColors.primary.withValues(
                        alpha: 0.1,
                      ),
                      child: Text(
                        '${index + 1}',
                        style: FudiTypography.bodySmall.copyWith(
                          color: FudiColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            style: FudiTypography.bodyMedium.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${product.sold} unidades vendidas',
                            style: FudiTypography.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '\$${product.revenue.toStringAsFixed(0)}',
                      style: FudiTypography.bodyMedium.copyWith(
                        color: FudiColors.success,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}

// ── Resumen del período ─────────────────────────────────────────────────────────

class _PeriodSummary extends StatelessWidget {
  const _PeriodSummary({required this.stats, required this.period});

  final BusinessStats stats;
  final DashboardPeriod period;

  @override
  Widget build(BuildContext context) {
    final days = period.approxDays;
    final dailyAvg = stats.revenue > 0
        ? (stats.revenue / days).toStringAsFixed(2)
        : '0.00';
    final ticketAvg = stats.ordersCount > 0
        ? (stats.revenue / stats.ordersCount).toStringAsFixed(2)
        : '0.00';

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(FudiSpacing.lg),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            FudiColors.primary,
            FudiColors.primary.withValues(alpha: 0.8),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: FudiColors.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(FudiSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resumen del período',
              style: FudiTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: FudiColors.primaryForeground,
              ),
            ),
            const SizedBox(height: FudiSpacing.sm),
            Text(
              'Tus ventas han ${stats.revenueChange >= 0 ? 'crecido' : 'decaído'} un ${stats.revenueChange.abs().toStringAsFixed(1)}% comparado con el período anterior. Has rescatado ${stats.rescuedCount} comidas, evitando el desperdicio de alimentos.',
              style: FudiTypography.bodySmall.copyWith(
                color: FudiColors.primaryForeground.withValues(alpha: 0.9),
              ),
            ),
            const SizedBox(height: FudiSpacing.md),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Promedio diario',
                        style: FudiTypography.bodySmall.copyWith(
                          color: FudiColors.primaryForeground.withValues(alpha: 0.75),
                        ),
                      ),
                      Text(
                        '\$$dailyAvg',
                        style: FudiTypography.h2.copyWith(
                          color: FudiColors.primaryForeground,
                          fontWeight: FontWeight.bold,
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
                        'Ticket promedio',
                        style: FudiTypography.bodySmall.copyWith(
                          color: FudiColors.primaryForeground.withValues(alpha: 0.75),
                        ),
                      ),
                      Text(
                        '\$$ticketAvg',
                        style: FudiTypography.h2.copyWith(
                          color: FudiColors.primaryForeground,
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
      ),
    );
  }
}

// ── Skeleton de carga ────────────────────────────────────────────────────────────

class _DashboardSkeleton extends StatelessWidget {
  const _DashboardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: FudiColors.muted,
      highlightColor: FudiColors.surfaceBackground,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(FudiSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 48),
            Container(
              height: 44,
              decoration: BoxDecoration(
                color: FudiColors.muted,
                borderRadius: BorderRadius.circular(FudiSpacing.md),
              ),
            ),
            const SizedBox(height: FudiSpacing.md),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: FudiSpacing.md,
              mainAxisSpacing: FudiSpacing.md,
              childAspectRatio: 1.5,
              children: List.generate(
                4,
                (_) => Container(
                  decoration: BoxDecoration(
                    color: FudiColors.muted,
                    borderRadius: BorderRadius.circular(FudiSpacing.lg),
                  ),
                ),
              ),
            ),
            const SizedBox(height: FudiSpacing.md),
            Container(
              height: 220,
              decoration: BoxDecoration(
                color: FudiColors.muted,
                borderRadius: BorderRadius.circular(FudiSpacing.lg),
              ),
            ),
            const SizedBox(height: FudiSpacing.md),
            Container(
              height: 160,
              decoration: BoxDecoration(
                color: FudiColors.muted,
                borderRadius: BorderRadius.circular(FudiSpacing.lg),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Estado de error ──────────────────────────────────────────────────────────────

class _DashboardError extends StatelessWidget {
  const _DashboardError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(FudiSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              FudiIcons.alertTriangle,
              size: 56,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: FudiSpacing.md),
            Text(
              message,
              textAlign: TextAlign.center,
              style: FudiTypography.bodyMedium.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: FudiSpacing.lg),
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reintentar'),
              style: TextButton.styleFrom(foregroundColor: FudiColors.primary),
            ),
          ],
        ),
      ),
    );
  }
}
