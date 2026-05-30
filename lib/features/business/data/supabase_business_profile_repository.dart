import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/error/data_exceptions.dart';
import '../../../core/error/fudi_exception.dart';
import '../../../core/error/postgrest_exception_mapper.dart';
import '../domain/business_profile.dart';
import '../domain/business_profile_repository.dart';

class SupabaseBusinessProfileRepository implements BusinessProfileRepository {
  SupabaseBusinessProfileRepository({required SupabaseClient supabaseClient})
    : _supabaseClient = supabaseClient;

  final SupabaseClient _supabaseClient;

  static const _businessSelectFields = '''
    id, name, type, image, cover_image, rating, review_count,
    description, address, phone, email, website,
    latitude, longitude, created_at
  ''';

  @override
  Future<BusinessProfile> getBusinessProfile(String businessId) async {
    try {
      final response = await _supabaseClient
          .from('businesses')
          .select(_businessSelectFields)
          .eq('id', businessId)
          .maybeSingle();

      if (response == null) {
        throw const NotFoundException(message: 'Negocio no encontrado');
      }

      final hoursFuture = getBusinessHours(businessId);
      final reviewsFuture = getBusinessReviews(businessId);

      final hours = await hoursFuture;
      final reviews = await reviewsFuture;

      final ordersResponse = await _supabaseClient
          .from('orders')
          .select('id')
          .eq('business_id', businessId)
          .eq('status', 'completed');

      final totalRescued = ordersResponse.length;

      return _mapBusinessProfile(response, hours, reviews, totalRescued);
    } on NotFoundException {
      rethrow;
    } on PostgrestException catch (e) {
      throw e.toFudiException(feature: 'business_profile');
    } on FudiException {
      rethrow;
    } catch (e) {
      throw UnknownDataException(
        message: 'Error al cargar el perfil del negocio',
      );
    }
  }

  @override
  Future<List<BusinessHours>> getBusinessHours(String businessId) async {
    try {
      final response = await _supabaseClient
          .from('business_hours')
          .select('day, open_time, close_time, is_closed')
          .eq('business_id', businessId)
          .order('day', ascending: true);

      if (response.isEmpty) return [];

      return _groupHours(response.map(_mapHourEntry).toList());
    } catch (_) {
      return [];
    }
  }

  @override
  Future<List<BusinessReview>> getBusinessReviews(
    String businessId, {
    int limit = 5,
  }) async {
    try {
      final response = await _supabaseClient
          .from('reviews')
          .select('''
        id, product_rating, business_rating, comment, created_at,
        profiles!reviews_user_id_fkey(full_name),
        orders!reviews_order_id_fkey(
          offers!orders_offer_id_fkey(title)
        )
      ''')
          .eq('business_id', businessId)
          .order('created_at', ascending: false)
          .limit(limit);

      return response.map(_mapReview).toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<List<BusinessProfile>> getBusinessesByOwnerId(String ownerId) async {
    try {
      final response = await _supabaseClient
          .from('businesses')
          .select(_businessSelectFields)
          .eq('owner_id', ownerId)
          .order('name');

      return response
          .map((json) => _mapBusinessProfile(json, [], [], 0))
          .toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> createBusiness(
    BusinessProfile profile,
    String ownerId, {
    XFile? logoFile,
    XFile? coverFile,
  }) async {
    try {
      String? logoUrl;
      String? coverUrl;

      if (logoFile != null) {
        logoUrl = await _uploadXFile(
          logoFile,
          'logos/${ownerId}_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
      } else if (profile.imageUrl != null &&
          profile.imageUrl!.startsWith('http')) {
        logoUrl = profile.imageUrl;
      }

      if (coverFile != null) {
        coverUrl = await _uploadXFile(
          coverFile,
          'covers/${ownerId}_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
      } else if (profile.coverImageUrl != null &&
          profile.coverImageUrl!.startsWith('http')) {
        coverUrl = profile.coverImageUrl;
      }

      final randomSuffix = Random().nextInt(9999).toString().padLeft(4, '0');
      final slug =
          '${profile.name.toLowerCase().trim().replaceAll(RegExp(r'[^a-z0-9]'), '-').replaceAll(RegExp(r'-+'), '-')}-$randomSuffix';

      final businessData = {
        'owner_id': ownerId,
        'name': profile.name,
        'slug': slug,
        'type': profile.type.toLowerCase(),
        'address': profile.address,
        'phone': profile.phone,
        'email': profile.email,
        'description': profile.description,
        'image': logoUrl,
        'cover_image': coverUrl,
        'website': profile.website,
        'latitude': profile.latitude,
        'longitude': profile.longitude,
        'rating': 0.0,
        'review_count': 0,
      };

      final response = await _supabaseClient
          .from('businesses')
          .insert(businessData)
          .select('id')
          .single();

      final businessId = response['id'] as String;

      if (profile.hours.isNotEmpty) {
        final hoursData = profile.hours.map((h) {
          final isClosed = h.hours.toLowerCase().contains('cerrado');
          String open = '00:00';
          String close = '00:00';

          if (!isClosed) {
            final parts = h.hours.split('-').map((s) => s.trim()).toList();
            if (parts.length == 2) {
              open = _parseToTime(parts[0]);
              close = _parseToTime(parts[1]);
            }
          }

          return {
            'business_id': businessId,
            'day': _mapDayToDb(h.day),
            'open_time': open,
            'close_time': close,
            'is_closed': isClosed,
          };
        }).toList();

        await _supabaseClient.from('business_hours').insert(hoursData);
      }

      if (profile.address.isNotEmpty &&
          profile.latitude != null &&
          profile.longitude != null) {
        await _supabaseClient.from('business_locations').insert({
          'business_id': businessId,
          'name': profile.name,
          'address': profile.address,
          'phone': profile.phone,
          'latitude': profile.latitude,
          'longitude': profile.longitude,
        });
      }
    } on PostgrestException catch (e) {
      throw e.toFudiException(feature: 'business_profile');
    } on FudiException {
      rethrow;
    } catch (e) {
      throw UnknownDataException(message: 'Error al crear el negocio');
    }
  }

  Future<String> _uploadXFile(XFile xFile, String remotePath) async {
    try {
      final bytes = await xFile.readAsBytes();

      await _supabaseClient.storage
          .from('business_images')
          .uploadBinary(
            remotePath,
            bytes,
            fileOptions: const FileOptions(
              contentType: 'image/jpeg',
              upsert: true,
            ),
          );

      return _supabaseClient.storage
          .from('business_images')
          .getPublicUrl(remotePath);
    } catch (e) {
      return xFile.path;
    }
  }

  // ─── Mapping helpers ──────────────────────────────────────────

  BusinessProfile _mapBusinessProfile(
    Map<String, dynamic> json,
    List<BusinessHours> hours,
    List<BusinessReview> reviews,
    int totalRescued,
  ) {
    final createdAt = json['created_at'] as String?;
    String? memberSince;
    if (createdAt != null) {
      final dt = DateTime.parse(createdAt);
      memberSince = _formatMemberSince(dt);
    }

    return BusinessProfile(
      id: json['id'] as String,
      name: json['name'] as String,
      type: _mapBusinessType(json['type'] as String?),
      address: json['address'] as String? ?? '',
      rating: _toDouble(json['rating']) ?? 0.0,
      imageUrl: json['image'] as String?,
      coverImageUrl: json['cover_image'] as String?,
      description: json['description'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      website: json['website'] as String?,
      latitude: _toDouble(json['latitude']),
      longitude: _toDouble(json['longitude']),
      reviewCount: json['review_count'] as int? ?? 0,
      totalRescued: totalRescued,
      memberSince: memberSince,
      hours: hours,
      reviews: reviews,
    );
  }

  ({String day, String open, String close, bool isClosed}) _mapHourEntry(
    Map<String, dynamic> json,
  ) {
    return (
      day: json['day'] as String,
      open: json['open_time'] as String? ?? '00:00',
      close: json['close_time'] as String? ?? '00:00',
      isClosed: json['is_closed'] as bool? ?? false,
    );
  }

  List<BusinessHours> _groupHours(
    List<({String day, String open, String close, bool isClosed})> entries,
  ) {
    if (entries.isEmpty) return [];

    final dayLabels = {
      'monday': 'Lunes',
      'tuesday': 'Martes',
      'wednesday': 'Miércoles',
      'thursday': 'Jueves',
      'friday': 'Viernes',
      'saturday': 'Sábado',
      'sunday': 'Domingo',
    };

    final result = <BusinessHours>[];
    var rangeStart = entries.first;
    var rangeEnd = entries.first;

    for (var i = 1; i < entries.length; i++) {
      final entry = entries[i];
      final sameHours =
          entry.open == rangeEnd.open &&
          entry.close == rangeEnd.close &&
          entry.isClosed == rangeEnd.isClosed;

      if (sameHours) {
        rangeEnd = entry;
      } else {
        result.add(_buildHoursRange(rangeStart, rangeEnd, dayLabels));
        rangeStart = entry;
        rangeEnd = entry;
      }
    }
    result.add(_buildHoursRange(rangeStart, rangeEnd, dayLabels));

    return result;
  }

  BusinessHours _buildHoursRange(
    ({String day, String open, String close, bool isClosed}) start,
    ({String day, String open, String close, bool isClosed}) end,
    Map<String, String> dayLabels,
  ) {
    final startLabel = dayLabels[start.day] ?? start.day;
    final endLabel = dayLabels[end.day] ?? end.day;

    final dayRange = start.day == end.day
        ? startLabel
        : '$startLabel - $endLabel';

    final hoursDisplay = start.isClosed
        ? 'Cerrado'
        : '${_formatTime(start.open)} - ${_formatTime(end.close)}';

    return BusinessHours(day: dayRange, hours: hoursDisplay);
  }

  BusinessReview _mapReview(Map<String, dynamic> json) {
  final profile = json['profiles'] as Map<String, dynamic>?;
  final order = json['orders'] as Map<String, dynamic>?;
  final offer = order?['offers'] as Map<String, dynamic>?;

  return BusinessReview(
    id: json['id'] as String,
    userName: profile?['full_name'] as String? ?? 'Usuario',
    productRating: json['product_rating'] as int,
    businessRating: json['business_rating'] as int,
    date: DateTime.parse(json['created_at'] as String),
    comment: json['comment'] as String?,
    productName: offer?['title'] as String?,
  );
}

  String _parseToTime(String time) {
    final parts = time.split(':');
    if (parts.length == 2) {
      return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}:00';
    }
    return '00:00:00';
  }

  String _mapDayToDb(String day) {
    final mapping = {
      'Lunes': 'monday',
      'Martes': 'tuesday',
      'Miércoles': 'wednesday',
      'Jueves': 'thursday',
      'Viernes': 'friday',
      'Sábado': 'saturday',
      'Domingo': 'sunday',
    };
    return mapping[day] ?? day.toLowerCase();
  }

  double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();
    return null;
  }

  String _formatTime(String time) {
    final parts = time.split(':');
    if (parts.length >= 2) {
      return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
    }
    return time;
  }

  String _mapBusinessType(String? type) {
    return switch (type?.toLowerCase()) {
      'restaurant' => 'Restaurante',
      'bakery' => 'Panadería',
      'cafe' => 'Cafetería',
      'grocery' => 'Supermercado',
      'other' => 'Otro',
      _ => type ?? '',
    };
  }

  String _formatMemberSince(DateTime dt) {
    const months = [
      '',
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre',
    ];
    return '${months[dt.month]} ${dt.year}';
  }
}
