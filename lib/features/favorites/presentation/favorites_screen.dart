import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/error/user_friendly_message.dart';
import '../../../core/routing/route_names.dart';
import '../../../core/ui/cards/deal_card.dart';
import '../../../core/ui/fudi_colors.dart';
import '../../../core/ui/atoms/icons/fudi_icons.dart';
import '../../../core/ui/fudi_info_banner.dart';
import '../../../core/ui/fudi_spacing.dart';
import '../../../core/ui/fudi_sticky_page_header.dart';
import '../../../core/ui/fudi_pressable_scale.dart';
import '../../../core/ui/fudi_typography.dart';
import '../../auth/presentation/auth_state_provider.dart';
import 'favorites_providers.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritesAsync = ref.watch(favoriteOffersProvider);
    final userId = ref.watch(
      authSessionNotifierProvider.select((state) => state.profile?.id),
    );

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: const FudiStickyPageHeader(title: 'Favoritos'),
      body: favoritesAsync.when(
        loading: () => const _FavoritesLoadingState(),
        error: (error, _) =>
            _FavoritesErrorState(message: userFriendlyMessage(error)),
        data: (favorites) {
          if (favorites.isEmpty) {
            return _FavoritesEmptyState(
              onExplore: () => context.go(RouteNames.homePath),
            );
          }

          final totalSaved = favorites.fold<double>(
            0,
            (sum, favorite) => sum + favorite.totalSaved,
          );

          return RefreshIndicator(
            onRefresh: () async => ref.refresh(favoriteOffersProvider.future),
            color: FudiColors.primary,
            child: ListView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              padding: const EdgeInsets.all(FudiSpacing.xl),
              children: [
                FudiInfoBanner(
                  icon: FudiIcons.heart,
                  message:
                      'Has identificado \$${totalSaved.toStringAsFixed(0)} de ahorro potencial en tus favoritos.',
                ),
                const SizedBox(height: FudiSpacing.xl),
                ...favorites.map(
                  (favorite) => Padding(
                    padding: const EdgeInsets.only(bottom: FudiSpacing.md),
                    child: DealCard(
                      imageUrl: favorite.imageUrl ?? '',
                      offerTitle: favorite.title,
                      businessName: favorite.businessName,
                      originalPrice: favorite.originalPrice,
                      discountedPrice: favorite.discountedPrice,
                      rating: favorite.rating,
                      distance: favorite.address,
                      availableQuantity: 1,
                      pickupUntil: const TimeOfDay(hour: 23, minute: 59),
                      isFavorite: true,
                      onTap: () => context.push('/product/${favorite.offerId}'),
                      onFavoriteToggle: userId == null
                          ? null
                          : () async {
                              await ref
                                  .read(favoritedOfferIdsProvider.notifier)
                                  .toggleFavorite(favorite.offerId);
                            },
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─── Empty State Estilizado ─────────────────────────────────────────

class _FavoritesEmptyState extends StatelessWidget {
  const _FavoritesEmptyState({required this.onExplore});

  final VoidCallback onExplore;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(FudiSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: FudiColors.inputBackground.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                FudiIcons.heartOutline,
                size: 48,
                color: FudiColors.mutedForeground,
              ),
            ),
            const SizedBox(height: FudiSpacing.xl),
            Text(
              'No tienes favoritos',
              style: FudiTypography.h3.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: FudiSpacing.xs),
            Text(
              'Guarda tus ofertas preferidas aquí para poder rescatarlas en cualquier momento.',
              textAlign: TextAlign.center,
              style: FudiTypography.bodyMedium.copyWith(
                color: FudiColors.mutedForeground,
                height: 1.3,
              ),
            ),
            const SizedBox(height: FudiSpacing.xxl),
            FudiPressableScale(
              onTap: onExplore,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: FudiColors.foreground,
                  borderRadius: BorderRadius.circular(FudiRadius.lg),
                ),
                child: Center(
                  child: Text(
                    'Explorar ofertas cerca',
                    style: FudiTypography.labelSmall.copyWith(
                      color: FudiColors.primaryForeground,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Loading Skeleton Realista ──────────────────────────────────────

class _FavoritesLoadingState extends StatelessWidget {
  const _FavoritesLoadingState();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(FudiSpacing.xl),
      itemCount: 3,
      itemBuilder: (context, index) => const Padding(
        padding: EdgeInsets.only(bottom: FudiSpacing.md),
        child: DealCardSkeleton(),
      ),
    );
  }
}

// ─── Error State ────────────────────────────────────────────────────

class _FavoritesErrorState extends StatelessWidget {
  const _FavoritesErrorState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(FudiSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              FudiIcons.error,
              size: 40,
              color: FudiColors.destructiveVibrant,
            ),
            const SizedBox(height: FudiSpacing.sm),
            Text(
              'Algo salió mal',
              style: FudiTypography.h3.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: FudiSpacing.xs),
            Text(
              message,
              textAlign: TextAlign.center,
              style: FudiTypography.bodySmall.copyWith(
                color: FudiColors.mutedForeground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
