import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/profile_order_repository.dart';
import '../domain/user_order.dart';

class SupabaseProfileOrderRepository implements ProfileOrderRepository {
  SupabaseProfileOrderRepository({required SupabaseClient supabaseClient})
      : _supabaseClient = supabaseClient;

  final SupabaseClient _supabaseClient;

  static const _co2KgPerOrder = 1.2;

  @override
  Future<UserStats> getUserStats(String userId) async {
    final response = await _supabaseClient
        .from('orders')
        .select('price, original_price')
        .eq('user_id', userId)
        .neq('status', 'cancelled');

    final orders = response.toList();
    double totalSaved = 0;
    for (final row in orders) {
      final original = _toDouble(row['original_price']) ?? 0;
      final paid = _toDouble(row['price']) ?? 0;
      totalSaved += original - paid;
    }

    return UserStats(
      totalSaved: totalSaved,
      totalOrders: orders.length,
      co2SavedKg: orders.length * _co2KgPerOrder,
    );
  }

  @override
  Future<List<UserOrder>> getUserOrders(String userId) async {
    final response = await _supabaseClient
        .from('orders')
        .select('''
          id, order_number, status, price, original_price,
          pickup_time, created_at,
          businesses:business_id (name)
        ''')
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return response.map(_mapOrder).toList();
  }

  UserOrder _mapOrder(Map<String, dynamic> json) {
    final businessJson = json['businesses'] as Map<String, dynamic>?;

    return UserOrder(
      id: json['id'] as String,
      orderNumber: json['order_number'] as String,
      businessName: businessJson?['name'] as String? ?? '',
      status: OrderStatus.fromString(json['status'] as String?),
      price: _toDouble(json['price']) ?? 0,
      originalPrice: _toDouble(json['original_price']) ?? 0,
      pickupTime: json['pickup_time'] != null
          ? DateTime.parse(json['pickup_time'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
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
