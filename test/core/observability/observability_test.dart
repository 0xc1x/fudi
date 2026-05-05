import 'package:flutter_test/flutter_test.dart';
import 'package:fudi/core/error/fudi_exception.dart';
import 'package:fudi/core/observability/sentry_breadcrumb.dart';

void main() {
  group('SentryBreadcrumb', () {
    group('navigation', () {
      test('creates breadcrumb with from and to without throwing', () {
        expect(
          () => SentryBreadcrumb.navigation('/login', '/home'),
          returnsNormally,
        );
      });

      test('creates breadcrumb with optional role', () {
        expect(
          () => SentryBreadcrumb.navigation('/home', '/business', role: 'user'),
          returnsNormally,
        );
      });
    });

    group('userAction', () {
      test('creates breadcrumb with action and target', () {
        expect(
          () => SentryBreadcrumb.userAction('tap', 'reserve_button'),
          returnsNormally,
        );
      });

      test('creates breadcrumb with extra data', () {
        expect(
          () => SentryBreadcrumb.userAction('tap', 'reserve_button', extra: {'offer_id': 'o1'}),
          returnsNormally,
        );
      });
    });

    group('apiCall', () {
      test('creates breadcrumb with method and endpoint', () {
        expect(
          () => SentryBreadcrumb.apiCall('GET', '/offers'),
          returnsNormally,
        );
      });

      test('creates breadcrumb with status code', () {
        expect(
          () => SentryBreadcrumb.apiCall('POST', '/orders', statusCode: 201),
          returnsNormally,
        );
      });

      test('creates breadcrumb with duration', () {
        expect(
          () => SentryBreadcrumb.apiCall('GET', '/offers', duration: const Duration(milliseconds: 250)),
          returnsNormally,
        );
      });
    });

    group('payment', () {
      test('creates breadcrumb with action and order ID', () {
        expect(
          () => SentryBreadcrumb.payment('checkout_started', 'ord-123'),
          returnsNormally,
        );
      });

      test('creates breadcrumb with gateway and status', () {
        expect(
          () => SentryBreadcrumb.payment('payment_completed', 'ord-123', gateway: 'placetopay', status: 'approved'),
          returnsNormally,
        );
      });
    });
  });

  group('ErrorSeverity', () {
    test('all severity levels exist', () {
      expect(ErrorSeverity.values.length, 4);
      expect(ErrorSeverity.values, contains(ErrorSeverity.low));
      expect(ErrorSeverity.values, contains(ErrorSeverity.medium));
      expect(ErrorSeverity.values, contains(ErrorSeverity.high));
      expect(ErrorSeverity.values, contains(ErrorSeverity.fatal));
    });

    test('severity ordering is logical', () {
      expect(ErrorSeverity.low.index, lessThan(ErrorSeverity.medium.index));
      expect(ErrorSeverity.medium.index, lessThan(ErrorSeverity.high.index));
      expect(ErrorSeverity.high.index, lessThan(ErrorSeverity.fatal.index));
    });
  });
}
