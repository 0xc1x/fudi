import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/error/data_exceptions.dart';
import '../../../core/error/fudi_exception.dart';
import '../../../core/error/postgrest_exception_mapper.dart';
import '../domain/business_notification_preferences.dart';
import '../domain/business_notification_repository.dart';

class SupabaseBusinessNotificationRepository
    implements BusinessNotificationRepository {
  SupabaseBusinessNotificationRepository({
    required SupabaseClient supabaseClient,
  }) : _supabase = supabaseClient;

  final SupabaseClient _supabase;

  @override
  Future<BusinessNotificationPreferences> getPreferences(
    String businessId,
  ) async {
    try {
      final response = await _supabase
          .from('business_notification_preferences')
          .select()
          .eq('business_id', businessId)
          .maybeSingle();

      if (response == null) return BusinessNotificationPreferences.defaults;

      return _map(response);
    } on PostgrestException catch (e) {
      throw e.toFudiException(feature: 'business_notification');
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
    String businessId,
    BusinessNotificationPreferences preferences,
  ) async {
    try {
      await _supabase.from('business_notification_preferences').upsert({
        'business_id': businessId,
        'push_enabled': preferences.pushEnabled,
        'email_enabled': preferences.emailEnabled,
        'sms_enabled': preferences.smsEnabled,
        'whatsapp_enabled': preferences.whatsappEnabled,
        'new_orders_enabled': preferences.newOrdersEnabled,
        'pickup_ready_enabled': preferences.pickupReadyEnabled,
        'reviews_enabled': preferences.reviewsEnabled,
        'low_stock_enabled': preferences.lowStockEnabled,
        'daily_summary_enabled': preferences.dailySummaryEnabled,
        'quiet_hours_from': preferences.quietHoursFrom,
        'quiet_hours_to': preferences.quietHoursTo,
      }, onConflict: 'business_id');
    } on PostgrestException catch (e) {
      throw e.toFudiException(feature: 'business_notification');
    } on FudiException {
      rethrow;
    } catch (e) {
      throw UnknownDataException(
        message: 'Error al guardar preferencias de notificación',
      );
    }
  }

  BusinessNotificationPreferences _map(Map<String, dynamic> json) {
    return BusinessNotificationPreferences(
      pushEnabled: json['push_enabled'] as bool? ?? true,
      emailEnabled: json['email_enabled'] as bool? ?? true,
      smsEnabled: json['sms_enabled'] as bool? ?? false,
      whatsappEnabled: json['whatsapp_enabled'] as bool? ?? false,
      newOrdersEnabled: json['new_orders_enabled'] as bool? ?? true,
      pickupReadyEnabled: json['pickup_ready_enabled'] as bool? ?? true,
      reviewsEnabled: json['reviews_enabled'] as bool? ?? true,
      lowStockEnabled: json['low_stock_enabled'] as bool? ?? false,
      dailySummaryEnabled: json['daily_summary_enabled'] as bool? ?? true,
      quietHoursFrom: json['quiet_hours_from'] as String?,
      quietHoursTo: json['quiet_hours_to'] as String?,
    );
  }
}
