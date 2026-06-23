import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/error/data_exceptions.dart';
import '../../../core/error/fudi_exception.dart';
import '../../../core/error/postgrest_exception_mapper.dart';
import '../../orders/domain/order_model.dart';
import '../../orders/domain/order_status.dart';
import '../domain/business_order_repository.dart';
import '../domain/pickup_validation_result.dart';

class SupabaseBusinessOrderRepository implements BusinessOrderRepository {
  SupabaseBusinessOrderRepository({required SupabaseClient supabaseClient})
    : _supabaseClient = supabaseClient;

  final SupabaseClient _supabaseClient;

  static const _selectFields = '''
    id, user_id, offer_id, business_id, order_number, status, 
    price, original_price, pickup_code, pickup_time, coupon_id, created_at,
    offers!orders_offer_id_fkey(
      title, image,
      business_locations:business_location_id (address)
    ),
    businesses!orders_business_id_fkey(name, phone),
    profiles!orders_user_id_fkey(full_name, phone, email)
  ''';

  @override
  Future<List<OrderModel>> getBusinessOrders(String businessId) async {
    try {
      final response = await _supabaseClient
          .from('orders')
          .select(_selectFields)
          .eq('business_id', businessId)
          .order('created_at', ascending: false);

      return response.map(_mapOrderFromJson).toList();
    } catch (e) {
      throw UnknownDataException(message: 'Error al cargar los pedidos');
    }
  }

  @override
  Stream<List<OrderModel>> watchBusinessOrders(String businessId) {
    return _supabaseClient
        .from('orders')
        .stream(primaryKey: ['id'])
        .eq('business_id', businessId)
        .order('created_at', ascending: false)
        .asyncMap((_) => getBusinessOrders(businessId));
  }

  @override
  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    try {
      await _supabaseClient
          .from('orders')
          .update({'status': status.dbValue})
          .eq('id', orderId);
    } catch (e) {
      throw UnknownDataException(
        message: 'Error al actualizar el estado del pedido',
      );
    }
  }

  @override
  Future<PickupValidationResult> validatePickupCode({
    required String orderId,
    required String pickupCode,
  }) async {
    try {
      final response = await _supabaseClient.rpc(
        'validate_pickup_code',
        params: {'p_order_id': orderId, 'p_pickup_code': pickupCode},
      );

      final result = response as Map<String, dynamic>;

      if (result['success'] == true) {
        return PickupValidationResult(
          success: true,
          orderId: result['order_id'] as String?,
        );
      }

      return PickupValidationResult(
        success: false,
        errorCode: result['error'] as String?,
        message: result['message'] as String?,
      );
    } on PostgrestException catch (e) {
      throw e.toFudiException(feature: 'business');
    } on FudiException {
      rethrow;
    } catch (e) {
      throw UnknownDataException(
        message: 'Error al validar el código de recogida',
      );
    }
  }

  OrderModel _mapOrderFromJson(Map<String, dynamic> json) {
    final offer = json['offers'] as Map<String, dynamic>?;
    final business = json['businesses'] as Map<String, dynamic>?;
    final customer = json['profiles'] as Map<String, dynamic>?;
    final location =
        offer?['business_locations'] as Map<String, dynamic>?;

    return OrderModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      offerId: json['offer_id'] as String,
      businessId: json['business_id'] as String,
      orderNumber: json['order_number'] as String? ?? '',
      status: OrderStatus.fromString(json['status'] as String?),
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      originalPrice: (json['original_price'] as num?)?.toDouble() ?? 0.0,
      pickupCode: json['pickup_code'] as String? ?? '',
      pickupTime: json['pickup_time'] != null
          ? DateTime.parse(json['pickup_time'] as String)
          : null,
      couponId: json['coupon_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      offerTitle: offer?['title'] as String? ?? 'Oferta',
      offerImageUrl: offer?['image'] as String?,
      businessName: business?['name'] as String? ?? 'Negocio',
      businessAddress: location?['address'] as String?,
      businessPhone: business?['phone'] as String?,
      customerName: customer?['full_name'] as String?,
      customerPhone: customer?['phone'] as String?,
      customerEmail: customer?['email'] as String?,
    );
  }
}
