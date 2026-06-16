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
import '../../notifications/data/firebase_push_service.dart';
import '../data/supabase_auth_repository.dart';
import '../domain/auth_repository.dart';
import '../domain/user_profile.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final supabaseClient = ref.watch(supabaseClientProvider);
  return SupabaseAuthRepository(supabaseClient: supabaseClient);
});

final authSessionNotifierProvider =
    NotifierProvider<AuthSessionNotifier, AuthSessionState>(
      AuthSessionNotifier.new,
    );

final authRefreshListenableProvider = Provider<ChangeNotifier>((ref) {
  final notifier = ref.watch(authSessionNotifierProvider.notifier);
  return notifier._refreshListenable;
});

final authControllerProvider =
    NotifierProvider<AuthController, AsyncValue<void>>(AuthController.new);

class AuthSessionNotifier extends Notifier<AuthSessionState> {
  StreamSubscription<AuthStateChange>? _subscription;
  final _refreshListenable = AuthRefreshListenable();
  AuthFlowEvent _lastEvent = AuthFlowEvent.initialSession;
  bool _signOutRequested = false;
  bool _hasPendingPasswordRecovery = false;
  bool _hasAuthError = false;
  String? _pendingNotice;

  Timer? _refreshTimer;
  int _refreshRetryCount = 0;
  static const int _maxRefreshRetries = 3;
  static const Duration _refreshInterval = Duration(minutes: 30);
  static const Duration _refreshRetryDelay = Duration(seconds: 5);

  @override
  AuthSessionState build() {
    final repository = ref.watch(authRepositoryProvider);
    final initialState = repository.currentSnapshot();

    _subscription = repository.watchAuthState().listen((nextState) {
      final previousState = state;
      _lastEvent = nextState.event;
      state = nextState.state;

      if (nextState.event == AuthFlowEvent.passwordRecovery) {
        _hasPendingPasswordRecovery = true;
      }

      if (nextState.event == AuthFlowEvent.signedOut &&
          previousState.isAuthenticated &&
          !_signOutRequested) {
        _pendingNotice =
            'Tu sesión expiró. Inicia sesión de nuevo para continuar.';
      }

      if (nextState.event == AuthFlowEvent.signedOut) {
        _signOutRequested = false;
        _stopRefreshTimer();
      }

      if (nextState.event == AuthFlowEvent.signedIn) {
        _hasAuthError = false;
        _startRefreshTimer();
      }

      if (nextState.event == AuthFlowEvent.tokenRefreshed) {
        _refreshRetryCount = 0;
      }

      _refreshListenable._notify();
    });

    if (initialState.isAuthenticated) {
      _startRefreshTimer();
    }

    ref.onDispose(() {
      _subscription?.cancel();
      _stopRefreshTimer();
      _refreshListenable.dispose();
    });

    return initialState;
  }

  void _startRefreshTimer() {
    _stopRefreshTimer();
    _refreshTimer = Timer.periodic(_refreshInterval, (_) => _refreshSession());
  }

  void _stopRefreshTimer() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  Future<void> _refreshSession() async {
    final repository = ref.read(authRepositoryProvider);
    final currentSession = state.session;

    if (currentSession == null) {
      _stopRefreshTimer();
      return;
    }

    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final expiresAt = currentSession.expiresAt;

    if (expiresAt != null && now >= expiresAt - 300) {
      await _performRefreshWithRetry(repository);
    }
  }

  Future<void> _performRefreshWithRetry(AuthRepository repository) async {
    try {
      final newSession = await repository.refreshSession();
      if (newSession != null) {
        _refreshRetryCount = 0;
        _refreshListenable._notify();
      } else {
        _handleRefreshFailure();
      }
    } catch (error) {
      _refreshRetryCount++;
      if (_refreshRetryCount >= _maxRefreshRetries) {
        _handleRefreshFailure();
      } else {
        await Future.delayed(_refreshRetryDelay * _refreshRetryCount);
        await _performRefreshWithRetry(repository);
      }
    }
  }

  void _handleRefreshFailure() {
    _refreshRetryCount = 0;
    _stopRefreshTimer();
    _pendingNotice = 'Tu sesión expiró. Inicia sesión de nuevo para continuar.';
    final notifier = ref.read(authControllerProvider.notifier);
    notifier.signOut();
  }

  AuthFlowEvent get lastEvent => _lastEvent;
  bool get hasPendingPasswordRecovery => _hasPendingPasswordRecovery;
  bool get hasAuthError => _hasAuthError;
  AuthSessionState get currentAuthState => state;

  void markAuthError() {
    _hasAuthError = true;
    _refreshListenable._notify();
  }

  void clearAuthError() {
    if (_hasAuthError) {
      _hasAuthError = false;
      _refreshListenable._notify();
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
    _refreshListenable._notify();
  }
}

class AuthRefreshListenable extends ChangeNotifier {
  void _notify() => notifyListeners();
}

class AuthController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() {
    return const AsyncValue.data(null);
  }

  AuthRepository get _repository => ref.read(authRepositoryProvider);
  AnalyticsService get _analytics => ref.read(analyticsServiceProvider);
  AppConfig get _config => ref.read(appConfigProvider);
  AuthSessionNotifier get _sessionNotifier =>
      ref.read(authSessionNotifierProvider.notifier);

  Future<void> signIn({required String email, required String password}) async {
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

      final pushService = ref.read(pushServiceProvider);
      await pushService.initialize();
      await pushService.registerToken(profile.id);
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
    SentryBreadcrumb.userAction(
      'submit',
      'signup_form',
      extra: {'role': role.name},
    );

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
        AuthSignupCompletedEvent(method: AuthMethod.email, role: role.name),
      );

      if (result.profile != null) {
        final pushService = ref.read(pushServiceProvider);
        await pushService.initialize();
        await pushService.registerToken(result.profile!.id);
      }

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
    final pushService = ref.read(pushServiceProvider);
    await pushService.unregisterToken();
    state = const AsyncValue.data(null);
  }

  Future<void> sendPasswordResetEmail({required String email}) async {
    state = const AsyncValue.loading();
    SentryBreadcrumb.userAction('submit', 'forgot_password_form');

    state = await AsyncValue.guard(() async {
      await _repository.sendPasswordResetEmail(
        email: email,
        redirectTo: _config.hasAuthResetRedirectUrl
            ? _config.authResetRedirectUrl
            : null,
      );
    });
  }

  Future<void> updatePassword({required String newPassword}) async {
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
  const AuthFeedbackListener({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<AuthFeedbackListener> createState() =>
      _AuthFeedbackListenerState();
}

class _AuthFeedbackListenerState extends ConsumerState<AuthFeedbackListener> {
  AuthSessionNotifier? _notifier;
  VoidCallback? _listener;

  @override
  void initState() {
    super.initState();
    _subscribe();
  }

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
    final notifier = ref.read(authSessionNotifierProvider.notifier);
    if (identical(_notifier, notifier)) {
      return;
    }

    _removeListener();
    _notifier = notifier;
    final listenable = ref.read(authRefreshListenableProvider);
    _listener = _handleAuthFeedback;
    listenable.addListener(_listener!);
  }

  void _removeListener() {
    if (_listener != null) {
      final listenable = ref.read(authRefreshListenableProvider);
      listenable.removeListener(_listener!);
      _listener = null;
    }
  }

  void _handleAuthFeedback() {
    if (!mounted) return;

    final notice = _notifier?.consumePendingNotice();
    if (notice != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(notice)));
      });
    }
  }

  @override
  void dispose() {
    _removeListener();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
