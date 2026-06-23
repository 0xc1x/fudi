import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../../../core/network/push_service.dart';
import '../../../core/utils/web_notification.dart';
import '../../auth/presentation/auth_state_provider.dart';
import '../data/firebase_push_service.dart';

final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

const _androidChannel = AndroidNotificationChannel(
  'fudi_orders',
  'Pedidos',
  description: 'Notificaciones de tus pedidos en Fudi',
  importance: Importance.high,
);

const _androidOfferChannel = AndroidNotificationChannel(
  'fudi_offers',
  'Ofertas',
  description: 'Ofertas cercanas y recomendaciones',
  importance: Importance.defaultImportance,
);

Future<void> initLocalNotifications() async {
  if (kIsWeb) return;

  const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  const iosSettings = DarwinInitializationSettings(
    requestAlertPermission: false,
    requestBadgePermission: false,
    requestSoundPermission: false,
  );
  const settings = InitializationSettings(
    android: androidSettings,
    iOS: iosSettings,
  );

  await flutterLocalNotificationsPlugin.initialize(
    settings: settings,
    onDidReceiveNotificationResponse: (response) {},
  );

  final android = flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>();
  await android?.createNotificationChannel(_androidChannel);
  await android?.createNotificationChannel(_androidOfferChannel);
}

class PushNotificationHandler extends ConsumerStatefulWidget {
  const PushNotificationHandler({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<PushNotificationHandler> createState() =>
      _PushNotificationHandlerState();
}

class _PushNotificationHandlerState
    extends ConsumerState<PushNotificationHandler> {
  @override
  void initState() {
    super.initState();
    _setupForegroundHandler();
    _handleInitialMessage();
    _handleOnMessageOpened();
    _registerTokenIfAuthenticated();
  }

  void _registerTokenIfAuthenticated() {
    final authState = ref.read(authSessionNotifierProvider);
    if (!authState.isAuthenticated) return;
    final userId = authState.session?.user.id;
    if (userId == null) return;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final pushService = ref.read(pushServiceProvider);

      if (kIsWeb) {
        if (!supportsWebNotifications) {
          _showWebNotificationsUnsupported();
          return;
        }

        final permission = getWebNotificationPermission();
        if (permission == 'granted') {
          await pushService.initialize();
          await pushService.registerToken(userId);
          return;
        }

        if (permission == 'default') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Activá notificaciones para recibir ofertas'),
              duration: const Duration(seconds: 15),
              action: SnackBarAction(
                label: 'Activar',
                onPressed: () async {
                  final granted = await requestWebNotificationPermission();
                  if (!mounted) return;
                  if (granted) {
                    await pushService.initialize();
                    await pushService.registerToken(userId);
                  } else {
                    _showPermissionBlockedHelp();
                  }
                },
              ),
            ),
          );
          return;
        }

        _showPermissionBlockedHelp();
        return;
      }

      await pushService.initialize();
      await pushService.registerToken(userId);
    });
  }

  void _setupForegroundHandler() {
    final pushService = ref.read(pushServiceProvider);
    pushService.onMessage.listen((notification) {
      final title = notification.title ?? 'Fudi';
      final body = notification.body ?? '';
      if (kIsWeb) {
        showWebNotification(title, body);
        return;
      }
      _showNativeNotification(notification);
    });
  }

  void _handleInitialMessage() async {
    final pushService = ref.read(pushServiceProvider);
    final message = await pushService.initialMessage;
    if (message != null && mounted) {
      _handleNavigation(message.data);
    }
  }

  void _handleOnMessageOpened() {
    final pushService = ref.read(pushServiceProvider);
    pushService.onMessageOpenedApp.listen((notification) {
      if (mounted) {
        _handleNavigation(notification.data);
      }
    });
  }

  void _handleNavigation(Map<String, String> data) {
    final link = data['link'];
    if (link == null || !mounted) return;

    try {
      context.go(link);
    } catch (e, st) {
      Sentry.captureException(e, stackTrace: st);
    }
  }

  void _showPermissionBlockedHelp() {
    final browser = getBrowserName();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$browser bloqueó las notificaciones. Activálas manualmente en Configuración del sitio.',
        ),
        duration: const Duration(seconds: 8),
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {},
        ),
      ),
    );
  }

  void _showWebNotificationsUnsupported() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Las notificaciones web no están disponibles en iOS Safari. Usá la app desde Chrome o instalala en tu dispositivo.',
        ),
        duration: const Duration(seconds: 10),
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {},
        ),
      ),
    );
  }

  void _showNativeNotification(PushNotification notification) {
    final channel = notification.data['type'] == 'order'
        ? _androidChannel.id
        : _androidOfferChannel.id;

    final title = notification.title ?? 'Fudi';
    final body = notification.body ?? '';

    flutterLocalNotificationsPlugin.show(
      id: notification.hashCode,
      title: title,
      body: body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          channel,
          channel == _androidChannel.id ? 'Pedidos' : 'Ofertas',
          channelDescription:
              channel == _androidChannel.id
                  ? 'Notificaciones de pedidos'
                  : 'Ofertas cercanas',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: notification.data['link'],
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
