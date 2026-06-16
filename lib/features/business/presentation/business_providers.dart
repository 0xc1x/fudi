import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/core_providers.dart';
import '../data/supabase_business_catalog_repository.dart';
import '../data/supabase_business_coupon_repository.dart';
import '../data/supabase_business_notification_repository.dart';
import '../data/supabase_business_order_repository.dart';
import '../data/supabase_business_stats_repository.dart';
import '../data/supabase_business_location_repository.dart';
import '../data/supabase_business_payout_repository.dart';
import '../domain/business_catalog_repository.dart';
import '../domain/business_coupon_repository.dart';
import '../domain/business_location.dart';
import '../domain/business_location_repository.dart';
import '../domain/business_notification_preferences.dart';
import '../domain/business_notification_repository.dart';
import '../domain/business_order_repository.dart';
import '../domain/business_payout.dart';
import '../domain/business_payout_repository.dart';
import '../domain/business_stats_repository.dart';
import '../../offers/domain/offer.dart';
import '../../orders/domain/order_model.dart';
import '../../orders/domain/coupon.dart';
import '../../auth/presentation/auth_state_provider.dart';
import '../../auth/domain/user_profile.dart';
import '../domain/business_profile.dart';
import '../domain/business_stats.dart';
import 'business_profile_providers.dart';

/// Repository providers
final businessCatalogRepositoryProvider = Provider<BusinessCatalogRepository>(
  (ref) => SupabaseBusinessCatalogRepository(
    supabaseClient: ref.watch(supabaseClientProvider),
  ),
);

final businessOrderRepositoryProvider = Provider<BusinessOrderRepository>(
  (ref) => SupabaseBusinessOrderRepository(
    supabaseClient: ref.watch(supabaseClientProvider),
  ),
);

final businessStatsRepositoryProvider = Provider<BusinessStatsRepository>(
  (ref) => SupabaseBusinessStatsRepository(
    supabaseClient: ref.watch(supabaseClientProvider),
  ),
);

final businessLocationRepositoryProvider = Provider<BusinessLocationRepository>(
  (ref) => SupabaseBusinessLocationRepository(
    supabaseClient: ref.watch(supabaseClientProvider),
  ),
);

final businessPayoutRepositoryProvider = Provider<BusinessPayoutRepository>(
  (ref) => SupabaseBusinessPayoutRepository(
    supabaseClient: ref.watch(supabaseClientProvider),
  ),
);

final businessCouponRepositoryProvider = Provider<BusinessCouponRepository>(
  (ref) => SupabaseBusinessCouponRepository(
    supabaseClient: ref.watch(supabaseClientProvider),
  ),
);

/// Catalog providers
final businessOffersProvider = FutureProvider.family<List<Offer>, String>((
  ref,
  businessId,
) async {
  return ref
      .watch(businessCatalogRepositoryProvider)
      .getBusinessOffers(businessId);
});

/// Order providers
final businessOrdersProvider = FutureProvider.family<List<OrderModel>, String>((
  ref,
  businessId,
) async {
  return ref
      .watch(businessOrderRepositoryProvider)
      .getBusinessOrders(businessId);
});

final businessOrdersStreamProvider =
    StreamProvider.family<List<OrderModel>, String>((ref, businessId) {
      return ref
          .watch(businessOrderRepositoryProvider)
          .watchBusinessOrders(businessId);
    });

/// Stats providers
final businessStatsProvider = FutureProvider.family<BusinessStats, String>((
  ref,
  businessId,
) async {
  return ref
      .watch(businessStatsRepositoryProvider)
      .getBusinessStats(businessId);
});

final businessLocationsProvider =
    FutureProvider.family<List<BusinessLocation>, String>((ref, businessId) {
      return ref
          .watch(businessLocationRepositoryProvider)
          .getLocations(businessId);
    });

final businessLocationProvider =
    FutureProvider.family<BusinessLocation, String>((ref, locationId) {
      return ref
          .watch(businessLocationRepositoryProvider)
          .getLocation(locationId);
    });

final businessPayoutsProvider =
    FutureProvider.family<List<BusinessPayout>, String>((ref, businessId) {
      return ref.watch(businessPayoutRepositoryProvider).getPayouts(businessId);
    });

final businessPayoutProvider = FutureProvider.family<BusinessPayout, String>((
  ref,
  payoutId,
) {
  return ref.watch(businessPayoutRepositoryProvider).getPayout(payoutId);
});

final businessCouponsProvider = FutureProvider.family<List<Coupon>, String>((
  ref,
  businessId,
) {
  return ref.watch(businessCouponRepositoryProvider).getCoupons(businessId);
});

final businessCouponProvider = FutureProvider.family<Coupon, String>((ref, id) {
  return ref.watch(businessCouponRepositoryProvider).getCoupon(id);
});

/// Selected business ID for the current session (Migrated to Notifier for Riverpod 3.0)
class SelectedBusinessId extends Notifier<String?> {
  @override
  String? build() => null;

  void select(String? id) => state = id;
}

final selectedBusinessIdProvider =
    NotifierProvider<SelectedBusinessId, String?>(SelectedBusinessId.new);

/// All businesses owned by the current user
final userBusinessesProvider = FutureProvider<List<BusinessProfile>>((
  ref,
) async {
  final authState = ref.watch(authSessionNotifierProvider);

  if (!authState.isAuthenticated) return [];

  final userId = authState.session?.user.id;
  if (userId == null) return [];

  final profile = authState.profile;
  if (profile != null && profile.role != UserRole.business) return [];

  final repo = ref.watch(businessProfileRepositoryProvider);
  return repo.getBusinessesByOwnerId(userId);
});

/// Current business provider (resolved from selection or first available)
final currentBusinessProvider = FutureProvider<BusinessProfile?>((ref) async {
  final businesses = await ref.watch(userBusinessesProvider.future);
  if (businesses.isEmpty) return null;

  final selectedId = ref.watch(selectedBusinessIdProvider);
  if (selectedId != null) {
    return businesses.firstWhere(
      (b) => b.id == selectedId,
      orElse: () => businesses.first,
    );
  }

  return businesses.first;
});

final businessNotificationRepositoryProvider =
    Provider<BusinessNotificationRepository>((ref) {
  return SupabaseBusinessNotificationRepository(
    supabaseClient: ref.watch(supabaseClientProvider),
  );
});

final businessNotificationPreferencesProvider =
    FutureProvider.family<BusinessNotificationPreferences, String>((
  ref,
  businessId,
) async {
  return ref
      .watch(businessNotificationRepositoryProvider)
      .getPreferences(businessId);
});
