import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/analytics/analytics_service.dart';
import '../../../core/analytics/analytics_provider.dart';
import '../../../core/analytics/events/auth_events.dart';
import '../../../core/analytics/models/user_properties.dart';
import '../../../core/config/app_config.dart';
import '../../../core/di/core_providers.dart';
import '../../../core/observability/sentry_breadcrumb.dart';
import '../data/supabase_auth_repository.dart';
import '../domain/auth_repository.dart';
import '../domain/user_profile.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final supabaseClient = ref.watch(supabaseClientProvider);
  return SupabaseAuthRepository(supabaseClient: supabaseClient);
});

final authSessionNotifierProvider = Provider<AuthSessionNotifier>((ref) {
  final notifier = AuthSessionNotifier(ref.watch(authRepositoryProvider));
  ref.onDispose(notifier.dispose);
  return notifier;
});

final authControllerProvider =
    NotifierProvider<AuthController, AsyncValue<void>>(AuthController.new);

class AuthSessionNotifier extends ChangeNotifier {
  AuthSessionNotifier(this._repository) {
    _state = _repository.currentSnapshot();
    _subscription = _repository.watchAuthState().listen((nextState) {
      final previousState = _state;
      _state = nextState.state;
      _lastEvent = nextState.event;

      if (nextState.event == AuthFlowEvent.passwordRecovery) {
        _hasPendingPasswordRecovery = true;
      }

      if (nextState.event == AuthFlowEvent.signedOut &&
          previousState.isAuthenticated &&
          !_signOutRequested) {
        _pendingNotice = 'Tu sesión expiró. Inicia sesión de nuevo para continuar.';
      }

      if (nextState.event == AuthFlowEvent.signedOut) {
        _signOutRequested = false;
      }

      // Clear auth error on successful sign-in — the guard can now redirect.
      if (nextState.event == AuthFlowEvent.signedIn) {
        _hasAuthError = false;
      }

      notifyListeners();
    });
  }

  final AuthRepository _repository;
  late AuthSessionState _state;
  StreamSubscription<AuthStateChange>? _subscription;
  AuthFlowEvent _lastEvent = AuthFlowEvent.initialSession;
  bool _signOutRequested = false;
  bool _hasPendingPasswordRecovery = false;
  bool _hasAuthError = false;
  String? _pendingNotice;

  AuthSessionState get state => _state;
  AuthFlowEvent get lastEvent => _lastEvent;
  bool get hasPendingPasswordRecovery => _hasPendingPasswordRecovery;

  /// Whether the last auth operation (sign-in / sign-up) failed.
  ///
  /// The GoRouter guard checks this flag to avoid redirecting away from
  /// `/login` when the user is still on the login screen after a failed
  /// attempt.  Without it, `refreshListenable` fires `notifyListeners()`
  /// and the guard would redirect to home even though sign-in failed.
  bool get hasAuthError => _hasAuthError;

  /// Mark that the last auth operation failed (called by AuthController).
  void markAuthError() {
    _hasAuthError = true;
    notifyListeners();
  }

  /// Clear the auth-error flag (called on successful sign-in or when the
  /// user leaves the login screen).
  void clearAuthError() {
    if (_hasAuthError) {
      _hasAuthError = false;
      notifyListeners();
    }
  }

  void markSignOutRequested() {
    _signOutRequested = true;
  }

  String? consumePendingNotice() {
    final notice = _pendingNotice;
    _pendingNotice = null;
    return notice;
  }

  void clearPasswordRecoveryFlag() {
    _hasPendingPasswordRecovery = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

class AuthController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() {
    return const AsyncValue.data(null);
  }

  AuthRepository get _repository => ref.read(authRepositoryProvider);
  AnalyticsService get _analytics => ref.read(analyticsServiceProvider);
  AppConfig get _config => ref.read(appConfigProvider);
  AuthSessionNotifier get _sessionNotifier => ref.read(authSessionNotifierProvider);

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    SentryBreadcrumb.userAction('submit', 'login_form');
    await _analytics.track(AuthLoginStartedEvent(method: AuthMethod.email));

    state = await AsyncValue.guard(() async {
      final profile = await _repository.signInWithEmail(
        email: email,
        password: password,
      );

      _analytics.setConsent(profile.analyticsConsentGranted);
      await _analytics.setUserId(profile.id);
      await _analytics.setUserProperties(
        UserProperties(
          role: profile.role.name,
          city: profile.city,
          isBusiness: profile.isBusiness,
        ),
      );
      await _analytics.track(
        AuthLoginCompletedEvent(method: AuthMethod.email, isNewUser: false),
      );
    });

    state.whenOrNull(
      error: (error, _) {
        _sessionNotifier.markAuthError();
        _analytics.track(
          AuthLoginFailedEvent(
            method: AuthMethod.email,
            errorType: error.runtimeType.toString(),
          ),
        );
      },
    );
  }

  Future<SignUpResult> signUp({
    required String fullName,
    required String email,
    required String password,
    required UserRole role,
    required bool analyticsConsentGranted,
  }) async {
    state = const AsyncValue.loading();
    SentryBreadcrumb.userAction('submit', 'signup_form', extra: {'role': role.name});

    try {
      final result = await _repository.signUpWithEmail(
        fullName: fullName,
        email: email,
        password: password,
        role: role,
        analyticsConsentGranted: analyticsConsentGranted,
      );

      if (result.profile != null) {
        _analytics.setConsent(result.profile!.analyticsConsentGranted);
        await _analytics.setUserId(result.profile!.id);
        await _analytics.setUserProperties(
          UserProperties(
            role: result.profile!.role.name,
            city: result.profile!.city,
            isBusiness: result.profile!.isBusiness,
          ),
        );
      }

      await _analytics.track(
        AuthSignupCompletedEvent(
          method: AuthMethod.email,
          role: role.name,
        ),
      );

      state = const AsyncValue.data(null);
      return result;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    _sessionNotifier.markSignOutRequested();
    await _repository.signOut();
    await _analytics.track(AuthLogoutEvent());
    await _analytics.reset();
    state = const AsyncValue.data(null);
  }

  Future<void> sendPasswordResetEmail({
    required String email,
  }) async {
    state = const AsyncValue.loading();
    SentryBreadcrumb.userAction('submit', 'forgot_password_form');

    state = await AsyncValue.guard(() async {
      await _repository.sendPasswordResetEmail(
        email: email,
        redirectTo:
            _config.hasAuthResetRedirectUrl ? _config.authResetRedirectUrl : null,
      );
    });
  }

  Future<void> updatePassword({
    required String newPassword,
  }) async {
    state = const AsyncValue.loading();
    SentryBreadcrumb.userAction('submit', 'update_password_form');

    state = await AsyncValue.guard(() async {
      await _repository.updatePassword(newPassword: newPassword);
      _sessionNotifier.markSignOutRequested();
      await _repository.signOut();
      await _analytics.reset();
    });
  }
}

class AuthFeedbackListener extends ConsumerStatefulWidget {
  const AuthFeedbackListener({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  ConsumerState<AuthFeedbackListener> createState() => _AuthFeedbackListenerState();
}

class _AuthFeedbackListenerState extends ConsumerState<AuthFeedbackListener> {
  AuthSessionNotifier? _notifier;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _subscribe();
  }

  @override
  void didUpdateWidget(covariant AuthFeedbackListener oldWidget) {
    super.didUpdateWidget(oldWidget);
    _subscribe();
  }

  void _subscribe() {
    final notifier = ref.read(authSessionNotifierProvider);
    if (identical(_notifier, notifier)) {
      return;
    }

    _notifier?.removeListener(_handleAuthFeedback);
    _notifier = notifier;
    _notifier?.addListener(_handleAuthFeedback);
  }

  void _handleAuthFeedback() {
    if (!mounted) return;

    final notice = _notifier?.consumePendingNotice();
    if (notice != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(notice)),
        );
      });
    }

  }

  @override
  void dispose() {
    _notifier?.removeListener(_handleAuthFeedback);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
