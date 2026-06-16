import 'dart:async';
import 'dart:html' as html;

void showWebNotification(String title, String body) {
  if (html.Notification.permission == 'granted') {
    html.Notification(
      title,
      body: body,
      icon: '/icons/Icon-192.png',
    );
    return;
  }

  if (html.Notification.permission == 'default') {
    html.Notification.requestPermission().then((permission) {
      if (permission == 'granted') {
        html.Notification(
          title,
          body: body,
          icon: '/icons/Icon-192.png',
        );
      }
    });
  }
}

String getWebNotificationPermission() => html.Notification.permission ?? 'denied';

Future<bool> requestWebNotificationPermission() {
  final completer = Completer<bool>();
  html.Notification.requestPermission().then((permission) {
    completer.complete(permission == 'granted');
  });
  return completer.future;
}
