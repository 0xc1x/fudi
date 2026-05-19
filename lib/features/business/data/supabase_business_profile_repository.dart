import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/error/data_exceptions.dart';
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
      // Fetch business row
      final response = await _supabaseClient
          .from('businesses')
          .select(_businessSelectFields)
          .eq('id', businessId)
          .maybeSingle();

      if (response == null) {
        throw const NotFoundException(message: 'Negocio no encontrado');
      }

      // Fetch hours and reviews in parallel
      final hoursFuture = getBusinessHours(businessId);
      final reviewsFuture = getBusinessReviews(businessId);

      final hours = await hoursFuture;
      final reviews = await reviewsFuture;

      // Count total rescued from completed orders
      final ordersResponse = await _supabaseClient
          .from('orders')
          .select('id')
          .eq('business_id', businessId)
          .eq('status', 'completed');

      final totalRescued = ordersResponse.length;

      return _mapBusinessProfile(response, hours, reviews, totalRescued);
    } on NotFoundException {
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

      // Group consecutive days with same hours
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
            id, rating, comment, created_at,
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

  /// Groups consecutive days with identical hours into ranges
  /// like "Lunes - Viernes: 6:00 - 21:00".
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
      final sameHours = entry.open == rangeEnd.open &&
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
      rating: json['rating'] as int,
      date: DateTime.parse(json['created_at'] as String),
      comment: json['comment'] as String?,
      productName: offer?['title'] as String?,
    );
  }

  // ─── Utility ──────────────────────────────────────────────────

  double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();
    return null;
  }

  /// Formats "HH:MM:SS" or "HH:MM" to "HH:MM".
  String _formatTime(String time) {
    final parts = time.split(':');
    if (parts.length >= 2) {
      return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
    }
    return time;
  }

  /// Maps the DB enum to a user-friendly Spanish label.
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

  /// Formats a DateTime to a Spanish "Month Year" string.
  String _formatMemberSince(DateTime dt) {
    const months = [
      '', 'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre',
      'Diciembre',
    ];
    return '${months[dt.month]} ${dt.year}';
  }
}
