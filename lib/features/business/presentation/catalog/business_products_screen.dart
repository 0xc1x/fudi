import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/ui/fudi_colors.dart';
import '../../../../core/ui/fudi_spacing.dart';
import '../../../../core/ui/fudi_typography.dart';
import '../../../../core/ui/fudi_icons.dart';
import '../../../../core/ui/app_logo.dart';
import '../business_providers.dart';
import '../components/no_business_prompt.dart';
import '../../domain/business_profile.dart';
import '../../../offers/domain/offer.dart';

class BusinessProductsScreen extends ConsumerWidget {
  const BusinessProductsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final businessAsync = ref.watch(currentBusinessProvider);

    return Scaffold(
      backgroundColor: FudiColors.muted,
      body: businessAsync.when(
        data: (business) {
          if (business == null) return const NoBusinessPrompt();

          final allBusinessesAsync = ref.watch(userBusinessesProvider);
          final offersAsync = ref.watch(businessOffersProvider(business.id));

          return offersAsync.when(
            data: (offers) => _BusinessProductsContent(
              business: business,
              allBusinesses: allBusinessesAsync.asData?.value ?? [business],
              offers: offers,
            ),
            loading: () => _BusinessProductsContent(
              business: business,
              allBusinesses: allBusinessesAsync.asData?.value ?? [business],
              offers: const [],
              isLoading: true,
            ),
            error: (e, _) => Center(child: Text('Error: $e')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _BusinessProductsContent extends ConsumerWidget {
  const _BusinessProductsContent({
    required this.business,
    required this.allBusinesses,
    required this.offers,
    this.isLoading = false,
  });

  final BusinessProfile business;
  final List<BusinessProfile> allBusinesses;
  final List<Offer> offers;
  final bool isLoading;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeCount = offers.where((o) => o.isActive).length;
    final soldToday = offers.fold<int>(
      0,
      (sum, o) => sum + (o.initialStock - o.stock),
    );
    final availableCount = offers.fold<int>(0, (sum, o) => sum + o.stock);

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: _BusinessHeader(
            business: business,
            allBusinesses: allBusinesses,
          ),
        ),
        SliverToBoxAdapter(
          child: _StatsRow(
            activeCount: activeCount,
            soldToday: soldToday,
            availableCount: availableCount,
          ),
        ),
        SliverToBoxAdapter(
          child: _CreateProductButton(
            onTap: () => context.push('/business/products/create'),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              FudiSpacing.lg,
              FudiSpacing.md,
              FudiSpacing.lg,
              FudiSpacing.sm,
            ),
            child: Text('Todos los productos', style: FudiTypography.h4),
          ),
        ),
        if (isLoading)
          const SliverToBoxAdapter(
            child: Center(child: CircularProgressIndicator()),
          )
        else if (offers.isEmpty)
          SliverToBoxAdapter(
            child: _EmptyProductsState(
              onTap: () => context.push('/business/products/create'),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: FudiSpacing.lg),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => Padding(
                  padding: const EdgeInsets.only(bottom: FudiSpacing.md),
                  child: _ProductCard(offer: offers[index]),
                ),
                childCount: offers.length,
              ),
            ),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: FudiSpacing.xxl)),
      ],
    );
  }
}

class _BusinessHeader extends ConsumerWidget {
  const _BusinessHeader({required this.business, required this.allBusinesses});

  final BusinessProfile business;
  final List<BusinessProfile> allBusinesses;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      color: FudiColors.ring,
      padding: const EdgeInsets.symmetric(
        horizontal: FudiSpacing.lg,
        vertical: FudiSpacing.md,
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mis Productos',
                    style: FudiTypography.h2.copyWith(
                      color: FudiColors.foreground,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  _LocationSelector(
                    business: business,
                    allBusinesses: allBusinesses,
                    onSelected: (id) => ref
                        .read(selectedBusinessIdProvider.notifier)
                        .select(id),
                  ),
                ],
              ),
            ),
            const AppLogo(size: AppLogoSize.lg, variant: AppLogoVariant.light),
          ],
        ),
      ),
    );
  }
}

class _LocationSelector extends StatelessWidget {
  const _LocationSelector({
    required this.business,
    required this.allBusinesses,
    required this.onSelected,
  });

  final BusinessProfile business;
  final List<BusinessProfile> allBusinesses;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    if (allBusinesses.length <= 1) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(FudiIcons.mapPin, size: 14, color: FudiColors.primary),
          const SizedBox(width: 4),
          Text(
            business.name,
            style: const TextStyle(
              fontSize: 12,
              color: FudiColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
    }

    return PopupMenuButton<String>(
      onSelected: onSelected,
      offset: const Offset(0, 32),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(FudiRadius.md),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(FudiIcons.mapPin, size: 14, color: FudiColors.primary),
          const SizedBox(width: 4),
          Text(
            business.name,
            style: const TextStyle(
              fontSize: 12,
              color: FudiColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Icon(
            FudiIcons.chevronDown,
            size: 14,
            color: FudiColors.primary,
          ),
        ],
      ),
      itemBuilder: (context) => allBusinesses
          .map(
            (b) => PopupMenuItem(
              value: b.id,
              child: Row(
                children: [
                  Icon(
                    FudiIcons.mapPin,
                    size: 16,
                    color: b.id == business.id
                        ? FudiColors.primary
                        : FudiColors.mutedForeground,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    b.name,
                    style: TextStyle(
                      fontWeight: b.id == business.id
                          ? FontWeight.bold
                          : FontWeight.normal,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({
    required this.activeCount,
    required this.soldToday,
    required this.availableCount,
  });

  final int activeCount;
  final int soldToday;
  final int availableCount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(FudiSpacing.lg),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              value: '$activeCount',
              label: 'Activos',
              valueColor: FudiColors.primary,
            ),
          ),
          const SizedBox(width: FudiSpacing.md),
          Expanded(
            child: _StatCard(
              value: '$soldToday',
              label: 'Vendidos hoy',
              valueColor: Colors.green,
            ),
          ),
          const SizedBox(width: FudiSpacing.md),
          Expanded(
            child: _StatCard(
              value: '$availableCount',
              label: 'Disponibles',
              valueColor: Colors.orange,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.value,
    required this.label,
    required this.valueColor,
  });

  final String value;
  final String label;
  final Color valueColor;

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
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: FudiTypography.bodySmall.copyWith(fontSize: 11)),
        ],
      ),
    );
  }
}

class _CreateProductButton extends StatelessWidget {
  const _CreateProductButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: FudiSpacing.lg),
      child: SizedBox(
        width: double.infinity,
        child: FilledButton(
          onPressed: onTap,
          style: FilledButton.styleFrom(
            backgroundColor: FudiColors.primary,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(FudiRadius.xl),
            ),
            elevation: 4,
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_rounded,
                color: FudiColors.primaryForeground,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Crear nuevo producto',
                style: TextStyle(
                  color: FudiColors.primaryForeground,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductCard extends ConsumerWidget {
  const _ProductCard({required this.offer});

  final Offer offer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: offer.isActive ? FudiColors.background : FudiColors.muted,
        borderRadius: BorderRadius.circular(FudiRadius.xl),
        border: Border.all(
          color: offer.isActive
              ? FudiColors.borderSolid
              : FudiColors.borderSolid,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        type: MaterialType.transparency,
        borderRadius: BorderRadius.circular(FudiRadius.xl),
        child: InkWell(
          onTap: () => context.push('/business/products/${offer.id}'),
          borderRadius: BorderRadius.circular(FudiRadius.xl),
          child: Padding(
            padding: const EdgeInsets.all(FudiSpacing.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ProductImage(offer: offer),
                const SizedBox(width: FudiSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              offer.title,
                              style: FudiTypography.h4.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: offer.isActive
                                    ? FudiColors.foreground
                                    : FudiColors.mutedForeground,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          _ProductMenu(offer: offer),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            '\$${offer.discountedPrice.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: FudiColors.primary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '\$${offer.originalPrice.toStringAsFixed(2)}',
                            style: FudiTypography.bodySmall.copyWith(
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            'Stock: ${offer.stock}',
                            style: FudiTypography.bodySmall.copyWith(
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '•',
                            style: FudiTypography.bodySmall.copyWith(
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Hasta ${_formatPickupEnd(offer)}',
                            style: FudiTypography.bodySmall.copyWith(
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '•',
                            style: FudiTypography.bodySmall.copyWith(
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${offer.initialStock - offer.stock} vendidos',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _StatusBadge(isActive: offer.isActive),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatPickupEnd(Offer offer) {
    final hour = offer.pickupEnd.hour.toString().padLeft(2, '0');
    final minute = offer.pickupEnd.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

class _ProductImage extends StatelessWidget {
  const _ProductImage({required this.offer});

  final Offer offer;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(FudiSpacing.sm),
        color: FudiColors.muted,
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(FudiSpacing.sm),
            child: offer.imageUrl != null
                ? CachedNetworkImage(
                    imageUrl: offer.imageUrl!,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorWidget: (_, _, _) => const Center(
                      child: Icon(
                        FudiIcons.package_,
                        color: FudiColors.mutedForeground,
                      ),
                    ),
                  )
                : const Center(
                    child: Icon(
                      FudiIcons.package_,
                      color: FudiColors.mutedForeground,
                    ),
                  ),
          ),
          if (!offer.isActive)
            ClipRRect(
              borderRadius: BorderRadius.circular(FudiSpacing.sm),
              child: Container(
                color: Colors.black54,
                child: const Center(
                  child: Icon(FudiIcons.eyeOff, color: Colors.white, size: 24),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.isActive});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFDCFCE7) : FudiColors.muted,
        borderRadius: BorderRadius.circular(FudiRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive
                  ? const Color(0xFF16A34A)
                  : FudiColors.mutedForeground,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            isActive ? 'Activo' : 'Inactivo',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isActive
                  ? const Color(0xFF15803D)
                  : FudiColors.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductMenu extends ConsumerWidget {
  const _ProductMenu({required this.offer});

  final Offer offer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<String>(
      icon: const Icon(
        Icons.more_vert,
        color: FudiColors.mutedForeground,
        size: 20,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(FudiRadius.md),
      ),
      onSelected: (value) async {
        if (value == 'toggle') {
          await ref
              .read(businessCatalogRepositoryProvider)
              .toggleOfferStatus(offer.id, !offer.isActive);
          ref.invalidate(businessOffersProvider(offer.businessId));
        } else if (value == 'edit') {
      if (context.mounted) {
          context.push('/business/products/edit/${offer.id}');
        }
        } else if (value == 'delete') {
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Eliminar producto'),
              content: const Text(
                '¿Estás seguro de que deseas eliminar este producto?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text(
                    'Eliminar',
                    style: TextStyle(color: FudiColors.destructive),
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
          }
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'toggle',
          child: Row(
            children: [
              Icon(offer.isActive ? FudiIcons.eyeOff : FudiIcons.eye, size: 18),
              const SizedBox(width: 8),
              Text(offer.isActive ? 'Desactivar' : 'Activar'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit_rounded, size: 18),
              SizedBox(width: 8),
              Text('Editar'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(
                Icons.delete_outline_rounded,
                size: 18,
                color: FudiColors.destructive,
              ),
              SizedBox(width: 8),
              Text('Eliminar', style: TextStyle(color: FudiColors.destructive)),
            ],
          ),
        ),
      ],
    );
  }
}

class _EmptyProductsState extends StatelessWidget {
  const _EmptyProductsState({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(FudiSpacing.xl),
      child: Center(
        child: Column(
          children: [
            const Icon(
              FudiIcons.package_,
              size: 64,
              color: FudiColors.mutedForeground,
            ),
            const SizedBox(height: FudiSpacing.md),
            const Text(
              'No tienes productos publicados',
              style: FudiTypography.h4,
            ),
            const SizedBox(height: FudiSpacing.sm),
            TextButton(
              onPressed: onTap,
              child: const Text('Crear mi primer producto'),
            ),
          ],
        ),
      ),
    );
  }
}
