class BusinessNotificationPreferences {
  const BusinessNotificationPreferences({
    required this.pushEnabled,
    required this.emailEnabled,
    required this.smsEnabled,
    required this.whatsappEnabled,
    required this.newOrdersEnabled,
    required this.pickupReadyEnabled,
    required this.reviewsEnabled,
    required this.lowStockEnabled,
    required this.dailySummaryEnabled,
    this.quietHoursFrom,
    this.quietHoursTo,
  });

  final bool pushEnabled;
  final bool emailEnabled;
  final bool smsEnabled;
  final bool whatsappEnabled;
  final bool newOrdersEnabled;
  final bool pickupReadyEnabled;
  final bool reviewsEnabled;
  final bool lowStockEnabled;
  final bool dailySummaryEnabled;
  final String? quietHoursFrom;
  final String? quietHoursTo;

  BusinessNotificationPreferences copyWith({
    bool? pushEnabled,
    bool? emailEnabled,
    bool? smsEnabled,
    bool? whatsappEnabled,
    bool? newOrdersEnabled,
    bool? pickupReadyEnabled,
    bool? reviewsEnabled,
    bool? lowStockEnabled,
    bool? dailySummaryEnabled,
    Object? quietHoursFrom = _sentinel,
    Object? quietHoursTo = _sentinel,
  }) {
    return BusinessNotificationPreferences(
      pushEnabled: pushEnabled ?? this.pushEnabled,
      emailEnabled: emailEnabled ?? this.emailEnabled,
      smsEnabled: smsEnabled ?? this.smsEnabled,
      whatsappEnabled: whatsappEnabled ?? this.whatsappEnabled,
      newOrdersEnabled: newOrdersEnabled ?? this.newOrdersEnabled,
      pickupReadyEnabled: pickupReadyEnabled ?? this.pickupReadyEnabled,
      reviewsEnabled: reviewsEnabled ?? this.reviewsEnabled,
      lowStockEnabled: lowStockEnabled ?? this.lowStockEnabled,
      dailySummaryEnabled: dailySummaryEnabled ?? this.dailySummaryEnabled,
      quietHoursFrom: quietHoursFrom == _sentinel ? this.quietHoursFrom : quietHoursFrom as String?,
      quietHoursTo: quietHoursTo == _sentinel ? this.quietHoursTo : quietHoursTo as String?,
    );
  }

  static const _sentinel = Object();

  static const defaults = BusinessNotificationPreferences(
    pushEnabled: true,
    emailEnabled: true,
    smsEnabled: false,
    whatsappEnabled: false,
    newOrdersEnabled: true,
    pickupReadyEnabled: true,
    reviewsEnabled: true,
    lowStockEnabled: false,
    dailySummaryEnabled: true,
    quietHoursFrom: null,
    quietHoursTo: null,
  );

  static const empty = BusinessNotificationPreferences(
    pushEnabled: true,
    emailEnabled: true,
    smsEnabled: false,
    whatsappEnabled: false,
    newOrdersEnabled: true,
    pickupReadyEnabled: true,
    reviewsEnabled: true,
    lowStockEnabled: false,
    dailySummaryEnabled: true,
    quietHoursFrom: null,
    quietHoursTo: null,
  );
}
