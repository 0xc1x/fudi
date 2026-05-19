import 'offer.dart';

abstract class OfferRepository {
  Future<List<Offer>> getPopularOffers({int limit = 10});

  Future<List<Offer>> getPopularOffersFiltered({
    String? category,
    int limit = 10,
  });

  Future<List<Offer>> getNearbyOffers({
    required double lat,
    required double lng,
    double radiusKm = 5,
    int limit = 20,
    String? category,
  });

  Future<List<Offer>> getFilteredOffers({
    required double lat,
    required double lng,
    String? category,
    double? maxPrice,
    double? maxDistanceKm,
    String? searchQuery,
  });

  Future<Offer> getOfferById(String id);

  Stream<Offer> watchOffer(String id);
}
