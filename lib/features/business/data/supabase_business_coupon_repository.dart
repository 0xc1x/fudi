import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/error/data_exceptions.dart';
import '../../../core/error/fudi_exception.dart';
import '../../../core/error/postgrest_exception_mapper.dart';
import '../../orders/domain/coupon.dart';
import '../domain/business_coupon_repository.dart';

class SupabaseBusinessCouponRepository implements BusinessCouponRepository {
  SupabaseBusinessCouponRepository({required SupabaseClient supabaseClient})
    : _supabaseClient = supabaseClient;

  final SupabaseClient _supabaseClient;

  @override
  Future<List<Coupon>> getCoupons(String businessId) async {
    try {
      final rows = await _supabaseClient
          .from('coupons')
          .select()
          .eq('business_id', businessId)
          .order('created_at', ascending: false);
      return rows.map(Coupon.fromJson).toList();
    } on PostgrestException catch (e) {
      throw e.toFudiException(feature: 'business_coupons');
    } on FudiException {
      rethrow;
    } catch (_) {
      throw UnknownDataException(message: 'Error al cargar cupones');
    }
  }

  @override
  Future<Coupon> getCoupon(String id) async {
    try {
      final row = await _supabaseClient
          .from('coupons')
          .select()
          .eq('id', id)
          .single();
      return Coupon.fromJson(row);
    } on PostgrestException catch (e) {
      throw e.toFudiException(feature: 'business_coupons');
    } on FudiException {
      rethrow;
    } catch (_) {
      throw UnknownDataException(message: 'Error al cargar cupón');
    }
  }

  @override
  Future<Coupon> upsertCoupon(Coupon coupon) async {
    try {
      final data = {
        if (coupon.id.isNotEmpty) 'id': coupon.id,
        'business_id': coupon.businessId,
        'code': coupon.code.toUpperCase(),
        'name': coupon.name,
        'type': coupon.type,
        'value': coupon.value,
        'min_order_amount': coupon.minOrderAmount,
        'max_uses': coupon.maxUses,
        'is_active': coupon.isActive,
        'expires_at': coupon.expiresAt?.toIso8601String(),
      };
      final row = await _supabaseClient
          .from('coupons')
          .upsert(data)
          .select()
          .single();
      return Coupon.fromJson(row);
    } on PostgrestException catch (e) {
      throw e.toFudiException(feature: 'business_coupons');
    } on FudiException {
      rethrow;
    } catch (_) {
      throw UnknownDataException(message: 'Error al guardar cupón');
    }
  }

  @override
  Future<void> toggleCouponStatus(String id, bool isActive) async {
    try {
      await _supabaseClient
          .from('coupons')
          .update({'is_active': isActive})
          .eq('id', id);
    } on PostgrestException catch (e) {
      throw e.toFudiException(feature: 'business_coupons');
    } on FudiException {
      rethrow;
    } catch (_) {
      throw UnknownDataException(message: 'Error al cambiar estado del cupón');
    }
  }

  @override
  Future<void> deleteCoupon(String id) async {
    try {
      await _supabaseClient.from('coupons').delete().eq('id', id);
    } on PostgrestException catch (e) {
      throw e.toFudiException(feature: 'business_coupons');
    } on FudiException {
      rethrow;
    } catch (_) {
      throw UnknownDataException(message: 'Error al eliminar cupón');
    }
  }
}
