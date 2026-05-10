import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/app_mode.dart';
import '../domain/user_profile.dart';
import 'auth_state_provider.dart';

/// Provider que maneja el modo actual de la aplicación (Consumer vs Business).
/// 
/// Por defecto se basa en el rol del usuario autenticado, pero permite
/// el cambio manual para usuarios con rol de negocio.
final appModeProvider = NotifierProvider<AppModeNotifier, AppMode>(AppModeNotifier.new);

class AppModeNotifier extends Notifier<AppMode> {
  @override
  AppMode build() {
    final authState = ref.watch(authSessionNotifierProvider);

    if (authState.role == UserRole.business) {
      return AppMode.business;
    }

    return AppMode.consumer;
  }

  /// Cambia explícitamente el modo de la aplicación.
  void setMode(AppMode mode) {
    state = mode;
  }

  /// Alterna entre los dos modos disponibles.
  void toggleMode() {
    state = state == AppMode.consumer ? AppMode.business : AppMode.consumer;
  }
}
