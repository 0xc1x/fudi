import 'package:image_picker/image_picker.dart';
import 'business_profile.dart';

abstract class BusinessProfileRepository {
  Future<BusinessProfile> getBusinessProfile(String businessId);
  Future<List<BusinessHours>> getBusinessHours(String businessId);
  Future<List<BusinessReview>> getBusinessReviews(
    String businessId, {
    int limit = 5,
  });
  Future<List<BusinessProfile>> getBusinessesByOwnerId(String ownerId);
  Future<void> createBusiness(
    BusinessProfile profile,
    String ownerId, {
    XFile? logoFile,
    XFile? coverFile,
  });

  Future<void> updateBusiness(BusinessProfile profile);
}
