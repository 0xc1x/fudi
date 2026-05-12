import '../models/analytics_event.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Navigation Events — docs/ai/ANALYTICS.md → Navigation
// ─────────────────────────────────────────────────────────────────────────────

/// A screen was viewed. Track this at every route transition.
class ScreenViewedEvent extends AnalyticsEvent {
  /// Logical screen name (e.g. 'offer_detail', 'checkout', 'business_dashboard').
  final String screenName;

  /// Where the user came from (previous screen or entry point).
  final String? source;

  /// Active role when the screen was viewed: user, business, admin, guest.
  final String? role;

  ScreenViewedEvent({required this.screenName, this.source, this.role});

  @override
  String get name => 'screen_viewed';

  @override
  Map<String, dynamic> get properties => {
    'screen_name': screenName,
    'source': ?source,
    'role': ?role,
  };
}

/// A bottom navigation tab was tapped.
class BottomNavTappedEvent extends AnalyticsEvent {
  final int tabIndex;
  final String tabName;

  BottomNavTappedEvent({required this.tabIndex, required this.tabName});

  @override
  String get name => 'bottom_nav_tapped';

  @override
  Map<String, dynamic> get properties => {
    'tab_index': tabIndex,
    'tab_name': tabName,
  };
}
