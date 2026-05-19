class ProfileDetails {
  const ProfileDetails({
    required this.id,
    required this.email,
    this.fullName,
    this.avatarUrl,
    this.phone,
    this.city,
    this.notificationRadiusKm = 5,
  });

  final String id;
  final String email;
  final String? fullName;
  final String? avatarUrl;
  final String? phone;
  final String? city;
  final int notificationRadiusKm;

  String get displayName {
    final trimmed = fullName?.trim();
    if (trimmed == null || trimmed.isEmpty) return 'Usuario Fudi';
    return trimmed;
  }
}

class ProfileUpdateInput {
  const ProfileUpdateInput({
    required this.fullName,
    this.phone,
    this.city,
  });

  final String fullName;
  final String? phone;
  final String? city;
}

class UserPreferences {
  const UserPreferences({
    required this.language,
    required this.darkMode,
    required this.pushNotificationsEnabled,
    required this.emailNotificationsEnabled,
    required this.notificationRadiusKm,
    required this.favoriteCategories,
  });

  final String language;
  final bool darkMode;
  final bool pushNotificationsEnabled;
  final bool emailNotificationsEnabled;
  final int notificationRadiusKm;
  final List<String> favoriteCategories;

  UserPreferences copyWith({
    String? language,
    bool? darkMode,
    bool? pushNotificationsEnabled,
    bool? emailNotificationsEnabled,
    int? notificationRadiusKm,
    List<String>? favoriteCategories,
  }) {
    return UserPreferences(
      language: language ?? this.language,
      darkMode: darkMode ?? this.darkMode,
      pushNotificationsEnabled:
          pushNotificationsEnabled ?? this.pushNotificationsEnabled,
      emailNotificationsEnabled:
          emailNotificationsEnabled ?? this.emailNotificationsEnabled,
      notificationRadiusKm:
          notificationRadiusKm ?? this.notificationRadiusKm,
      favoriteCategories: favoriteCategories ?? this.favoriteCategories,
    );
  }
}

class NotificationSettings {
  const NotificationSettings({
    required this.newDealsEnabled,
    required this.favoriteAlertsEnabled,
    required this.pickupReminderEnabled,
    required this.lastMinuteDealsEnabled,
    required this.weeklySummaryEnabled,
    required this.promotionsEnabled,
  });

  final bool newDealsEnabled;
  final bool favoriteAlertsEnabled;
  final bool pickupReminderEnabled;
  final bool lastMinuteDealsEnabled;
  final bool weeklySummaryEnabled;
  final bool promotionsEnabled;

  NotificationSettings copyWith({
    bool? newDealsEnabled,
    bool? favoriteAlertsEnabled,
    bool? pickupReminderEnabled,
    bool? lastMinuteDealsEnabled,
    bool? weeklySummaryEnabled,
    bool? promotionsEnabled,
  }) {
    return NotificationSettings(
      newDealsEnabled: newDealsEnabled ?? this.newDealsEnabled,
      favoriteAlertsEnabled:
          favoriteAlertsEnabled ?? this.favoriteAlertsEnabled,
      pickupReminderEnabled:
          pickupReminderEnabled ?? this.pickupReminderEnabled,
      lastMinuteDealsEnabled:
          lastMinuteDealsEnabled ?? this.lastMinuteDealsEnabled,
      weeklySummaryEnabled:
          weeklySummaryEnabled ?? this.weeklySummaryEnabled,
      promotionsEnabled: promotionsEnabled ?? this.promotionsEnabled,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'newDealsEnabled': newDealsEnabled,
      'favoriteAlertsEnabled': favoriteAlertsEnabled,
      'pickupReminderEnabled': pickupReminderEnabled,
      'lastMinuteDealsEnabled': lastMinuteDealsEnabled,
      'weeklySummaryEnabled': weeklySummaryEnabled,
      'promotionsEnabled': promotionsEnabled,
    };
  }

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      newDealsEnabled: json['newDealsEnabled'] as bool? ?? true,
      favoriteAlertsEnabled: json['favoriteAlertsEnabled'] as bool? ?? true,
      pickupReminderEnabled: json['pickupReminderEnabled'] as bool? ?? true,
      lastMinuteDealsEnabled:
          json['lastMinuteDealsEnabled'] as bool? ?? false,
      weeklySummaryEnabled: json['weeklySummaryEnabled'] as bool? ?? true,
      promotionsEnabled: json['promotionsEnabled'] as bool? ?? false,
    );
  }

  static const defaults = NotificationSettings(
    newDealsEnabled: true,
    favoriteAlertsEnabled: true,
    pickupReminderEnabled: true,
    lastMinuteDealsEnabled: false,
    weeklySummaryEnabled: true,
    promotionsEnabled: false,
  );
}

class SavedAddress {
  const SavedAddress({
    required this.id,
    required this.label,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.isDefault,
  });

  final String id;
  final String label;
  final String address;
  final double latitude;
  final double longitude;
  final bool isDefault;
}

class SavedAddressInput {
  const SavedAddressInput({
    required this.label,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.isDefault,
  });

  final String label;
  final String address;
  final double latitude;
  final double longitude;
  final bool isDefault;
}

class PaymentMethod {
  const PaymentMethod({
    required this.id,
    required this.brand,
    required this.last4,
    required this.expiryMonth,
    required this.expiryYear,
    required this.cardholderName,
    required this.isDefault,
  });

  final String id;
  final String brand;
  final String last4;
  final int expiryMonth;
  final int expiryYear;
  final String cardholderName;
  final bool isDefault;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'brand': brand,
      'last4': last4,
      'expiryMonth': expiryMonth,
      'expiryYear': expiryYear,
      'cardholderName': cardholderName,
      'isDefault': isDefault,
    };
  }

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['id'] as String,
      brand: json['brand'] as String? ?? 'Tarjeta',
      last4: json['last4'] as String? ?? '0000',
      expiryMonth: json['expiryMonth'] as int? ?? 1,
      expiryYear: json['expiryYear'] as int? ?? 2000,
      cardholderName: json['cardholderName'] as String? ?? '',
      isDefault: json['isDefault'] as bool? ?? false,
    );
  }
}

class PaymentMethodInput {
  const PaymentMethodInput({
    required this.cardNumber,
    required this.expiryMonth,
    required this.expiryYear,
    required this.cardholderName,
    required this.isDefault,
  });

  final String cardNumber;
  final int expiryMonth;
  final int expiryYear;
  final String cardholderName;
  final bool isDefault;
}
