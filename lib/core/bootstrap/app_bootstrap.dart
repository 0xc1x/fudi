import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../config/app_config.dart';
import '../config/app_environment.dart';

class AppBootstrapResult {
  final AppEnvironment environment;
  final AppConfig config;
  final bool sentryEnabled;

  const AppBootstrapResult({
    required this.environment,
    required this.config,
    required this.sentryEnabled,
  });
}

class AppBootstrap {
  AppBootstrap._();

  static Future<AppBootstrapResult> run() async {
    await initializeDateFormatting('es');

    const envString = String.fromEnvironment('APP_ENV', defaultValue: 'dev');
    final environment = AppEnvironment.fromString(envString);

    await _loadEnv(environment);

    final config = AppConfig.fromEnv(environment);

    await Supabase.initialize(
      url: config.supabaseUrl,
      anonKey: config.supabaseAnonKey,
      debug: config.isDev,
    );

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

    bool sentryEnabled = false;
    if (config.hasSentry) {
      sentryEnabled = true;
      await SentryFlutter.init((options) {
        options.dsn = config.sentryDsn;
        options.environment = config.environment.name;
        options.release = 'fudi@1.0.0+1';
        options.tracesSampleRate = config.isDev
            ? 1.0
            : (config.isStaging ? 0.5 : 0.2);
        // ignore: experimental_member_use
        options.profilesSampleRate = config.isDev
            ? 1.0
            : (config.isStaging ? 0.3 : 0.1);
        options.attachStacktrace = true;
        options.attachThreads = true;
        options.sendDefaultPii = false;
        options.enableLogs = true;

        options.beforeSend = (event, hint) {
          event.tags ??= {};
          event.tags!['app_version'] = '1.0.0';
          event.tags!['environment'] = config.environment.shortName;
          return event;
        };

        options.beforeSendTransaction = (transaction, hint) {
          final transactionName = transaction.transaction;
          if (transactionName != null &&
              transactionName.startsWith('GET /health')) {
            return null;
          }
          return transaction;
        };
      });
    }

    return AppBootstrapResult(
      environment: environment,
      config: config,
      sentryEnabled: sentryEnabled,
    );
  }

  static Future<void> _loadEnv(AppEnvironment environment) async {
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
}
