import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/ui/fudi_colors.dart';
import '../../../../core/ui/fudi_spacing.dart';
import '../../../../core/ui/fudi_typography.dart';
import '../../../../core/ui/fudi_surface_card.dart';
import '../../../../core/ui/fudi_icons.dart';
import '../business_providers.dart';
import '../components/no_business_prompt.dart';
import '../../../offers/domain/offer.dart';

class BusinessProductsScreen extends ConsumerWidget {
  const BusinessProductsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final businessAsync = ref.watch(currentBusinessProvider);

    return Scaffold(
      backgroundColor: FudiColors.background,
      appBar: AppBar(
        title: const Text('Mis Productos', style: FudiTypography.h2),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => context.push('/business/products/create'),
          ),
        ],
      ),
      body: businessAsync.when(
        data: (business) {
          if (business == null) return const NoBusinessPrompt();
          
          final offersAsync = ref.watch(businessOffersProvider(business.id));
          
          return offersAsync.when(
            data: (offers) => _ProductsList(offers: offers),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/business/products/create'),
        backgroundColor: FudiColors.primary,
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }
}

class _ProductsList extends StatelessWidget {
  const _ProductsList({required this.offers});

  final List<Offer> offers;

  @override
  Widget build(BuildContext context) {
    if (offers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(FudiIcons.package_, size: 64, color: FudiColors.mutedForeground),
            const SizedBox(height: FudiSpacing.md),
            const Text('No tienes productos publicados', style: FudiTypography.h4),
            const SizedBox(height: FudiSpacing.sm),
            TextButton(
              onPressed: () => context.push('/business/products/create'),
              child: const Text('Crear mi primer producto'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(FudiSpacing.md),
      itemCount: offers.length,
      itemBuilder: (context, index) {
        final offer = offers[index];
        return _ProductCard(offer: offer);
      },
    );
  }
}

class _ProductCard extends ConsumerWidget {
  const _ProductCard({required this.offer});

  final Offer offer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(bottom: FudiSpacing.md),
      child: FudiSurfaceCard(
        padding: EdgeInsets.zero,
        child: InkWell(
          onTap: () => context.push('/business/products/edit/${offer.id}'),
          child: Column(
            children: [
              Padding(
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
                                  style: FudiTypography.h4,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              _ProductActions(offer: offer),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                '\$${offer.discountedPrice.toStringAsFixed(0)}',
                                style: FudiTypography.h3.copyWith(color: FudiColors.primary),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '\$${offer.originalPrice.toStringAsFixed(0)}',
                                style: FudiTypography.bodySmall.copyWith(
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          _ProductStats(offer: offer),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              _ProductStatusToggle(offer: offer),
            ],
          ),
        ),
      ),
    );
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(FudiSpacing.sm),
        child: offer.imageUrl != null
            ? Image.network(offer.imageUrl!, fit: BoxFit.cover)
            : const Icon(FudiIcons.package_, color: FudiColors.mutedForeground),
      ),
    );
  }
}

class _ProductStats extends StatelessWidget {
  const _ProductStats({required this.offer});

  final Offer offer;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatItem(label: 'Stock', value: '${offer.stock}'),
        const SizedBox(width: 12),
        _StatItem(label: 'Ventas', value: '${offer.initialStock - offer.stock}'),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: FudiTypography.bodySmall),
        Text(value, style: FudiTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _ProductActions extends StatelessWidget {
  const _ProductActions({required this.offer});

  final Offer offer;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, color: FudiColors.mutedForeground),
      onSelected: (value) {
        if (value == 'edit') {
          context.push('/business/products/edit/${offer.id}');
        }
      },
      itemBuilder: (context) => [
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
      ],
    );
  }
}

class _ProductStatusToggle extends ConsumerWidget {
  const _ProductStatusToggle({required this.offer});

  final Offer offer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: FudiSpacing.md, vertical: 8),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: FudiColors.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: offer.isActive ? Colors.green : Colors.grey,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                offer.isActive ? 'Activo' : 'Inactivo',
                style: FudiTypography.bodySmall.copyWith(
                  color: offer.isActive ? Colors.green : FudiColors.mutedForeground,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Switch.adaptive(
            value: offer.isActive,
            activeTrackColor: FudiColors.primary,
            onChanged: (value) async {
              await ref.read(businessCatalogRepositoryProvider).toggleOfferStatus(offer.id, value);
              ref.invalidate(businessOffersProvider(offer.businessId));
            },
          ),
        ],
      ),
    );
  }
}
