import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'app_environment.dart';

/// Central application configuration loaded from environment-specific
/// .env files via flutter_dotenv.
///
/// Usage:
///   final config = AppConfig.fromEnv(AppEnvironment.dev);
///   print(config.supabaseUrl);
class AppConfig {
  final AppEnvironment environment;
  final String supabaseUrl;
  final String supabaseAnonKey;
  final String sentryDsn;
  final String googleMapsApiKey;

  const AppConfig({
    required this.environment,
    required this.supabaseUrl,
    required this.supabaseAnonKey,
    required this.sentryDsn,
    required this.googleMapsApiKey,
  });

  /// Factory constructor that reads values from the currently loaded
  /// flutter_dotenv environment.
  ///
  /// Ensure [dotenv.load(fileName)] has been called before using this.
  factory AppConfig.fromEnv(AppEnvironment env) {
    return AppConfig(
      environment: env,
      supabaseUrl: dotenv.env['SUPABASE_URL'] ?? '',
      supabaseAnonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
      sentryDsn: dotenv.env['SENTRY_DSN'] ?? '',
      googleMapsApiKey: dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '',
    );
  }

  /// Convenience getters for environment checks.
  bool get isDev => environment == AppEnvironment.dev;
  bool get isStaging => environment == AppEnvironment.staging;
  bool get isProd => environment == AppEnvironment.prod;

  /// Whether Sentry crash reporting is configured for this environment.
  bool get hasSentry => sentryDsn.isNotEmpty;

  /// Whether Google Maps integration is configured for this environment.
  bool get hasGoogleMaps => googleMapsApiKey.isNotEmpty;

  @override
  String toString() {
    return 'AppConfig('
        'environment: $environment, '
        'supabaseUrl: $supabaseUrl, '
        'hasSentry: $hasSentry, '
        'hasGoogleMaps: $hasGoogleMaps'
        ')';
  }
}
