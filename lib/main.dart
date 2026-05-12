import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/config/app_config.dart';
import 'core/config/app_environment.dart';
import 'core/di/core_providers.dart';
import 'core/observability/sentry_init.dart';
import 'core/ui/fudi_theme.dart';
import 'features/auth/presentation/auth_state_provider.dart';

void main() async {
  // 1. Ensure Flutter bindings are initialized before any async work
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Determine environment (compile-time constant or fallback to dev)
  const envString = String.fromEnvironment('APP_ENV', defaultValue: 'dev');
  final environment = AppEnvironment.fromString(envString);

  // 3. Load environment-specific .env file (from assets or filesystem)
  await _loadEnv(environment);

  // 4. Build AppConfig from loaded env vars
  final config = AppConfig.fromEnv(environment);

  // 5. Initialize Supabase
  await Supabase.initialize(
    url: config.supabaseUrl,
    anonKey: config.supabaseAnonKey,
    debug: config.isDev,
  );

  // 5b. Initialize Firebase (only if configured)
  if (config.hasFirebase) {
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: config.firebaseApiKey,
        projectId: config.firebaseProjectId,
        messagingSenderId: config.firebaseMessagingSenderId,
        appId: config.firebaseAppId,
      ),
    );
  }

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

/// Loads the .env file for the given [environment].
///
/// On web: only `.env.dev` is bundled as an asset. Other environments
/// must provide credentials via `--dart-define` compile-time constants.
///
/// On native: tries the target env file first, then falls back to
/// `.env.dev`. In debug mode, silently skips if no file is found.
///
/// On web in non-dev environments: skips dotenv entirely and relies
/// on `--dart-define` constants (AppConfig.fromEnv reads those too).
Future<void> _loadEnv(AppEnvironment environment) async {
  if (kIsWeb && environment != AppEnvironment.dev) {
    return;
  }

  final fileName = environment.envFileName;

  try {
    await dotenv.load(fileName: fileName);
    return;
  } catch (_) {}

  if (environment != AppEnvironment.dev) {
    try {
      await dotenv.load(fileName: AppEnvironment.dev.envFileName);
      return;
    } catch (_) {}
  }

  if (kDebugMode) {
    return;
  }

  throw StateError(
    'No .env file found. Create $fileName or .env.dev with your '
    'Supabase and service credentials. See .env.example for reference.',
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
      theme: FudiTheme.light(),
      routerConfig: router,
      builder: (context, child) {
        return AuthFeedbackListener(child: child ?? const SizedBox.shrink());
      },
    );
  }
}
