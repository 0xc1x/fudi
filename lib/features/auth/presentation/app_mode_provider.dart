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
    // Escuchamos los cambios de auth para sincronizar el modo inicial
    final authState = ref.watch(authSessionNotifierProvider).state;
    
    // Si es negocio, por defecto entra en modo negocio
    if (authState.role == UserRole.business) {
      return AppMode.business;
    }
    
    // Por defecto modo consumidor (incluye guests y users regulares)
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
