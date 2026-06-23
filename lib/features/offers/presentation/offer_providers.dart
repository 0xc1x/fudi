import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../../core/di/core_providers.dart';
import '../../../core/error/fudi_exception.dart';
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
    final position = await ref.watch(userLocationProvider.future);

    if (position == null) {
      return repo.getPopularOffers();
    }

    return repo.getNearbyOffers(
      lat: position.latitude,
      lng: position.longitude,
      category: _category?.dbValue,
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
        category: _category?.dbValue,
      );
    });
  }

  Future<void> filterByCategory(OfferCategory? category) async {
    _category = category;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(offerRepositoryProvider);
      final position = await ref.read(userLocationProvider.future);

      if (position == null) {
        if (_category == null) return repo.getPopularOffers();
        return repo.getPopularOffersFiltered(category: _category!.dbValue);
      }

      return repo.getNearbyOffers(
        lat: position.latitude,
        lng: position.longitude,
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

  Future<Position?> _safeLocation() async {
    try {
      return await ref.read(userLocationProvider.future);
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

    final hasFilters = category != null ||
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
    return _load();
  }

  Future<int> _getRadius() async {
    try {
      final prefs = await ref.read(consumerPreferencesProvider.future);
      return prefs.notificationRadiusKm;
    } on FudiException {
      return 5;
    } catch (_) {
      return 5;
    }
  }

  Future<List<Offer>> _load() async {
    final repo = ref.read(offerRepositoryProvider);
    final radius = await _getRadius();
    final position = await ref.read(userLocationProvider.future);

    if (position == null) {
      return repo.getExpiringSoonOffers(radiusKm: radius.toDouble());
    }

    return repo.getExpiringSoonOffers(
      lat: position.latitude,
      lng: position.longitude,
      radiusKm: radius.toDouble(),
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    ref.invalidate(userLocationProvider);
    state = await AsyncValue.guard(() => _load());
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
    return _load();
  }

  Future<int> _getRadius() async {
    try {
      final prefs = await ref.read(consumerPreferencesProvider.future);
      return prefs.notificationRadiusKm;
    } on FudiException {
      return 5;
    } catch (_) {
      return 5;
    }
  }

  Future<List<Offer>> _load() async {
    final repo = ref.read(offerRepositoryProvider);
    final radius = await _getRadius();
    final position = await ref.read(userLocationProvider.future);

    if (position == null) {
      return repo.getRecentOffers(radiusKm: radius.toDouble());
    }

    return repo.getRecentOffers(
      lat: position.latitude,
      lng: position.longitude,
      radiusKm: radius.toDouble(),
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    ref.invalidate(userLocationProvider);
    state = await AsyncValue.guard(() => _load());
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
    return _load();
  }

  Future<int> _getRadius() async {
    try {
      final prefs = await ref.read(consumerPreferencesProvider.future);
      return prefs.notificationRadiusKm;
    } on FudiException {
      return 5;
    } catch (_) {
      return 5;
    }
  }

  Future<List<BusinessSummary>> _load() async {
    final repo = ref.read(offerRepositoryProvider);
    final radius = await _getRadius();
    final position = await ref.read(userLocationProvider.future);

    return repo.getNearbyBusinesses(
      lat: position?.latitude,
      lng: position?.longitude,
      radiusKm: radius.toDouble(),
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    ref.invalidate(userLocationProvider);
    state = await AsyncValue.guard(() => _load());
  }
}

// ─── All Active Offers (for /all-offers screen) ─────────────────

enum AllOffersView { all, popular, recent, expiring, nearby, }

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
    final position = await ref.read(userLocationProvider.future);

    switch (view) {
      case AllOffersView.popular:
        return repo.getPopularOffers(limit: 50);
      case AllOffersView.recent:
        return repo.getRecentOffers(
          lat: position?.latitude,
          lng: position?.longitude,
          radiusKm: 50,
          limit: 50,
        );
      case AllOffersView.expiring:
        return repo.getExpiringSoonOffers(
          lat: position?.latitude,
          lng: position?.longitude,
          radiusKm: 50,
          limit: 50,
        );
      case AllOffersView.nearby:
        if (position == null) return repo.getPopularOffers(limit: 50);
        return repo.getNearbyOffers(
          lat: position.latitude,
          lng: position.longitude,
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
    final position = await ref.read(userLocationProvider.future);

    final hasFilters = category != null ||
        maxPrice != null ||
        maxDistanceKm != null ||
        (searchQuery != null && searchQuery.isNotEmpty);

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      if (!hasFilters) {
        return repo.getAllActiveOffers();
      }
      return repo.getFilteredOffers(
        lat: position?.latitude ?? 0,
        lng: position?.longitude ?? 0,
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
    FutureProvider.family<List<BusinessSummary>, AllBusinessesFilter>(
      (ref, filter) async {
        final repo = ref.read(offerRepositoryProvider);
        final position = await ref.read(userLocationProvider.future);

        return repo.getAllBusinesses(
          lat: position?.latitude,
          lng: position?.longitude,
          searchQuery: filter.searchQuery,
          type: filter.type,
        );
      },
    );

class AllBusinessesFilter {
  const AllBusinessesFilter({
    this.searchQuery,
    this.type,
  });

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
