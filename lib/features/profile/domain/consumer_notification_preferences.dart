class ConsumerNotificationPreferences {
  const ConsumerNotificationPreferences({
    required this.pushEnabled,
    required this.emailEnabled,
    required this.smsEnabled,
    required this.whatsappEnabled,
    required this.favoriteAlertsEnabled,
    required this.pickupRemindersEnabled,
    required this.lastMinuteDealsEnabled,
    required this.weeklySummaryEnabled,
    this.quietHoursFrom,
    this.quietHoursTo,
  });

  final bool pushEnabled;
  final bool emailEnabled;
  final bool smsEnabled;
  final bool whatsappEnabled;
  final bool favoriteAlertsEnabled;
  final bool pickupRemindersEnabled;
  final bool lastMinuteDealsEnabled;
  final bool weeklySummaryEnabled;
  final String? quietHoursFrom;
  final String? quietHoursTo;

  ConsumerNotificationPreferences copyWith({
    bool? pushEnabled,
    bool? emailEnabled,
    bool? smsEnabled,
    bool? whatsappEnabled,
    bool? favoriteAlertsEnabled,
    bool? pickupRemindersEnabled,
    bool? lastMinuteDealsEnabled,
    bool? weeklySummaryEnabled,
    Object? quietHoursFrom = _sentinel,
    Object? quietHoursTo = _sentinel,
  }) {
    return ConsumerNotificationPreferences(
      pushEnabled: pushEnabled ?? this.pushEnabled,
      emailEnabled: emailEnabled ?? this.emailEnabled,
      smsEnabled: smsEnabled ?? this.smsEnabled,
      whatsappEnabled: whatsappEnabled ?? this.whatsappEnabled,
      favoriteAlertsEnabled: favoriteAlertsEnabled ?? this.favoriteAlertsEnabled,
      pickupRemindersEnabled: pickupRemindersEnabled ?? this.pickupRemindersEnabled,
      lastMinuteDealsEnabled: lastMinuteDealsEnabled ?? this.lastMinuteDealsEnabled,
      weeklySummaryEnabled: weeklySummaryEnabled ?? this.weeklySummaryEnabled,
      quietHoursFrom: quietHoursFrom == _sentinel ? this.quietHoursFrom : quietHoursFrom as String?,
      quietHoursTo: quietHoursTo == _sentinel ? this.quietHoursTo : quietHoursTo as String?,
    );
  }

  static const _sentinel = Object();

  static const defaults = ConsumerNotificationPreferences(
    pushEnabled: true,
    emailEnabled: true,
    smsEnabled: false,
    whatsappEnabled: false,
    favoriteAlertsEnabled: true,
    pickupRemindersEnabled: true,
    lastMinuteDealsEnabled: false,
    weeklySummaryEnabled: true,
    quietHoursFrom: null,
    quietHoursTo: null,
  );

  static const empty = ConsumerNotificationPreferences(
    pushEnabled: true,
    emailEnabled: true,
    smsEnabled: false,
    whatsappEnabled: false,
    favoriteAlertsEnabled: true,
    pickupRemindersEnabled: true,
    lastMinuteDealsEnabled: false,
    weeklySummaryEnabled: true,
    quietHoursFrom: null,
    quietHoursTo: null,
  );
}
