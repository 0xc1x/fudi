import 'favorite_offer.dart';

abstract class FavoritesRepository {
  Future<List<FavoriteOffer>> getFavorites(String userId);

  Future<void> removeFavorite(String userId, String favoriteId);
}
