import 'favorite_offer.dart';

abstract class FavoritesRepository {
  /// Returns the full list of favorite offers for the given user.
  Future<List<FavoriteOffer>> getFavorites(String userId);

  /// Returns a [Set] of offer IDs that the user has favorited.
  /// Used to mark cards as favorited in offer lists.
  Future<Set<String>> getFavoriteOfferIds(String userId);

  /// Adds an offer to the user's favorites. Returns the new favorites row [id].
  Future<String> addFavorite(String userId, String offerId);

  /// Removes a favorite by its row primary-key [favoriteId].
  Future<void> removeFavorite(String userId, String favoriteId);

  /// Removes a favorite by the referenced [offerId] — used for toggle.
  Future<void> removeFavoriteByOfferId(String userId, String offerId);
}
