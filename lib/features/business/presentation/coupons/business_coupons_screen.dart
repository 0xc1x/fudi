import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/route_names.dart';
import '../../../../core/ui/fudi_colors.dart';
import '../../../../core/ui/fudi_theme.dart';
import '../../../../core/ui/fudi_pressable_scale.dart';
import '../../../../core/ui/atoms/icons/fudi_icons.dart';
import '../../../../core/ui/fudi_spacing.dart';
import '../../../../core/ui/fudi_typography.dart';
import '../../../../core/ui/atoms/fudi_stat_card.dart';
import '../../../orders/domain/coupon.dart';
import '../../../../core/ui/fudi_tips_card.dart';
import '../business_providers.dart';
import '../components/no_business_prompt.dart';
import 'coupon_components.dart';

class BusinessCouponsScreen extends ConsumerWidget {
  const BusinessCouponsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final themeExt = theme.extension<FudiThemeExtension>();
    final businessAsync = ref.watch(currentBusinessProvider);

    return Scaffold(
      backgroundColor: (themeExt?.mutedBackground ?? FudiColors.muted).withValues(alpha: 0.4),
      appBar: _AppBar(
        onCreate: () => context.push(RouteNames.businessCouponCreatePath),
      ),
      body: businessAsync.when(
        data: (business) {
          if (business == null) return const NoBusinessPrompt();
          final couponsAsync = ref.watch(businessCouponsProvider(business.id));
          return couponsAsync.when(
            data: (coupons) => RefreshIndicator(
              color: FudiColors.primary,
              backgroundColor: Theme.of(context).colorScheme.surface,
              onRefresh: () async {
                ref.invalidate(businessCouponsProvider(business.id));
              },
              child: _Content(coupons: coupons, businessId: business.id),
            ),
            loading: () => const CouponsLoadingSkeleton(),
            error: (e, _) => BusinessCouponErrorState(
              message: 'No pudimos cargar tus cupones de promoción.',
              onRetry: () =>
                  ref.invalidate(businessCouponsProvider(business.id)),
            ),
          );
        },
        loading: () => const CouponsLoadingSkeleton(),
        error: (e, _) => BusinessCouponErrorState(
          message: 'No pudimos verificar la identidad de tu negocio.',
          onRetry: () => ref.invalidate(currentBusinessProvider),
        ),
      ),
    );
  }
}

// ─── AppBar ──────────────────────────────────────────────────────────

class _AppBar extends StatelessWidget implements PreferredSizeWidget {
  const _AppBar({required this.onCreate});
  final VoidCallback onCreate;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 8);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppBar(
      backgroundColor: colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      leadingWidth: 56,
      leading: const BusinessCouponBackButton(),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Cupones',
            style: FudiTypography.h3.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 1),
          Text(
            'Gestiona tus ofertas y códigos',
            style: FudiTypography.bodySmall.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: FudiSpacing.xl),
          child: Center(
            child: Semantics(
              label: 'Crear nuevo cupón',
              button: true,
              child: FudiPressableScale(
                onTap: onCreate,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: FudiSpacing.lg,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.onSurface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(FudiIcons.plus, size: 14, color: FudiColors.primaryForeground),
                      const SizedBox(width: FudiSpacing.xs),
                      Text(
                        'Nuevo',
                        style: FudiTypography.bodyMedium.copyWith(
                          color: FudiColors.primaryForeground,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Content ─────────────────────────────────────────────────────────

class _Content extends StatelessWidget {
  const _Content({required this.coupons, required this.businessId});
  final List<Coupon> coupons;
  final String businessId;

  @override
  Widget build(BuildContext context) {
    final activeCount = coupons.where((c) => c.isValid).length;
    final totalUses = coupons.fold<int>(0, (s, c) => s + c.usedCount);

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(
        horizontal: FudiSpacing.xl,
        vertical: FudiSpacing.lg,
      ),
      children: [
        Row(
          children: [
            Expanded(
              child: FudiStatCard(
                label: 'Activos',
                value: '$activeCount',
                valueColor: FudiColors.successDark,
                backgroundColor: Theme.of(context).colorScheme.surface,
              ),
            ),
            const SizedBox(width: FudiSpacing.sm),
            Expanded(
              child: FudiStatCard(
                label: 'Usos Totales',
                value: '$totalUses',
                valueColor: FudiColors.primary,
                backgroundColor: Theme.of(context).colorScheme.surface,
              ),
            ),
            const SizedBox(width: FudiSpacing.sm),
            Expanded(
              child: FudiStatCard(
                label: 'Creados',
                value: '${coupons.length}',
                valueColor: FudiColors.foreground,
                backgroundColor: Theme.of(context).colorScheme.surface,
              ),
            ),
          ],
        ),
        const SizedBox(height: FudiSpacing.xl),

        if (coupons.isEmpty)
          EmptyCouponsView(
            onCreate: () => context.push(RouteNames.businessCouponCreatePath),
          )
        else ...[
          Text(
            'Historial de promociones',
            style: FudiTypography.labelSmall.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: FudiSpacing.md),
          ...coupons.map((c) => CouponCard(coupon: c)),
        ],

        const SizedBox(height: FudiSpacing.lg),
        const FudiTipsCard(
          title: 'Optimiza tus campañas',
          tips: [
            'Crea códigos cortos y directos (ej. "PROMOFUDI").',
            'Configura un monto mínimo de compra para proteger tu margen neto.',
            'Establece un límite de usos máximos para controlar presupuestos diarios.',
            'Monitorea el rendimiento de tus cupones activos desde esta sección.',
          ],
        ),
      ],
    );
  }
}
