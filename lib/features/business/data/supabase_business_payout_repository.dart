import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/error/data_exceptions.dart';
import '../../../core/error/fudi_exception.dart';
import '../../../core/error/postgrest_exception_mapper.dart';
import '../domain/business_payout.dart';
import '../domain/business_payout_repository.dart';

class SupabaseBusinessPayoutRepository implements BusinessPayoutRepository {
  SupabaseBusinessPayoutRepository({required SupabaseClient supabaseClient})
    : _supabaseClient = supabaseClient;

  final SupabaseClient _supabaseClient;

  static const _fields =
      'id,business_id,period_start,period_end,gross_amount,platform_fee,net_amount,status,gateway_payout_id,paid_at,created_at';

  @override
  Future<List<BusinessPayout>> getPayouts(String businessId) async {
    try {
      final rows = await _supabaseClient
          .from('payouts')
          .select(_fields)
          .eq('business_id', businessId)
          .order('period_end', ascending: false);
      return rows.map(_fromJson).toList();
    } on PostgrestException catch (e) {
      throw e.toFudiException(feature: 'business_payouts');
    } on FudiException {
      rethrow;
    } catch (_) {
      throw UnknownDataException(message: 'Error al cargar pagos');
    }
  }

  @override
  Future<BusinessPayout> getPayout(String id) async {
    try {
      final row = await _supabaseClient
          .from('payouts')
          .select(_fields)
          .eq('id', id)
          .single();
      return _fromJson(row);
    } on PostgrestException catch (e) {
      throw e.toFudiException(feature: 'business_payouts');
    } on FudiException {
      rethrow;
    } catch (_) {
      throw UnknownDataException(message: 'Error al cargar detalle del pago');
    }
  }

  BusinessPayout _fromJson(Map<String, dynamic> json) => BusinessPayout(
    id: json['id'] as String,
    businessId: json['business_id'] as String,
    periodStart: DateTime.parse(json['period_start'] as String),
    periodEnd: DateTime.parse(json['period_end'] as String),
    grossAmount: _toDouble(json['gross_amount']) ?? 0,
    platformFee: _toDouble(json['platform_fee']) ?? 0,
    netAmount: _toDouble(json['net_amount']) ?? 0,
    status: BusinessPayoutStatus.fromString(json['status'] as String?),
    gatewayPayoutId: json['gateway_payout_id'] as String?,
    paidAt: json['paid_at'] != null
        ? DateTime.parse(json['paid_at'] as String)
        : null,
    createdAt: json['created_at'] != null
        ? DateTime.parse(json['created_at'] as String)
        : null,
  );

  double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return null;
  }
}
