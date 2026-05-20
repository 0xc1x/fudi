import 'business_stats.dart';

abstract class BusinessStatsRepository {
  Future<BusinessStats> getBusinessStats(String businessId, {String period = 'month'});
}
