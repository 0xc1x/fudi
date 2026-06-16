void showWebNotification(String title, String body) {}

String getWebNotificationPermission() => 'denied';

Future<bool> requestWebNotificationPermission() async => false;
