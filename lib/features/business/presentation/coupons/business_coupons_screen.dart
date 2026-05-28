import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/route_names.dart';
import '../../../../core/ui/fudi_colors.dart';
import '../../../../core/ui/atoms/icons/fudi_icons.dart';
import '../../../../core/ui/fudi_spacing.dart';
import '../../../../core/ui/fudi_surface_card.dart';
import '../../../../core/ui/fudi_typography.dart';
import '../../../orders/domain/coupon.dart';
import '../business_providers.dart';
import '../components/no_business_prompt.dart';

class BusinessCouponsScreen extends ConsumerWidget {
  const BusinessCouponsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final businessAsync = ref.watch(currentBusinessProvider);
    return Scaffold(
      backgroundColor: FudiColors.muted,
      appBar: _AppBar(onCreate: () => context.push(RouteNames.businessCouponCreatePath)),
      body: businessAsync.when(
        data: (business) {
          if (business == null) return const NoBusinessPrompt();
          final couponsAsync = ref.watch(businessCouponsProvider(business.id));
          return couponsAsync.when(
            data: (coupons) => _Content(coupons: coupons),
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

class _AppBar extends StatelessWidget implements PreferredSizeWidget {
  const _AppBar({required this.onCreate});
  final VoidCallback onCreate;

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
          Text('Cupones de descuento', style: FudiTypography.h4),
          Text('Gestiona tus promociones', style: FudiTypography.bodySmall),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: FudiSpacing.lg),
          child: FilledButton(
            onPressed: onCreate,
            style: FilledButton.styleFrom(
              backgroundColor: FudiColors.primary,
              foregroundColor: FudiColors.primaryForeground,
              padding: const EdgeInsets.symmetric(
                horizontal: FudiSpacing.lg,
                vertical: FudiSpacing.sm,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(FudiRadius.md),
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(FudiIcons.plus, size: 16),
                SizedBox(width: FudiSpacing.xs),
                Text('Crear', style: TextStyle(fontWeight: FontWeight.w500)),
              ],
            ),
          ),
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

class _Content extends StatelessWidget {
  const _Content({required this.coupons});
  final List<Coupon> coupons;

  @override
  Widget build(BuildContext context) {
    final activeCount = coupons.where((c) => c.isValid).length;
    final totalUses = coupons.fold<int>(0, (s, c) => s + c.usedCount);

    return ListView(
      padding: const EdgeInsets.all(FudiSpacing.lg),
      children: [
        Row(
          children: [
            Expanded(child: _StatCard(label: 'Activos', value: '$activeCount', color: FudiColors.primary)),
            const SizedBox(width: FudiSpacing.md),
            Expanded(child: _StatCard(label: 'Usos totales', value: '$totalUses', color: const Color(0xFF16A34A))),
            const SizedBox(width: FudiSpacing.md),
            Expanded(child: _StatCard(label: 'Total', value: '${coupons.length}', color: const Color(0xFFEA580C))),
          ],
        ),
        const SizedBox(height: FudiSpacing.lg),
        if (coupons.isEmpty)
          _EmptyCoupons(onCreate: () => context.push(RouteNames.businessCouponCreatePath))
        else
          ...coupons.map((c) => _CouponCard(coupon: c)),
        const SizedBox(height: FudiSpacing.lg),
        _TipsCard(),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(FudiSpacing.md),
      decoration: BoxDecoration(
        color: FudiColors.background,
        borderRadius: BorderRadius.circular(FudiRadius.xl),
        border: Border.all(color: FudiColors.borderSolid),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: FudiTypography.h2.copyWith(color: color),
          ),
          const SizedBox(height: FudiSpacing.xs),
          Text(label, style: FudiTypography.bodySmall),
        ],
      ),
    );
  }
}

class _CouponCard extends ConsumerWidget {
  const _CouponCard({required this.coupon});
  final Coupon coupon;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(bottom: FudiSpacing.md),
      child: FudiSurfaceCard(
        padding: const EdgeInsets.all(FudiSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _CouponHeader(coupon: coupon)),
                _CouponMenu(coupon: coupon),
              ],
            ),
            const SizedBox(height: FudiSpacing.md),
            _CouponDetails(coupon: coupon),
          ],
        ),
      ),
    );
  }
}

class _CouponHeader extends StatelessWidget {
  const _CouponHeader({required this.coupon});
  final Coupon coupon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: FudiSpacing.md,
                vertical: FudiSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: FudiColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(FudiRadius.md),
              ),
              child: Text(
                coupon.code,
                style: FudiTypography.h3.copyWith(
                  color: FudiColors.primary,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            const SizedBox(width: FudiSpacing.sm),
            _StatusBadge(coupon: coupon),
          ],
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.coupon});
  final Coupon coupon;

  @override
  Widget build(BuildContext context) {
    final (label, bg, fg) = _badgeConfig(coupon);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: FudiSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(FudiRadius.full),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: fg,
        ),
      ),
    );
  }

  (String, Color, Color) _badgeConfig(Coupon c) {
    if (c.isValid) return ('Activo', const Color(0xFFDCFCE7), const Color(0xFF15803D));
    if (c.isExpired) return ('Expirado', const Color(0xFFFEE2E2), FudiColors.destructive);
    if (c.isExhausted) return ('Límite alcanzado', const Color(0xFFFFEDD5), const Color(0xFFC2410C));
    return ('Inactivo', FudiColors.muted, FudiColors.mutedForeground);
  }
}

class _CouponDetails extends StatelessWidget {
  const _CouponDetails({required this.coupon});
  final Coupon coupon;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 4,
      mainAxisSpacing: FudiSpacing.sm,
      children: [
        _DetailRow(
          icon: coupon.type == 'percentage' ? Icons.percent_rounded : Icons.attach_money_rounded,
          text: coupon.type == 'percentage'
              ? '${coupon.value.toStringAsFixed(0)}% descuento'
              : '\$${coupon.value.toStringAsFixed(2)} descuento',
        ),
        if (coupon.minOrderAmount > 0)
          _DetailRow(
            icon: FudiIcons.tag,
            text: 'Mín. \$${coupon.minOrderAmount.toStringAsFixed(0)}',
          )
        else
          const SizedBox.shrink(),
        _DetailRow(
          icon: Icons.calendar_today,
          text: coupon.expiresAt != null ? _formatDate(coupon.expiresAt!) : 'Sin expiración',
        ),
        _DetailRow(
          icon: Icons.group_rounded,
          text: '${coupon.usedCount}${coupon.maxUses != null ? ' / ${coupon.maxUses}' : ''} usos',
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      '', 'ene', 'feb', 'mar', 'abr', 'may', 'jun',
      'jul', 'ago', 'sep', 'oct', 'nov', 'dic',
    ];
    return '${date.day} ${months[date.month]} ${date.year}';
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: FudiColors.primary),
        const SizedBox(width: FudiSpacing.xs),
        Expanded(
          child: Text(text, style: FudiTypography.bodySmall, overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }
}

class _CouponMenu extends ConsumerWidget {
  const _CouponMenu({required this.coupon});
  final Coupon coupon;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<String>(
      onSelected: (value) async {
        switch (value) {
          case 'copy':
            await Clipboard.setData(ClipboardData(text: coupon.code));
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Código "${coupon.code}" copiado'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          case 'edit':
            if (context.mounted) {
              context.push('/business/coupons/edit/${coupon.id}');
            }
          case 'toggle':
            await ref
                .read(businessCouponRepositoryProvider)
                .toggleCouponStatus(coupon.id, !coupon.isActive);
            ref.invalidate(businessCouponsProvider(coupon.businessId));
          case 'delete':
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Eliminar cupón'),
                content: Text('¿Estás seguro de que deseas eliminar el cupón "${coupon.code}"?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(false),
                    child: const Text('Cancelar'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(true),
                    style: TextButton.styleFrom(foregroundColor: FudiColors.destructive),
                    child: const Text('Eliminar'),
                  ),
                ],
              ),
            );
            if (confirmed == true) {
              await ref
                  .read(businessCouponRepositoryProvider)
                  .deleteCoupon(coupon.id);
              ref.invalidate(businessCouponsProvider(coupon.businessId));
            }
        }
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(FudiRadius.lg)),
      itemBuilder: (_) => [
        PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit_rounded, size: 18, color: FudiColors.primary),
              const SizedBox(width: FudiSpacing.sm),
              const Text('Editar'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'copy',
          child: Row(
            children: [
              Icon(Icons.copy_rounded, size: 18, color: FudiColors.primary),
              const SizedBox(width: FudiSpacing.sm),
              const Text('Copiar código'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'toggle',
          child: Row(
            children: [
              Icon(
                coupon.isActive ? Icons.pause_circle_outline_rounded : Icons.play_circle_outline_rounded,
                size: 18,
                color: FudiColors.primary,
              ),
              const SizedBox(width: FudiSpacing.sm),
              Text(coupon.isActive ? 'Desactivar' : 'Activar'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete_outline_rounded, size: 18, color: FudiColors.destructive),
              const SizedBox(width: FudiSpacing.sm),
              Text('Eliminar', style: TextStyle(color: FudiColors.destructive)),
            ],
          ),
        ),
      ],
    );
  }
}

class _EmptyCoupons extends StatelessWidget {
  const _EmptyCoupons({required this.onCreate});
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return FudiSurfaceCard(
      padding: const EdgeInsets.symmetric(
        vertical: FudiSpacing.xxl * 2,
        horizontal: FudiSpacing.xl,
      ),
      child: Column(
        children: [
          Icon(FudiIcons.tag, size: 48, color: FudiColors.mutedForeground),
          const SizedBox(height: FudiSpacing.md),
          Text('No hay cupones creados', style: FudiTypography.bodyMedium.copyWith(color: FudiColors.mutedForeground)),
          const SizedBox(height: FudiSpacing.lg),
          FilledButton(
            onPressed: onCreate,
            style: FilledButton.styleFrom(
              backgroundColor: FudiColors.primary,
              foregroundColor: FudiColors.primaryForeground,
              padding: const EdgeInsets.symmetric(
                horizontal: FudiSpacing.xl,
                vertical: FudiSpacing.md,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(FudiRadius.xl),
              ),
            ),
            child: const Text('Crear primer cupón'),
          ),
        ],
      ),
    );
  }
}

class _TipsCard extends StatelessWidget {
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
            'Consejos para cupones',
            style: FudiTypography.labelSmall.copyWith(
              color: const Color(0xFF1E3A5F),
            ),
          ),
          const SizedBox(height: FudiSpacing.sm),
          _tip('Usa códigos memorables y fáciles de compartir'),
          _tip('Define límites de uso para controlar el presupuesto'),
          _tip('Establece compras mínimas para mantener rentabilidad'),
          _tip('Revisa regularmente los cupones expirados'),
        ],
      ),
    );
  }

  Widget _tip(String text) {
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
