import 'business_profile.dart';

/// Abstract repository for fetching business profile data.
///
/// Clean Architecture: the domain layer defines the contract;
/// the data layer implements it with Supabase.
abstract class BusinessProfileRepository {
  /// Fetches the full profile for a business by its ID.
  ///
  /// Throws [NotFoundException] if the business does not exist.
  Future<BusinessProfile> getBusinessProfile(String businessId);

  /// Fetches the opening hours for a business.
  Future<List<BusinessHours>> getBusinessHours(String businessId);

  /// Fetches recent reviews for a business (limited to [limit]).
  Future<List<BusinessReview>> getBusinessReviews(
    String businessId, {
    int limit = 5,
  });
}
