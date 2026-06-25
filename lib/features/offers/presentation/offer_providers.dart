import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../../core/di/core_providers.dart';
import '../../profile/presentation/profile_providers.dart';
import '../data/supabase_offer_repository.dart';
import '../domain/offer.dart';
import '../domain/offer_category.dart';
import '../domain/offer_repository.dart';

final offerRepositoryProvider = Provider<OfferRepository>((ref) {
  return SupabaseOfferRepository(
    supabaseClient: ref.watch(supabaseClientProvider),
  );
});

final userLocationProvider = FutureProvider<Position?>((ref) async {
  // Timeout total para evitar que geolocalización en web cuelgue
  // a todos los providers que dependen de este.
  try {
    return await _getPositionWithTimeout(const Duration(seconds: 3));
  } catch (_) {
    return null;
  }
});

final selectedDiscoveryLocationProvider = FutureProvider<DiscoveryLocation?>((
  ref,
) async {
  final selectedAddress = ref.watch(userSelectedAddressProvider);
  if (selectedAddress != null) {
    return DiscoveryLocation(
      latitude: selectedAddress.latitude,
      longitude: selectedAddress.longitude,
      source: DiscoveryLocationSource.savedAddress,
    );
  }

  final position = await ref.watch(userLocationProvider.future);
  if (position == null) return null;

  return DiscoveryLocation(
    latitude: position.latitude,
    longitude: position.longitude,
    source: DiscoveryLocationSource.device,
  );
});

enum DiscoveryLocationSource { savedAddress, device }

class DiscoveryLocation {
  const DiscoveryLocation({
    required this.latitude,
    required this.longitude,
    required this.source,
  });

  final double latitude;
  final double longitude;
  final DiscoveryLocationSource source;
}

Future<Position?> _getPositionWithTimeout(Duration timeout) async {
  try {
    final result = await Geolocator.getCurrentPosition(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.medium,
        timeLimit: timeout,
      ),
    ).timeout(timeout);
    return result;
  } on TimeoutException {
    return null;
  } catch (_) {
    return null;
  }
}

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

  Future<void> filterByCategory(OfferCategory? category) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(offerRepositoryProvider);
      if (category == null) {
        return repo.getPopularOffers();
      }
      return repo.getPopularOffersFiltered(category: category.dbValue);
    });
  }
}

final nearbyOffersProvider =
    AsyncNotifierProvider<NearbyOffersNotifier, List<Offer>>(
      NearbyOffersNotifier.new,
    );

class NearbyOffersNotifier extends AsyncNotifier<List<Offer>> {
  OfferCategory? _category;

  @override
  Future<List<Offer>> build() async {
    final repo = ref.watch(offerRepositoryProvider);
    final location = ref.watch(selectedDiscoveryLocationProvider).asData?.value;

    if (location == null) {
      return repo.getPopularOffers();
    }

    return repo.getNearbyOffers(
      lat: location.latitude,
      lng: location.longitude,
      category: _category?.dbValue,
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    ref.invalidate(userLocationProvider);
    state = await AsyncValue.guard(() async {
      final repo = ref.read(offerRepositoryProvider);
      final location = await ref.read(selectedDiscoveryLocationProvider.future);

      if (location == null) {
        return repo.getPopularOffers();
      }

      return repo.getNearbyOffers(
        lat: location.latitude,
        lng: location.longitude,
        category: _category?.dbValue,
      );
    });
  }

  Future<void> filterByCategory(OfferCategory? category) async {
    _category = category;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(offerRepositoryProvider);
      final location = await ref.read(selectedDiscoveryLocationProvider.future);

      if (location == null) {
        if (_category == null) return repo.getPopularOffers();
        return repo.getPopularOffersFiltered(category: _category!.dbValue);
      }

      return repo.getNearbyOffers(
        lat: location.latitude,
        lng: location.longitude,
        category: _category?.dbValue,
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

final categoriesProvider = FutureProvider<List<OfferCategory>>((ref) async {
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

  Future<DiscoveryLocation?> _safeLocation() async {
    try {
      return await ref.read(selectedDiscoveryLocationProvider.future);
    } catch (_) {
      return null;
    }
  }

  Future<List<Offer>> _loadOffers({
    OfferCategory? category,
    double? maxPrice,
    double? maxDistanceKm,
    String? searchQuery,
  }) async {
    final repo = ref.read(offerRepositoryProvider);
    final position = await _safeLocation();

    final hasFilters =
        category != null ||
        maxPrice != null ||
        maxDistanceKm != null ||
        (searchQuery != null && searchQuery.isNotEmpty);

    if (position == null) {
      if (!hasFilters) {
        return repo.getPopularOffers(limit: 5);
      }
      return repo.getFilteredOffers(
        lat: 0,
        lng: 0,
        category: category?.dbValue,
        maxPrice: maxPrice,
        searchQuery: searchQuery,
      );
    }

    if (!hasFilters) {
      return repo.getPopularOffers(limit: 5);
    }

    return repo.getFilteredOffers(
      lat: position.latitude,
      lng: position.longitude,
      category: category?.dbValue,
      maxPrice: maxPrice,
      maxDistanceKm: maxDistanceKm ?? 10.0,
      searchQuery: searchQuery,
    );
  }

  Future<void> applyFilters({
    OfferCategory? category,
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

// ─── Expiring Soon Offers ────────────────────────────────────────

final expiringSoonOffersProvider =
    AsyncNotifierProvider<ExpiringSoonOffersNotifier, List<Offer>>(
      ExpiringSoonOffersNotifier.new,
    );

class ExpiringSoonOffersNotifier extends AsyncNotifier<List<Offer>> {
  @override
  Future<List<Offer>> build() async {
    final repo = ref.watch(offerRepositoryProvider);
    final location = ref.watch(selectedDiscoveryLocationProvider).asData?.value;

    if (location == null) {
      return repo.getExpiringSoonOffers();
    }

    return repo.getExpiringSoonOffers(
      lat: location.latitude,
      lng: location.longitude,
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    ref.invalidate(selectedDiscoveryLocationProvider);
    state = await AsyncValue.guard(() => build());
  }
}

// ─── Recent Offers ───────────────────────────────────────────────

final recentOffersProvider =
    AsyncNotifierProvider<RecentOffersNotifier, List<Offer>>(
      RecentOffersNotifier.new,
    );

class RecentOffersNotifier extends AsyncNotifier<List<Offer>> {
  @override
  Future<List<Offer>> build() async {
    final repo = ref.watch(offerRepositoryProvider);
    final location = ref.watch(selectedDiscoveryLocationProvider).asData?.value;

    if (location == null) {
      return repo.getRecentOffers();
    }

    return repo.getRecentOffers(
      lat: location.latitude,
      lng: location.longitude,
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    ref.invalidate(selectedDiscoveryLocationProvider);
    state = await AsyncValue.guard(() => build());
  }
}

// ─── Nearby Businesses ───────────────────────────────────────────

final nearbyBusinessesProvider =
    AsyncNotifierProvider<NearbyBusinessesNotifier, List<BusinessSummary>>(
      NearbyBusinessesNotifier.new,
    );

class NearbyBusinessesNotifier extends AsyncNotifier<List<BusinessSummary>> {
  @override
  Future<List<BusinessSummary>> build() async {
    final repo = ref.watch(offerRepositoryProvider);
    final location = ref.watch(selectedDiscoveryLocationProvider).asData?.value;

    if (location == null) {
      return repo.getNearbyBusinesses();
    }

    return repo.getNearbyBusinesses(
      lat: location.latitude,
      lng: location.longitude,
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    ref.invalidate(selectedDiscoveryLocationProvider);
    state = await AsyncValue.guard(() => build());
  }
}

// ─── All Active Offers (for /all-offers screen) ─────────────────

enum AllOffersView { all, popular, recent, expiring, nearby }

final allActiveOffersProvider =
    AsyncNotifierProvider<AllOffersNotifier, List<Offer>>(
      AllOffersNotifier.new,
    );

class AllOffersNotifier extends AsyncNotifier<List<Offer>> {
  @override
  Future<List<Offer>> build() async {
    final repo = ref.read(offerRepositoryProvider);
    return repo.getAllActiveOffers();
  }

  Future<void> loadView(AllOffersView view) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _loadByView(view));
  }

  Future<List<Offer>> _loadByView(AllOffersView view) async {
    final repo = ref.read(offerRepositoryProvider);
    final location = await ref.read(selectedDiscoveryLocationProvider.future);

    switch (view) {
      case AllOffersView.popular:
        return repo.getPopularOffers(limit: 50);
      case AllOffersView.recent:
        return repo.getRecentOffers(
          lat: location?.latitude,
          lng: location?.longitude,
          radiusKm: 50,
          limit: 50,
        );
      case AllOffersView.expiring:
        return repo.getExpiringSoonOffers(
          lat: location?.latitude,
          lng: location?.longitude,
          radiusKm: 50,
          limit: 50,
        );
      case AllOffersView.nearby:
        if (location == null) return repo.getPopularOffers(limit: 50);
        return repo.getNearbyOffers(
          lat: location.latitude,
          lng: location.longitude,
          radiusKm: 10,
          limit: 50,
        );
      case AllOffersView.all:
        return repo.getAllActiveOffers();
    }
  }

  Future<void> applyFilters({
    OfferCategory? category,
    double? maxPrice,
    double? maxDistanceKm,
    String? searchQuery,
  }) async {
    final repo = ref.read(offerRepositoryProvider);
    final location = await ref.read(selectedDiscoveryLocationProvider.future);

    final hasFilters =
        category != null ||
        maxPrice != null ||
        maxDistanceKm != null ||
        (searchQuery != null && searchQuery.isNotEmpty);

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      if (!hasFilters) {
        return repo.getAllActiveOffers();
      }
      return repo.getFilteredOffers(
        lat: location?.latitude ?? 0,
        lng: location?.longitude ?? 0,
        category: category?.dbValue,
        maxPrice: maxPrice,
        maxDistanceKm: maxDistanceKm,
        searchQuery: searchQuery,
      );
    });
  }
}

// ─── All Businesses (for /all-businesses screen) ─────────────────

final allBusinessesProvider =
    FutureProvider.family<List<BusinessSummary>, AllBusinessesFilter>((
      ref,
      filter,
    ) async {
      final repo = ref.read(offerRepositoryProvider);
      final location = await ref.read(selectedDiscoveryLocationProvider.future);

      return repo.getAllBusinesses(
        lat: location?.latitude,
        lng: location?.longitude,
        searchQuery: filter.searchQuery,
        type: filter.type,
      );
    });

class AllBusinessesFilter {
  const AllBusinessesFilter({this.searchQuery, this.type});

  final String? searchQuery;
  final String? type;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AllBusinessesFilter &&
          runtimeType == other.runtimeType &&
          searchQuery == other.searchQuery &&
          type == other.type;

  @override
  int get hashCode => Object.hash(searchQuery, type);
}
