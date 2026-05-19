class ConsumerPreferences {
  const ConsumerPreferences({
    required this.notificationRadiusKm,
    required this.language,
    required this.darkMode,
    required this.pushNotificationsEnabled,
    required this.emailNotificationsEnabled,
    required this.favoriteCategories,
    required this.favoriteAlertsEnabled,
    required this.pickupRemindersEnabled,
    required this.lastMinuteDealsEnabled,
    required this.weeklySummaryEnabled,
  });

  final int notificationRadiusKm;
  final String language;
  final bool darkMode;
  final bool pushNotificationsEnabled;
  final bool emailNotificationsEnabled;
  final List<String> favoriteCategories;
  final bool favoriteAlertsEnabled;
  final bool pickupRemindersEnabled;
  final bool lastMinuteDealsEnabled;
  final bool weeklySummaryEnabled;

  ConsumerPreferences copyWith({
    int? notificationRadiusKm,
    String? language,
    bool? darkMode,
    bool? pushNotificationsEnabled,
    bool? emailNotificationsEnabled,
    List<String>? favoriteCategories,
    bool? favoriteAlertsEnabled,
    bool? pickupRemindersEnabled,
    bool? lastMinuteDealsEnabled,
    bool? weeklySummaryEnabled,
  }) {
    return ConsumerPreferences(
      notificationRadiusKm:
          notificationRadiusKm ?? this.notificationRadiusKm,
      language: language ?? this.language,
      darkMode: darkMode ?? this.darkMode,
      pushNotificationsEnabled:
          pushNotificationsEnabled ?? this.pushNotificationsEnabled,
      emailNotificationsEnabled:
          emailNotificationsEnabled ?? this.emailNotificationsEnabled,
      favoriteCategories: favoriteCategories ?? this.favoriteCategories,
      favoriteAlertsEnabled:
          favoriteAlertsEnabled ?? this.favoriteAlertsEnabled,
      pickupRemindersEnabled:
          pickupRemindersEnabled ?? this.pickupRemindersEnabled,
      lastMinuteDealsEnabled:
          lastMinuteDealsEnabled ?? this.lastMinuteDealsEnabled,
      weeklySummaryEnabled:
          weeklySummaryEnabled ?? this.weeklySummaryEnabled,
    );
  }

  static const empty = ConsumerPreferences(
    notificationRadiusKm: 5,
    language: 'es',
    darkMode: false,
    pushNotificationsEnabled: true,
    emailNotificationsEnabled: true,
    favoriteCategories: [],
    favoriteAlertsEnabled: true,
    pickupRemindersEnabled: true,
    lastMinuteDealsEnabled: false,
    weeklySummaryEnabled: true,
  );
}
