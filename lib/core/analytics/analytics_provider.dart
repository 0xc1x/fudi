import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';

import '../config/app_config.dart';
import '../di/core_providers.dart';
import 'analytics_service.dart';
import 'trackers/firebase_tracker.dart';
import 'trackers/mixpanel_tracker.dart';

/// Provider for the [AnalyticsService] singleton.
///
/// The service is created with Firebase and Mixpanel trackers.
/// Consent is NOT granted by default — call `setConsent(true)` after
/// the user accepts analytics tracking (typically during onboarding
/// or from profile settings).
///
/// Usage:
/// ```dart
/// final analytics = ref.read(analyticsServiceProvider);
/// await analytics.track(AuthLoginStartedEvent(method: AuthMethod.email));
/// ```
final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  final config = ref.watch(appConfigProvider);

  final trackers = <AnalyticsTracker>[
    FirebaseTracker(),
    MixpanelTracker(),
  ];

  return AnalyticsService(trackers: trackers);
});

/// Provider for Firebase Analytics instance.
///
/// Useful for Firebase-specific operations like setting screen names
/// from route observers that need the raw FirebaseAnalytics object.
final firebaseAnalyticsProvider = Provider<FirebaseAnalytics>((ref) {
  return FirebaseAnalytics.instance;
});
