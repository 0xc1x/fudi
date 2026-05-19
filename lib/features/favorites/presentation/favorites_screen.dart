import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/core_providers.dart';
import '../../../core/routing/route_names.dart';
import '../../../core/ui/fudi_colors.dart';
import '../../../core/ui/fudi_icons.dart';
import '../../../core/ui/fudi_info_banner.dart';
import '../../../core/ui/fudi_spacing.dart';
import '../../../core/ui/fudi_sticky_page_header.dart';
import '../../../core/ui/fudi_surface_card.dart';
import '../../../core/ui/fudi_typography.dart';
import '../../auth/presentation/auth_state_provider.dart';
import '../data/supabase_favorites_repository.dart';
import '../domain/favorite_offer.dart';
import '../domain/favorites_repository.dart';

final favoritesRepositoryProvider = Provider<FavoritesRepository>((ref) {
  return SupabaseFavoritesRepository(
    supabaseClient: ref.watch(supabaseClientProvider),
  );
});

final favoriteOffersProvider = FutureProvider<List<FavoriteOffer>>((ref) async {
  final userId = ref.watch(
    authSessionNotifierProvider.select((state) => state.profile?.id),
  );
  if (userId == null) return const [];

  final repository = ref.watch(favoritesRepositoryProvider);
  return repository.getFavorites(userId);
});

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritesAsync = ref.watch(favoriteOffersProvider);
    final userId = ref.watch(
      authSessionNotifierProvider.select((state) => state.profile?.id),
    );

    return Scaffold(
      backgroundColor: FudiColors.muted,
      appBar: const FudiStickyPageHeader(title: 'Favoritos'),
      body: favoritesAsync.when(
        loading: () => const _FavoritesLoadingState(),
        error: (error, _) => _FavoritesErrorState(message: error.toString()),
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
            child: ListView(
              padding: const EdgeInsets.all(FudiSpacing.lg),
              children: [
                FudiInfoBanner(
                  icon: FudiIcons.heart,
                  message:
                      'Has identificado \$${totalSaved.toStringAsFixed(0)} de ahorro potencial en tus favoritos.',
                ),
                const SizedBox(height: FudiSpacing.lg),
                ...favorites.map(
                  (favorite) => Padding(
                    padding: const EdgeInsets.only(bottom: FudiSpacing.md),
                    child: _FavoriteCard(
                      favorite: favorite,
                      onOpen: () => context.push('/product/${favorite.offerId}'),
                      onRemove: userId == null
                          ? null
                          : () async {
                              final repository = ref.read(
                                favoritesRepositoryProvider,
                              );
                              await repository.removeFavorite(
                                userId,
                                favorite.favoriteId,
                              );
                              ref.invalidate(favoriteOffersProvider);
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

class _FavoriteCard extends StatelessWidget {
  const _FavoriteCard({
    required this.favorite,
    required this.onOpen,
    required this.onRemove,
  });

  final FavoriteOffer favorite;
  final VoidCallback onOpen;
  final Future<void> Function()? onRemove;

  @override
  Widget build(BuildContext context) {
    return FudiSurfaceCard(
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _FavoriteImage(imageUrl: favorite.imageUrl),
              const SizedBox(width: FudiSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            favorite.businessName,
                            style: FudiTypography.labelSmall,
                          ),
                        ),
                        IconButton(
                          onPressed: onRemove == null
                              ? null
                              : () async => onRemove!.call(),
                          visualDensity: VisualDensity.compact,
                          icon: const Icon(
                            Icons.delete_outline_rounded,
                            color: FudiColors.destructive,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      favorite.title,
                      style: FudiTypography.bodySmall.copyWith(
                        color: FudiColors.foreground,
                      ),
                    ),
                    const SizedBox(height: FudiSpacing.xs),
                    Text(
                      favorite.category ?? 'Oferta destacada',
                      style: FudiTypography.bodySmall.copyWith(
                        color: FudiColors.mutedForeground,
                      ),
                    ),
                    const SizedBox(height: FudiSpacing.sm),
                    Row(
                      children: [
                        const Icon(
                          FudiIcons.star,
                          size: 16,
                          color: Colors.amber,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          favorite.rating.toStringAsFixed(1),
                          style: FudiTypography.bodySmall,
                        ),
                        const SizedBox(width: FudiSpacing.sm),
                        const Icon(
                          FudiIcons.mapPin,
                          size: 16,
                          color: FudiColors.mutedForeground,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            favorite.address,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: FudiTypography.bodySmall.copyWith(
                              color: FudiColors.mutedForeground,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: FudiSpacing.md),
          Row(
            children: [
              Expanded(
                child: _MetricBlock(
                  label: 'Precio actual',
                  value: '\$${favorite.discountedPrice.toStringAsFixed(0)}',
                  color: FudiColors.primary,
                ),
              ),
              Expanded(
                child: _MetricBlock(
                  label: 'Ahorro',
                  value: '\$${favorite.totalSaved.toStringAsFixed(0)}',
                  color: const Color(0xFF15803D),
                ),
              ),
            ],
          ),
          const SizedBox(height: FudiSpacing.md),
          SizedBox(
            width: double.infinity,
            child: FilledButton.tonal(
              onPressed: onOpen,
              style: FilledButton.styleFrom(
                foregroundColor: FudiColors.primary,
                backgroundColor: FudiColors.primary.withValues(alpha: 0.12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(FudiRadius.lg),
                ),
              ),
              child: const Text('Ver oferta'),
            ),
          ),
        ],
      ),
    );
  }
}

class _FavoriteImage extends StatelessWidget {
  const _FavoriteImage({required this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(FudiRadius.lg),
        gradient: LinearGradient(
          colors: [
            FudiColors.primary.withValues(alpha: 0.16),
            const Color(0xFFFFE7D1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: imageUrl != null && imageUrl!.isNotEmpty
          ? CachedNetworkImage(
              imageUrl: imageUrl!,
              fit: BoxFit.cover,
            )
          : const Icon(
              FudiIcons.heart,
              size: 32,
              color: FudiColors.primary,
            ),
    );
  }
}

class _MetricBlock extends StatelessWidget {
  const _MetricBlock({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: FudiTypography.bodySmall.copyWith(
            color: FudiColors.mutedForeground,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: FudiTypography.labelSmall.copyWith(color: color),
        ),
      ],
    );
  }
}

class _FavoritesEmptyState extends StatelessWidget {
  const _FavoritesEmptyState({required this.onExplore});

  final VoidCallback onExplore;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(FudiSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              FudiIcons.heartOutline,
              size: 56,
              color: FudiColors.mutedForeground,
            ),
            const SizedBox(height: FudiSpacing.md),
            Text('No tienes favoritos', style: FudiTypography.h2),
            const SizedBox(height: FudiSpacing.sm),
            Text(
              'Marca tus ofertas preferidas para volver a ellas rápidamente.',
              textAlign: TextAlign.center,
              style: FudiTypography.bodyMedium.copyWith(
                color: FudiColors.mutedForeground,
              ),
            ),
            const SizedBox(height: FudiSpacing.lg),
            FilledButton(
              onPressed: onExplore,
              child: const Text('Explorar ofertas'),
            ),
          ],
        ),
      ),
    );
  }
}

class _FavoritesLoadingState extends StatelessWidget {
  const _FavoritesLoadingState();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(FudiSpacing.lg),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: FudiSpacing.md),
          child: Container(
            height: 180,
            decoration: BoxDecoration(
              color: FudiColors.background,
              borderRadius: BorderRadius.circular(FudiRadius.xl),
              border: Border.all(color: FudiColors.borderSolid),
            ),
          ),
        );
      },
    );
  }
}

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
              size: 48,
              color: FudiColors.destructive,
            ),
            const SizedBox(height: FudiSpacing.sm),
            Text('Error al cargar favoritos', style: FudiTypography.h2),
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
