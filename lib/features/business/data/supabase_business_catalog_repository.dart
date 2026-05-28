import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/error/data_exceptions.dart';
import '../../../core/error/fudi_exception.dart';
import '../../../core/error/postgrest_exception_mapper.dart';
import '../../offers/domain/offer.dart';
import '../domain/business_catalog_repository.dart';

class SupabaseBusinessCatalogRepository implements BusinessCatalogRepository {
  SupabaseBusinessCatalogRepository({required SupabaseClient supabaseClient})
    : _supabaseClient = supabaseClient;

  final SupabaseClient _supabaseClient;

  static const _selectFields = '''
    id, business_id, title, description, image, category,
    original_price, discounted_price, rating, stock, initial_stock,
    pickup_start, pickup_end, is_active, includes, allergens,
    businesses:business_id (
      id, name, type, image, latitude, longitude, rating, address
    )
  ''';

  @override
  Future<List<Offer>> getBusinessOffers(String businessId) async {
    try {
      final response = await _supabaseClient
          .from('offers')
          .select(_selectFields)
          .eq('business_id', businessId)
          .order('created_at', ascending: false);

      return response.map((json) => _mapOfferFromJson(json)).toList();
    } on PostgrestException catch (e) {
      throw e.toFudiException(feature: 'catalog');
    } on FudiException {
      rethrow;
    } catch (e) {
      throw UnknownDataException(message: 'Error al cargar el catálogo');
    }
  }

  @override
  Future<Offer> createOffer(Offer offer, {XFile? imageFile}) async {
    try {
      String? imageUrl;

      if (imageFile != null) {
        imageUrl = await _uploadXFile(
          imageFile,
          'products/${offer.businessId}_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
      } else if (offer.imageUrl != null && offer.imageUrl!.startsWith('http')) {
        imageUrl = offer.imageUrl;
      }

      final data = _mapOfferToJson(offer);
      data['image'] = imageUrl;

      final response = await _supabaseClient
          .from('offers')
          .insert(data)
          .select(_selectFields)
          .single();

      return _mapOfferFromJson(response);
    } on PostgrestException catch (e) {
      throw e.toFudiException(feature: 'catalog');
    } on FudiException {
      rethrow;
    } catch (e) {
      throw UnknownDataException(message: 'Error al crear la oferta');
    }
  }

  @override
  Future<Offer> updateOffer(Offer offer, {XFile? imageFile}) async {
    try {
      String? imageUrl;

      if (imageFile != null) {
        imageUrl = await _uploadXFile(
          imageFile,
          'products/${offer.businessId}_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
      } else if (offer.imageUrl != null && offer.imageUrl!.startsWith('http')) {
        imageUrl = offer.imageUrl;
      }

      final data = _mapOfferToJson(offer);
      data['image'] = imageUrl;

      final response = await _supabaseClient
          .from('offers')
          .update(data)
          .eq('id', offer.id)
          .select(_selectFields)
          .single();

      return _mapOfferFromJson(response);
    } on PostgrestException catch (e) {
      throw e.toFudiException(feature: 'catalog');
    } on FudiException {
      rethrow;
    } catch (e) {
      throw UnknownDataException(message: 'Error al actualizar la oferta');
    }
  }

  Future<String> _uploadXFile(XFile xFile, String remotePath) async {
    try {
      final bytes = await xFile.readAsBytes();

      await _supabaseClient.storage
          .from('product_images')
          .uploadBinary(
            remotePath,
            bytes,
            fileOptions: const FileOptions(
              contentType: 'image/jpeg',
              upsert: true,
            ),
          );

      return _supabaseClient.storage
          .from('product_images')
          .getPublicUrl(remotePath);
    } catch (e) {
      return xFile.path;
    }
  }

  @override
  Future<void> deleteOffer(String offerId) async {
    try {
      await _supabaseClient.from('offers').delete().eq('id', offerId);
    } on PostgrestException catch (e) {
      throw e.toFudiException(feature: 'catalog');
    } on FudiException {
      rethrow;
    } catch (e) {
      throw UnknownDataException(message: 'Error al eliminar la oferta');
    }
  }

  @override
  Future<void> toggleOfferStatus(String offerId, bool isActive) async {
    try {
      await _supabaseClient
          .from('offers')
          .update({'is_active': isActive})
          .eq('id', offerId);
    } on PostgrestException catch (e) {
      throw e.toFudiException(feature: 'catalog');
    } on FudiException {
      rethrow;
    } catch (e) {
      throw UnknownDataException(
        message: 'Error al cambiar el estado de la oferta',
      );
    }
  }

  // ─── Mapping helpers ──────────────────────────────────────────

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
      includes: json['includes'] as String?,
      allergens: json['allergens'] as String?,
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

  Map<String, dynamic> _mapOfferToJson(Offer offer) {
    return {
      'business_id': offer.businessId,
      'title': offer.title,
      'description': offer.description,
      'category': offer.category,
      'includes': offer.includes,
      'allergens': offer.allergens,
      'original_price': offer.originalPrice,
      'discounted_price': offer.discountedPrice,
      'stock': offer.stock,
      'initial_stock': offer.initialStock,
      'pickup_start': offer.pickupStart.toIso8601String(),
      'pickup_end': offer.pickupEnd.toIso8601String(),
      'is_active': offer.isActive,
    };
  }

  double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();
    return null;
  }
}
