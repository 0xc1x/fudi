import 'dart:async';
import 'dart:js_interop';
import 'package:web/web.dart' as web;

bool _isSafari() {
  final ua = web.window.navigator.userAgent.toLowerCase();
  return ua.contains('safari') && !ua.contains('chrome');
}

bool isSafari() => _isSafari();

bool isiOS() {
  final ua = web.window.navigator.userAgent.toLowerCase();
  return ua.contains('iphone') || ua.contains('ipad') || ua.contains('ipod');
}

String getBrowserName() {
  if (_isSafari()) return 'Safari';
  if (web.window.navigator.userAgent.toLowerCase().contains('firefox')) {
    return 'Firefox';
  }
  return 'Chrome';
}

void showWebNotification(String title, String body) {
  if (web.Notification.permission == 'granted') {
    web.Notification(
      title,
      web.NotificationOptions(body: body, icon: '/icons/Icon-192.png'),
    );
    return;
  }

  if (web.Notification.permission == 'default') {
    web.Notification.requestPermission().toDart.then((permission) {
      if (permission.toDart == 'granted') {
        web.Notification(
          title,
          web.NotificationOptions(body: body, icon: '/icons/Icon-192.png'),
        );
      }
    });
  }
}

String getWebNotificationPermission() => web.Notification.permission;

bool get supportsWebNotifications => _isSafari() && isiOS() ? false : true;

Future<bool> requestWebNotificationPermission() {
  final completer = Completer<bool>();
  web.Notification.requestPermission().toDart.then((permission) {
    completer.complete(permission.toDart == 'granted');
  });
  return completer.future;
}
