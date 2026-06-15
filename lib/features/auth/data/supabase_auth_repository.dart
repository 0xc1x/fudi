import 'package:supabase_flutter/supabase_flutter.dart' as supa;

import '../../../core/error/auth_exceptions.dart';
import '../../../core/error/data_exceptions.dart';
import '../domain/auth_repository.dart';
import '../domain/user_profile.dart';

class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository({required supa.SupabaseClient supabaseClient})
    : _supabaseClient = supabaseClient;

  final supa.SupabaseClient _supabaseClient;

  @override
  AuthSessionState currentSnapshot() {
    final session = _supabaseClient.auth.currentSession;
    final user = _supabaseClient.auth.currentUser;

    if (session == null || user == null) {
      return const AuthSessionState.unauthenticated();
    }

    return AuthSessionState(
      session: session,
      profile: null,
      fallbackRole: UserRole.fromString(user.userMetadata?['role'] as String?),
    );
  }

  @override
  Stream<AuthStateChange> watchAuthState() async* {
    yield AuthStateChange(
      event: AuthFlowEvent.initialSession,
      state: await _buildStateFromSession(_supabaseClient.auth.currentSession),
    );

    await for (final authState in _supabaseClient.auth.onAuthStateChange) {
      yield AuthStateChange(
        event: _mapAuthFlowEvent(authState.event),
        state: await _buildStateFromSession(authState.session),
      );
    }
  }

  @override
  Future<UserProfile> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user == null) {
        throw const UnauthorizedException(
          message: 'No se pudo iniciar sesión con esas credenciales',
        );
      }

      await _syncAnalyticsConsentIfNeeded(
        userId: user.id,
        metadataConsentGranted:
            user.userMetadata?['analytics_consent_granted'] == true,
      );

      return _fetchProfile(user.id);
    } on supa.AuthException catch (error) {
      throw _mapAuthException(error);
    } on AuthException {
      rethrow;
    } catch (_) {
      throw const UnauthorizedException(
        message: 'No se pudo iniciar sesión en este momento',
      );
    }
  }

  @override
  Future<SignUpResult> signUpWithEmail({
    required String fullName,
    required String email,
    required String password,
    required UserRole role,
    required bool analyticsConsentGranted,
  }) async {
    try {
      final response = await _supabaseClient.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'role': role.name,
          'analytics_consent_granted': analyticsConsentGranted,
        },
      );

      final user = response.user;
      if (user == null) {
        throw const ValidationException(message: 'No se pudo crear la cuenta');
      }

      final hasActiveSession = response.session != null;
      if (hasActiveSession && analyticsConsentGranted) {
        await _syncAnalyticsConsentIfNeeded(
          userId: user.id,
          metadataConsentGranted: true,
        );
      }

      if (!hasActiveSession) {
        return const SignUpResult(requiresEmailConfirmation: true);
      }

      final profile = await _fetchProfile(user.id);
      return SignUpResult(requiresEmailConfirmation: false, profile: profile);
    } on supa.AuthException catch (error) {
      throw _mapAuthException(error);
    } on AuthException {
      rethrow;
    } catch (_) {
      throw const ValidationException(
        message: 'No se pudo completar el registro',
      );
    }
  }

  @override
  Future<void> signOut() async {
    await _supabaseClient.auth.signOut();
  }

  @override
  Future<supa.Session?> refreshSession() async {
    try {
      final response = await _supabaseClient.auth.refreshSession();
      return response.session;
    } on supa.AuthException catch (error) {
      throw _mapAuthException(error);
    } catch (_) {
      throw const UnauthorizedException(
        message: 'No se pudo renovar la sesión',
      );
    }
  }

  @override
  Future<void> sendPasswordResetEmail({
    required String email,
    String? redirectTo,
  }) async {
    try {
      await _supabaseClient.auth.resetPasswordForEmail(
        email,
        redirectTo: redirectTo,
      );
    } on supa.AuthException catch (error) {
      throw _mapAuthException(error);
    } catch (_) {
      throw const UnauthorizedException(
        message: 'No pudimos enviar el correo de recuperación',
      );
    }
  }

  @override
  Future<void> updatePassword({required String newPassword}) async {
    try {
      await _supabaseClient.auth.updateUser(
        supa.UserAttributes(password: newPassword),
      );
    } on supa.AuthException catch (error) {
      throw _mapAuthException(error);
    } catch (_) {
      throw const ValidationException(
        message: 'No pudimos actualizar la contraseña',
      );
    }
  }

  Future<AuthSessionState> _buildStateFromSession(supa.Session? session) async {
    final user = session?.user;
    if (session == null || user == null) {
      return const AuthSessionState.unauthenticated();
    }

    try {
      await _syncAnalyticsConsentIfNeeded(
        userId: user.id,
        metadataConsentGranted:
            user.userMetadata?['analytics_consent_granted'] == true,
      );

      final profile = await _fetchProfile(user.id);
      return AuthSessionState(
        session: session,
        profile: profile,
        fallbackRole: profile.role,
      );
    } catch (_) {
      return AuthSessionState(
        session: session,
        profile: null,
        fallbackRole: UserRole.fromString(
          user.userMetadata?['role'] as String?,
        ),
      );
    }
  }

  Future<UserProfile> _fetchProfile(String userId) async {
    final profileResponse = await _supabaseClient
        .from('profiles')
        .select('id, email, full_name, avatar_url, phone, city, role')
        .eq('id', userId)
        .maybeSingle();

    if (profileResponse == null) {
      throw const NotFoundException(message: 'Perfil no encontrado');
    }

    final analyticsConsentResponse = await _supabaseClient
        .from('user_consents')
        .select('granted')
        .eq('user_id', userId)
        .eq('consent_type', 'analytics')
        .maybeSingle();

    return UserProfile(
      id: profileResponse['id'] as String,
      email: profileResponse['email'] as String? ?? '',
      fullName: profileResponse['full_name'] as String?,
      avatarUrl: profileResponse['avatar_url'] as String?,
      phone: profileResponse['phone'] as String?,
      city: profileResponse['city'] as String?,
      role: UserRole.fromString(profileResponse['role'] as String?),
      analyticsConsentGranted:
          (analyticsConsentResponse?['granted'] as bool?) ?? false,
    );
  }

  Future<void> _updateAnalyticsConsent({
    required String userId,
    required bool granted,
  }) async {
    await _supabaseClient.from('user_consents').upsert({
      'user_id': userId,
      'consent_type': 'analytics',
      'granted': granted,
      'granted_at': granted ? DateTime.now().toIso8601String() : null,
      'revoked_at': granted ? null : DateTime.now().toIso8601String(),
    });
  }

  Future<void> _syncAnalyticsConsentIfNeeded({
    required String userId,
    required bool metadataConsentGranted,
  }) async {
    if (!metadataConsentGranted) {
      return;
    }

    final analyticsConsentResponse = await _supabaseClient
        .from('user_consents')
        .select('granted')
        .eq('user_id', userId)
        .eq('consent_type', 'analytics')
        .maybeSingle();

    final alreadyGranted =
        (analyticsConsentResponse?['granted'] as bool?) ?? false;
    if (alreadyGranted) {
      return;
    }

    await _updateAnalyticsConsent(userId: userId, granted: true);
  }

  AuthException _mapAuthException(supa.AuthException error) {
    final message = error.message.toLowerCase();

    if (message.contains('invalid login credentials') ||
        message.contains('invalid credentials')) {
      return const InvalidCredentialsException();
    }

    if (message.contains('email not confirmed')) {
      return const UnauthorizedException(
        message: 'Debes confirmar tu correo antes de iniciar sesión',
      );
    }

    if (message.contains('already registered') ||
        message.contains('already been registered') ||
        message.contains('user already registered')) {
      return const AuthConflictException();
    }

    if (message.contains('session') && message.contains('expired')) {
      return const TokenExpiredException();
    }

    return UnauthorizedException(message: error.message);
  }

  AuthFlowEvent _mapAuthFlowEvent(supa.AuthChangeEvent event) {
    switch (event) {
      case supa.AuthChangeEvent.initialSession:
        return AuthFlowEvent.initialSession;
      case supa.AuthChangeEvent.signedIn:
        return AuthFlowEvent.signedIn;
      case supa.AuthChangeEvent.signedOut:
        return AuthFlowEvent.signedOut;
      case supa.AuthChangeEvent.passwordRecovery:
        return AuthFlowEvent.passwordRecovery;
      case supa.AuthChangeEvent.tokenRefreshed:
        return AuthFlowEvent.tokenRefreshed;
      case supa.AuthChangeEvent.userUpdated:
        return AuthFlowEvent.userUpdated;
      case supa.AuthChangeEvent.mfaChallengeVerified:
        return AuthFlowEvent.mfaChallengeVerified;
      default:
        return AuthFlowEvent.unknown;
    }
  }
}
