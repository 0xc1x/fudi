import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/error/data_exceptions.dart';
import '../domain/business_stats.dart';
import '../domain/business_stats_repository.dart';

class SupabaseBusinessStatsRepository implements BusinessStatsRepository {
  SupabaseBusinessStatsRepository({required SupabaseClient supabaseClient})
      : _supabaseClient = supabaseClient;

  final SupabaseClient _supabaseClient;

  @override
  Future<BusinessStats> getBusinessStats(String businessId, {String period = 'month'}) async {
    try {
      // In a real production app, this would be a Supabase RPC for efficiency.
      // For Phase 1, we fetch the data and aggregate client-side to avoid hardcoding.
      
      final now = DateTime.now();
      final startDate = _getStartDate(now, period);
      final prevStartDate = _getStartDate(startDate, period);

      // Fetch current period orders
      final currentOrders = await _fetchOrders(businessId, startDate, now);
      // Fetch previous period orders for comparison
      final previousOrders = await _fetchOrders(businessId, prevStartDate, startDate);

      // Aggregate stats
      final currentStats = _calculatePeriodStats(currentOrders);
      final previousStats = _calculatePeriodStats(previousOrders);

      // Calculate changes
      final revenueChange = _calculateChange(currentStats.revenue, previousStats.revenue);
      final ordersChange = _calculateChange(currentStats.count.toDouble(), previousStats.count.toDouble());
      
      // Top products (from current period)
      final topProducts = _calculateTopProducts(currentOrders);
      
      // Daily stats (last 7 days or based on period)
      final dailyStats = _calculateDailyStats(currentOrders);

      // Get business rating
      final businessResponse = await _supabaseClient
          .from('businesses')
          .select('rating')
          .eq('id', businessId)
          .single();
      
      final rating = (businessResponse['rating'] as num?)?.toDouble() ?? 0.0;

      return BusinessStats(
        revenue: currentStats.revenue,
        ordersCount: currentStats.count,
        rescuedCount: currentStats.count, // In Fudi, 1 order = 1 rescued meal
        avgRating: rating,
        revenueChange: revenueChange,
        ordersChange: ordersChange,
        rescuedChange: ordersChange,
        topProducts: topProducts,
        dailyStats: dailyStats,
      );
    } catch (e) {
      throw UnknownDataException(message: 'Error al calcular estadísticas');
    }
  }

  DateTime _getStartDate(DateTime end, String period) {
    switch (period) {
      case 'week':
        return end.subtract(const Duration(days: 7));
      case 'year':
        return DateTime(end.year - 1, end.month, end.day);
      case 'month':
      default:
        return DateTime(end.year, end.month - 1, end.day);
    }
  }

  Future<List<Map<String, dynamic>>> _fetchOrders(String businessId, DateTime start, DateTime end) async {
    final response = await _supabaseClient
        .from('orders')
        .select('id, price, created_at, offers(title)')
        .eq('business_id', businessId)
        .eq('status', 'completed')
        .gte('created_at', start.toIso8601String())
        .lte('created_at', end.toIso8601String());
    
    return List<Map<String, dynamic>>.from(response);
  }

  ({double revenue, int count}) _calculatePeriodStats(List<Map<String, dynamic>> orders) {
    double revenue = 0;
    for (final order in orders) {
      revenue += (order['price'] as num?)?.toDouble() ?? 0.0;
    }
    return (revenue: revenue, count: orders.length);
  }

  double _calculateChange(double current, double previous) {
    if (previous == 0) return current > 0 ? 100 : 0;
    return ((current - previous) / previous) * 100;
  }

  List<TopProductStat> _calculateTopProducts(List<Map<String, dynamic>> orders) {
    final productMap = <String, ({int sold, double revenue})>{};
    
    for (final order in orders) {
      final offer = order['offers'] as Map<String, dynamic>?;
      final title = offer?['title'] as String? ?? 'Desconocido';
      final price = (order['price'] as num?)?.toDouble() ?? 0.0;
      
      final current = productMap[title] ?? (sold: 0, revenue: 0.0);
      productMap[title] = (sold: current.sold + 1, revenue: current.revenue + price);
    }

    final stats = productMap.entries.map((e) => TopProductStat(
      name: e.key,
      sold: e.value.sold,
      revenue: e.value.revenue,
    )).toList();

    stats.sort((a, b) => b.sold.compareTo(a.sold));
    return stats.take(5).toList();
  }

  List<DailyStat> _calculateDailyStats(List<Map<String, dynamic>> orders) {
    final dailyMap = <String, ({int count, double revenue})>{};
    final dayNames = ['Dom', 'Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb'];

    // Initialize last 7 days
    final now = DateTime.now();
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dayName = dayNames[date.weekday % 7];
      dailyMap[dayName] = (count: 0, revenue: 0.0);
    }

    for (final order in orders) {
      final date = DateTime.parse(order['created_at'] as String);
      final dayName = dayNames[date.weekday % 7];
      
      if (dailyMap.containsKey(dayName)) {
        final current = dailyMap[dayName]!;
        dailyMap[dayName] = (
          count: current.count + 1, 
          revenue: current.revenue + ((order['price'] as num?)?.toDouble() ?? 0.0)
        );
      }
    }

    return dailyMap.entries.map((e) => DailyStat(
      day: e.key,
      orders: e.value.count,
      revenue: e.value.revenue,
    )).toList();
  }
}
