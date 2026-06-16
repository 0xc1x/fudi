import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../../core/di/core_providers.dart';
import '../data/supabase_offer_repository.dart';
import '../domain/offer.dart';
import '../domain/offer_repository.dart';

final offerRepositoryProvider = Provider<OfferRepository>((ref) {
  return SupabaseOfferRepository(
    supabaseClient: ref.watch(supabaseClientProvider),
  );
});

final userLocationProvider = FutureProvider<Position?>((ref) async {
  bool serviceEnabled;
  LocationPermission permission;

  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) return null;

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) return null;
  }
  if (permission == LocationPermission.deniedForever) return null;

  return await Geolocator.getCurrentPosition(
    locationSettings: const LocationSettings(
      accuracy: LocationAccuracy.medium,
      timeLimit: Duration(seconds: 5),
    ),
  );
});

final popularOffersProvider =
    AsyncNotifierProvider<PopularOffersNotifier, List<Offer>>(
      PopularOffersNotifier.new,
    );

class PopularOffersNotifier extends AsyncNotifier<List<Offer>> {
  @override
  Future<List<Offer>> build() async {
    final repo = ref.watch(offerRepositoryProvider);
    return repo.getPopularOffers();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(offerRepositoryProvider);
      return repo.getPopularOffers();
    });
  }

  Future<void> filterByCategory(String? category) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(offerRepositoryProvider);
      if (category == null || category.isEmpty) {
        return repo.getPopularOffers();
      }
      return repo.getPopularOffersFiltered(category: category);
    });
  }
}

final nearbyOffersProvider =
    AsyncNotifierProvider<NearbyOffersNotifier, List<Offer>>(
      NearbyOffersNotifier.new,
    );

class NearbyOffersNotifier extends AsyncNotifier<List<Offer>> {
  String? _category;

  @override
  Future<List<Offer>> build() async {
    final repo = ref.watch(offerRepositoryProvider);
    final position = await ref.watch(userLocationProvider.future);

    if (position == null) {
      return repo.getPopularOffers();
    }

    return repo.getNearbyOffers(
      lat: position.latitude,
      lng: position.longitude,
      category: _category,
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    ref.invalidate(userLocationProvider);
    state = await AsyncValue.guard(() async {
      final repo = ref.read(offerRepositoryProvider);
      final position = await ref.read(userLocationProvider.future);

      if (position == null) {
        return repo.getPopularOffers();
      }

      return repo.getNearbyOffers(
        lat: position.latitude,
        lng: position.longitude,
        category: _category,
      );
    });
  }

  Future<void> filterByCategory(String? category) async {
    _category = (category != null && category.isNotEmpty) ? category : null;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(offerRepositoryProvider);
      final position = await ref.read(userLocationProvider.future);

      if (position == null) {
        if (_category == null) return repo.getPopularOffers();
        return repo.getPopularOffersFiltered(category: _category);
      }

      return repo.getNearbyOffers(
        lat: position.latitude,
        lng: position.longitude,
        category: _category,
      );
    });
  }
}

final offerDetailProvider = FutureProvider.family<Offer, String>((
  ref,
  id,
) async {
  final repo = ref.watch(offerRepositoryProvider);
  return repo.getOfferById(id);
});

final categoryStatsProvider = FutureProvider<List<CategoryStat>>((ref) async {
  final repo = ref.watch(offerRepositoryProvider);
  return repo.getCategoryStats();
});

final popularAreasProvider = FutureProvider<List<AreaStat>>((ref) async {
  final repo = ref.watch(offerRepositoryProvider);
  return repo.getPopularAreas();
});

final categoriesProvider = FutureProvider<List<String>>((ref) async {
  final repo = ref.watch(offerRepositoryProvider);
  return repo.getCategories();
});

final filteredOffersProvider =
    AsyncNotifierProvider<FilteredOffersNotifier, List<Offer>>(
      FilteredOffersNotifier.new,
    );

class FilteredOffersNotifier extends AsyncNotifier<List<Offer>> {
  @override
  Future<List<Offer>> build() async {
    return _loadOffers();
  }

  Future<List<Offer>> _loadOffers({
    String? category,
    double? maxPrice,
    double? maxDistanceKm,
    String? searchQuery,
  }) async {
    final repo = ref.read(offerRepositoryProvider);
    final position = await ref.read(userLocationProvider.future);

    final hasFilters = category != null ||
        maxPrice != null ||
        maxDistanceKm != null ||
        (searchQuery != null && searchQuery.isNotEmpty);

    if (position == null) {
      if (!hasFilters) {
        return repo.getPopularOffers();
      }
      return repo.getFilteredOffers(
        lat: 0,
        lng: 0,
        category: category,
        maxPrice: maxPrice,
        searchQuery: searchQuery,
      );
    }

    if (!hasFilters) {
      return repo.getNearbyOffers(
        lat: position.latitude,
        lng: position.longitude,
      );
    }

    return repo.getFilteredOffers(
      lat: position.latitude,
      lng: position.longitude,
      category: category,
      maxPrice: maxPrice,
      maxDistanceKm: maxDistanceKm ?? 10.0,
      searchQuery: searchQuery,
    );
  }

  Future<void> applyFilters({
    String? category,
    double? maxPrice,
    double? maxDistanceKm,
    String? searchQuery,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _loadOffers(
        category: category,
        maxPrice: maxPrice,
        maxDistanceKm: maxDistanceKm,
        searchQuery: searchQuery,
      ),
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    ref.invalidate(userLocationProvider);
    state = await AsyncValue.guard(() => _loadOffers());
  }
}
