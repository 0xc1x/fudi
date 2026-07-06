import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fudi/core/ui/theme_notifier.dart';
import 'package:fudi/core/di/core_providers.dart';
import 'package:fudi/features/profile/domain/consumer_preferences.dart';
import 'package:fudi/features/profile/presentation/profile_providers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ThemeNotifier State Management Tests', () {
    late SharedPreferences sharedPrefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({
        'app_theme_mode': 'dark',
      });
      sharedPrefs = await SharedPreferences.getInstance();
    });

    test('Loads initial theme mode from SharedPreferences', () {
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(sharedPrefs),
          // Override consumerPreferencesProvider to avoid Supabase dependency
          consumerPreferencesProvider.overrideWith(
            (ref) async => ConsumerPreferences.empty.copyWith(themeMode: 'dark'),
          ),
        ],
      );
      addTearDown(container.dispose);

      final themeMode = container.read(themeNotifierProvider);
      expect(themeMode, AppThemeMode.dark);
    });

    test('Defaults to system when no SharedPreferences value exists', () async {
      SharedPreferences.setMockInitialValues({});
      final emptyPrefs = await SharedPreferences.getInstance();

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(emptyPrefs),
          consumerPreferencesProvider.overrideWith(
            (ref) async => ConsumerPreferences.empty.copyWith(themeMode: 'system'),
          ),
        ],
      );
      addTearDown(container.dispose);

      final themeMode = container.read(themeNotifierProvider);
      expect(themeMode, AppThemeMode.system);
    });

    test('AppThemeMode.fromString handles all valid values', () {
      expect(AppThemeMode.fromString('light'), AppThemeMode.light);
      expect(AppThemeMode.fromString('dark'), AppThemeMode.dark);
      expect(AppThemeMode.fromString('system'), AppThemeMode.system);
      expect(AppThemeMode.fromString(null), AppThemeMode.system);
      expect(AppThemeMode.fromString('invalid'), AppThemeMode.system);
    });

    test('ThemeNotifier.themeMode returns correct Flutter ThemeMode', () {
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(sharedPrefs),
          consumerPreferencesProvider.overrideWith(
            (ref) async => ConsumerPreferences.empty.copyWith(themeMode: 'dark'),
          ),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(themeNotifierProvider.notifier);
      expect(notifier.themeMode, ThemeMode.dark);
    });
  });
}
