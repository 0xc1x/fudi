import 'business_payout.dart';

abstract class BusinessPayoutRepository {
  Future<List<BusinessPayout>> getPayouts(String businessId);
  Future<BusinessPayout> getPayout(String id);
}
