import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';

import 'package:fudi/core/config/app_config.dart';
import 'package:fudi/core/config/app_environment.dart';
import 'package:fudi/core/di/core_providers.dart';
import 'package:fudi/core/network/push_service.dart';
import 'package:fudi/features/auth/domain/auth_repository.dart';
import 'package:fudi/features/auth/presentation/auth_state_provider.dart';
import 'package:fudi/features/notifications/data/firebase_push_service.dart';
import 'package:fudi/main.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('FudiApp smoke test — app renders without crash', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          // ── Environment & config overrides ────────────────────────
          appEnvironmentProvider.overrideWithValue(AppEnvironment.dev),
          appConfigProvider.overrideWithValue(
            const AppConfig(
              environment: AppEnvironment.dev,
              supabaseUrl: '',
              supabaseAnonKey: '',
              sentryDsn: '',
              googleMapsApiKey: '',
              authResetRedirectUrl: '',
              firebaseApiKey: '',
              firebaseProjectId: '',
              firebaseMessagingSenderId: '',
              firebaseAppId: '',
              firebaseVapidKey: '',
            ),
          ),

          // ── Router — bypass auth guards, Sentry observers ──────────
          appRouterProvider.overrideWithValue(
            GoRouter(
              initialLocation: '/',
              routes: [
                GoRoute(
                  path: '/',
                  builder: (_, _) =>
                      const Scaffold(body: Center(child: Text('Fudi'))),
                ),
              ],
            ),
          ),

          // ── Auth — avoid Supabase dependency ───────────────────────
          authSessionNotifierProvider.overrideWith(
            () => _TestAuthSessionNotifier(),
          ),
          authRefreshListenableProvider.overrideWithValue(ChangeNotifier()),

          // ── Push service — avoid Firebase dependency ───────────────
          pushServiceProvider.overrideWithValue(_TestPushService()),
        ],
        child: const FudiApp(),
      ),
    );

    // Allow one frame so post-frame callbacks run and the widget tree
    // settles (PushNotificationHandler._registerTokenIfAuthenticated
    // uses addPostFrameCallback, and GoRouter needs a frame to resolve).
    await tester.pump();

    // ── Assertions ────────────────────────────────────────────────
    // Verify that the MaterialApp.router was rendered.
    expect(find.byType(MaterialApp), findsOneWidget);

    // Verify that the mock route content appears inside the app.
    expect(find.text('Fudi'), findsOneWidget);

    // Verify no render overflow or binding errors.
    expect(tester.takeException(), isNull);
  });
}

/// A minimal [AuthSessionNotifier] that returns
/// [AuthSessionState.unauthenticated] without setting up Supabase
/// subscriptions or token-refresh timers.
class _TestAuthSessionNotifier extends AuthSessionNotifier {
  @override
  AuthSessionState build() {
    return const AuthSessionState.unauthenticated();
  }
}

/// A no-op [PushService] that satisfies all interface contracts
/// without depending on Firebase, Supabase, or any native plugin.
class _TestPushService implements PushService {
  @override
  Stream<PushNotification> get onMessage =>
      const Stream<PushNotification>.empty();

  @override
  Stream<PushNotification> get onMessageOpenedApp =>
      const Stream<PushNotification>.empty();

  @override
  Future<PushNotification?> get initialMessage async => null;

  @override
  void dispose() {}

  @override
  Future<String?> getInitialToken() async => null;

  @override
  Future<String?> getToken() async => null;

  @override
  Future<void> initialize() async {}

  @override
  Future<void> registerToken(String userId) async {}

  @override
  Future<bool> requestPermission() async => false;

  @override
  Future<void> unregisterToken() async {}
}
