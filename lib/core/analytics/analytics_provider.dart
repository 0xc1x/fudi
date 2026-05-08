import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

import 'analytics_service.dart';
import 'trackers/analytics_tracker.dart';
import 'trackers/firebase_tracker.dart';
import 'trackers/mixpanel_tracker.dart';

final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  final trackers = <AnalyticsTracker>[
    FirebaseTracker(),
    MixpanelTracker(),
  ];

  return AnalyticsService(trackers: trackers);
});

final firebaseAnalyticsProvider = Provider<FirebaseAnalytics?>((ref) {
  try {
    if (Firebase.apps.isEmpty) return null;
    return FirebaseAnalytics.instance;
  } catch (_) {
    return null;
  }
});
