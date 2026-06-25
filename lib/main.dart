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
      home: Scaffold(
        backgroundColor: FudiColors.primary,
        body: Stack(
          children: [
            const _LoadingBackgroundPatterns(),
            Center(
              child: FractionallySizedBox(
                widthFactor: 0.92,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 780),
                  child: const FudiLogo(
                    variant: FudiLogoVariant.wordmark,
                    width: double.infinity,
                    color: FudiColors.accentForeground,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingBackgroundPatterns extends StatelessWidget {
  const _LoadingBackgroundPatterns();

  @override
  Widget build(BuildContext context) {
    final patterns = [
      _PatternData(top: -70, left: -60, width: 320, rotation: 0.2),
      _PatternData(top: 50, right: -80, width: 260, rotation: -0.49),
      _PatternData(topFraction: 0.35, left: -40, width: 170, rotation: 0.14),
      _PatternData(topFraction: 0.45, right: -60, width: 210, rotation: -0.26),
      _PatternData(bottom: -50, left: -45, width: 240, rotation: 0.35),
      _PatternData(bottom: -80, right: -65, width: 310, rotation: -0.31),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final h = constraints.maxHeight;
        return Stack(
          children: patterns.map((p) {
            return Positioned(
              top: p.top != null ? p.top : (p.topFraction != null ? h * p.topFraction! : null),
              left: p.left,
              right: p.right,
              bottom: p.bottom,
              child: Transform.rotate(
                angle: p.rotation,
                child: Opacity(
                  opacity: 0.09,
                  child: FudiLogo(
                    variant: FudiLogoVariant.icon,
                    width: p.width,
                    color: Colors.white,
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _PatternData {
  final double? top;
  final double? topFraction;
  final double? left;
  final double? right;
  final double? bottom;
  final double width;
  final double rotation;
  _PatternData({
    this.top,
    this.topFraction,
    this.left,
    this.right,
    this.bottom,
    required this.width,
    required this.rotation,
  });
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
