import 'consumer_notification_preferences.dart';

abstract class ConsumerNotificationRepository {
  Future<ConsumerNotificationPreferences> getPreferences();
  Future<void> updatePreferences(ConsumerNotificationPreferences preferences);
}
