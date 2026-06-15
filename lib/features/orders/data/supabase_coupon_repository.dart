import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/coupon.dart';
import '../domain/coupon_repository.dart';

class SupabaseCouponRepository implements CouponRepository {
  SupabaseCouponRepository({required SupabaseClient supabaseClient})
    : _supabaseClient = supabaseClient;

  final SupabaseClient _supabaseClient;

  @override
  Future<Coupon?> getCouponByCode(String code, String businessId) async {
    final response = await _supabaseClient
        .from('coupons')
        .select()
        .eq('code', code.toUpperCase())
        .eq('business_id', businessId)
        .eq('is_active', true)
        .maybeSingle();

    if (response == null) return null;
    return Coupon.fromJson(response);
  }
}
