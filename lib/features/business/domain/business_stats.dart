class BusinessStats {
  const BusinessStats({
    required this.revenue,
    required this.ordersCount,
    required this.rescuedCount,
    required this.avgRating,
    this.revenueChange = 0,
    this.ordersChange = 0,
    this.rescuedChange = 0,
    this.ratingChange = 0,
    this.topProducts = const [],
    this.dailyStats = const [],
  });

  final double revenue;
  final int ordersCount;
  final int rescuedCount;
  final double avgRating;

  final double revenueChange;
  final double ordersChange;
  final double rescuedChange;
  final double ratingChange;

  final List<TopProductStat> topProducts;
  final List<DailyStat> dailyStats;
}

class TopProductStat {
  const TopProductStat({
    required this.name,
    required this.sold,
    required this.revenue,
  });

  final String name;
  final int sold;
  final double revenue;
}

class DailyStat {
  const DailyStat({
    required this.day,
    required this.orders,
    required this.revenue,
  });

  final String day;
  final int orders;
  final double revenue;
}
