import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../di/core_providers.dart';
import '../../features/auth/presentation/auth_state_provider.dart';
import '../../features/profile/presentation/profile_providers.dart';

enum AppThemeMode {
  light,
  dark,
  system;

  String get name => toString().split('.').last;

  static AppThemeMode fromString(String? name) {
    return AppThemeMode.values.firstWhere(
      (e) => e.name == name,
      orElse: () => AppThemeMode.system,
    );
  }
}

final themeNotifierProvider = NotifierProvider<ThemeNotifier, AppThemeMode>(
  ThemeNotifier.new,
);

class ThemeNotifier extends Notifier<AppThemeMode> {
  static const _kThemeModeKey = 'app_theme_mode';

  @override
  AppThemeMode build() {
    final localPrefs = ref.watch(sharedPreferencesProvider);
    final prefsAsync = ref.watch(consumerPreferencesProvider);

    // Start with local cache (synchronous, prevents flash on first paint)
    final localThemeStr = localPrefs.getString(_kThemeModeKey);
    final localMode = AppThemeMode.fromString(localThemeStr);

    // When remote preferences are available, prefer them
    final prefs = prefsAsync.asData?.value;
    if (prefs != null) {
      final remoteMode = AppThemeMode.fromString(prefs.themeMode);
      if (remoteMode != localMode) {
        unawaited(localPrefs.setString(_kThemeModeKey, remoteMode.name));
        return remoteMode;
      }
    }

    return localMode;
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    state = mode;
    final localPrefs = ref.read(sharedPreferencesProvider);
    await localPrefs.setString(_kThemeModeKey, mode.name);

    // Sincronizar con Supabase si el usuario está autenticado
    final authState = ref.read(authSessionNotifierProvider);
    final userId = authState.profile?.id;
    if (userId != null) {
      final profileRepo = ref.read(consumerProfileRepositoryProvider);
      try {
        final currentPrefs = await ref.read(consumerPreferencesProvider.future);
        final updatedPrefs = currentPrefs.copyWith(themeMode: mode.name);
        await profileRepo.updatePreferences(updatedPrefs);
        ref.invalidate(consumerPreferencesProvider);
      } catch (_) {
        // Si falla por falta de red, ya está persistido localmente en SharedPreferences
      }
    }
  }

  ThemeMode get themeMode {
    switch (state) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }
}
