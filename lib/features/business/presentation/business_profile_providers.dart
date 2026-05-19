import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/core_providers.dart';
import '../data/supabase_business_profile_repository.dart';
import '../domain/business_profile.dart';
import '../domain/business_profile_repository.dart';

/// Repository provider for the business profile feature.
final businessProfileRepositoryProvider = Provider<BusinessProfileRepository>(
  (ref) => SupabaseBusinessProfileRepository(
    supabaseClient: ref.watch(supabaseClientProvider),
  ),
);

/// Provider that fetches a full business profile by ID.
///
/// Usage:
/// ```dart
/// final profileAsync = ref.watch(businessProfileProvider(businessId));
/// ```
final businessProfileProvider =
    FutureProvider.family<BusinessProfile, String>((ref, businessId) async {
  final repo = ref.watch(businessProfileRepositoryProvider);
  return repo.getBusinessProfile(businessId);
});
