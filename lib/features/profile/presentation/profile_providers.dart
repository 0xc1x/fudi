import 'package:flutter_riverpod/flutter_riverpod.dart';

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

class SelectedAddressNotifier extends Notifier<SavedAddressModel?> {
  @override
  SavedAddressModel? build() {
    final addresses = ref.watch(savedAddressesProvider).asData?.value;
    if (addresses != null && addresses.isNotEmpty) {
      return addresses.first;
    }
    return null;
  }

  void select(SavedAddressModel address) {
    state = address;
  }
}
