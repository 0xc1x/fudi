import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/error/data_exceptions.dart';
import '../domain/business_stats.dart';
import '../domain/business_stats_repository.dart';

class SupabaseBusinessStatsRepository implements BusinessStatsRepository {
  SupabaseBusinessStatsRepository({required SupabaseClient supabaseClient})
    : _supabaseClient = supabaseClient;

  final SupabaseClient _supabaseClient;

  @override
  Future<BusinessStats> getBusinessStats(
    String businessId, {
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final duration = endDate.difference(startDate);
      final prevStartDate = startDate.subtract(duration);
      final prevEndDate = startDate;

      final currentOrders = await _fetchOrders(businessId, startDate, endDate);
      final previousOrders = await _fetchOrders(
        businessId,
        prevStartDate,
        prevEndDate,
      );

      final currentStats = _calculatePeriodStats(currentOrders);
      final previousStats = _calculatePeriodStats(previousOrders);

      final revenueChange = _calculateChange(
        currentStats.revenue,
        previousStats.revenue,
      );
      final ordersChange = _calculateChange(
        currentStats.count.toDouble(),
        previousStats.count.toDouble(),
      );

      final topProducts = _calculateTopProducts(currentOrders);
      final dailyStats = _calculateDailyStats(
        currentOrders,
        startDate,
        endDate,
      );

      final businessResponse = await _supabaseClient
          .from('businesses')
          .select('rating')
          .eq('id', businessId)
          .single();

      final rating = (businessResponse['rating'] as num?)?.toDouble() ?? 0.0;

      return BusinessStats(
        revenue: currentStats.revenue,
        ordersCount: currentStats.count,
        rescuedCount: currentStats.count,
        avgRating: rating,
        revenueChange: revenueChange,
        ordersChange: ordersChange,
        rescuedChange: ordersChange,
        topProducts: topProducts,
        dailyStats: dailyStats,
      );
    } catch (e) {
      throw const UnknownDataException(
        message: 'Error al calcular estadísticas',
      );
    }
  }

  Future<List<Map<String, dynamic>>> _fetchOrders(
    String businessId,
    DateTime start,
    DateTime end,
  ) async {
    final response = await _supabaseClient
        .from('orders')
        .select('id, price, created_at, offers(title)')
        .eq('business_id', businessId)
        .eq('status', 'completed')
        .gte('created_at', start.toIso8601String())
        .lte('created_at', end.toIso8601String());

    return List<Map<String, dynamic>>.from(response);
  }

  ({double revenue, int count}) _calculatePeriodStats(
    List<Map<String, dynamic>> orders,
  ) {
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

  List<TopProductStat> _calculateTopProducts(
    List<Map<String, dynamic>> orders,
  ) {
    final productMap = <String, ({int sold, double revenue})>{};

    for (final order in orders) {
      final offer = order['offers'] as Map<String, dynamic>?;
      final title = offer?['title'] as String? ?? 'Desconocido';
      final price = (order['price'] as num?)?.toDouble() ?? 0.0;

      final current = productMap[title] ?? (sold: 0, revenue: 0.0);
      productMap[title] = (
        sold: current.sold + 1,
        revenue: current.revenue + price,
      );
    }

    final stats = productMap.entries
        .map(
          (e) => TopProductStat(
            name: e.key,
            sold: e.value.sold,
            revenue: e.value.revenue,
          ),
        )
        .toList();

    stats.sort((a, b) => b.sold.compareTo(a.sold));
    return stats.take(5).toList();
  }

  static const _monthAbbr = [
    'ene',
    'feb',
    'mar',
    'abr',
    'may',
    'jun',
    'jul',
    'ago',
    'sep',
    'oct',
    'nov',
    'dic',
  ];

  static const _fullMonths = [
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

  static _Aggregation _resolveAggregation(int totalDays) {
    if (totalDays <= 14) return _Aggregation.day;
    if (totalDays <= 60) return _Aggregation.week;
    return _Aggregation.month;
  }

  static String _bucketKey(DateTime d, _Aggregation agg) {
    return switch (agg) {
      _Aggregation.day => '${d.year}-${d.month}-${d.day}',
      _Aggregation.week => _weekKey(d),
      _Aggregation.month => '${d.year}-${d.month}',
    };
  }

  /// Monday-based week key: "2026-W27"
  static String _weekKey(DateTime d) {
    final monday = d.subtract(Duration(days: d.weekday - 1));
    final jan1 = DateTime(monday.year);
    final weekNum = (monday.difference(jan1).inDays ~/ 7) + 1;
    return '${monday.year}-W$weekNum';
  }

  static String _formatBucketLabel(String key, _Aggregation agg) {
    return switch (agg) {
      _Aggregation.day => () {
        final parts = key.split('-');
        final date = DateTime(
          int.parse(parts[0]),
          int.parse(parts[1]),
          int.parse(parts[2]),
        );
        const dayNames = ['Dom', 'Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb'];
        return dayNames[date.weekday % 7];
      }(),
      _Aggregation.week => () {
        final parts = key.split('-W');
        final y = int.parse(parts[0]);
        final weekNum = int.parse(parts[1]);
        final jan1 = DateTime(y);
        final monday = jan1.add(Duration(days: (weekNum - 1) * 7));
        final saturday = monday.add(const Duration(days: 6));
        if (monday.year != y) return 'Sem $weekNum';
        if (monday.month == saturday.month) {
          return '${monday.day}–${saturday.day} ${_monthAbbr[monday.month - 1]}';
        }
        return '${monday.day} ${_monthAbbr[monday.month - 1]} – ${saturday.day} ${_monthAbbr[saturday.month - 1]}';
      }(),
      _Aggregation.month => () {
        final parts = key.split('-');
        return _fullMonths[int.parse(parts[1]) - 1];
      }(),
    };
  }

  static List<DailyStat> _calculateDailyStats(
    List<Map<String, dynamic>> orders,
    DateTime startDate,
    DateTime endDate,
  ) {
    final totalDays = endDate.difference(startDate).inDays;
    final agg = _resolveAggregation(totalDays);
    final dataMap = <String, ({int count, double revenue})>{};

    final seen = <String>{};
    for (int i = 0; i <= totalDays; i++) {
      final date = startDate.add(Duration(days: i));
      final key = _bucketKey(date, agg);
      if (seen.add(key)) {
        dataMap[key] = (count: 0, revenue: 0.0);
      }
    }

    for (final order in orders) {
      final date = DateTime.parse(order['created_at'] as String);
      final key = _bucketKey(date, agg);
      if (dataMap.containsKey(key)) {
        final current = dataMap[key]!;
        dataMap[key] = (
          count: current.count + 1,
          revenue:
              current.revenue + ((order['price'] as num?)?.toDouble() ?? 0.0),
        );
      }
    }

    return dataMap.entries
        .map(
          (e) => DailyStat(
            day: _formatBucketLabel(e.key, agg),
            orders: e.value.count,
            revenue: e.value.revenue,
          ),
        )
        .toList();
  }
}

enum _Aggregation { day, week, month }
