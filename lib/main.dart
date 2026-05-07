import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/config/app_config.dart';
import 'core/config/app_environment.dart';
import 'core/di/core_providers.dart';
import 'core/observability/sentry_init.dart';

void main() async {
  // 1. Ensure Flutter bindings are initialized before any async work
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Determine environment (compile-time constant or fallback to dev)
  const envString = String.fromEnvironment('APP_ENV', defaultValue: 'dev');
  final environment = AppEnvironment.fromString(envString);

  // 3. Load environment-specific .env file
  await dotenv.load(fileName: environment.envFileName);

  // 4. Build AppConfig from loaded env vars
  final config = AppConfig.fromEnv(environment);

  // 5. Initialize Supabase
  await Supabase.initialize(
    url: config.supabaseUrl,
    anonKey: config.supabaseAnonKey,
    debug: config.isDev,
  );

  // 6. Initialize Sentry (only if DSN is configured)
  if (config.hasSentry) {
    await initSentry(config);
  }

  // 7. Run the app with Riverpod + Sentry integration
  runApp(
    ProviderScope(
      overrides: [
        // Override the environment provider so the rest of the app
        // reads the resolved environment without re-parsing
        appEnvironmentProvider.overrideWithValue(environment),
        appConfigProvider.overrideWithValue(config),
      ],
      child: const FudiApp(),
    ),
  );
}

/// Root widget for the Fudi application.
///
/// Wraps the MaterialApp with Sentry's navigation observer
/// and uses GoRouter for declarative routing.
class FudiApp extends ConsumerWidget {
  const FudiApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(appConfigProvider);
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Fudi',
      debugShowCheckedModeBanner: config.isDev,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF256646), // Fudi primary green
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}
