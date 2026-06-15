import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fudi/features/auth/domain/auth_repository.dart';
import 'package:fudi/features/auth/domain/user_profile.dart';
import 'package:fudi/features/auth/presentation/auth_state_provider.dart';
import 'package:fudi/features/favorites/domain/favorites_repository.dart';
import 'package:fudi/features/favorites/presentation/favorites_providers.dart';

class MockFavoritesRepository extends Mock implements FavoritesRepository {}

class MockAuthSessionNotifier extends AuthSessionNotifier {
  @override
  AuthSessionState build() {
    return const AuthSessionState(
      session: null,
      profile: UserProfile(
        id: 'user-123',
        email: 'test@fudi.com',
        role: UserRole.user,
      ),
      fallbackRole: UserRole.user,
    );
  }
}

void main() {
  late MockFavoritesRepository mockRepo;

  setUp(() {
    mockRepo = MockFavoritesRepository();

    // Default mock setup
    when(
      () => mockRepo.getFavoriteOfferIds('user-123'),
    ).thenAnswer((_) async => {'offer-1', 'offer-2'});
  });

  group('Favorites Providers Integration', () {
    test('loads initial favorited offer IDs', () async {
      final container = ProviderContainer(
        overrides: [
          favoritesRepositoryProvider.overrideWithValue(mockRepo),
          authSessionNotifierProvider.overrideWith(MockAuthSessionNotifier.new),
        ],
      );
      addTearDown(container.dispose);

      // Initially state might be empty or loading
      expect(container.read(favoritedOfferIdsProvider), isEmpty);

      // Wait for initial load async call to resolve
      await Future.delayed(const Duration(milliseconds: 10));

      expect(
        container.read(favoritedOfferIdsProvider),
        equals({'offer-1', 'offer-2'}),
      );
      verify(() => mockRepo.getFavoriteOfferIds('user-123')).called(1);
    });

    test('toggleFavorite adds favorite and triggers ref.invalidate', () async {
      when(
        () => mockRepo.addFavorite('user-123', 'offer-3'),
      ).thenAnswer((_) async => 'fav-3');

      final container = ProviderContainer(
        overrides: [
          favoritesRepositoryProvider.overrideWithValue(mockRepo),
          authSessionNotifierProvider.overrideWith(MockAuthSessionNotifier.new),
        ],
      );
      addTearDown(container.dispose);

      // Trigger initialization and wait for load
      container.read(favoritedOfferIdsProvider);
      await Future.delayed(const Duration(milliseconds: 10));

      final notifier = container.read(favoritedOfferIdsProvider.notifier);
      final toggleFuture = notifier.toggleFavorite('offer-3');

      // Optimistic check
      expect(
        container.read(favoritedOfferIdsProvider),
        equals({'offer-1', 'offer-2', 'offer-3'}),
      );

      await toggleFuture;

      verify(() => mockRepo.addFavorite('user-123', 'offer-3')).called(1);
    });

    test('toggleFavorite reverts on error', () async {
      // Return a Future that throws an exception to simulate an async DB failure
      when(
        () => mockRepo.addFavorite('user-123', 'offer-3'),
      ).thenAnswer((_) async => throw Exception('DB error'));

      final container = ProviderContainer(
        overrides: [
          favoritesRepositoryProvider.overrideWithValue(mockRepo),
          authSessionNotifierProvider.overrideWith(MockAuthSessionNotifier.new),
        ],
      );
      addTearDown(container.dispose);

      // Trigger initialization and wait for load
      container.read(favoritedOfferIdsProvider);
      await Future.delayed(const Duration(milliseconds: 10));

      final notifier = container.read(favoritedOfferIdsProvider.notifier);
      final toggleFuture = notifier.toggleFavorite('offer-3');

      // Optimistic check (should be active during the async operation)
      expect(
        container.read(favoritedOfferIdsProvider),
        equals({'offer-1', 'offer-2', 'offer-3'}),
      );

      await toggleFuture;

      // Reverted check (after the async failure resolves)
      expect(
        container.read(favoritedOfferIdsProvider),
        equals({'offer-1', 'offer-2'}),
      );
      verify(() => mockRepo.addFavorite('user-123', 'offer-3')).called(1);
    });

    test('toggleFavorite removes favorite', () async {
      when(
        () => mockRepo.removeFavoriteByOfferId('user-123', 'offer-1'),
      ).thenAnswer((_) async {});

      final container = ProviderContainer(
        overrides: [
          favoritesRepositoryProvider.overrideWithValue(mockRepo),
          authSessionNotifierProvider.overrideWith(MockAuthSessionNotifier.new),
        ],
      );
      addTearDown(container.dispose);

      // Trigger initialization and wait for load
      container.read(favoritedOfferIdsProvider);
      await Future.delayed(const Duration(milliseconds: 10));

      final notifier = container.read(favoritedOfferIdsProvider.notifier);
      final toggleFuture = notifier.toggleFavorite('offer-1');

      // Optimistic check
      expect(container.read(favoritedOfferIdsProvider), equals({'offer-2'}));

      await toggleFuture;

      verify(
        () => mockRepo.removeFavoriteByOfferId('user-123', 'offer-1'),
      ).called(1);
    });
  });
}
