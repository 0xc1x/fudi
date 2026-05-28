import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/error/data_exceptions.dart';
import '../../../core/error/fudi_exception.dart';
import '../../../core/error/postgrest_exception_mapper.dart';
import '../domain/business_location.dart';
import '../domain/business_location_repository.dart';

class SupabaseBusinessLocationRepository implements BusinessLocationRepository {
  SupabaseBusinessLocationRepository({required SupabaseClient supabaseClient})
    : _supabaseClient = supabaseClient;

  final SupabaseClient _supabaseClient;

  static const _fields =
      'id,business_id,name,address,phone,latitude,longitude,is_active,created_at';

  @override
  Future<List<BusinessLocation>> getLocations(String businessId) async {
    try {
      final rows = await _supabaseClient
          .from('business_locations')
          .select(_fields)
          .eq('business_id', businessId)
          .order('created_at', ascending: false);
      return rows.map(_fromJson).toList();
    } on PostgrestException catch (e) {
      throw e.toFudiException(feature: 'business_locations');
    } on FudiException {
      rethrow;
    } catch (_) {
      throw UnknownDataException(message: 'Error al cargar locales');
    }
  }

  @override
  Future<BusinessLocation> getLocation(String id) async {
    try {
      final row = await _supabaseClient
          .from('business_locations')
          .select(_fields)
          .eq('id', id)
          .single();
      return _fromJson(row);
    } on PostgrestException catch (e) {
      throw e.toFudiException(feature: 'business_locations');
    } on FudiException {
      rethrow;
    } catch (_) {
      throw UnknownDataException(message: 'Error al cargar el local');
    }
  }

  @override
  Future<BusinessLocation> upsertLocation(BusinessLocation location) async {
    try {
      final data = {
        if (location.id.isNotEmpty) 'id': location.id,
        'business_id': location.businessId,
        'name': location.name,
        'address': location.address,
        'phone': location.phone,
        'latitude': location.latitude,
        'longitude': location.longitude,
        'is_active': location.isActive,
      };

      final row = await _supabaseClient
          .from('business_locations')
          .upsert(data)
          .select(_fields)
          .single();
      return _fromJson(row);
    } on PostgrestException catch (e) {
      throw e.toFudiException(feature: 'business_locations');
    } on FudiException {
      rethrow;
    } catch (_) {
      throw UnknownDataException(message: 'Error al guardar el local');
    }
  }

  @override
  Future<void> toggleLocationStatus(String id, bool isActive) async {
    try {
      await _supabaseClient
          .from('business_locations')
          .update({'is_active': isActive})
          .eq('id', id);
    } on PostgrestException catch (e) {
      throw e.toFudiException(feature: 'business_locations');
    } on FudiException {
      rethrow;
    } catch (_) {
      throw UnknownDataException(message: 'Error al cambiar estado del local');
    }
  }

  BusinessLocation _fromJson(Map<String, dynamic> json) {
    return BusinessLocation(
      id: json['id'] as String,
      businessId: json['business_id'] as String,
      name: json['name'] as String? ?? '',
      address: json['address'] as String? ?? '',
      phone: json['phone'] as String?,
      latitude: _toDouble(json['latitude']),
      longitude: _toDouble(json['longitude']),
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return null;
  }
}
