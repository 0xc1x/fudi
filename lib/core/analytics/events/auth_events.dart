import '../models/analytics_event.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Auth Events — docs/ai/ANALYTICS.md → Auth
// ─────────────────────────────────────────────────────────────────────────────

/// Auth method used for login/signup flows.
enum AuthMethod { email, google, apple }

/// User initiates a login attempt.
class AuthLoginStartedEvent extends AnalyticsEvent {
  final AuthMethod method;

  AuthLoginStartedEvent({required this.method});

  @override
  String get name => 'auth_login_started';

  @override
  Map<String, dynamic> get properties => {'method': method.name};
}

/// Login succeeded.
class AuthLoginCompletedEvent extends AnalyticsEvent {
  final AuthMethod method;
  final bool isNewUser;

  AuthLoginCompletedEvent({required this.method, required this.isNewUser});

  @override
  String get name => 'auth_login_completed';

  @override
  Map<String, dynamic> get properties => {
    'method': method.name,
    'is_new_user': isNewUser,
  };
}

/// Login failed.
class AuthLoginFailedEvent extends AnalyticsEvent {
  final AuthMethod method;
  final String errorType;

  AuthLoginFailedEvent({required this.method, required this.errorType});

  @override
  String get name => 'auth_login_failed';

  @override
  Map<String, dynamic> get properties => {
    'method': method.name,
    'error_type': errorType,
  };
}

/// Signup completed successfully.
class AuthSignupCompletedEvent extends AnalyticsEvent {
  final AuthMethod method;
  final String role;

  AuthSignupCompletedEvent({required this.method, required this.role});

  @override
  String get name => 'auth_signup_completed';

  @override
  Map<String, dynamic> get properties => {'method': method.name, 'role': role};
}

/// User logged out.
class AuthLogoutEvent extends AnalyticsEvent {
  @override
  String get name => 'auth_logout';

  @override
  Map<String, dynamic> get properties => const {};
}

/// Session expired (detected client-side or via Supabase auth state).
class AuthSessionExpiredEvent extends AnalyticsEvent {
  @override
  String get name => 'auth_session_expired';

  @override
  Map<String, dynamic> get properties => const {};
}
