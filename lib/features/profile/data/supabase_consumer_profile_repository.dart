import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../offers/domain/offer.dart';
import '../domain/consumer_preferences.dart';
import '../domain/payment_method_model.dart';
import '../domain/saved_address_model.dart';

class SupabaseConsumerProfileRepository {
  SupabaseConsumerProfileRepository({required SupabaseClient supabaseClient})
    : _supabaseClient = supabaseClient;

  final SupabaseClient _supabaseClient;
  static const _uuid = Uuid();
  static const _storage = FlutterSecureStorage();

  Future<List<Offer>> getFavoriteOffers() async {
    final userId = _supabaseClient.auth.currentUser?.id;
    if (userId == null) return [];

    final response = await _supabaseClient
        .from('favorites')
        .select('''
          offer_id,
          offers!inner (
            id, business_id, title, description, image, category,
            original_price, discounted_price, rating, stock, initial_stock,
            pickup_start, pickup_end, is_active,
            businesses:business_id (
              id, name, type, image, latitude, longitude, rating, address
            )
          )
        ''')
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return response.map((row) {
      final offerJson = row['offers'] as Map<String, dynamic>;
      final businessJson = offerJson['businesses'] as Map<String, dynamic>;
      return Offer(
        id: offerJson['id'] as String,
        businessId: offerJson['business_id'] as String,
        business: BusinessInfo(
          id: businessJson['id'] as String,
          name: businessJson['name'] as String,
          type: businessJson['type'] as String,
          rating: (businessJson['rating'] as num?)?.toDouble() ?? 0,
          address: businessJson['address'] as String? ?? '',
          imageUrl: businessJson['image'] as String?,
          latitude: (businessJson['latitude'] as num?)?.toDouble(),
          longitude: (businessJson['longitude'] as num?)?.toDouble(),
        ),
        title: offerJson['title'] as String,
        description: offerJson['description'] as String?,
        imageUrl: offerJson['image'] as String?,
        category: offerJson['category'] as String?,
        originalPrice: (offerJson['original_price'] as num).toDouble(),
        discountedPrice: (offerJson['discounted_price'] as num).toDouble(),
        rating: (offerJson['rating'] as num?)?.toDouble() ?? 0,
        stock: offerJson['stock'] as int? ?? 0,
        initialStock: offerJson['initial_stock'] as int? ?? 0,
        pickupStart: DateTime.parse(offerJson['pickup_start'] as String),
        pickupEnd: DateTime.parse(offerJson['pickup_end'] as String),
        isActive: offerJson['is_active'] as bool? ?? false,
      );
    }).toList();
  }

  Future<void> removeFavorite(String offerId) async {
    final userId = _supabaseClient.auth.currentUser?.id;
    if (userId == null) return;

    await _supabaseClient
        .from('favorites')
        .delete()
        .eq('user_id', userId)
        .eq('offer_id', offerId);
  }

  Future<List<SavedAddressModel>> getSavedAddresses() async {
    final userId = _supabaseClient.auth.currentUser?.id;
    if (userId == null) return [];

    final response = await _supabaseClient
        .from('saved_addresses')
        .select()
        .eq('user_id', userId)
        .order('is_default', ascending: false)
        .order('created_at', ascending: false);

    return response
        .map(
          (row) => SavedAddressModel(
            id: row['id'] as String,
            label: row['label'] as String,
            address: row['address'] as String,
            latitude: (row['latitude'] as num).toDouble(),
            longitude: (row['longitude'] as num).toDouble(),
            isDefault: row['is_default'] as bool? ?? false,
          ),
        )
        .toList();
  }

  Future<void> saveAddress({
    required String label,
    required String address,
    required double latitude,
    required double longitude,
  }) async {
    final userId = _supabaseClient.auth.currentUser?.id;
    if (userId == null) return;

    final current = await getSavedAddresses();
    await _supabaseClient.from('saved_addresses').insert({
      'id': _uuid.v4(),
      'user_id': userId,
      'label': label,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'is_default': current.isEmpty,
    });
  }

  Future<void> deleteAddress(String id) async {
    await _supabaseClient.from('saved_addresses').delete().eq('id', id);
  }

  Future<void> setDefaultAddress(String id) async {
    final userId = _supabaseClient.auth.currentUser?.id;
    if (userId == null) return;

    await _supabaseClient
        .from('saved_addresses')
        .update({'is_default': false})
        .eq('user_id', userId);
    await _supabaseClient
        .from('saved_addresses')
        .update({'is_default': true})
        .eq('id', id);
  }

  Future<ConsumerPreferences> getPreferences() async {
    final userId = _supabaseClient.auth.currentUser?.id;
    if (userId == null) return ConsumerPreferences.empty;

    final response = await _supabaseClient
        .from('user_preferences')
        .select()
        .eq('user_id', userId)
        .maybeSingle();
    final local = await SharedPreferences.getInstance();

    return ConsumerPreferences(
      notificationRadiusKm: response?['notification_radius_km'] as int? ?? 5,
      language: response?['language'] as String? ?? 'es',
      darkMode: response?['dark_mode'] as bool? ?? false,
      pushNotificationsEnabled:
          response?['push_notifications_enabled'] as bool? ?? true,
      emailNotificationsEnabled:
          response?['email_notifications_enabled'] as bool? ?? true,
      favoriteCategories:
          (response?['favorite_categories'] as List<dynamic>? ?? [])
              .map((item) => item.toString())
              .toList(),
      favoriteAlertsEnabled:
          local.getBool('favorite_alerts_enabled') ?? true,
      pickupRemindersEnabled:
          local.getBool('pickup_reminders_enabled') ?? true,
      lastMinuteDealsEnabled:
          local.getBool('last_minute_deals_enabled') ?? false,
      weeklySummaryEnabled:
          local.getBool('weekly_summary_enabled') ?? true,
    );
  }

  Future<void> updatePreferences(ConsumerPreferences preferences) async {
    final userId = _supabaseClient.auth.currentUser?.id;
    if (userId == null) return;

    await _supabaseClient.from('user_preferences').upsert({
      'user_id': userId,
      'notification_radius_km': preferences.notificationRadiusKm,
      'language': preferences.language,
      'dark_mode': preferences.darkMode,
      'push_notifications_enabled': preferences.pushNotificationsEnabled,
      'email_notifications_enabled': preferences.emailNotificationsEnabled,
      'favorite_categories': preferences.favoriteCategories,
    }, onConflict: 'user_id');

    final local = await SharedPreferences.getInstance();
    await local.setBool(
      'favorite_alerts_enabled',
      preferences.favoriteAlertsEnabled,
    );
    await local.setBool(
      'pickup_reminders_enabled',
      preferences.pickupRemindersEnabled,
    );
    await local.setBool(
      'last_minute_deals_enabled',
      preferences.lastMinuteDealsEnabled,
    );
    await local.setBool(
      'weekly_summary_enabled',
      preferences.weeklySummaryEnabled,
    );
  }

  Future<List<PaymentMethodModel>> getPaymentMethods() async {
    final userId = _supabaseClient.auth.currentUser?.id;
    if (userId == null) return [];

    final raw = await _storage.read(key: 'payment_methods_$userId');
    if (raw == null || raw.isEmpty) return [];

    final decoded = (jsonDecode(raw) as List<dynamic>)
        .cast<Map<String, dynamic>>();
    return decoded.map(PaymentMethodModel.fromJson).toList();
  }

  Future<void> savePaymentMethod(PaymentMethodModel method) async {
    final userId = _supabaseClient.auth.currentUser?.id;
    if (userId == null) return;

    final current = await getPaymentMethods();
    final updated = [
      for (final item in current)
        item.copyWith(isDefault: method.isDefault ? false : item.isDefault),
      method,
    ];
    await _storage.write(
      key: 'payment_methods_$userId',
      value: jsonEncode(updated.map((item) => item.toJson()).toList()),
    );
  }

  Future<void> deletePaymentMethod(String id) async {
    final userId = _supabaseClient.auth.currentUser?.id;
    if (userId == null) return;

    final current = await getPaymentMethods();
    final updated = current.where((item) => item.id != id).toList();
    if (updated.isNotEmpty && !updated.any((item) => item.isDefault)) {
      updated[0] = updated[0].copyWith(isDefault: true);
    }
    await _storage.write(
      key: 'payment_methods_$userId',
      value: jsonEncode(updated.map((item) => item.toJson()).toList()),
    );
  }

  Future<void> setDefaultPaymentMethod(String id) async {
    final userId = _supabaseClient.auth.currentUser?.id;
    if (userId == null) return;

    final current = await getPaymentMethods();
    final updated = current
        .map((item) => item.copyWith(isDefault: item.id == id))
        .toList();
    await _storage.write(
      key: 'payment_methods_$userId',
      value: jsonEncode(updated.map((item) => item.toJson()).toList()),
    );
  }
}
