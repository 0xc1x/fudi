import 'package:flutter_test/flutter_test.dart';
import 'package:fudi/core/config/app_environment.dart';
import 'package:fudi/core/config/app_config.dart';

void main() {
  group('AppEnvironment', () {
    group('fromString', () {
      test('returns dev for unknown string', () {
        expect(AppEnvironment.fromString('unknown'), AppEnvironment.dev);
      });

      test('returns dev for empty string', () {
        expect(AppEnvironment.fromString(''), AppEnvironment.dev);
      });

      test('returns staging for "staging"', () {
        expect(AppEnvironment.fromString('staging'), AppEnvironment.staging);
      });

      test('returns prod for "prod"', () {
        expect(AppEnvironment.fromString('prod'), AppEnvironment.prod);
      });

      test('returns prod for "production"', () {
        expect(AppEnvironment.fromString('production'), AppEnvironment.prod);
      });

      test('is case insensitive', () {
        expect(AppEnvironment.fromString('DEV'), AppEnvironment.dev);
        expect(AppEnvironment.fromString('Staging'), AppEnvironment.staging);
        expect(AppEnvironment.fromString('PROD'), AppEnvironment.prod);
      });
    });

    group('displayName', () {
      test('returns human-readable names', () {
        expect(AppEnvironment.dev.displayName, 'Development');
        expect(AppEnvironment.staging.displayName, 'Staging');
        expect(AppEnvironment.prod.displayName, 'Production');
      });
    });

    group('shortName', () {
      test('returns short identifiers', () {
        expect(AppEnvironment.dev.shortName, 'dev');
        expect(AppEnvironment.staging.shortName, 'staging');
        expect(AppEnvironment.prod.shortName, 'prod');
      });
    });

    group('envFileName', () {
      test('returns correct .env file names', () {
        expect(AppEnvironment.dev.envFileName, '.env.dev');
        expect(AppEnvironment.staging.envFileName, '.env.staging');
        expect(AppEnvironment.prod.envFileName, '.env.prod');
      });
    });
  });

  group('AppConfig', () {
    test('isDev returns true for dev environment', () {
    const config = AppConfig(
      environment: AppEnvironment.dev,
      supabaseUrl: 'https://example.supabase.co',
      supabaseAnonKey: 'key',
      sentryDsn: '',
      googleMapsApiKey: '',
      authResetRedirectUrl: '',
      firebaseApiKey: '',
      firebaseProjectId: '',
      firebaseMessagingSenderId: '',
      firebaseAppId: '',
    );
      expect(config.isDev, true);
      expect(config.isStaging, false);
      expect(config.isProd, false);
    });

    test('hasSentry returns false for empty DSN', () {
    const config = AppConfig(
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
    );
    expect(config.hasSentry, false);
  });

  test('hasSentry returns true for non-empty DSN', () {
    const config = AppConfig(
      environment: AppEnvironment.prod,
      supabaseUrl: '',
      supabaseAnonKey: '',
      sentryDsn: 'https://abc@sentry.io/123',
      googleMapsApiKey: '',
      authResetRedirectUrl: '',
      firebaseApiKey: '',
      firebaseProjectId: '',
      firebaseMessagingSenderId: '',
      firebaseAppId: '',
    );
      expect(config.hasSentry, true);
    });

    test('hasGoogleMaps returns false for empty key', () {
    const config = AppConfig(
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
    );
    expect(config.hasGoogleMaps, false);
  });

  test('toString does not expose secrets', () {
    const config = AppConfig(
      environment: AppEnvironment.prod,
      supabaseUrl: 'https://secret.supabase.co',
      supabaseAnonKey: 'super-secret-key',
      sentryDsn: 'https://abc@sentry.io/123',
      googleMapsApiKey: 'maps-key',
      authResetRedirectUrl: 'https://example.com/reset',
      firebaseApiKey: 'fb-api-key',
      firebaseProjectId: 'fb-project',
      firebaseMessagingSenderId: 'fb-sender',
      firebaseAppId: 'fb-app',
    );
      final str = config.toString();
      expect(str, contains('AppConfig'));
      expect(str, contains('hasSentry'));
      expect(str, isNot(contains('super-secret-key')));
      expect(str, isNot(contains('maps-key')));
    });
  });
}
