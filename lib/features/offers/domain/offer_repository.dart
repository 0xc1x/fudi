import 'offer.dart';
import 'offer_category.dart';

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

  Future<List<OfferCategory>> getCategories();

  Future<List<Offer>> getExpiringSoonOffers({
    double? lat,
    double? lng,
    double radiusKm = 5,
    int limit = 5,
  });

  Future<List<Offer>> getRecentOffers({
    double? lat,
    double? lng,
    double radiusKm = 5,
    int limit = 5,
  });

  Future<List<BusinessSummary>> getNearbyBusinesses({
    double? lat,
    double? lng,
    double radiusKm = 5,
    int limit = 5,
  });

  Future<List<Offer>> getAllActiveOffers();

  Future<List<BusinessSummary>> getAllBusinesses({
    double? lat,
    double? lng,
    double radiusKm = 10,
    String? searchQuery,
    String? type,
    int limit = 50,
  });
}

class CategoryStat {
  const CategoryStat({
    required this.id,
    required this.name,
    required this.count,
    required this.emoji,
    required this.imageUrl,
  });

  final String id;
  final String name;
  final int count;
  final String emoji;
  final String imageUrl;
}

class AreaStat {
  const AreaStat({required this.name, required this.deals});

  final String name;
  final int deals;
}
