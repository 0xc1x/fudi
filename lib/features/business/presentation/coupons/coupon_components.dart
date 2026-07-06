import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/ui/atoms/fudi_status_badge.dart';
import '../../../../core/ui/fudi_colors.dart';
import '../../../../core/ui/fudi_pressable_scale.dart';
import '../../../../core/ui/atoms/icons/fudi_icons.dart';
import '../../../../core/ui/fudi_spacing.dart';
import '../../../../core/ui/fudi_surface_card.dart';
import '../../../../core/ui/fudi_typography.dart';
import '../../../orders/domain/coupon.dart';
import '../business_providers.dart';

// ─── Shared AppBar Back Button ───────────────────────────────────────

class BusinessCouponBackButton extends StatelessWidget {
  const BusinessCouponBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: FudiSpacing.md),
      child: Center(
        child: Semantics(
          label: 'Volver atrás',
          button: true,
          child: FudiPressableScale(
            onTap: () => context.pop(),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: FudiColors.inputBackground.withValues(alpha: 0.7),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                FudiIcons.chevronLeft,
                size: 18,
                color: FudiColors.foreground,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Shared Error State ──────────────────────────────────────────────

class BusinessCouponErrorState extends StatelessWidget {
  const BusinessCouponErrorState({
    required this.message,
    required this.onRetry,
    super.key,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(FudiSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              FudiIcons.alertTriangle,
              size: 48,
              color: FudiColors.destructive,
            ),
            const SizedBox(height: FudiSpacing.md),
            Text(
              message,
              textAlign: TextAlign.center,
              style: FudiTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: FudiSpacing.lg),
            FudiPressableScale(
              onTap: onRetry,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: FudiColors.borderSolid),
                  borderRadius: BorderRadius.circular(FudiRadius.md),
                  color: Theme.of(context).colorScheme.surface,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.refresh_rounded, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      'Reintentar',
                      style: FudiTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Shared Input Decoration ─────────────────────────────────────────

InputDecoration couponInputDecoration({required String hint, Widget? prefix}) {
  return InputDecoration(
    hintText: hint,
    hintStyle: FudiTypography.bodyMedium.copyWith(
      color: FudiColors.mutedForeground.withValues(alpha: 0.6),
    ),
    prefixIcon: prefix,
    prefixIconConstraints: const BoxConstraints(),
    counterText: '',
    filled: true,
    fillColor: FudiColors.inputBackground.withValues(alpha: 0.5),
    contentPadding: const EdgeInsets.symmetric(
      horizontal: FudiSpacing.lg,
      vertical: 12,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(FudiRadius.md),
      borderSide: const BorderSide(color: FudiColors.borderSolid),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(FudiRadius.md),
      borderSide: const BorderSide(color: FudiColors.borderSolid),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(FudiRadius.md),
      borderSide: const BorderSide(color: FudiColors.foreground, width: 1.2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(FudiRadius.md),
      borderSide: const BorderSide(color: FudiColors.destructive),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(FudiRadius.md),
      borderSide: const BorderSide(color: FudiColors.destructive, width: 1.5),
    ),
    errorStyle: FudiTypography.bodySmall.copyWith(
      color: FudiColors.destructive,
      fontSize: 11,
    ),
  );
}

// ─── Date Formatters ─────────────────────────────────────────────────

String formatShortDate(DateTime date) {
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
  return '${date.day} ${months[date.month]} ${date.year}';
}

String formatLongDate(DateTime date) {
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

// ─── Coupon Card ─────────────────────────────────────────────────────

class CouponCard extends StatelessWidget {
  const CouponCard({required this.coupon, super.key});

  final Coupon coupon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: FudiSpacing.sm),
      child: FudiSurfaceCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: _CouponHeader(coupon: coupon)),
                _CouponMenu(coupon: coupon),
              ],
            ),
            const SizedBox(height: FudiSpacing.md),
            const Divider(color: FudiColors.borderSolid, height: 1),
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
    return Wrap(
      spacing: FudiSpacing.sm,
      runSpacing: FudiSpacing.xs,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: FudiColors.primary.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(FudiRadius.sm),
            border: Border.all(
              color: FudiColors.primary.withValues(alpha: 0.15),
            ),
          ),
          child: Text(
            coupon.code,
            style: FudiTypography.bodyMedium.copyWith(
              color: FudiColors.primary,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
            ),
          ),
        ),
        _CouponStatusBadge(coupon: coupon),
      ],
    );
  }
}

(String, Color) couponBadgeConfig(Coupon c) {
  if (!c.isActive) return ('Pausado', FudiColors.mutedForeground);
  if (c.isValid) return ('Activo', FudiColors.successDark);
  if (c.isExpired) return ('Expirado', FudiColors.destructive);
  if (c.isExhausted) return ('Agotado', FudiColors.warningOrange);
  return ('Inactivo', FudiColors.mutedForeground);
}

class _CouponStatusBadge extends StatelessWidget {
  const _CouponStatusBadge({required this.coupon});
  final Coupon coupon;

  @override
  Widget build(BuildContext context) {
    final (label, color) = couponBadgeConfig(coupon);
    return FudiStatusBadge(
      label: label,
      color: color,
      backgroundColor: color.withValues(alpha: 0.08),
      size: FudiStatusBadgeSize.sm,
    );
  }
}

class _CouponDetails extends StatelessWidget {
  const _CouponDetails({required this.coupon});
  final Coupon coupon;

  @override
  Widget build(BuildContext context) {
    final isPercentage = coupon.type == 'percentage';

    return Wrap(
      spacing: FudiSpacing.lg,
      runSpacing: FudiSpacing.sm,
      children: [
        _DetailItem(
          icon: isPercentage
              ? Icons.percent_rounded
              : Icons.confirmation_number_outlined,
          title: 'Beneficio',
          value: isPercentage
              ? '${coupon.value.toStringAsFixed(0)}% OFF'
              : '\$${coupon.value.toStringAsFixed(2)} Desc.',
        ),
        _DetailItem(
          icon: Icons.calendar_today_outlined,
          title: 'Vence el',
          value: coupon.expiresAt != null
              ? formatShortDate(coupon.expiresAt!)
              : 'Sin límite',
        ),
        _DetailItem(
          icon: Icons.analytics_outlined,
          title: 'Redenciones',
          value:
              '${coupon.usedCount}${coupon.maxUses != null ? ' / ${coupon.maxUses}' : ' u'}',
        ),
        if (coupon.minOrderAmount > 0)
          _DetailItem(
            icon: Icons.shopping_bag_outlined,
            title: 'Mín. compra',
            value: '\$${coupon.minOrderAmount.toStringAsFixed(2)}',
          ),
      ],
    );
  }
}

class _DetailItem extends StatelessWidget {
  const _DetailItem({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: FudiColors.mutedForeground.withValues(alpha: 0.8),
        ),
        const SizedBox(width: FudiSpacing.xs),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: FudiTypography.bodySmall.copyWith(
                fontSize: 10,
                color: FudiColors.mutedForeground,
              ),
            ),
            Text(
              value,
              style: FudiTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                height: 1.1,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─── Coupon Context Menu ─────────────────────────────────────────────

class _CouponMenu extends ConsumerStatefulWidget {
  const _CouponMenu({required this.coupon});
  final Coupon coupon;

  @override
  ConsumerState<_CouponMenu> createState() => _CouponMenuState();
}

class _CouponMenuState extends ConsumerState<_CouponMenu> {
  bool _isProcessing = false;

  void _showFeedback(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: FudiTypography.bodyMedium.copyWith(
            color: FudiColors.primaryForeground,
            fontWeight: FontWeight.w500,
          ),
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError
            ? FudiColors.destructive
            : FudiColors.foreground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(FudiRadius.md),
        ),
        margin: const EdgeInsets.all(FudiSpacing.lg),
      ),
    );
  }

  Future<void> _handleCopy() async {
    await Clipboard.setData(ClipboardData(text: widget.coupon.code));
    _showFeedback('Código "${widget.coupon.code}" copiado al portapapeles.');
  }

  Future<void> _handleToggle() async {
    setState(() => _isProcessing = true);
    try {
      await ref
          .read(businessCouponRepositoryProvider)
          .toggleCouponStatus(widget.coupon.id, !widget.coupon.isActive);
      ref.invalidate(businessCouponsProvider(widget.coupon.businessId));
      _showFeedback(
        widget.coupon.isActive
            ? 'Cupón pausado temporalmente.'
            : 'Cupón activado exitosamente.',
      );
    } catch (e) {
      _showFeedback(
        'No se pudo actualizar el estado del cupón.',
        isError: true,
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _handleDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(FudiRadius.lg),
        ),
        title: Text(
          '¿Eliminar cupón?',
          style: FudiTypography.h3.copyWith(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'El código "${widget.coupon.code}" será removido definitivamente de tu catálogo de promociones.',
          style: FudiTypography.bodyMedium.copyWith(
            color: FudiColors.mutedForeground,
          ),
        ),
        actionsPadding: const EdgeInsets.symmetric(
          horizontal: FudiSpacing.lg,
          vertical: FudiSpacing.md,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(
              'Cancelar',
              style: TextStyle(
                color: FudiColors.mutedForeground,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: FudiColors.destructive,
            ),
            child: const Text(
              'Eliminar promoción',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _isProcessing = true);
    try {
      await ref
          .read(businessCouponRepositoryProvider)
          .deleteCoupon(widget.coupon.id);
      ref.invalidate(businessCouponsProvider(widget.coupon.businessId));
      _showFeedback('Cupón removido satisfactoriamente.');
    } catch (e) {
      _showFeedback(
        'Hubo un error al intentar eliminar el cupón.',
        isError: true,
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isProcessing) {
      return const SizedBox(
        width: 32,
        height: 32,
        child: Padding(
          padding: EdgeInsets.all(8),
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: FudiColors.primary,
          ),
        ),
      );
    }

    return Semantics(
      label: 'Menú de opciones',
      button: true,
      child: PopupMenuButton<String>(
        onSelected: (value) {
          switch (value) {
            case 'copy':
              unawaited(_handleCopy());
              break;
            case 'edit':
              unawaited(context.push('/business/coupons/${widget.coupon.id}/edit'));
              break;
            case 'toggle':
              unawaited(_handleToggle());
              break;
            case 'delete':
              unawaited(_handleDelete());
              break;
          }
        },
        color: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(FudiRadius.lg),
        ),
        icon: const Icon(
          Icons.more_vert_rounded,
          color: FudiColors.mutedForeground,
        ),
        itemBuilder: (_) => [
          const PopupMenuItem(
            value: 'edit',
            child: Row(
              children: [
                Icon(
                  Icons.edit_outlined,
                  size: 18,
                  color: FudiColors.foreground,
                ),
                SizedBox(width: FudiSpacing.sm),
                Text('Editar promoción', style: FudiTypography.bodyMedium),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'copy',
            child: Row(
              children: [
                Icon(
                  Icons.copy_rounded,
                  size: 18,
                  color: FudiColors.foreground,
                ),
                SizedBox(width: FudiSpacing.sm),
                Text('Copiar código', style: FudiTypography.bodyMedium),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'toggle',
            child: Row(
              children: [
                Icon(
                  widget.coupon.isActive
                      ? Icons.pause_circle_outline_rounded
                      : Icons.play_circle_outline_rounded,
                  size: 18,
                  color: FudiColors.foreground,
                ),
                const SizedBox(width: FudiSpacing.sm),
                Text(
                  widget.coupon.isActive ? 'Pausar cupón' : 'Reactivar',
                  style: FudiTypography.bodyMedium,
                ),
              ],
            ),
          ),
          const PopupMenuDivider(height: 1, color: FudiColors.borderSolid),
          PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                const Icon(
                  Icons.delete_outline_rounded,
                  size: 18,
                  color: FudiColors.destructive,
                ),
                const SizedBox(width: FudiSpacing.sm),
                Text(
                  'Eliminar',
                  style: FudiTypography.bodyMedium.copyWith(
                    color: FudiColors.destructive,
                    fontWeight: FontWeight.bold,
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

// ─── Empty Coupons ───────────────────────────────────────────────────

class EmptyCouponsView extends StatelessWidget {
  const EmptyCouponsView({required this.onCreate, super.key});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return FudiSurfaceCard(
      padding: const EdgeInsets.symmetric(
        vertical: FudiSpacing.xxl * 1.5,
        horizontal: FudiSpacing.xl,
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: FudiColors.muted.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.local_offer_outlined,
              size: 40,
              color: FudiColors.mutedForeground,
            ),
          ),
          const SizedBox(height: FudiSpacing.lg),
          Text(
            'Sin cupones activos',
            style: FudiTypography.h3.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: FudiSpacing.xs),
          Text(
            'Lanza tu primera promoción para fidelizar clientes y reducir excedentes de alimentos rápidamente.',
            textAlign: TextAlign.center,
            style: FudiTypography.bodyMedium.copyWith(
              color: FudiColors.mutedForeground,
              height: 1.4,
            ),
          ),
          const SizedBox(height: FudiSpacing.xl),
          FudiPressableScale(
            onTap: onCreate,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
              decoration: BoxDecoration(
                color: FudiColors.primary,
                borderRadius: BorderRadius.circular(FudiRadius.md),
              ),
              child: Text(
                'Crear primer cupón',
                style: FudiTypography.bodyMedium.copyWith(
                  color: FudiColors.primaryForeground,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Coupons Loading Skeleton ────────────────────────────────────────

class CouponsLoadingSkeleton extends StatelessWidget {
  const CouponsLoadingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: FudiColors.inputBackground.withValues(alpha: 0.6),
      highlightColor: FudiColors.inputBackground.withValues(alpha: 0.2),
      child: ListView(
        padding: const EdgeInsets.all(FudiSpacing.xl),
        physics: const NeverScrollableScrollPhysics(),
        children: [
          Row(
            children: List.generate(
              3,
              (i) => Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: i < 2 ? FudiSpacing.sm : 0),
                  child: Container(
                    height: 64,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(FudiRadius.md),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: FudiSpacing.xl),
          ...List.generate(
            3,
            (_) => Padding(
              padding: const EdgeInsets.only(bottom: FudiSpacing.sm),
              child: Container(
                height: 128,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(FudiRadius.lg),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Coupon Edit Form Loading Skeleton ───────────────────────────────

class CouponEditFormSkeleton extends StatelessWidget {
  const CouponEditFormSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: FudiColors.inputBackground.withValues(alpha: 0.6),
      highlightColor: FudiColors.inputBackground.withValues(alpha: 0.2),
      child: ListView(
        padding: const EdgeInsets.all(FudiSpacing.xl),
        physics: const NeverScrollableScrollPhysics(),
        children: List.generate(
          4,
          (_) => Padding(
            padding: const EdgeInsets.only(bottom: FudiSpacing.md),
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(FudiRadius.lg),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
