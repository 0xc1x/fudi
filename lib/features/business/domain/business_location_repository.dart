import 'business_location.dart';

abstract class BusinessLocationRepository {
  Future<List<BusinessLocation>> getLocations(String businessId);
  Future<BusinessLocation> getLocation(String id);
  Future<BusinessLocation> upsertLocation(BusinessLocation location);
  Future<void> toggleLocationStatus(String id, bool isActive);
}
