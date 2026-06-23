import 'dart:math' as math;

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/error/business_exceptions.dart';
import '../../../core/error/data_exceptions.dart';
import '../../../core/error/fudi_exception.dart';
import '../../../core/error/postgrest_exception_mapper.dart';
import '../domain/offer.dart';
import '../domain/offer_category.dart';
import '../domain/offer_repository.dart';

class SupabaseOfferRepository implements OfferRepository {
  SupabaseOfferRepository({required SupabaseClient supabaseClient})
    : _supabaseClient = supabaseClient;

  final SupabaseClient _supabaseClient;

  static const _earthRadiusKm = 6371.0;

  static const kExpiringSoonWindowHours = 3;

  static const _selectFields = '''
  id, business_id, business_location_id, title, description, image, category,
  original_price, discounted_price, stock, initial_stock,
  pickup_start, pickup_end, is_active, rating, review_count,
  created_at,
  businesses:business_id (
    id, name, type, image, rating, review_count
  ),
  business_locations:business_location_id (
    id, name, address, latitude, longitude, zone
  )
  ''';

  @override
  Future<List<Offer>> getPopularOffers({int limit = 10}) async {
    try {
      final response = await _supabaseClient
          .from('offers')
          .select(_selectFields)
          .eq('is_active', true)
          .gt('stock', 0)
          .gt('pickup_end', DateTime.now().toUtc().toIso8601String())
          .order('created_at', ascending: false)
          .limit(limit);

      return response.map(_mapOfferFromJson).toList();
    } on PostgrestException catch (e) {
      throw e.toFudiException(feature: 'offers');
    } on FudiException {
      rethrow;
    } catch (e) {
      throw UnknownDataException(message: 'Error al cargar ofertas populares');
    }
  }

  @override
  Future<List<Offer>> getPopularOffersFiltered({
    String? category,
    int limit = 10,
  }) async {
    try {
      var query = _supabaseClient
          .from('offers')
          .select(_selectFields)
          .eq('is_active', true)
          .gt('stock', 0)
          .gt('pickup_end', DateTime.now().toUtc().toIso8601String());

      if (category != null && category.isNotEmpty) {
        query = query.eq('category', category);
      }

      final response = await query
          .order('created_at', ascending: false)
          .limit(limit);

      return response.map(_mapOfferFromJson).toList();
    } on PostgrestException catch (e) {
      throw e.toFudiException(feature: 'offers');
    } on FudiException {
      rethrow;
    } catch (e) {
      throw UnknownDataException(message: 'Error al cargar ofertas populares');
    }
  }

  @override
  Future<List<Offer>> getNearbyOffers({
    required double lat,
    required double lng,
    double radiusKm = 5,
    int limit = 20,
    String? category,
  }) async {
    try {
      final allOffers = await _fetchActiveOffers(category: category);
      final nearby =
          allOffers.where((offer) {
            if (offer.business.latitude == null ||
                offer.business.longitude == null) {
              return false;
            }
            final distance = _haversineKm(
              lat,
              lng,
              offer.business.latitude!,
              offer.business.longitude!,
            );
            return distance <= radiusKm;
          }).toList()..sort((a, b) {
            final distA = _haversineKm(
              lat,
              lng,
              a.business.latitude ?? 0,
              a.business.longitude ?? 0,
            );
            final distB = _haversineKm(
              lat,
              lng,
              b.business.latitude ?? 0,
              b.business.longitude ?? 0,
            );
            return distA.compareTo(distB);
          });

      return nearby.take(limit).toList();
    } on PostgrestException catch (e) {
      throw e.toFudiException(feature: 'offers');
    } on FudiException {
      rethrow;
    } catch (e) {
      if (e is DataException || e is BusinessRuleException) rethrow;
      throw UnknownDataException(message: 'Error al cargar ofertas cercanas');
    }
  }

  @override
  Future<List<Offer>> getFilteredOffers({
    required double lat,
    required double lng,
    String? category,
    double? maxPrice,
    double? maxDistanceKm,
    String? searchQuery,
  }) async {
    try {
      var query = _supabaseClient
          .from('offers')
          .select(_selectFields)
          .eq('is_active', true)
          .gt('stock', 0)
          .gt('pickup_end', DateTime.now().toUtc().toIso8601String());

      if (category != null && category.isNotEmpty) {
        query = query.eq('category', category);
      }
      if (maxPrice != null) {
        query = query.lte('discounted_price', maxPrice);
      }
      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.or(
          'title.ilike.%$searchQuery%,description.ilike.%$searchQuery%',
        );
      }

      final response = await query.order('created_at', ascending: false);
      var offers = response.map(_mapOfferFromJson).toList();

      if (searchQuery != null && searchQuery.isNotEmpty) {
        final q = searchQuery.toLowerCase();
        offers = offers.where((o) {
          if (o.business.name.toLowerCase().contains(q)) return true;
          if (o.description?.toLowerCase().contains(q) ?? false) return true;
          return false;
        }).toList();
      }

      if (maxDistanceKm != null) {
        offers = offers.where((offer) {
          if (offer.business.latitude == null ||
              offer.business.longitude == null) {
            return false;
          }
          return _haversineKm(
                lat,
                lng,
                offer.business.latitude!,
                offer.business.longitude!,
              ) <=
              maxDistanceKm;
        }).toList();
      }

      return offers;
    } on PostgrestException catch (e) {
      throw e.toFudiException(feature: 'offers');
    } on FudiException {
      rethrow;
    } catch (e) {
      if (e is DataException || e is BusinessRuleException) rethrow;
      throw UnknownDataException(message: 'Error al filtrar ofertas');
    }
  }

  @override
  Future<Offer> getOfferById(String id) async {
    try {
      final response = await _supabaseClient
          .from('offers')
          .select(_selectFields)
          .eq('id', id)
          .maybeSingle();

      if (response == null) {
        throw const OfferUnavailableException();
      }

      return _mapOfferFromJson(response);
    } on OfferUnavailableException {
      rethrow;
    } on PostgrestException catch (e) {
      throw e.toFudiException(feature: 'offers');
    } on FudiException {
      rethrow;
    } catch (e) {
      throw UnknownDataException(message: 'Error al cargar la oferta');
    }
  }

  @override
  Stream<Offer> watchOffer(String id) {
    return _supabaseClient
        .from('offers')
        .stream(primaryKey: ['id'])
        .eq('id', id)
        .map((events) {
          if (events.isEmpty) {
            throw const OfferUnavailableException();
          }
          return _mapOfferFromJson(events.first);
        });
  }

  Future<List<Offer>> _fetchActiveOffers({String? category}) async {
    var query = _supabaseClient
        .from('offers')
        .select(_selectFields)
        .eq('is_active', true)
        .gt('stock', 0)
        .gt('pickup_end', DateTime.now().toUtc().toIso8601String());

    if (category != null && category.isNotEmpty) {
      query = query.eq('category', category);
    }

    final response = await query.order('created_at', ascending: false);

    return response.map(_mapOfferFromJson).toList();
  }

  @override
  Future<List<CategoryStat>> getCategoryStats() async {
    try {
      final response = await _supabaseClient
          .from('offers')
          .select('category')
          .eq('is_active', true)
          .gt('stock', 0)
          .gt('pickup_end', DateTime.now().toUtc().toIso8601String());

      final counts = <String, int>{};
      for (final row in response) {
        final cat = row['category'] as String?;
        if (cat != null) {
          final category = OfferCategory.fromDb(cat);
          if (category != null) {
            counts[category.dbValue] = (counts[category.dbValue] ?? 0) + 1;
          }
        }
      }

      final stats = OfferCategory.values.map((cat) {
        return CategoryStat(
          id: cat.dbValue,
          name: cat.dbValue,
          count: counts[cat.dbValue] ?? 0,
          emoji: cat.emoji,
        );
      }).toList();

      stats.sort((a, b) => b.count.compareTo(a.count));
      return stats;
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<AreaStat>> getPopularAreas() async {
    try {
      final response = await _supabaseClient
          .from('offers')
          .select(
            'business_locations!offers_business_location_id_fkey(zone)',
          )
          .eq('is_active', true)
          .gt('stock', 0)
          .gt('pickup_end', DateTime.now().toUtc().toIso8601String())
          .limit(5000);

      final areaCounts = <String, int>{};
      for (final row in response) {
        final location = row['business_locations']
            as Map<String, dynamic>?;
        final zone = location?['zone'] as String?;
        if (zone != null && zone.isNotEmpty) {
          areaCounts[zone] = (areaCounts[zone] ?? 0) + 1;
        }
      }

      final stats = areaCounts.entries
          .map((e) => AreaStat(name: e.key, deals: e.value))
          .toList();

      stats.sort((a, b) => b.deals.compareTo(a.deals));
      return stats.take(5).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<OfferCategory>> getCategories() async {
    return OfferCategory.values.toList();
  }

  @override
  Future<List<Offer>> getExpiringSoonOffers({
    double? lat,
    double? lng,
    double radiusKm = 5,
    int limit = 5,
  }) async {
    try {
      final cutoff = DateTime.now().toUtc().add(
        const Duration(hours: kExpiringSoonWindowHours),
      );
      final allOffers = await _fetchActiveOffers();
      final now = DateTime.now().toUtc();

      var filtered = allOffers.where((offer) {
        return offer.pickupEnd.isAfter(now) && offer.pickupEnd.isBefore(cutoff);
      }).toList();

      if (lat != null && lng != null) {
        filtered = filtered.where((offer) {
          if (offer.business.latitude == null ||
              offer.business.longitude == null) {
            return false;
          }
          return _haversineKm(
                lat,
                lng,
                offer.business.latitude!,
                offer.business.longitude!,
              ) <=
              radiusKm;
        }).toList();
      }

      filtered.sort((a, b) => a.pickupEnd.compareTo(b.pickupEnd));
      return filtered.take(limit).toList();
    } on PostgrestException catch (e) {
      throw e.toFudiException(feature: 'offers');
    } on FudiException {
      rethrow;
    } catch (e) {
      if (e is DataException || e is BusinessRuleException) rethrow;
      throw UnknownDataException(
        message: 'Error al cargar ofertas por expirar',
      );
    }
  }

  @override
  Future<List<Offer>> getRecentOffers({
    double? lat,
    double? lng,
    double radiusKm = 5,
    int limit = 5,
  }) async {
    try {
      final allOffers = await _fetchActiveOffers();

      if (lat != null && lng != null) {
        final nearby = allOffers.where((offer) {
          if (offer.business.latitude == null ||
              offer.business.longitude == null) {
            return false;
          }
          return _haversineKm(
                lat,
                lng,
                offer.business.latitude!,
                offer.business.longitude!,
              ) <=
              radiusKm;
        }).toList();

        nearby.sort((a, b) {
          final da = a.createdAt ?? DateTime(2000);
          final db = b.createdAt ?? DateTime(2000);
          return db.compareTo(da);
        });
        return nearby.take(limit).toList();
      }

      return allOffers.take(limit).toList();
    } on PostgrestException catch (e) {
      throw e.toFudiException(feature: 'offers');
    } on FudiException {
      rethrow;
    } catch (e) {
      if (e is DataException || e is BusinessRuleException) rethrow;
      throw UnknownDataException(
        message: 'Error al cargar ofertas recientes',
      );
    }
  }

  @override
  Future<List<BusinessSummary>> getNearbyBusinesses({
    double? lat,
    double? lng,
    double radiusKm = 5,
    int limit = 5,
  }) async {
    try {
      final allOffers = await _fetchActiveOffers();
      final hasLocation = lat != null && lng != null;

      final businessMap = <String, _BusinessSummaryBuilder>{};
      for (final offer in allOffers) {
        if (hasLocation) {
          if (offer.business.latitude == null ||
              offer.business.longitude == null) {
            continue;
          }
          final distance = _haversineKm(
            lat,
            lng,
            offer.business.latitude!,
            offer.business.longitude!,
          );
          if (distance > radiusKm) continue;
        }

        businessMap.putIfAbsent(
          offer.business.id,
          () => _BusinessSummaryBuilder(id: offer.business.id),
        );
        final builder = businessMap[offer.business.id]!;
        builder.name = offer.business.name;
        builder.type = offer.business.type;
        builder.address = offer.business.address;
        builder.businessLocationId = offer.businessLocationId;
        builder.zone = offer.business.zone;
        builder.imageUrl = offer.business.imageUrl;
        builder.latitude = offer.business.latitude;
        builder.longitude = offer.business.longitude;
        builder.rating = offer.business.rating;
        builder.reviewCount = offer.business.reviewCount;
        builder.activeDealsCount++;
      }

      final businesses = businessMap.values
          .map((b) => b.build())
          .toList()
        ..sort((a, b) {
          final da = a.distanceKm ?? double.infinity;
          final db = b.distanceKm ?? double.infinity;
          return da.compareTo(db);
        });
      return businesses.take(limit).toList();
    } on PostgrestException catch (e) {
      throw e.toFudiException(feature: 'offers');
    } on FudiException {
      rethrow;
    } catch (e) {
      if (e is DataException || e is BusinessRuleException) rethrow;
      throw UnknownDataException(
        message: 'Error al cargar negocios cercanos',
      );
    }
  }

  @override
  Future<List<Offer>> getAllActiveOffers() async {
    try {
      return await _fetchActiveOffers();
    } on PostgrestException catch (e) {
      throw e.toFudiException(feature: 'offers');
    } on FudiException {
      rethrow;
    } catch (e) {
      if (e is DataException || e is BusinessRuleException) rethrow;
      throw UnknownDataException(message: 'Error al cargar ofertas');
    }
  }

  @override
  Future<List<BusinessSummary>> getAllBusinesses({
    double? lat,
    double? lng,
    double radiusKm = 10,
    String? searchQuery,
    String? type,
    int limit = 50,
  }) async {
    try {
      final allOffers = await _fetchActiveOffers();
      final hasLocation = lat != null && lng != null;

      final businessMap = <String, _BusinessSummaryBuilder>{};
      for (final offer in allOffers) {
        if (hasLocation) {
          if (offer.business.latitude == null ||
              offer.business.longitude == null) {
            continue;
          }
          final distance = _haversineKm(
            lat,
            lng,
            offer.business.latitude!,
            offer.business.longitude!,
          );
          if (distance > radiusKm) continue;
        }

        if (type != null &&
            offer.business.type.toLowerCase() != type.toLowerCase()) {
          continue;
        }
        if (searchQuery != null &&
            searchQuery.isNotEmpty &&
            !offer.business.name.toLowerCase().contains(
              searchQuery.toLowerCase(),
            )) {
          continue;
        }

        businessMap.putIfAbsent(
          offer.business.id,
          () => _BusinessSummaryBuilder(id: offer.business.id),
        );
        final builder = businessMap[offer.business.id]!;
        builder.name = offer.business.name;
        builder.type = offer.business.type;
        builder.address = offer.business.address;
        builder.businessLocationId = offer.businessLocationId;
        builder.zone = offer.business.zone;
        builder.imageUrl = offer.business.imageUrl;
        builder.latitude = offer.business.latitude;
        builder.longitude = offer.business.longitude;
        builder.rating = offer.business.rating;
        builder.reviewCount = offer.business.reviewCount;
        builder.activeDealsCount++;
      }

      final businesses = businessMap.values
          .map((b) => b.build())
          .toList()
        ..sort((a, b) => b.activeDealsCount.compareTo(a.activeDealsCount));
      return businesses.take(limit).toList();
    } on PostgrestException catch (e) {
      throw e.toFudiException(feature: 'offers');
    } on FudiException {
      rethrow;
    } catch (e) {
      if (e is DataException || e is BusinessRuleException) rethrow;
      throw UnknownDataException(message: 'Error al cargar negocios');
    }
  }

  Offer _mapOfferFromJson(Map<String, dynamic> json) {
    final businessJson = json['businesses'] as Map<String, dynamic>;
    final locationJson = json['business_locations']
        as Map<String, dynamic>?;

    return Offer(
      id: json['id'] as String,
      businessId: json['business_id'] as String,
      businessLocationId: json['business_location_id'] as String,
      business: BusinessInfo(
        id: businessJson['id'] as String,
        name: businessJson['name'] as String,
        type: businessJson['type'] as String,
        imageUrl: businessJson['image'] as String?,
        address: locationJson?['address'] as String? ?? '',
        businessLocationId: locationJson?['id'] as String?,
        latitude: _toDouble(locationJson?['latitude']),
        longitude: _toDouble(locationJson?['longitude']),
        zone: locationJson?['zone'] as String?,
        rating: _toDouble(businessJson['rating']) ?? 0.0,
        reviewCount: businessJson['review_count'] as int? ?? 0,
      ),
      title: json['title'] as String,
      description: json['description'] as String?,
      imageUrl: json['image'] as String?,
      category: OfferCategory.fromDb(json['category'] as String?),
      originalPrice: _toDouble(json['original_price']) ?? 0.0,
      discountedPrice: _toDouble(json['discounted_price']) ?? 0.0,
      stock: json['stock'] as int? ?? 0,
      initialStock: json['initial_stock'] as int? ?? 0,
      pickupStart: DateTime.parse(json['pickup_start'] as String),
      pickupEnd: DateTime.parse(json['pickup_end'] as String),
      isActive: json['is_active'] as bool? ?? false,
      rating: _toDouble(json['rating']) ?? 0.0,
      reviewCount: json['review_count'] as int? ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();
    return null;
  }

  double _haversineKm(double lat1, double lng1, double lat2, double lng2) {
    final dLat = _toRad(lat2 - lat1);
    final dLng = _toRad(lng2 - lng1);
    final a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRad(lat1)) *
            math.cos(_toRad(lat2)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return _earthRadiusKm * c;
  }

  double _toRad(double deg) => deg * math.pi / 180;
}

class _BusinessSummaryBuilder {
  _BusinessSummaryBuilder({required this.id});
  final String id;
  String name = '';
  String type = '';
  String address = '';
  String? businessLocationId;
  String? zone;
  String? imageUrl;
  double? latitude;
  double? longitude;
  double rating = 0;
  int reviewCount = 0;
  int activeDealsCount = 0;
  double? distanceKm;

  BusinessSummary build() {
    return BusinessSummary(
      id: id,
      name: name,
      type: type,
      address: address,
      businessLocationId: businessLocationId,
      zone: zone,
      imageUrl: imageUrl,
      latitude: latitude,
      longitude: longitude,
      rating: rating,
      reviewCount: reviewCount,
      activeDealsCount: activeDealsCount,
      distanceKm: distanceKm,
    );
  }
}
