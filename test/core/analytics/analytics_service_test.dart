import 'package:flutter_test/flutter_test.dart';
import 'package:fudi/core/analytics/analytics_service.dart';
import 'package:fudi/core/analytics/models/analytics_event.dart';
import 'package:fudi/core/analytics/models/user_properties.dart';
import 'package:fudi/core/analytics/trackers/analytics_tracker.dart';
import 'package:fudi/core/analytics/events/auth_events.dart';
import 'package:fudi/core/analytics/events/navigation_events.dart';
import 'package:fudi/core/analytics/events/offer_events.dart';
import 'package:fudi/core/analytics/events/order_events.dart';
import 'package:fudi/core/analytics/events/payment_events.dart';
import 'package:fudi/core/analytics/events/business_events.dart';

class _MockTracker implements AnalyticsTracker {
  final List<AnalyticsEvent> trackedEvents = [];
  String? userId;
  UserProperties? properties;
  bool enabled = false;
  bool resetCalled = false;
  int trackCallCount = 0;

  @override
  String get trackerName => 'MockTracker';

  @override
  Future<void> track(AnalyticsEvent event) async {
    trackCallCount++;
    trackedEvents.add(event);
  }

  @override
  Future<void> setUserId(String id) async {
    userId = id;
  }

  @override
  Future<void> setUserProperties(UserProperties props) async {
    properties = props;
  }

  @override
  Future<void> reset() async {
    resetCalled = true;
    userId = null;
  }

  @override
  void setEnabled(bool isEnabled) {
    enabled = isEnabled;
  }
}

class _FailingTracker implements AnalyticsTracker {
  @override
  String get trackerName => 'FailingTracker';

  @override
  Future<void> track(AnalyticsEvent event) async {
    throw Exception('Tracker failed');
  }

  @override
  Future<void> setUserId(String userId) async {
    throw Exception('setUserId failed');
  }

  @override
  Future<void> setUserProperties(UserProperties properties) async {
    throw Exception('setUserProperties failed');
  }

  @override
  Future<void> reset() async {
    throw Exception('reset failed');
  }

  @override
  void setEnabled(bool enabled) {}
}

void main() {
  group('AnalyticsService', () {
    late AnalyticsService service;
    late _MockTracker tracker;

    setUp(() {
      tracker = _MockTracker();
      service = AnalyticsService(trackers: [tracker]);
    });

    group('consent', () {
      test('consent is not granted by default', () {
        expect(service.consentGranted, false);
      });

      test('setConsent enables all trackers', () {
        service.setConsent(true);
        expect(service.consentGranted, true);
        expect(tracker.enabled, true);
      });

      test('setConsent(false) disables all trackers', () {
        service.setConsent(true);
        service.setConsent(false);
        expect(service.consentGranted, false);
        expect(tracker.enabled, false);
      });
    });

    group('track', () {
      test('does nothing without consent', () async {
        final event = AuthLogoutEvent();
        await service.track(event);
        expect(tracker.trackedEvents, isEmpty);
      });

      test('tracks event when consent is granted', () async {
        service.setConsent(true);
        final event = AuthLogoutEvent();
        await service.track(event);
        expect(tracker.trackedEvents.length, 1);
        expect(tracker.trackedEvents.first.name, 'auth_logout');
      });

      test('fires to all trackers', () async {
        final tracker2 = _MockTracker();
        final multiService = AnalyticsService(trackers: [tracker, tracker2]);
        multiService.setConsent(true);
        await multiService.track(AuthLogoutEvent());
        expect(tracker.trackedEvents.length, 1);
        expect(tracker2.trackedEvents.length, 1);
      });
    });

    group('setUserId', () {
      test('does nothing without consent', () async {
        await service.setUserId('user-123');
        expect(tracker.userId, isNull);
      });

      test('sets user ID when consent is granted', () async {
        service.setConsent(true);
        await service.setUserId('user-123');
        expect(tracker.userId, 'user-123');
      });
    });

    group('setUserProperties', () {
      test('does nothing without consent', () async {
        final props = UserProperties(role: 'user');
        await service.setUserProperties(props);
        expect(tracker.properties, isNull);
      });

      test('sets properties when consent is granted', () async {
        service.setConsent(true);
        final props = UserProperties(role: 'user', city: 'Bogota');
        await service.setUserProperties(props);
        expect(tracker.properties?.role, 'user');
        expect(tracker.properties?.city, 'Bogota');
      });
    });

    group('reset', () {
      test('reset always runs regardless of consent', () async {
        service.setConsent(true);
        await service.setUserId('user-123');
        await service.reset();
        expect(tracker.resetCalled, true);
        expect(tracker.userId, isNull);
      });
    });

    group('convenience methods', () {
      test('trackScreenView delegates to track', () async {
        service.setConsent(true);
        await service.trackScreenView(screenName: 'home', role: 'user');
        expect(tracker.trackedEvents.length, 1);
        expect(tracker.trackedEvents.first.name, 'screen_viewed');
      });

      test('trackBottomNavTap delegates to track', () async {
        service.setConsent(true);
        await service.trackBottomNavTap(tabIndex: 0, tabName: 'home');
        expect(tracker.trackedEvents.length, 1);
        expect(tracker.trackedEvents.first.name, 'bottom_nav_tapped');
      });
    });

    group('error resilience', () {
      test('failing tracker does not crash the service', () async {
        final failingTracker = _FailingTracker();
        final resilientService = AnalyticsService(trackers: [failingTracker, tracker]);
        resilientService.setConsent(true);

        await resilientService.track(AuthLogoutEvent());
        expect(tracker.trackedEvents.length, 1);
      });

      test('failing setUserId does not crash the service', () async {
        final failingTracker = _FailingTracker();
        final resilientService = AnalyticsService(trackers: [failingTracker, tracker]);
        resilientService.setConsent(true);

        await resilientService.setUserId('user-123');
        expect(tracker.userId, 'user-123');
      });
    });
  });

  group('Analytics Events', () {
    group('AuthEvents', () {
      test('AuthLoginStartedEvent has correct name and properties', () {
        final event = AuthLoginStartedEvent(method: AuthMethod.email);
        expect(event.name, 'auth_login_started');
        expect(event.properties['method'], 'email');
      });

      test('AuthLoginCompletedEvent includes isNewUser', () {
        final event = AuthLoginCompletedEvent(method: AuthMethod.google, isNewUser: true);
        expect(event.name, 'auth_login_completed');
        expect(event.properties['method'], 'google');
        expect(event.properties['is_new_user'], true);
      });

      test('AuthLoginFailedEvent includes errorType', () {
        final event = AuthLoginFailedEvent(method: AuthMethod.apple, errorType: 'network');
        expect(event.properties['error_type'], 'network');
      });

      test('AuthSignupCompletedEvent includes role', () {
        final event = AuthSignupCompletedEvent(method: AuthMethod.email, role: 'business');
        expect(event.properties['role'], 'business');
      });

      test('AuthLogoutEvent has empty properties', () {
        final event = AuthLogoutEvent();
        expect(event.properties, isEmpty);
      });
    });

    group('NavigationEvents', () {
      test('ScreenViewedEvent includes screen name', () {
        final event = ScreenViewedEvent(screenName: 'home', role: 'user');
        expect(event.name, 'screen_viewed');
        expect(event.properties['screen_name'], 'home');
        expect(event.properties['role'], 'user');
      });

      test('BottomNavTappedEvent includes tab info', () {
        final event = BottomNavTappedEvent(tabIndex: 2, tabName: 'favorites');
        expect(event.properties['tab_index'], 2);
        expect(event.properties['tab_name'], 'favorites');
      });
    });

    group('OfferEvents', () {
      test('OfferListViewedEvent has source and count', () {
        final event = OfferListViewedEvent(source: 'home', count: 10);
        expect(event.name, 'offer_list_viewed');
        expect(event.properties['source'], 'home');
        expect(event.properties['count'], 10);
      });

      test('OfferDetailViewedEvent includes price', () {
        final event = OfferDetailViewedEvent(
          offerId: 'o1', businessId: 'b1', price: 15000, discountPct: 30.0,
        );
        expect(event.properties['price'], 15000);
        expect(event.properties['discount_pct'], 30.0);
      });

      test('OfferSearchPerformedEvent has query and results', () {
        final event = OfferSearchPerformedEvent(query: 'pizza', resultsCount: 5);
        expect(event.properties['query'], 'pizza');
        expect(event.properties['results_count'], 5);
      });
    });

    group('OrderEvents', () {
      test('OrderReserveStartedEvent includes amount', () {
        final event = OrderReserveStartedEvent(
          offerId: 'o1', businessId: 'b1', amount: 15000,
        );
        expect(event.name, 'order_reserve_started');
        expect(event.properties['amount'], 15000);
      });

      test('OrderCancelledEvent includes reason and by', () {
        final event = OrderCancelledEvent(orderId: 'ord1', reason: 'changed_mind', by: 'user');
        expect(event.properties['reason'], 'changed_mind');
        expect(event.properties['by'], 'user');
      });
    });

    group('PaymentEvents', () {
      test('CheckoutStartedEvent includes amount', () {
        final event = CheckoutStartedEvent(
          offerId: 'o1', businessId: 'b1', amount: 9.99,
        );
        expect(event.name, 'checkout_started');
        expect(event.properties['amount'], 9.99);
      });

      test('PaymentCompletedEvent includes gateway', () {
        final event = PaymentCompletedEvent(
          orderId: 'ord1', amount: 9.99, gateway: 'placetopay', paymentMethod: 'card',
        );
        expect(event.properties['gateway'], 'placetopay');
      });
    });

    group('BusinessEvents', () {
      test('BusinessOfferCreatedEvent includes price', () {
        final event = BusinessOfferCreatedEvent(
          businessId: 'b1', offerId: 'o1', price: 25000,
        );
        expect(event.name, 'business_offer_created');
        expect(event.properties['price'], 25000);
      });

      test('BusinessDashboardViewedEvent only has businessId', () {
        final event = BusinessDashboardViewedEvent(businessId: 'b1');
        expect(event.properties.keys, contains('business_id'));
        expect(event.properties.length, 1);
      });
    });

    group('AnalyticsEvent base', () {
      test('timestamp is set on creation', () {
        final before = DateTime.now();
        final event = AuthLogoutEvent();
        final after = DateTime.now();
        expect(event.timestamp.isAfter(before.subtract(const Duration(milliseconds: 1))), true);
        expect(event.timestamp.isBefore(after.add(const Duration(milliseconds: 1))), true);
      });
    });
  });

  group('UserProperties', () {
    test('toMap omits null values', () {
      final props = UserProperties(role: 'user');
      final map = props.toMap();
      expect(map.containsKey('role'), true);
      expect(map.containsKey('city'), false);
      expect(map.containsKey('userId'), false);
    });

    test('toMap includes all set values', () {
      final props = UserProperties(
        userId: 'u1',
        role: 'business',
        city: 'Bogota',
        totalOrders: 5,
        totalSaved: 150.0,
      );
      final map = props.toMap();
      expect(map['user_id'], 'u1');
      expect(map['role'], 'business');
      expect(map['city'], 'Bogota');
      expect(map['total_orders'], 5);
      expect(map['total_saved'], 150.0);
    });

    test('copyWith preserves existing values', () {
      final props = UserProperties(role: 'user', city: 'Medellin');
      final updated = props.copyWith(city: 'Bogota');
      expect(updated.role, 'user');
      expect(updated.city, 'Bogota');
    });

    test('copyWith does not modify original', () {
      final props = UserProperties(role: 'user');
      props.copyWith(role: 'business');
      expect(props.role, 'user');
    });

    test('toString includes map representation', () {
      final props = UserProperties(role: 'user');
      expect(props.toString(), contains('UserProperties'));
      expect(props.toString(), contains('role'));
    });
  });
}
