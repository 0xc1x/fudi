import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'app_environment.dart';

/// Central application configuration loaded from environment-specific
/// .env files via flutter_dotenv, with fallback to `--dart-define`
/// compile-time constants.
///
/// Resolution order per key:
/// 1. dotenv.env (from .env file)
/// 2. String.fromEnvironment (from --dart-define)
/// 3. Empty string fallback
///
/// Usage:
/// final config = AppConfig.fromEnv(AppEnvironment.dev);
/// print(config.supabaseUrl);
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
  final String firebaseVapidKey;

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
    required this.firebaseVapidKey,
  });

  /// Factory constructor that reads values from the currently loaded
  /// flutter_dotenv environment.
  ///
  /// Ensure [dotenv.load(fileName)] has been called before using this.
  factory AppConfig.fromEnv(AppEnvironment env) {
    return AppConfig(
      environment: env,
      supabaseUrl: _resolveAny(['SUPABASE_URL', 'SUPABASE_PROJECT_URL']),
      supabaseAnonKey: _resolve('SUPABASE_ANON_KEY'),
      sentryDsn: _resolve('SENTRY_DSN'),
      googleMapsApiKey: _resolve('GOOGLE_MAPS_API_KEY'),
      authResetRedirectUrl: _resolve('AUTH_RESET_REDIRECT_URL'),
      firebaseApiKey: _resolve('FIREBASE_API_KEY'),
      firebaseProjectId: _resolve('FIREBASE_PROJECT_ID'),
      firebaseMessagingSenderId: _resolve('FIREBASE_MESSAGING_SENDER_ID'),
      firebaseAppId: _resolve('FIREBASE_APP_ID'),
      firebaseVapidKey: _resolve('FIREBASE_VAPID_KEY'),
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

String _resolve(String key) {
  final fromDotenv = dotenv.env[key];
  if (fromDotenv != null && fromDotenv.isNotEmpty) return fromDotenv;
  return _dartDefine[key] ?? '';
}

String _resolveAny(List<String> keys) {
  for (final key in keys) {
    final value = _resolve(key);
    if (value.isNotEmpty) return value;
  }
  return '';
}

const _dartDefine = {
  'SUPABASE_URL': String.fromEnvironment('SUPABASE_URL', defaultValue: ''),
  'SUPABASE_ANON_KEY': String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  ),
  'SENTRY_DSN': String.fromEnvironment('SENTRY_DSN', defaultValue: ''),
  'GOOGLE_MAPS_API_KEY': String.fromEnvironment(
    'GOOGLE_MAPS_API_KEY',
    defaultValue: '',
  ),
  'AUTH_RESET_REDIRECT_URL': String.fromEnvironment(
    'AUTH_RESET_REDIRECT_URL',
    defaultValue: '',
  ),
  'FIREBASE_API_KEY': String.fromEnvironment(
    'FIREBASE_API_KEY',
    defaultValue: '',
  ),
  'FIREBASE_PROJECT_ID': String.fromEnvironment(
    'FIREBASE_PROJECT_ID',
    defaultValue: '',
  ),
  'FIREBASE_MESSAGING_SENDER_ID': String.fromEnvironment(
    'FIREBASE_MESSAGING_SENDER_ID',
    defaultValue: '',
  ),
  'FIREBASE_APP_ID': String.fromEnvironment(
    'FIREBASE_APP_ID',
    defaultValue: '',
  ),
  'FIREBASE_VAPID_KEY': String.fromEnvironment(
    'FIREBASE_VAPID_KEY',
    defaultValue: '',
  ),
};
