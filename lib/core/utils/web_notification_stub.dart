void showWebNotification(String title, String body) {}

String getWebNotificationPermission() => 'denied';

Future<bool> requestWebNotificationPermission() async => false;

bool isSafari() => false;

bool isiOS() => false;

String getBrowserName() => 'Chrome';

bool get supportsWebNotifications => true;
