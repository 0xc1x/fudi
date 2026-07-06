class ConsumerPreferences {
  const ConsumerPreferences({
    required this.notificationRadiusKm,
    required this.language,
    required this.themeMode,
    required this.favoriteCategories,
  });

  final int notificationRadiusKm;
  final String language;
  final String themeMode;
  final List<String> favoriteCategories;

  ConsumerPreferences copyWith({
    int? notificationRadiusKm,
    String? language,
    String? themeMode,
    List<String>? favoriteCategories,
  }) {
    return ConsumerPreferences(
      notificationRadiusKm: notificationRadiusKm ?? this.notificationRadiusKm,
      language: language ?? this.language,
      themeMode: themeMode ?? this.themeMode,
      favoriteCategories: favoriteCategories ?? this.favoriteCategories,
    );
  }

  static const empty = ConsumerPreferences(
    notificationRadiusKm: 5,
    language: 'es',
    themeMode: 'system',
    favoriteCategories: [],
  );
}
