import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/push_service.dart';
import '../../../core/utils/web_notification.dart';
import '../../auth/presentation/auth_state_provider.dart';
import '../data/firebase_push_service.dart';

bool get isPushSupported => kIsWeb ? supportsWebNotifications : true;

Future<bool> ensurePushPermission(
  BuildContext context,
  WidgetRef ref,
) async {
  if (!isPushSupported) {
    if (kIsWeb && isSafari() && isiOS() && !isStandalone()) {
      _showSnack(
        context,
        'Instalá Fudi en tu pantalla de inicio para activar notificaciones en iOS.',
      );
    } else {
      _showSnack(context, 'Tu navegador no soporta notificaciones push.');
    }
    return false;
  }

  final pushService = ref.read(pushServiceProvider);

  if (kIsWeb) {
    final permission = getWebNotificationPermission();
    if (permission == 'granted') return true;

    if (permission == 'denied') {
      _showSnack(
        context,
        '${getBrowserName()} bloqueó las notificaciones. '
        'Activálas desde la configuración del sitio.',
      );
      return false;
    }

    final granted = await requestWebNotificationPermission();
    if (!granted) {
      if (!context.mounted) return false;
      _showSnack(
        context,
        'Permiso denegado. Activá las notificaciones desde la '
        'configuración del navegador.',
      );
      return false;
    }

    await _initAndRegister(ref, pushService);
    return true;
  }

  final granted = await pushService.requestPermission();
  if (!granted) {
    if (!context.mounted) return false;
    _showSnack(
      context,
      'Permiso denegado. Activá las notificaciones desde los '
      'ajustes del dispositivo.',
    );
    return false;
  }

  await _initAndRegister(ref, pushService);
  return true;
}

Future<void> _initAndRegister(WidgetRef ref, PushService pushService) async {
  final authState = ref.read(authSessionNotifierProvider);
  final userId = authState.session?.user.id;
  await pushService.initialize();
  if (userId != null) await pushService.registerToken(userId);
}

void _showSnack(BuildContext context, String message) {
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 8),
    ),
  );
}
