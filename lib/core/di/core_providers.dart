import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/auth/presentation/auth_state_provider.dart';
import '../config/app_config.dart';
import '../config/app_environment.dart';
import '../routing/app_router.dart';

/// Provider for the current [AppEnvironment].
///
/// Defaults to [AppEnvironment.dev]. Override in main.dart after
/// loading dotenv if you need to resolve environment from env vars.
final appEnvironmentProvider = Provider<AppEnvironment>((ref) {
  const envStr = String.fromEnvironment('APP_ENV', defaultValue: 'dev');
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
  return Supabase.instance.client;
});

/// Provider for the [GoRouter] instance.
///
/// Creates the router with all 40+ routes and auth/role guards.
/// The router is created fresh each time (not cached) because
/// GoRouter is stateful and shouldn't be reused across hot reloads.
final appRouterProvider = Provider<GoRouter>((ref) {
  final authSessionNotifier = ref.watch(authSessionNotifierProvider.notifier);
  final refreshListenable = ref.watch(authRefreshListenableProvider);
  return createAppRouter(authSessionNotifier, refreshListenable);
});

/// Provider for SharedPreferences. Must be overridden in main.dart.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});
