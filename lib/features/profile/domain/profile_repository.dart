import 'profile_models.dart';

abstract class ProfileRepository {
  Future<ProfileDetails> getProfile(String userId);

  Future<void> updateProfile(String userId, ProfileUpdateInput input);

  Future<UserPreferences> getPreferences(String userId);

  Future<void> updatePreferences(String userId, UserPreferences preferences);

  Future<NotificationSettings> getNotificationSettings(String userId);

  Future<void> updateNotificationSettings(
    String userId,
    NotificationSettings settings,
  );

  Future<List<SavedAddress>> getSavedAddresses(String userId);

  Future<void> addSavedAddress(String userId, SavedAddressInput input);

  Future<void> setDefaultAddress(String userId, String addressId);

  Future<void> updateSavedAddress(
    String userId,
    String addressId,
    SavedAddressInput input,
  );

  Future<void> deleteSavedAddress(String userId, String addressId);

  Future<List<PaymentMethod>> getPaymentMethods(String userId);

  Future<void> addPaymentMethod(String userId, PaymentMethodInput input);

  Future<void> setDefaultPaymentMethod(String userId, String paymentMethodId);

  Future<void> deletePaymentMethod(String userId, String paymentMethodId);
}
