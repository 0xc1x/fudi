import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/error/data_exceptions.dart';
import '../../../core/error/fudi_exception.dart';
import '../../../core/error/postgrest_exception_mapper.dart';
import '../domain/consumer_notification_preferences.dart';
import '../domain/consumer_notification_repository.dart';

class SupabaseConsumerNotificationRepository
    implements ConsumerNotificationRepository {
  SupabaseConsumerNotificationRepository({
    required SupabaseClient supabaseClient,
  }) : _supabase = supabaseClient;

  final SupabaseClient _supabase;

  @override
  Future<ConsumerNotificationPreferences> getPreferences() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return ConsumerNotificationPreferences.defaults;

    try {
      final response = await _supabase
          .from('consumer_notification_preferences')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (response == null) return ConsumerNotificationPreferences.defaults;

      return _map(response);
    } on PostgrestException catch (e) {
      throw e.toFudiException(feature: 'consumer_notification');
    } on FudiException {
      rethrow;
    } catch (e) {
      throw UnknownDataException(
        message: 'Error al cargar preferencias de notificación',
      );
    }
  }

  @override
  Future<void> updatePreferences(
    ConsumerNotificationPreferences preferences,
  ) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      await _supabase.from('consumer_notification_preferences').upsert({
        'user_id': userId,
        'push_enabled': preferences.pushEnabled,
        'email_enabled': preferences.emailEnabled,
        'sms_enabled': preferences.smsEnabled,
        'whatsapp_enabled': preferences.whatsappEnabled,
        'favorite_alerts_enabled': preferences.favoriteAlertsEnabled,
        'pickup_reminders_enabled': preferences.pickupRemindersEnabled,
        'last_minute_deals_enabled': preferences.lastMinuteDealsEnabled,
        'weekly_summary_enabled': preferences.weeklySummaryEnabled,
        'quiet_hours_from': preferences.quietHoursFrom,
        'quiet_hours_to': preferences.quietHoursTo,
      }, onConflict: 'user_id');
    } on PostgrestException catch (e) {
      throw e.toFudiException(feature: 'consumer_notification');
    } on FudiException {
      rethrow;
    } catch (e) {
      throw UnknownDataException(
        message: 'Error al guardar preferencias de notificación',
      );
    }
  }

  ConsumerNotificationPreferences _map(Map<String, dynamic> json) {
    return ConsumerNotificationPreferences(
      pushEnabled: json['push_enabled'] as bool? ?? true,
      emailEnabled: json['email_enabled'] as bool? ?? true,
      smsEnabled: json['sms_enabled'] as bool? ?? false,
      whatsappEnabled: json['whatsapp_enabled'] as bool? ?? false,
      favoriteAlertsEnabled: json['favorite_alerts_enabled'] as bool? ?? true,
      pickupRemindersEnabled:
          json['pickup_reminders_enabled'] as bool? ?? true,
      lastMinuteDealsEnabled:
          json['last_minute_deals_enabled'] as bool? ?? false,
      weeklySummaryEnabled: json['weekly_summary_enabled'] as bool? ?? true,
      quietHoursFrom: json['quiet_hours_from'] as String?,
      quietHoursTo: json['quiet_hours_to'] as String?,
    );
  }
}
