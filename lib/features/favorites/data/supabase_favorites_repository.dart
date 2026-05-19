import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/favorite_offer.dart';
import '../domain/favorites_repository.dart';

class SupabaseFavoritesRepository implements FavoritesRepository {
  SupabaseFavoritesRepository({required SupabaseClient supabaseClient})
    : _supabaseClient = supabaseClient;

  final SupabaseClient _supabaseClient;

  @override
  Future<List<FavoriteOffer>> getFavorites(String userId) async {
    final response = await _supabaseClient
        .from('favorites')
        .select('''
          id,
          offers:offer_id (
            id,
            title,
            category,
            image,
            original_price,
            discounted_price,
            rating,
            businesses:business_id (
              name,
              address
            )
          )
        ''')
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return response.map(_mapFavorite).toList();
  }

  @override
  Future<void> removeFavorite(String userId, String favoriteId) async {
    await _supabaseClient
        .from('favorites')
        .delete()
        .eq('user_id', userId)
        .eq('id', favoriteId);
  }

  FavoriteOffer _mapFavorite(Map<String, dynamic> json) {
    final offerJson = json['offers'] as Map<String, dynamic>? ?? const {};
    final businessJson =
        offerJson['businesses'] as Map<String, dynamic>? ?? const {};

    return FavoriteOffer(
      favoriteId: json['id'] as String,
      offerId: offerJson['id'] as String? ?? '',
      businessName: businessJson['name'] as String? ?? 'Negocio',
      address: businessJson['address'] as String? ?? '',
      category: offerJson['category'] as String?,
      title: offerJson['title'] as String? ?? 'Oferta',
      rating: _toDouble(offerJson['rating']) ?? 0,
      discountedPrice: _toDouble(offerJson['discounted_price']) ?? 0,
      originalPrice: _toDouble(offerJson['original_price']) ?? 0,
      imageUrl: offerJson['image'] as String?,
    );
  }

  double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();
    return null;
  }
}
