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
  final String authResetRedirectUrl;
  final String firebaseApiKey;
  final String firebaseProjectId;
  final String firebaseMessagingSenderId;
  final String firebaseAppId;

  const AppConfig({
    required this.environment,
    required this.supabaseUrl,
    required this.supabaseAnonKey,
    required this.sentryDsn,
    required this.googleMapsApiKey,
    required this.authResetRedirectUrl,
    required this.firebaseApiKey,
    required this.firebaseProjectId,
    required this.firebaseMessagingSenderId,
    required this.firebaseAppId,
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
      authResetRedirectUrl: dotenv.env['AUTH_RESET_REDIRECT_URL'] ?? '',
      firebaseApiKey: dotenv.env['FIREBASE_API_KEY'] ?? '',
      firebaseProjectId: dotenv.env['FIREBASE_PROJECT_ID'] ?? '',
      firebaseMessagingSenderId: dotenv.env['FIREBASE_MESSAGING_SENDER_ID'] ?? '',
      firebaseAppId: dotenv.env['FIREBASE_APP_ID'] ?? '',
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
  bool get hasAuthResetRedirectUrl => authResetRedirectUrl.isNotEmpty;

  bool get hasFirebase =>
      firebaseApiKey.isNotEmpty && firebaseProjectId.isNotEmpty;

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
