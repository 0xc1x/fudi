import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/di/core_providers.dart';
import '../../../core/network/push_service.dart';
import 'device_token_repository.dart';

final pushServiceProvider = Provider<PushService>((ref) {
  final config = ref.watch(appConfigProvider);
  final supabase = ref.watch(supabaseClientProvider);
  final repo = DeviceTokenRepository(supabaseClient: supabase);
  final service = FirebasePushService(
    config: config,
    deviceTokenRepo: repo,
    onBackgroundMessage: _firebaseMessagingBackgroundHandler,
  );
  ref.onDispose(() => service.dispose());
  return service;
});

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) {
  // Background messages are handled by the OS notification tray.
  // The payload data is available when user taps to open.
  return Future.value();
}

class FirebasePushService implements PushService {
  FirebasePushService({
    required AppConfig config,
    required DeviceTokenRepository deviceTokenRepo,
    required Future<void> Function(RemoteMessage) onBackgroundMessage,
  }) : _config = config,
       _deviceTokenRepo = deviceTokenRepo {
    FirebaseMessaging.onBackgroundMessage(onBackgroundMessage);
  }

  final AppConfig _config;
  final DeviceTokenRepository _deviceTokenRepo;

  final _messageController = StreamController<PushNotification>.broadcast();
  final _openController = StreamController<PushNotification>.broadcast();

  String? _currentUserId;
  String? _currentToken;
  StreamSubscription<String?>? _tokenSubscription;
  StreamSubscription<RemoteMessage>? _messageSubscription;
  StreamSubscription<RemoteMessage>? _openSubscription;

  @override
  Future<String?> getInitialToken() async {
    try {
      return await FirebaseMessaging.instance.getToken(
        vapidKey: kIsWeb ? _config.firebaseVapidKey : null,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<bool> requestPermission() async {
    if (kIsWeb) return true;

    final messaging = FirebaseMessaging.instance;
    final settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  @override
  Future<String?> getToken() async {
    try {
      _currentToken = await FirebaseMessaging.instance.getToken(
        vapidKey: kIsWeb ? _config.firebaseVapidKey : null,
      );
      return _currentToken;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> registerToken(String userId) async {
    _currentUserId = userId;

    final token = await getToken();
    if (token == null) return;

    await _deviceTokenRepo.upsertToken(userId: userId, token: token);

    _tokenSubscription?.cancel();
    _tokenSubscription = FirebaseMessaging.instance
        .onTokenRefresh
        .listen((newToken) async {
      _currentToken = newToken;
      if (_currentUserId != null) {
        await _deviceTokenRepo.upsertToken(
          userId: _currentUserId!,
          token: newToken,
        );
      }
    });
  }

  @override
  Future<void> unregisterToken() async {
    _tokenSubscription?.cancel();
    _tokenSubscription = null;

    if (_currentToken != null) {
      try {
        await FirebaseMessaging.instance.deleteToken();
      } catch (_) {}
      await _deviceTokenRepo.deactivateToken(token: _currentToken!);
    }

    _currentUserId = null;
    _currentToken = null;
  }

  @override
  Stream<PushNotification> get onMessage => _messageController.stream;

  @override
  Stream<PushNotification> get onMessageOpenedApp => _openController.stream;

  @override
  Future<PushNotification?> get initialMessage async {
    try {
      final message = await FirebaseMessaging.instance.getInitialMessage();
      if (message == null) return null;
      return _fromRemoteMessage(message);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> initialize() async {
    final granted = await requestPermission();
    if (!granted) return;

    _messageSubscription = FirebaseMessaging.onMessage.listen(
      (message) => _messageController.add(_fromRemoteMessage(message)),
    );

    _openSubscription = FirebaseMessaging.onMessageOpenedApp.listen(
      (message) => _openController.add(_fromRemoteMessage(message)),
    );

    await FirebaseMessaging.instance.setAutoInitEnabled(true);
  }

  @override
  void dispose() {
    _tokenSubscription?.cancel();
    _messageSubscription?.cancel();
    _openSubscription?.cancel();
    _messageController.close();
    _openController.close();
  }

  PushNotification _fromRemoteMessage(RemoteMessage message) {
    final data = Map<String, String>.from(
      (message.data).map((k, v) => MapEntry(k, v.toString())),
    );

    final aps = message.notification;
    return PushNotification(
      title: aps?.title,
      body: aps?.body,
      data: data,
    );
  }
}
