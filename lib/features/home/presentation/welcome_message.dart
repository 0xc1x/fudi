import 'package:fudi/features/auth/domain/user_profile.dart';

class WelcomeData {
  final String greeting;
  final String displayName;
  final String contextualMessage;
  final String emoji;

  const WelcomeData({
    required this.greeting,
    required this.displayName,
    required this.contextualMessage,
    required this.emoji,
  });

  String get fullMessage => '$greeting, $displayName! $contextualMessage';
}

class WelcomeMessage {
  const WelcomeMessage._();

  static WelcomeData generate({
    required UserProfile profile,
    required DateTime now,
  }) {
    final name = _getDisplayName(profile);
    final hour = now.hour;
    final weekday = now.weekday;

    return WelcomeData(
      greeting: _getTimeGreeting(hour),
      displayName: name,
      contextualMessage: _getContextualMessage(hour, weekday, profile),
      emoji: getTimeBasedEmoji(hour),
    );
  }

  static String _getDisplayName(UserProfile profile) {
    if (profile.fullName != null && profile.fullName!.isNotEmpty) {
      final parts = profile.fullName!.trim().split(' ');
      return parts.first;
    }
    if (profile.email.isNotEmpty) {
      return profile.email.split('@').first;
    }
    return 'Usuario';
  }

  static String _getTimeGreeting(int hour) {
    if (hour >= 6 && hour < 12) {
      return 'Buenos días';
    } else if (hour >= 12 && hour < 19) {
      return 'Buenas tardes';
    } else {
      return 'Buenas noches';
    }
  }

  static String _getContextualMessage(
    int hour,
    int weekday,
    UserProfile profile,
  ) {
    final isWeekend = weekday == 6 || weekday == 7;

    if (hour >= 6 && hour < 12) {
      if (isWeekend) {
        return '¿Qué se te antoja para empezar el día?';
      }
      return '¿Qué se te antoja hoy?';
    } else if (hour >= 12 && hour < 19) {
      if (weekday == 5) {
        return '¡Ya es viernes! Celebra con ofertas cerca';
      }
      if (isWeekend) {
        return 'Tenemos ofertas frescas para tu tarde';
      }
      return 'Tenemos ofertas frescas cerca';
    } else {
      return '¿Cena sorpresa?';
    }
  }

  static String getTimeBasedEmoji(int hour) {
    return '';
  }
}
