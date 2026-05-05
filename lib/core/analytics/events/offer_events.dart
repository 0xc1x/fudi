import '../models/analytics_event.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Offer Events — docs/ai/ANALYTICS.md → Offers (Discovery)
// ─────────────────────────────────────────────────────────────────────────────

/// The user viewed the offer list.
class OfferListViewedEvent extends AnalyticsEvent {
  /// Where the list was accessed from: home, explore, search.
  final String source;

  /// Active filters at the time of viewing.
  final Map<String, dynamic>? filters;

  /// Number of offers visible.
  final int count;

  OfferListViewedEvent({
    required this.source,
    this.filters,
    required this.count,
  });

  @override
  String get name => 'offer_list_viewed';

  @override
  Map<String, dynamic> get properties => {
        'source': source,
        'count': count,
        if (filters != null) 'filters': filters!,
      };
}

/// The user viewed a single offer's detail screen.
class OfferDetailViewedEvent extends AnalyticsEvent {
  final String offerId;
  final String businessId;
  final double price;
  final double? discountPct;

  OfferDetailViewedEvent({
    required this.offerId,
    required this.businessId,
    required this.price,
    this.discountPct,
  });

  @override
  String get name => 'offer_detail_viewed';

  @override
  Map<String, dynamic> get properties => {
        'offer_id': offerId,
        'business_id': businessId,
        'price': price,
        if (discountPct != null) 'discount_pct': discountPct!,
      };
}

/// The user performed a search.
class OfferSearchPerformedEvent extends AnalyticsEvent {
  final String query;
  final String? category;
  final int resultsCount;

  OfferSearchPerformedEvent({
    required this.query,
    this.category,
    required this.resultsCount,
  });

  @override
  String get name => 'offer_search_performed';

  @override
  Map<String, dynamic> get properties => {
        'query': query,
        if (category != null) 'category': category!,
        'results_count': resultsCount,
      };
}

/// The user applied a filter on the offer list.
class OfferFilterAppliedEvent extends AnalyticsEvent {
  final String filterType;
  final String filterValue;

  OfferFilterAppliedEvent({
    required this.filterType,
    required this.filterValue,
  });

  @override
  String get name => 'offer_filter_applied';

  @override
  Map<String, dynamic> get properties => {
        'filter_type': filterType,
        'filter_value': filterValue,
      };
}

/// The user interacted with the map view.
class OfferMapInteractionEvent extends AnalyticsEvent {
  /// pan, zoom, or tap_marker.
  final String action;

  OfferMapInteractionEvent({required this.action});

  @override
  String get name => 'offer_map_interaction';

  @override
  Map<String, dynamic> get properties => {'action': action};
}

/// The user favorited an offer.
class OfferFavoritedEvent extends AnalyticsEvent {
  final String offerId;
  final String businessId;

  OfferFavoritedEvent({required this.offerId, required this.businessId});

  @override
  String get name => 'offer_favorited';

  @override
  Map<String, dynamic> get properties => {
        'offer_id': offerId,
        'business_id': businessId,
      };
}
