import '../../orders/domain/coupon.dart';

abstract class BusinessCouponRepository {
  Future<List<Coupon>> getCoupons(String businessId);
  Future<Coupon> getCoupon(String id);
  Future<Coupon> upsertCoupon(Coupon coupon);
  Future<void> toggleCouponStatus(String id, bool isActive);
  Future<void> deleteCoupon(String id);
}
