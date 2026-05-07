import 'package:supabase_flutter/supabase_flutter.dart' as supa;

import 'user_profile.dart';

enum AuthFlowEvent {
  initialSession,
  signedIn,
  signedOut,
  passwordRecovery,
  tokenRefreshed,
  userUpdated,
  userDeleted,
  mfaChallengeVerified,
  unknown,
}

class AuthSessionState {
  const AuthSessionState({
    required this.session,
    required this.profile,
    required this.fallbackRole,
  });

  const AuthSessionState.unauthenticated()
      : session = null,
        profile = null,
        fallbackRole = UserRole.user;

  final supa.Session? session;
  final UserProfile? profile;
  final UserRole fallbackRole;

  bool get isAuthenticated => session != null;
  UserRole get role => profile?.role ?? fallbackRole;
}

class AuthStateChange {
  const AuthStateChange({
    required this.event,
    required this.state,
  });

  final AuthFlowEvent event;
  final AuthSessionState state;
}

class SignUpResult {
  const SignUpResult({
    required this.requiresEmailConfirmation,
    this.profile,
  });

  final bool requiresEmailConfirmation;
  final UserProfile? profile;
}

abstract class AuthRepository {
  AuthSessionState currentSnapshot();

  Stream<AuthStateChange> watchAuthState();

  Future<UserProfile> signInWithEmail({
    required String email,
    required String password,
  });

  Future<SignUpResult> signUpWithEmail({
    required String fullName,
    required String email,
    required String password,
    required UserRole role,
    required bool analyticsConsentGranted,
  });

  Future<void> sendPasswordResetEmail({
    required String email,
    String? redirectTo,
  });

  Future<void> updatePassword({
    required String newPassword,
  });

  Future<void> signOut();
}
