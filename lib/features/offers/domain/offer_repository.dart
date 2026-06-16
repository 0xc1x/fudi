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

  Future<List<CategoryStat>> getCategoryStats();

  Future<List<AreaStat>> getPopularAreas();

  Future<List<String>> getCategories();
}

class CategoryStat {
  const CategoryStat({
    required this.id,
    required this.name,
    required this.count,
    required this.emoji,
  });

  final String id;
  final String name;
  final int count;
  final String emoji;
}

class AreaStat {
  const AreaStat({required this.name, required this.deals});

  final String name;
  final int deals;
}
