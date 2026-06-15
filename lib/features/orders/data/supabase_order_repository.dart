import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/error/business_exceptions.dart';
import '../../../core/error/data_exceptions.dart';
import '../../../core/error/fudi_exception.dart';
import '../../../core/error/postgrest_exception_mapper.dart';
import '../domain/order_model.dart';
import '../domain/order_repository.dart';
import '../domain/order_status.dart';
import '../domain/reservation_result.dart';

class SupabaseOrderRepository implements OrderRepository {
  SupabaseOrderRepository({required SupabaseClient supabaseClient})
    : _supabaseClient = supabaseClient;

  final SupabaseClient _supabaseClient;

  @override
  Future<ReservationResult> reserveOffer({
    required String offerId,
    String? couponId,
  }) async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      if (userId == null) {
        throw const OfferUnavailableException(
          message: 'Debes iniciar sesión para reservar',
        );
      }

      final response = await _supabaseClient.rpc(
        'reserve_offer',
        params: {
          'p_user_id': userId,
          'p_offer_id': offerId,
          'p_coupon_id': couponId,
        },
      );

      final result = response as Map<String, dynamic>;

      if (result['success'] == true) {
        return ReservationSuccess(
          orderId: result['order_id'] as String,
          orderNumber: result['order_number'] as String,
          pickupCode: result['pickup_code'] as String,
          price: _toDouble(result['price']) ?? 0.0,
          originalPrice: _toDouble(result['original_price']) ?? 0.0,
          discount: _toDouble(result['discount']) ?? 0.0,
        );
      }

      final errorCode = result['error'] as String? ?? 'UNKNOWN';
      final message = result['message'] as String? ?? 'Error al reservar';

      return ReservationFailure(errorCode: errorCode, message: message);
    } on BusinessRuleException {
      rethrow;
    } on PostgrestException catch (e) {
      throw e.toFudiException(feature: 'orders');
    } on FudiException {
      rethrow;
    } catch (e, st) {
      throw UnknownDataException(
        message: 'Error al procesar la reserva',
        context: {'originalError': e.toString(), 'stackTrace': st.toString()},
      );
    }
  }

  @override
  Future<List<OrderModel>> getUserOrders() async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      if (userId == null) return [];

      final response = await _supabaseClient
          .from('orders')
          .select('''
          id, user_id, offer_id, business_id, order_number, status,
          price, original_price, pickup_code, pickup_time, coupon_id,
          created_at,
          offers!inner (title, image),
          businesses!inner (name, address, phone)
        ''')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return response.map(_mapOrderFromJson).toList();
    } on PostgrestException catch (e) {
      throw e.toFudiException(feature: 'orders');
    } on FudiException {
      rethrow;
    } catch (e) {
      throw UnknownDataException(message: 'Error al cargar pedidos');
    }
  }

  @override
  Future<OrderModel> getOrderById(String id) async {
    try {
      final response = await _supabaseClient
          .from('orders')
          .select('''
          id, user_id, offer_id, business_id, order_number, status,
          price, original_price, pickup_code, pickup_time, coupon_id,
          created_at,
          offers!inner (title, image),
          businesses!inner (name, address, phone)
        ''')
          .eq('id', id)
          .maybeSingle();

      if (response == null) {
        throw const NotFoundException(message: 'Pedido no encontrado');
      }

      return _mapOrderFromJson(response);
    } on DataException {
      rethrow;
    } on PostgrestException catch (e) {
      throw e.toFudiException(feature: 'orders');
    } on FudiException {
      rethrow;
    } catch (e) {
      throw UnknownDataException(message: 'Error al cargar el pedido');
    }
  }

  @override
  Stream<OrderModel> watchOrder(String id) {
    return _supabaseClient
        .from('orders')
        .stream(primaryKey: ['id'])
        .eq('id', id)
        .asyncMap((_) => getOrderById(id));
  }

  @override
  Stream<List<OrderModel>> watchUserOrders() {
    final userId = _supabaseClient.auth.currentUser?.id;
    if (userId == null) {
      return Stream.value([]);
    }
    return _supabaseClient
        .from('orders')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at')
        .asyncMap((_) => getUserOrders());
  }

  @override
  Future<CancelOrderResult> cancelOrder(String orderId) async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      if (userId == null) {
        return const CancelOrderResult(
          success: false,
          errorCode: 'NOT_AUTHENTICATED',
          message: 'Debes iniciar sesión para cancelar',
        );
      }

      final response = await _supabaseClient.rpc(
        'cancel_order',
        params: {'p_user_id': userId, 'p_order_id': orderId},
      );

      final result = response as Map<String, dynamic>;

      if (result['success'] == true) {
        return CancelOrderResult(
          success: true,
          orderId: result['order_id'] as String?,
        );
      }

      return CancelOrderResult(
        success: false,
        errorCode: result['error'] as String? ?? 'UNKNOWN',
        message: result['message'] as String? ?? 'Error al cancelar',
      );
    } on BusinessRuleException {
      rethrow;
    } on PostgrestException catch (e) {
      throw e.toFudiException(feature: 'orders');
    } on FudiException {
      rethrow;
    } catch (e) {
      throw UnknownDataException(message: 'Error al cancelar el pedido');
    }
  }

  OrderModel _mapOrderFromJson(Map<String, dynamic> json) {
    final offerJson = json['offers'] as Map<String, dynamic>?;
    final businessJson = json['businesses'] as Map<String, dynamic>?;

    return OrderModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      offerId: json['offer_id'] as String,
      businessId: json['business_id'] as String,
      orderNumber: json['order_number'] as String,
      status: OrderStatus.fromString(json['status'] as String?),
      price: _toDouble(json['price']) ?? 0.0,
      originalPrice: _toDouble(json['original_price']) ?? 0.0,
      pickupCode: json['pickup_code'] as String? ?? '',
      pickupTime: json['pickup_time'] != null
          ? DateTime.parse(json['pickup_time'] as String)
          : null,
      couponId: json['coupon_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      offerTitle: offerJson?['title'] as String? ?? '',
      offerImageUrl: offerJson?['image'] as String?,
      businessName: businessJson?['name'] as String? ?? '',
      businessAddress: businessJson?['address'] as String?,
      businessPhone: businessJson?['phone'] as String?,
    );
  }

  double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();
    return null;
  }
}
