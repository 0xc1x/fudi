import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../core/ui/fudi_colors.dart';
import '../../../../core/ui/fudi_pressable_scale.dart';
import '../../../../core/ui/atoms/icons/fudi_icons.dart';
import '../../../../core/ui/fudi_spacing.dart';
import '../../../../core/ui/fudi_typography.dart';
import '../business_providers.dart';
import '../../../offers/domain/offer.dart';

class BusinessProductDetailScreen extends ConsumerWidget {
  const BusinessProductDetailScreen({super.key, required this.productId});

  final String productId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final businessAsync = ref.watch(currentBusinessProvider);

    return businessAsync.when(
      data: (business) {
        if (business == null) {
          return const Scaffold(
            body: Center(child: Text('No se encontró el negocio')),
          );
        }

        final offersAsync = ref.watch(businessOffersProvider(business.id));

        return offersAsync.when(
          data: (offers) {
            final offer = offers.where((o) => o.id == productId).firstOrNull;
            if (offer == null) {
              return const Scaffold(
                body: Center(child: Text('Producto no encontrado')),
              );
            }
            return _ProductDetailContent(offer: offer);
          },
          loading: () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
          error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
        );
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
    );
  }
}

class _ProductDetailContent extends ConsumerWidget {
  const _ProductDetailContent({required this.offer});

  final Offer offer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: FudiColors.muted,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _DetailHeader(offer: offer)),
          SliverToBoxAdapter(child: _ProductHeroImage(offer: offer)),
          SliverPadding(
            padding: const EdgeInsets.all(FudiSpacing.lg),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _StatsSection(offer: offer),
                const SizedBox(height: FudiSpacing.md),
                _QuickActions(offer: offer),
                const SizedBox(height: FudiSpacing.md),
                _ProductInfoCard(offer: offer),
                const SizedBox(height: FudiSpacing.md),
                if (offer.includes != null && offer.includes!.isNotEmpty) ...[
                  _IncludesCard(offer: offer),
                  const SizedBox(height: FudiSpacing.md),
                ],
                if (offer.allergens != null && offer.allergens!.isNotEmpty) ...[
                  _AllergensCard(offer: offer),
                  const SizedBox(height: FudiSpacing.md),
                ],
                _PerformanceCard(offer: offer),
                const SizedBox(height: FudiSpacing.xxl),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailHeader extends StatelessWidget {
  const _DetailHeader({required this.offer});

  final Offer offer;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(
        horizontal: FudiSpacing.lg,
        vertical: FudiSpacing.md,
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            GestureDetector(
              onTap: () => context.pop(),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: FudiColors.muted,
                  borderRadius: BorderRadius.circular(FudiRadius.full),
                ),
                child: const Icon(FudiIcons.chevronLeft, size: 20),
              ),
            ),
            const SizedBox(width: FudiSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Detalle del producto',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: FudiColors.foreground,
                    ),
                  ),
                  Text(
                    offer.isActive ? 'Activo' : 'Inactivo',
                    style: TextStyle(
                      fontSize: 12,
                      color: offer.isActive
                          ? Colors.green
                          : FudiColors.mutedForeground,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductHeroImage extends StatelessWidget {
  const _ProductHeroImage({required this.offer});

  final Offer offer;

  int get _savings => offer.originalPrice > 0
      ? ((1 - offer.discountedPrice / offer.originalPrice) * 100).round()
      : 0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          height: 256,
          width: double.infinity,
          child: offer.imageUrl != null
              ? CachedNetworkImage(
                  imageUrl: offer.imageUrl!,
                  fit: BoxFit.cover,
                  errorWidget: (_, _, _) => Container(
                    color: FudiColors.muted,
                    child: const Center(
                      child: Icon(
                        FudiIcons.package_,
                        size: 64,
                        color: FudiColors.mutedForeground,
                      ),
                    ),
                  ),
                )
              : Container(
                  color: FudiColors.muted,
                  child: const Center(
                    child: Icon(
                      FudiIcons.package_,
                      size: 64,
                      color: FudiColors.mutedForeground,
                    ),
                  ),
                ),
        ),
        if (!offer.isActive)
          Container(
            height: 256,
            color: Colors.black54,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(FudiRadius.full),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(FudiIcons.eyeOff, size: 16),
                    SizedBox(width: 8),
                    Text(
                      'Producto inactivo',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
          ),
        if (_savings > 0)
          Positioned(
            bottom: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(FudiRadius.full),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                '-$_savings% OFF',
                style: const TextStyle(
                  color: FudiColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _StatsSection extends StatelessWidget {
  const _StatsSection({required this.offer});

  final Offer offer;

  int get _sold => offer.initialStock - offer.stock;
  double get _revenue => _sold * offer.discountedPrice;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: FudiIcons.package_,
            iconColor: FudiColors.primary,
            value: '$_sold',
            label: 'Vendidos',
          ),
        ),
        const SizedBox(width: FudiSpacing.md),
        Expanded(
          child: _StatCard(
            icon: Icons.account_balance_wallet_rounded,
            iconColor: Colors.green,
            value: '\$${_revenue.toStringAsFixed(2)}',
            label: 'Ingresos',
            valueColor: Colors.green,
          ),
        ),
        const SizedBox(width: FudiSpacing.md),
        Expanded(
          child: _StatCard(
            icon: Icons.trending_up_rounded,
            iconColor: Colors.orange,
            value: '${offer.initialStock}',
            label: 'Creados',
            valueColor: Colors.orange,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
    this.valueColor,
  });

  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(FudiSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(FudiRadius.xl),
        border: Border.all(color: FudiColors.borderSolid),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: iconColor),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: valueColor ?? FudiColors.foreground,
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: FudiTypography.bodySmall),
        ],
      ),
    );
  }
}

class _QuickActions extends ConsumerWidget {
  const _QuickActions({required this.offer});

  final Offer offer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Expanded(
          child: FudiPressableScale(
            onTap: () =>
                context.push('/business/products/edit/${offer.id}'),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: FudiColors.primary,
                borderRadius: BorderRadius.circular(FudiRadius.xl),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.edit_rounded, size: 16, color: Colors.white),
                  SizedBox(width: 6),
                  Text(
                    'Editar',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: FudiPressableScale(
            onTap: () async {
              await ref
                  .read(businessCatalogRepositoryProvider)
                  .toggleOfferStatus(offer.id, !offer.isActive);
              ref.invalidate(businessOffersProvider(offer.businessId));
              if (context.mounted) context.pop();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: offer.isActive ? FudiColors.muted : Colors.green,
                borderRadius: BorderRadius.circular(FudiRadius.xl),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    offer.isActive ? FudiIcons.eyeOff : FudiIcons.eye,
                    size: 16,
                    color: offer.isActive ? FudiColors.foreground : Colors.white,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    offer.isActive ? 'Ocultar' : 'Activar',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: offer.isActive ? FudiColors.foreground : Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: FudiPressableScale(
            onTap: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Eliminar producto'),
                  content: const Text(
                    '¿Estás seguro de que deseas eliminar este producto?',
                  ),
                  actions: [
                    FudiPressableScale(
                      onTap: () => Navigator.pop(ctx, false),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: Text('Cancelar'),
                      ),
                    ),
                    FudiPressableScale(
                      onTap: () => Navigator.pop(ctx, true),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: Text(
                          'Eliminar',
                          style: TextStyle(color: FudiColors.destructive),
                        ),
                      ),
                    ),
                  ],
                ),
              );
              if (confirmed == true) {
                await ref
                    .read(businessCatalogRepositoryProvider)
                    .deleteOffer(offer.id);
                ref.invalidate(businessOffersProvider(offer.businessId));
                if (context.mounted) context.pop();
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(FudiRadius.xl),
                border: Border.all(color: FudiColors.destructive),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.delete_outline_rounded, size: 16, color: FudiColors.destructive),
                  SizedBox(width: 6),
                  Text('Eliminar', style: TextStyle(color: FudiColors.destructive, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ProductInfoCard extends StatelessWidget {
  const _ProductInfoCard({required this.offer});

  final Offer offer;

  String _formatDate(DateTime dt) {
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
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '${dt.day} ${months[dt.month]} $hour:$minute';
  }

  String _formatPickupEnd() => _formatDate(offer.pickupEnd);

  String _formatPickupStart() => _formatDate(offer.pickupStart);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(FudiSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(FudiRadius.xxl),
        border: Border.all(color: FudiColors.borderSolid),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            offer.title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: FudiColors.foreground,
            ),
          ),
          const SizedBox(height: 8),
          if (offer.description != null && offer.description!.isNotEmpty)
            Text(
              offer.description!,
              style: FudiTypography.bodyMedium.copyWith(
                color: FudiColors.mutedForeground,
                height: 1.6,
              ),
            ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '\$${offer.discountedPrice.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: FudiColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '\$${offer.originalPrice.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 18,
                  decoration: TextDecoration.lineThrough,
                  color: FudiColors.mutedForeground,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 3.2,
            children: [
              _InfoField(
                label: 'Cantidad disponible',
                value: '${offer.stock} unidades',
              ),
              _InfoField(label: 'Disponible hasta', value: _formatPickupEnd()),
              _InfoField(
                label: 'Vendidos hoy',
                value: '${offer.initialStock - offer.stock} unidades',
                valueColor: Colors.green,
              ),
              _InfoField(
                label: 'Estado',
                value: offer.isActive ? 'Activo' : 'Inactivo',
                valueColor: offer.isActive
                    ? Colors.green
                    : FudiColors.mutedForeground,
              ),
              _InfoField(label: 'Recogida desde', value: _formatPickupStart()),
if (offer.category != null)
  _InfoField(label: 'Categoría', value: offer.categoryLabel)
              else
                _InfoField(
                  label: 'Horario',
                  value: '${_formatPickupStart()} - ${_formatPickupEnd()}',
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoField extends StatelessWidget {
  const _InfoField({required this.label, required this.value, this.valueColor});

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(label, style: FudiTypography.bodySmall.copyWith(fontSize: 11)),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: valueColor ?? FudiColors.foreground,
          ),
        ),
      ],
    );
  }
}

class _IncludesCard extends StatelessWidget {
  const _IncludesCard({required this.offer});

  final Offer offer;

  @override
  Widget build(BuildContext context) {
    final items = offer.includes!
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    return Container(
      padding: const EdgeInsets.all(FudiSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(FudiRadius.xxl),
        border: Border.all(color: FudiColors.borderSolid),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '¿Qué incluye?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: FudiColors.foreground,
            ),
          ),
          const SizedBox(height: 12),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '✓',
                    style: TextStyle(
                      color: FudiColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item,
                      style: FudiTypography.bodyMedium.copyWith(
                        color: FudiColors.mutedForeground,
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

class _AllergensCard extends StatelessWidget {
  const _AllergensCard({required this.offer});

  final Offer offer;

  @override
  Widget build(BuildContext context) {
    final allergens = offer.allergens!
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    return Container(
      padding: const EdgeInsets.all(FudiSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(FudiRadius.xxl),
        border: Border.all(color: FudiColors.borderSolid),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Alérgenos',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: FudiColors.foreground,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: allergens
                .map(
                  (allergen) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF7ED),
                      borderRadius: BorderRadius.circular(FudiRadius.full),
                      border: Border.all(color: const Color(0xFFFED7AA)),
                    ),
                    child: Text(
                      allergen,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFFC2410C),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _PerformanceCard extends StatelessWidget {
  const _PerformanceCard({required this.offer});

  final Offer offer;

  int get _sold => offer.initialStock - offer.stock;
  double get _revenue => _sold * offer.discountedPrice;

  @override
  Widget build(BuildContext context) {
    final stockPercent = offer.initialStock > 0
        ? (offer.stock / offer.initialStock).clamp(0.0, 1.0)
        : 0.0;
    final soldPercent = offer.initialStock > 0
        ? (_sold / offer.initialStock).clamp(0.0, 1.0)
        : 0.0;
    final revenuePercent = _revenue > 0
        ? (_revenue / (offer.initialStock * offer.discountedPrice)).clamp(
            0.0,
            1.0,
          )
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(FudiSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(FudiRadius.xxl),
        border: Border.all(color: FudiColors.borderSolid),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Rendimiento',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: FudiColors.foreground,
            ),
          ),
          const SizedBox(height: 16),
          _ProgressBar(
            label: 'Total vendidos (histórico)',
            value: '$_sold',
            percent: soldPercent,
            color: FudiColors.primary,
          ),
          const SizedBox(height: 16),
          _ProgressBar(
            label: 'Ingresos totales',
            value: '\$${_revenue.toStringAsFixed(2)}',
            percent: revenuePercent,
            color: Colors.green,
            valueColor: Colors.green,
          ),
          const SizedBox(height: 16),
          _ProgressBar(
            label: 'Stock restante',
            value: '${offer.stock} unidades',
            percent: stockPercent,
            color: Colors.orange,
            valueColor: Colors.orange,
          ),
        ],
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({
    required this.label,
    required this.value,
    required this.percent,
    required this.color,
    this.valueColor,
  });

  final String label;
  final String value;
  final double percent;
  final Color color;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                label,
                style: FudiTypography.bodySmall,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: valueColor ?? FudiColors.foreground,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percent,
            backgroundColor: FudiColors.muted,
            valueColor: AlwaysStoppedAnimation(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }
}
