class PushNotification {
  const PushNotification({
    this.title,
    this.body,
    this.data = const {},
  });

  final String? title;
  final String? body;
  final Map<String, String> data;
}

abstract class PushService {
  Future<String?> getInitialToken();
  Future<bool> requestPermission();
  Future<String?> getToken();
  Future<void> registerToken(String userId);
  Future<void> unregisterToken();
  Stream<PushNotification> get onMessage;
  Stream<PushNotification> get onMessageOpenedApp;
  Future<PushNotification?> get initialMessage;
  Future<void> initialize();
  void dispose();
}
