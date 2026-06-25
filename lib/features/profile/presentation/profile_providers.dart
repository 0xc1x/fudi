import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/di/core_providers.dart';
import '../../auth/presentation/auth_state_provider.dart';
import '../data/supabase_consumer_notification_repository.dart';
import '../data/supabase_consumer_profile_repository.dart';
import '../data/supabase_profile_order_repository.dart';
import '../domain/consumer_notification_preferences.dart';
import '../domain/consumer_notification_repository.dart';
import '../domain/consumer_preferences.dart';
import '../domain/payment_method_model.dart';
import '../domain/profile_order_repository.dart';
import '../domain/saved_address_model.dart';
import '../domain/user_order.dart';

final profileOrderRepositoryProvider = Provider<ProfileOrderRepository>((ref) {
  return SupabaseProfileOrderRepository(
    supabaseClient: ref.watch(supabaseClientProvider),
  );
});

final consumerProfileRepositoryProvider =
    Provider<SupabaseConsumerProfileRepository>((ref) {
      return SupabaseConsumerProfileRepository(
        supabaseClient: ref.watch(supabaseClientProvider),
      );
    });

final userStatsProvider = FutureProvider<UserStats>((ref) async {
  final authState = ref.watch(authSessionNotifierProvider);
  final userId = authState.profile?.id;
  if (userId == null) return UserStats.empty;

  final repo = ref.watch(profileOrderRepositoryProvider);
  return repo.getUserStats(userId);
});

final userOrdersProvider = FutureProvider<List<UserOrder>>((ref) async {
  final authState = ref.watch(authSessionNotifierProvider);
  final userId = authState.profile?.id;
  if (userId == null) return [];

  final repo = ref.watch(profileOrderRepositoryProvider);
  return repo.getUserOrders(userId);
});

final savedAddressesProvider = FutureProvider<List<SavedAddressModel>>((
  ref,
) async {
  final authState = ref.watch(authSessionNotifierProvider);
  final userId = authState.profile?.id;
  if (userId == null) return [];
  return ref.watch(consumerProfileRepositoryProvider).getSavedAddresses();
});

final paymentMethodsProvider = FutureProvider<List<PaymentMethodModel>>((
  ref,
) async {
  return ref.watch(consumerProfileRepositoryProvider).getPaymentMethods();
});

final consumerPreferencesProvider = FutureProvider<ConsumerPreferences>((
  ref,
) async {
  return ref.watch(consumerProfileRepositoryProvider).getPreferences();
});

final userSelectedAddressProvider =
    NotifierProvider<SelectedAddressNotifier, SavedAddressModel?>(
      SelectedAddressNotifier.new,
    );

final consumerNotificationRepositoryProvider =
    Provider<ConsumerNotificationRepository>((ref) {
      return SupabaseConsumerNotificationRepository(
        supabaseClient: ref.watch(supabaseClientProvider),
      );
    });

final consumerNotificationPreferencesProvider =
    FutureProvider<ConsumerNotificationPreferences>((ref) async {
      return ref.watch(consumerNotificationRepositoryProvider).getPreferences();
    });

const _kSelectedAddressIdKey = 'selected_address_id';

class SelectedAddressNotifier extends Notifier<SavedAddressModel?> {
  @override
  SavedAddressModel? build() {
    final addressesAsync = ref.watch(savedAddressesProvider);
    final addresses = addressesAsync.asData?.value;
    if (addresses == null || addresses.isEmpty) return null;

    _restoreSavedSelection(addresses);

    return addresses.firstWhere(
      (a) => a.isDefault,
      orElse: () => addresses.first,
    );
  }

  Future<void> _restoreSavedSelection(List<SavedAddressModel> addresses) async {
    final prefs = await SharedPreferences.getInstance();
    final savedId = prefs.getString(_kSelectedAddressIdKey);
    if (savedId == null) return;

    final match = addresses.cast<SavedAddressModel?>().firstWhere(
      (a) => a!.id == savedId,
      orElse: () => null,
    );
    if (match != null && match.id != state?.id) {
      state = match;
    }
  }

  Future<void> select(SavedAddressModel address) async {
    state = address;
    await _persistId(address.id);
    await ref
        .read(consumerProfileRepositoryProvider)
        .setDefaultAddress(address.id);
    ref.invalidate(savedAddressesProvider);
  }

  Future<void> _persistId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kSelectedAddressIdKey, id);
  }
}
