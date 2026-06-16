import 'business_notification_preferences.dart';

abstract class BusinessNotificationRepository {
  Future<BusinessNotificationPreferences> getPreferences(String businessId);
  Future<void> updatePreferences(
    String businessId,
    BusinessNotificationPreferences preferences,
  );
}
