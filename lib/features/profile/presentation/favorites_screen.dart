import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/ui/cards/deal_card.dart';
import '../../../core/ui/fudi_colors.dart';
import '../../../core/ui/fudi_icons.dart';
import '../../../core/ui/fudi_spacing.dart';
import '../../../core/ui/fudi_typography.dart';
import '../../../core/ui/fudi_sticky_page_header.dart';
import 'profile_providers.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritesAsync = ref.watch(favoriteOffersProvider);

    return Scaffold(
      appBar: const FudiStickyPageHeader(title: 'Mis Favoritos'),
      body: favoritesAsync.when(
        data: (offers) {
          if (offers.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(FudiIcons.heartOutline, size: 64, color: FudiColors.mutedForeground),
                  const SizedBox(height: FudiSpacing.md),
                  Text('Aún no tienes favoritos', style: FudiTypography.bodyLarge),
                  const SizedBox(height: FudiSpacing.sm),
                  Text(
                    'Toca el corazón en cualquier oferta para guardarla aquí.',
                    textAlign: TextAlign.center,
                    style: FudiTypography.bodySmall.copyWith(color: FudiColors.mutedForeground),
                  ),
                  const SizedBox(height: FudiSpacing.xl),
                  FilledButton(
                    onPressed: () => context.go('/explore'),
                    child: const Text('Explorar ofertas'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => ref.refresh(favoriteOffersProvider.future),
            child: ListView.separated(
              padding: const EdgeInsets.all(FudiSpacing.lg),
              itemCount: offers.length,
              separatorBuilder: (_, _) => const SizedBox(height: FudiSpacing.md),
              itemBuilder: (context, index) {
                final offer = offers[index];
                return DealCard(
                  imageUrl: offer.imageUrl ?? '',
                  businessName: offer.business.name,
                  businessType: offer.business.type,
                  originalPrice: offer.originalPrice,
                  discountedPrice: offer.discountedPrice,
                  rating: offer.rating,
                  distance: 'Cerca de ti', // We might need location here
                  availableQuantity: offer.stock,
                  pickupUntil: TimeOfDay.fromDateTime(offer.pickupEnd),
                  isFavorite: true,
                  onFavoriteToggle: () => _toggleFavorite(ref, offer.id),
                  onTap: () => context.push('/offer/${offer.id}'),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Future<void> _toggleFavorite(WidgetRef ref, String offerId) async {
    await ref.read(consumerProfileRepositoryProvider).removeFavorite(offerId);
    ref.invalidate(favoriteOffersProvider);
  }
}
