import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/app_config.dart';
import '../config/app_environment.dart';
import '../network/offline_aware_repository.dart';
import '../network/secure_http_client.dart';
import '../routing/app_router.dart';

/// Provider for the current [AppEnvironment].
///
/// Defaults to [AppEnvironment.dev]. Override in main.dart after
/// loading dotenv if you need to resolve environment from env vars.
final appEnvironmentProvider = Provider<AppEnvironment>((ref) {
  final envStr = const String.fromEnvironment('APP_ENV', defaultValue: 'dev');
  return AppEnvironment.fromString(envStr);
});

/// Provider for [AppConfig].
///
/// Depends on [appEnvironmentProvider]. Ensure dotenv is loaded
/// before this provider is first read.
final appConfigProvider = Provider<AppConfig>((ref) {
  final env = ref.watch(appEnvironmentProvider);
  return AppConfig.fromEnv(env);
});

/// Provider for the Supabase client singleton.
///
/// Supabase must be initialized in main.dart before this provider
/// is first read. The client is obtained via [Supabase.instanceClient].
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instanceClient;
});

/// Provider for the [SecureHttpClient].
///
/// Wraps Dio with auth token injection, Sentry tracing, error mapping,
/// retry with backoff, and circuit breaker. Depends on Supabase for
/// auth token injection.
final secureHttpClientProvider = Provider<SecureHttpClient>((ref) {
  final supabaseClient = ref.watch(supabaseClientProvider);
  return SecureHttpClient(supabaseClient: supabaseClient);
});

/// Provider for the [GoRouter] instance.
///
/// Creates the router with all 40+ routes and auth/role guards.
/// The router is created fresh each time (not cached) because
/// GoRouter is stateful and shouldn't be reused across hot reloads.
final appRouterProvider = Provider<GoRouter>((ref) {
  return createAppRouter();
});

/// Provider for the [OfflineAwareRepository].
///
/// Uses InternetConnection for connectivity checks and
/// FlutterSecureStorage for cache storage.
final offlineAwareRepositoryProvider = Provider<OfflineAwareRepository>((ref) {
  return OfflineAwareRepository(
    connectivity: InternetConnection(),
  );
});
