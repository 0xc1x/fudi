import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'core/bootstrap/app_bootstrap.dart';
import 'core/di/core_providers.dart';
import 'core/ui/fudi_colors.dart';
import 'core/ui/fudi_logo.dart';
import 'core/ui/fudi_spacing.dart';
import 'core/ui/fudi_theme.dart';
import 'core/ui/fudi_typography.dart';
import 'features/auth/presentation/auth_state_provider.dart';
import 'features/notifications/presentation/notification_handler.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const _FudiRoot());
}

class _FudiRoot extends StatefulWidget {
  const _FudiRoot();

  @override
  State<_FudiRoot> createState() => _FudiRootState();
}

class _FudiRootState extends State<_FudiRoot> {
  AppBootstrapResult? _bootstrapResult;
  Object? _bootstrapError;

  @override
  void initState() {
    super.initState();
    _runBootstrap();
  }

  Future<void> _runBootstrap() async {
    try {
      final result = await AppBootstrap.run();
      if (!mounted) return;
      await initLocalNotifications();
      if (!mounted) return;
      setState(() => _bootstrapResult = result);
    } catch (e, st) {
      if (!mounted) return;
      setState(() => _bootstrapError = e);
      Sentry.captureException(e, stackTrace: st);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_bootstrapResult != null) {
      final boot = _bootstrapResult!;
      final appWidget = ProviderScope(
        overrides: [
          appEnvironmentProvider.overrideWithValue(boot.environment),
          appConfigProvider.overrideWithValue(boot.config),
        ],
        child: const FudiApp(),
      );

      return boot.sentryEnabled ? SentryWidget(child: appWidget) : appWidget;
    }

    if (_bootstrapError != null) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: FudiTheme.light(),
        home: _BootstrapErrorScreen(error: _bootstrapError!),
      );
    }

    return const _BootstrapLoadingApp();
  }
}

class _BootstrapLoadingApp extends StatelessWidget {
  const _BootstrapLoadingApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: FudiTheme.light(),
      home: const Scaffold(
        backgroundColor: FudiColors.primary,
        body: Center(
          child: FudiLogo(
            variant: FudiLogoVariant.wordmark,
            color: FudiColors.accentForeground,
          ),
        ),
      ),
    );
  }
}

class _BootstrapErrorScreen extends StatelessWidget {
  const _BootstrapErrorScreen({required this.error});
  final Object error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FudiColors.primary,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(FudiSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FudiLogo(
                variant: FudiLogoVariant.wordmark,
                width: MediaQuery.sizeOf(context).width * 0.8,
                color: FudiColors.accentForeground.withValues(alpha: 0.8),
              ),
              const SizedBox(height: FudiSpacing.lg),
              Text(
                'No se pudo iniciar la app',
                style: FudiTypography.bodyLarge.copyWith(
                  color: FudiColors.accentForeground,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: FudiSpacing.sm),
              Text(
                error.toString(),
                textAlign: TextAlign.center,
                style: FudiTypography.bodySmall.copyWith(
                  color: FudiColors.accentForeground.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FudiApp extends ConsumerWidget {
  const FudiApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Fudi',
      debugShowCheckedModeBanner: false,
      theme: FudiTheme.light(),
      routerConfig: router,
      builder: (context, child) {
        return AuthFeedbackListener(
          child: PushNotificationHandler(
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },
    );
  }
}
