class ConsumerPreferences {
  const ConsumerPreferences({
    required this.notificationRadiusKm,
    required this.language,
    required this.darkMode,
    required this.favoriteCategories,
  });

  final int notificationRadiusKm;
  final String language;
  final bool darkMode;
  final List<String> favoriteCategories;

  ConsumerPreferences copyWith({
    int? notificationRadiusKm,
    String? language,
    bool? darkMode,
    List<String>? favoriteCategories,
  }) {
    return ConsumerPreferences(
      notificationRadiusKm: notificationRadiusKm ?? this.notificationRadiusKm,
      language: language ?? this.language,
      darkMode: darkMode ?? this.darkMode,
      favoriteCategories: favoriteCategories ?? this.favoriteCategories,
    );
  }

  static const empty = ConsumerPreferences(
    notificationRadiusKm: 5,
    language: 'es',
    darkMode: false,
    favoriteCategories: [],
  );
}
