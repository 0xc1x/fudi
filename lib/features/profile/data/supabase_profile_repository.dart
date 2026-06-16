import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../domain/profile_models.dart';
import '../domain/profile_repository.dart';

class SupabaseProfileRepository implements ProfileRepository {
  SupabaseProfileRepository({
    required SupabaseClient supabaseClient,
    required FlutterSecureStorage secureStorage,
    required SharedPreferencesAsync sharedPreferences,
  }) : _supabaseClient = supabaseClient,
       _secureStorage = secureStorage,
       _sharedPreferences = sharedPreferences;

  final SupabaseClient _supabaseClient;
  final FlutterSecureStorage _secureStorage;
  final SharedPreferencesAsync _sharedPreferences;
  final Uuid _uuid = const Uuid();

  @override
  Future<ProfileDetails> getProfile(String userId) async {
    final response = await _supabaseClient
        .from('profiles')
        .select(
          'id, email, full_name, avatar_url, phone, city',
        )
        .eq('id', userId)
        .single();

    return ProfileDetails(
      id: response['id'] as String,
      email: response['email'] as String? ?? '',
      fullName: response['full_name'] as String?,
      avatarUrl: response['avatar_url'] as String?,
      phone: response['phone'] as String?,
      city: response['city'] as String?,
    );
  }

  @override
  Future<void> updateProfile(String userId, ProfileUpdateInput input) async {
    await _supabaseClient
        .from('profiles')
        .update({
          'full_name': input.fullName.trim(),
          'phone': _nullableTrim(input.phone),
          'city': _nullableTrim(input.city),
        })
        .eq('id', userId);
  }

  @override
  Future<UserPreferences> getPreferences(String userId) async {
    final upResponse = await _supabaseClient
        .from('user_preferences')
        .select('language, dark_mode, notification_radius_km, favorite_categories')
        .eq('user_id', userId)
        .maybeSingle();

    final notifResponse = await _supabaseClient
        .from('consumer_notification_preferences')
        .select('push_enabled, email_enabled')
        .eq('user_id', userId)
        .maybeSingle();

    return UserPreferences(
      language: upResponse?['language'] as String? ?? 'es',
      darkMode: upResponse?['dark_mode'] as bool? ?? false,
      pushNotificationsEnabled: notifResponse?['push_enabled'] as bool? ?? true,
      emailNotificationsEnabled: notifResponse?['email_enabled'] as bool? ?? true,
      notificationRadiusKm: upResponse?['notification_radius_km'] as int? ?? 5,
      favoriteCategories:
          (upResponse?['favorite_categories'] as List<dynamic>? ?? const [])
              .whereType<String>()
              .toList(),
    );
  }

  @override
  Future<void> updatePreferences(
    String userId,
    UserPreferences preferences,
  ) async {
    await _supabaseClient.from('user_preferences').upsert({
      'user_id': userId,
      'language': preferences.language,
      'dark_mode': preferences.darkMode,
      'notification_radius_km': preferences.notificationRadiusKm,
      'favorite_categories': preferences.favoriteCategories,
    });

    await _supabaseClient.from('consumer_notification_preferences').upsert({
      'user_id': userId,
      'push_enabled': preferences.pushNotificationsEnabled,
      'email_enabled': preferences.emailNotificationsEnabled,
    }, onConflict: 'user_id');
  }

  @override
  Future<NotificationSettings> getNotificationSettings(String userId) async {
    final raw = await _sharedPreferences.getString(
      _notificationSettingsKey(userId),
    );

    if (raw == null || raw.isEmpty) {
      return NotificationSettings.defaults;
    }

    return NotificationSettings.fromJson(
      jsonDecode(raw) as Map<String, dynamic>,
    );
  }

  @override
  Future<void> updateNotificationSettings(
    String userId,
    NotificationSettings settings,
  ) async {
    await _sharedPreferences.setString(
      _notificationSettingsKey(userId),
      jsonEncode(settings.toJson()),
    );
  }

  @override
  Future<List<SavedAddress>> getSavedAddresses(String userId) async {
    final response = await _supabaseClient
        .from('saved_addresses')
        .select(
          'id, label, address, latitude, longitude, is_default, type, "references", housing_type',
        )
        .eq('user_id', userId)
        .order('is_default', ascending: false)
        .order('created_at', ascending: false);

    return response.map(_mapSavedAddress).toList();
  }

  @override
  Future<void> addSavedAddress(String userId, SavedAddressInput input) async {
    if (input.isDefault) {
      await _supabaseClient
          .from('saved_addresses')
          .update({'is_default': false})
          .eq('user_id', userId);
    }

    await _supabaseClient.from('saved_addresses').insert({
      'user_id': userId,
      'label': input.label.trim(),
      'address': input.address.trim(),
      'latitude': input.latitude,
      'longitude': input.longitude,
      'is_default': input.isDefault,
      'type': input.type.name,
      'references': input.references,
      'housing_type': input.housingType?.name,
    });
  }

  @override
  Future<void> updateSavedAddress(
    String userId,
    String addressId,
    SavedAddressInput input,
  ) async {
    if (input.isDefault) {
      await _supabaseClient
          .from('saved_addresses')
          .update({'is_default': false})
          .eq('user_id', userId);
    }

    await _supabaseClient
        .from('saved_addresses')
        .update({
          'label': input.label.trim(),
          'address': input.address.trim(),
          'latitude': input.latitude,
          'longitude': input.longitude,
          'is_default': input.isDefault,
          'type': input.type.name,
          'references': input.references,
          'housing_type': input.housingType?.name,
        })
        .eq('user_id', userId)
        .eq('id', addressId);
  }

  @override
  Future<void> setDefaultAddress(String userId, String addressId) async {
    await _supabaseClient
        .from('saved_addresses')
        .update({'is_default': false})
        .eq('user_id', userId);

    await _supabaseClient
        .from('saved_addresses')
        .update({'is_default': true})
        .eq('user_id', userId)
        .eq('id', addressId);
  }

  @override
  Future<void> deleteSavedAddress(String userId, String addressId) async {
    await _supabaseClient
        .from('saved_addresses')
        .delete()
        .eq('user_id', userId)
        .eq('id', addressId);
  }

  @override
  Future<List<PaymentMethod>> getPaymentMethods(String userId) async {
    final raw = await _secureStorage.read(key: _paymentMethodsKey(userId));
    if (raw == null || raw.isEmpty) {
      return const [];
    }

    final data = jsonDecode(raw) as List<dynamic>;
    return data
        .whereType<Map<String, dynamic>>()
        .map(PaymentMethod.fromJson)
        .toList();
  }

  @override
  Future<void> addPaymentMethod(String userId, PaymentMethodInput input) async {
    final paymentMethods = await getPaymentMethods(userId);
    final nextMethod = PaymentMethod(
      id: _uuid.v4(),
      brand: _detectCardBrand(input.cardNumber),
      last4: input.cardNumber
          .replaceAll(RegExp(r'\s+'), '')
          .substring(
            input.cardNumber.replaceAll(RegExp(r'\s+'), '').length - 4,
          ),
      expiryMonth: input.expiryMonth,
      expiryYear: input.expiryYear,
      cardholderName: input.cardholderName.trim(),
      isDefault: paymentMethods.isEmpty ? true : input.isDefault,
    );

    final nextList =
        paymentMethods
            .map(
              (method) => PaymentMethod(
                id: method.id,
                brand: method.brand,
                last4: method.last4,
                expiryMonth: method.expiryMonth,
                expiryYear: method.expiryYear,
                cardholderName: method.cardholderName,
                isDefault: nextMethod.isDefault ? false : method.isDefault,
              ),
            )
            .toList()
          ..insert(0, nextMethod);

    await _persistPaymentMethods(userId, nextList);
  }

  @override
  Future<void> setDefaultPaymentMethod(
    String userId,
    String paymentMethodId,
  ) async {
    final paymentMethods = await getPaymentMethods(userId);
    final nextList = paymentMethods
        .map(
          (method) => PaymentMethod(
            id: method.id,
            brand: method.brand,
            last4: method.last4,
            expiryMonth: method.expiryMonth,
            expiryYear: method.expiryYear,
            cardholderName: method.cardholderName,
            isDefault: method.id == paymentMethodId,
          ),
        )
        .toList();

    await _persistPaymentMethods(userId, nextList);
  }

  @override
  Future<void> deletePaymentMethod(
    String userId,
    String paymentMethodId,
  ) async {
    final paymentMethods = await getPaymentMethods(userId);
    final nextList = paymentMethods
        .where((method) => method.id != paymentMethodId)
        .toList();

    if (nextList.isNotEmpty && !nextList.any((method) => method.isDefault)) {
      final first = nextList.first;
      nextList[0] = PaymentMethod(
        id: first.id,
        brand: first.brand,
        last4: first.last4,
        expiryMonth: first.expiryMonth,
        expiryYear: first.expiryYear,
        cardholderName: first.cardholderName,
        isDefault: true,
      );
    }

    await _persistPaymentMethods(userId, nextList);
  }

  Future<void> _persistPaymentMethods(
    String userId,
    List<PaymentMethod> methods,
  ) async {
    await _secureStorage.write(
      key: _paymentMethodsKey(userId),
      value: jsonEncode(methods.map((method) => method.toJson()).toList()),
    );
  }

  SavedAddress _mapSavedAddress(Map<String, dynamic> json) {
    return SavedAddress(
      id: json['id'] as String,
      label: json['label'] as String? ?? '',
      address: json['address'] as String? ?? '',
      latitude: _toDouble(json['latitude']) ?? 0,
      longitude: _toDouble(json['longitude']) ?? 0,
      isDefault: json['is_default'] as bool? ?? false,
      type: _parseAddressType(json['type'] as String?),
      references: json['references'] as String?,
      housingType: _parseHousingType(json['housing_type'] as String?),
    );
  }

  static AddressType _parseAddressType(String? value) {
    if (value == null) return AddressType.other;
    return AddressType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => AddressType.other,
    );
  }

  static HousingType? _parseHousingType(String? value) {
    if (value == null) return null;
    return HousingType.values.cast<HousingType?>().firstWhere(
      (e) => e?.name == value,
      orElse: () => null,
    );
  }

  String _nullableTrim(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return '';
    return trimmed;
  }

  double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  String _paymentMethodsKey(String userId) => 'profile.payment_methods.$userId';

  String _notificationSettingsKey(String userId) =>
      'profile.notification_settings.$userId';

  String _detectCardBrand(String cardNumber) {
    final normalized = cardNumber.replaceAll(RegExp(r'\s+'), '');
    if (normalized.startsWith('4')) return 'Visa';
    if (RegExp(r'^(5[1-5]|2[2-7])').hasMatch(normalized)) {
      return 'Mastercard';
    }
    if (RegExp(r'^(34|37)').hasMatch(normalized)) {
      return 'American Express';
    }
    return 'Tarjeta';
  }
}
