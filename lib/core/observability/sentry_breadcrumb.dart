import 'package:sentry_flutter/sentry_flutter.dart';

/// Wrapper for adding structured breadcrumbs to Sentry.
///
/// Categories follow docs/ai/ERROR_HANDLING.md:
/// - navigation: route changes
/// - user.action: taps, submits, etc.
/// - http: API calls
/// - payment: payment flow events
class SentryBreadcrumb {
  /// Navigation breadcrumb — record route transitions.
  static void navigation(String from, String to, {String? role}) {
    Sentry.addBreadcrumb(
      Breadcrumb(
        category: 'navigation',
        message: '$from -> $to',
        level: SentryLevel.info,
        data: {'from': from, 'to': to, if (role != null) 'role': role},
      ),
    );
  }

  /// User action breadcrumb — taps, form submissions, etc.
  static void userAction(
    String action,
    String target, {
    Map<String, dynamic>? extra,
  }) {
    Sentry.addBreadcrumb(
      Breadcrumb(
        category: 'user.action',
        message: '$action on $target',
        level: SentryLevel.info,
        data: {'action': action, 'target': target, ...?extra},
      ),
    );
  }

  /// API call breadcrumb — HTTP requests.
  static void apiCall(
    String method,
    String endpoint, {
    int? statusCode,
    Duration? duration,
  }) {
    Sentry.addBreadcrumb(
      Breadcrumb(
        category: 'http',
        message: '$method $endpoint',
        level: statusCode != null && statusCode >= 400
            ? SentryLevel.error
            : SentryLevel.info,
        data: {
          'method': method,
          'endpoint': endpoint,
          if (statusCode != null) 'status_code': statusCode,
          if (duration != null) 'duration_ms': duration.inMilliseconds,
        },
      ),
    );
  }

  /// Payment breadcrumb — payment flow events.
  static void payment(
    String action,
    String orderId, {
    String? gateway,
    String? status,
  }) {
    Sentry.addBreadcrumb(
      Breadcrumb(
        category: 'payment',
        message: '$action for order $orderId',
        level: SentryLevel.info,
        data: {
          'action': action,
          'order_id': orderId,
          if (gateway != null) 'gateway': gateway,
          if (status != null) 'status': status,
        },
      ),
    );
  }
}
