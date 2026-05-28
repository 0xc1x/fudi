import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/ui/fudi_colors.dart';
import '../../../../core/ui/fudi_spacing.dart';
import '../../../../core/ui/fudi_typography.dart';
import '../../../../core/ui/fudi_surface_card.dart';
import '../../../../core/ui/atoms/icons/fudi_icons.dart';
import '../business_providers.dart';
import '../../domain/business_stats.dart';
import '../components/no_business_prompt.dart';
import '../../domain/business_profile.dart';

class BusinessDashboardScreen extends ConsumerWidget {
  const BusinessDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final businessAsync = ref.watch(currentBusinessProvider);
    final allBusinessesAsync = ref.watch(userBusinessesProvider);

    return Scaffold(
      backgroundColor: FudiColors.background,
      body: businessAsync.when(
        data: (business) {
          if (business == null) {
            return const NoBusinessPrompt();
          }
          final statsAsync = ref.watch(businessStatsProvider(business.id));

          return statsAsync.when(
            data: (stats) => _DashboardContent(
              business: business,
              allBusinesses: allBusinessesAsync.asData?.value ?? [business],
              stats: stats,
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) =>
                Center(child: Text('Error al cargar estadísticas: $e')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) =>
            Center(child: Text('Error al identificar negocio: $e')),
      ),
    );
  }
}

class _DashboardContent extends ConsumerWidget {
  const _DashboardContent({
    required this.business,
    required this.allBusinesses,
    required this.stats,
  });

  final BusinessProfile business;
  final List<BusinessProfile> allBusinesses;
  final BusinessStats stats;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          elevation: 0,
          backgroundColor: FudiColors.background,
          leading: Padding(
            padding: const EdgeInsets.all(FudiSpacing.sm),
            child: InkWell(
              onTap: () => context.pop(),
              borderRadius: BorderRadius.circular(FudiRadius.full),
              child: Container(
                decoration: BoxDecoration(
                  color: FudiColors.muted,
                  shape: BoxShape.circle,
                ),
                child: const Icon(FudiIcons.arrowLeft, size: 20),
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
                  color: FudiColors.mutedForeground,
                ),
              ),
            ],
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(FudiSpacing.md),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _PeriodSelector(),
              const SizedBox(height: FudiSpacing.md),
              _MainKPIs(stats: stats),
              const SizedBox(height: FudiSpacing.md),
              _DailyRevenueChart(dailyStats: stats.dailyStats),
              const SizedBox(height: FudiSpacing.md),
              _TopProducts(products: stats.topProducts),
              const SizedBox(height: FudiSpacing.md),
              _PeriodSummary(stats: stats),
              const SizedBox(height: 80),
            ]),
          ),
        ),
      ],
    );
  }
}

class _PeriodSelector extends StatefulWidget {
  @override
  State<_PeriodSelector> createState() => _PeriodSelectorState();
}

class _PeriodSelectorState extends State<_PeriodSelector> {
  String selected = 'Mes';

  @override
  Widget build(BuildContext context) {
    final periods = ['Semana', 'Mes', 'Año'];
    return Row(
      children: periods.map((p) {
        final isActive = selected == p;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: InkWell(
              onTap: () => setState(() => selected = p),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isActive ? FudiColors.primary : Colors.white,
                  borderRadius: BorderRadius.circular(FudiSpacing.md),
                  border: Border.all(
                    color: isActive ? FudiColors.primary : FudiColors.border,
                  ),
                ),
                child: Text(
                  p,
                  textAlign: TextAlign.center,
                  style: FudiTypography.labelSmall.copyWith(
                    color: isActive ? Colors.white : FudiColors.foreground,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

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
          color: Colors.green,
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
          color: Colors.orange,
        ),
        _KPIWidget(
          label: 'Rating',
          value: stats.avgRating.toStringAsFixed(1),
          change: stats.ratingChange,
          icon: FudiIcons.star,
          color: Colors.blue,
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
    final isPositive = change >= 0;
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
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 8),
              Text(label, style: FudiTypography.bodySmall),
            ],
          ),
          Text(value, style: FudiTypography.h3.copyWith(color: color)),
      Row(
        children: [
          Icon(
            isPositive ? Icons.trending_up : Icons.trending_down,
            size: 14,
            color: isPositive ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 4),
          Text(
            '${isPositive ? '+' : ''}${change.toStringAsFixed(1)}%',
            style: FudiTypography.bodySmall.copyWith(
              color: isPositive ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            'vs anterior',
            style: FudiTypography.bodySmall.copyWith(
              color: FudiColors.mutedForeground,
            ),
          ),
        ],
      ),
        ],
      ),
    );
  }
}

class _DailyRevenueChart extends StatelessWidget {
  const _DailyRevenueChart({required this.dailyStats});

  final List<DailyStat> dailyStats;

  @override
  Widget build(BuildContext context) {
    if (dailyStats.isEmpty) return const SizedBox.shrink();

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
                              color: Colors.green,
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
                    child: LinearProgressIndicator(
                      value: maxRevenue > 0 ? stat.revenue / maxRevenue : 0,
                      backgroundColor: FudiColors.muted,
                      valueColor: const AlwaysStoppedAnimation(
                        FudiColors.primary,
                      ),
                      minHeight: 8,
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

class _TopProducts extends StatelessWidget {
  const _TopProducts({required this.products});

  final List<TopProductStat> products;

  @override
  Widget build(BuildContext context) {
    return FudiSurfaceCard(
      padding: const EdgeInsets.all(FudiSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Productos más vendidos', style: FudiTypography.h4),
          const SizedBox(height: FudiSpacing.md),
          if (products.isEmpty)
            const Center(
              child: Text('Aún no hay ventas', style: FudiTypography.bodySmall),
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
                          ),
                          Text(
                            '${product.sold} unidades vendidas',
                            style: FudiTypography.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    Text(
              '\$${product.revenue.toStringAsFixed(0)}',
              style: FudiTypography.bodyMedium.copyWith(
                color: Colors.green,
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

class _PeriodSummary extends StatelessWidget {
  const _PeriodSummary({required this.stats});

  final BusinessStats stats;

  @override
  Widget build(BuildContext context) {
    final dailyAvg = stats.revenue > 0 ? (stats.revenue / 30).toStringAsFixed(2) : '0.00';
    final ticketAvg = stats.ordersCount > 0
        ? (stats.revenue / stats.ordersCount).toStringAsFixed(2)
        : '0.00';

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(FudiRadius.xl),
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
                color: Colors.white,
              ),
            ),
            const SizedBox(height: FudiSpacing.sm),
            Text(
              'Tus ventas han ${stats.revenueChange >= 0 ? 'crecido' : 'decaído'} un ${stats.revenueChange.abs().toStringAsFixed(1)}% comparado con el período anterior. Has rescatado ${stats.rescuedCount} comidas, evitando el desperdicio de alimentos.',
              style: FudiTypography.bodySmall.copyWith(
                color: Colors.white.withValues(alpha: 0.9),
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
                          color: Colors.white.withValues(alpha: 0.75),
                        ),
                      ),
                      Text(
                        '\$$dailyAvg',
                        style: FudiTypography.h2.copyWith(
                          color: Colors.white,
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
                          color: Colors.white.withValues(alpha: 0.75),
                        ),
                      ),
                      Text(
                        '\$$ticketAvg',
                        style: FudiTypography.h2.copyWith(
                          color: Colors.white,
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
