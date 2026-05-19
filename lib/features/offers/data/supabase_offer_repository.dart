import 'dart:math' as math;

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/error/business_exceptions.dart';
import '../../../core/error/data_exceptions.dart';
import '../domain/offer.dart';
import '../domain/offer_repository.dart';

class SupabaseOfferRepository implements OfferRepository {
  SupabaseOfferRepository({required SupabaseClient supabaseClient})
    : _supabaseClient = supabaseClient;

  final SupabaseClient _supabaseClient;

  static const _earthRadiusKm = 6371.0;

  static const _selectFields = '''
    id, business_id, title, description, image, category,
    original_price, discounted_price, rating, stock, initial_stock,
    pickup_start, pickup_end, is_active,
    businesses:business_id (
      id, name, type, image, latitude, longitude, rating, address
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
          .order('rating', ascending: false, nullsFirst: false)
          .limit(limit);

      return response.map(_mapOfferFromJson).toList();
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
          .order('rating', ascending: false, nullsFirst: false)
          .limit(limit);

      return response.map(_mapOfferFromJson).toList();
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
        query = query.ilike('title', '%$searchQuery%');
      }

      final response = await query.order(
        'rating',
        ascending: false,
        nullsFirst: false,
      );
      var offers = response.map(_mapOfferFromJson).toList();

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

    final response = await query
        .order('rating', ascending: false, nullsFirst: false);

    return response.map(_mapOfferFromJson).toList();
  }

  @override
  Future<List<CategoryStat>> getCategoryStats() async {
    try {
      // Get counts from Supabase
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
          counts[cat] = (counts[cat] ?? 0) + 1;
        }
      }

      // Map to CategoryStat with emoji/name mapping
      final stats = counts.entries.map((e) {
        final (name, emoji) = _getCategoryInfo(e.key);
        return CategoryStat(
          id: e.key,
          name: name,
          count: e.value,
          emoji: emoji,
        );
      }).toList();

      // Sort by count descending
      stats.sort((a, b) => b.count.compareTo(a.count));
      return stats;
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<AreaStat>> getPopularAreas() async {
    try {
      // In a real app, we might use a specific table or RPC
      // For now, we'll derive it from business addresses (first part of address)
      final response = await _supabaseClient
          .from('offers')
          .select('businesses(address)')
          .eq('is_active', true)
          .gt('stock', 0)
          .gt('pickup_end', DateTime.now().toUtc().toIso8601String());

      final areaCounts = <String, int>{};
      for (final row in response) {
        final business = row['businesses'] as Map<String, dynamic>?;
        final address = business?['address'] as String?;
        if (address != null) {
          final area = address.split(',').first.trim();
          areaCounts[area] = (areaCounts[area] ?? 0) + 1;
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

  (String, String) _getCategoryInfo(String id) {
    return switch (id.toLowerCase()) {
      'bakery' => ('Panadería', '🥖'),
      'restaurant' => ('Restaurante', '🍽️'),
      'cafe' => ('Café', '☕'),
      'grocery' => ('Mercado', '🛒'),
      'pastry' => ('Pastelería', '🍰'),
      'asian' => ('Asiática', '🍜'),
      'italian' => ('Italiana', '🍕'),
      'healthy' => ('Saludable', '🥗'),
      _ => (id[0].toUpperCase() + id.substring(1), '📦'),
    };
  }

  Offer _mapOfferFromJson(Map<String, dynamic> json) {
    final businessJson = json['businesses'] as Map<String, dynamic>;

    return Offer(
      id: json['id'] as String,
      businessId: json['business_id'] as String,
      business: BusinessInfo(
        id: businessJson['id'] as String,
        name: businessJson['name'] as String,
        type: businessJson['type'] as String,
        imageUrl: businessJson['image'] as String?,
        latitude: _toDouble(businessJson['latitude']),
        longitude: _toDouble(businessJson['longitude']),
        rating: _toDouble(businessJson['rating']) ?? 0.0,
        address: businessJson['address'] as String? ?? '',
      ),
      title: json['title'] as String,
      description: json['description'] as String?,
      imageUrl: json['image'] as String?,
      category: json['category'] as String?,
      originalPrice: _toDouble(json['original_price']) ?? 0.0,
      discountedPrice: _toDouble(json['discounted_price']) ?? 0.0,
      rating: _toDouble(json['rating']) ?? 0.0,
      stock: json['stock'] as int? ?? 0,
      initialStock: json['initial_stock'] as int? ?? 0,
      pickupStart: DateTime.parse(json['pickup_start'] as String),
      pickupEnd: DateTime.parse(json['pickup_end'] as String),
      isActive: json['is_active'] as bool? ?? false,
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
