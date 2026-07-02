import 'business_stats.dart';

abstract class BusinessStatsRepository {
  Future<BusinessStats> getBusinessStats(
    String businessId, {
    required DateTime startDate,
    required DateTime endDate,
  });
}
