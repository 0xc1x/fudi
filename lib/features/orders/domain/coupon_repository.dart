import 'coupon.dart';

abstract class CouponRepository {
  Future<Coupon?> getCouponByCode(String code, String businessId);
}
