import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/presentation/auth_state_provider.dart';
import '../data/supabase_favorites_repository.dart';
import '../domain/favorite_offer.dart';
import '../domain/favorites_repository.dart';
import '../../../core/di/core_providers.dart';

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

final favoritedOfferIdsProvider =
    NotifierProvider<FavoritedOfferIdsNotifier, Set<String>>(
      FavoritedOfferIdsNotifier.new,
    );

class FavoritedOfferIdsNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() {
    final userId = ref.watch(
      authSessionNotifierProvider.select((state) => state.profile?.id),
    );
    if (userId != null) {
      _loadFavorites(userId);
    }
    return const {};
  }

  Future<void> _loadFavorites(String userId) async {
    try {
      final repository = ref.read(favoritesRepositoryProvider);
      final ids = await repository.getFavoriteOfferIds(userId);
      state = ids;
    } catch (e) {
      // Quiet fail or log
    }
  }

  Future<void> toggleFavorite(String offerId) async {
    final userId = ref.read(
      authSessionNotifierProvider.select((state) => state.profile?.id),
    );
    if (userId == null) return;

    final isCurrentlyFavorite = state.contains(offerId);

    // Optimistic Update
    if (isCurrentlyFavorite) {
      state = Set<String>.from(state)..remove(offerId);
    } else {
      state = Set<String>.from(state)..add(offerId);
    }

    try {
      final repository = ref.read(favoritesRepositoryProvider);
      if (isCurrentlyFavorite) {
        await repository.removeFavoriteByOfferId(userId, offerId);
      } else {
        await repository.addFavorite(userId, offerId);
      }
      ref.invalidate(favoriteOffersProvider);
    } catch (e) {
      // Fallback on error
      if (isCurrentlyFavorite) {
        state = Set<String>.from(state)..add(offerId);
      } else {
        state = Set<String>.from(state)..remove(offerId);
      }
    }
  }
}
