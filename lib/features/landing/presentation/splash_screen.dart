import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/routing/route_names.dart';
import '../../../core/ui/fudi_colors.dart';
import '../../../core/ui/fudi_logo.dart';
import '../../../core/ui/fudi_spacing.dart';
import '../../../core/ui/fudi_typography.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    
    _controller.forward();

    // Redirigir después de 2.5 segundos
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        context.go(RouteNames.homePath);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FudiColors.background,
      body: Stack(
        children: [
          // ─── Patrones de fondo ─────────────────────────────────────
          const _BackgroundPatterns(),
          
          // ─── Contenido central ─────────────────────────────────────
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const FudiLogo(
                    variant: FudiLogoVariant.wordmark,
                    size: FudiLogoSize.lg,
                  ),
                  const SizedBox(height: FudiSpacing.md),
                  Text(
                    'Buena comida, mejores decisiones',
                    style: FudiTypography.bodyLarge.copyWith(
                      color: FudiColors.primary.withValues(alpha: 0.8),
                      fontWeight: FontWeight.w500,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BackgroundPatterns extends StatelessWidget {
  const _BackgroundPatterns();

  @override
  Widget build(BuildContext context) {
    // Generar posiciones deterministas "aleatorias" para que no cambien en cada rebuild
    final patterns = [
      _PatternData(top: -50, left: -40, size: 280, rotation: 0.2),
      _PatternData(top: 100, right: -80, size: 320, rotation: -0.4),
      _PatternData(bottom: -60, left: -20, size: 240, rotation: 0.6),
      _PatternData(bottom: 120, right: -40, size: 200, rotation: -0.2),
      _PatternData(top: 300, left: 100, size: 150, rotation: 0.1),
    ];

    return Stack(
      children: patterns.map((p) => _PositionedPattern(data: p)).toList(),
    );
  }
}

class _PositionedPattern extends StatelessWidget {
  const _PositionedPattern({required this.data});
  final _PatternData data;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: data.top,
      left: data.left,
      right: data.right,
      bottom: data.bottom,
      child: Transform.rotate(
        angle: data.rotation,
        child: Opacity(
          opacity: 0.08, // Muy sutil
          child: FudiLogo(
            variant: FudiLogoVariant.icon,
            width: data.size, // Usar el tamaño definido en data
            color: Colors.white, // Tono más claro que el crema del fondo
          ),
        ),
      ),
    );
  }
}

class _PatternData {
  final double? top;
  final double? left;
  final double? right;
  final double? bottom;
  final double size;
  final double rotation;

  _PatternData({
    this.top,
    this.left,
    this.right,
    this.bottom,
    required this.size,
    required this.rotation,
  });
}
