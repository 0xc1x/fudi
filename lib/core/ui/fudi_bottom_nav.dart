import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/domain/app_mode.dart';
import '../../features/auth/presentation/app_mode_provider.dart';
import '../routing/route_names.dart';
import 'fudi_colors.dart';
import 'atoms/icons/fudi_icons.dart';
import 'fudi_spacing.dart';

// ── Constantes a nivel de archivo ────────────────────────────────────────────
// Al estar aquí (y no dentro de una clase) son accesibles tanto desde
// FudiBottomNav como desde _FudiBottomNavState sin el prefijo de clase
// que causaba el error de compilación.

const _consumerItems = [
  _NavItem(label: 'Inicio', icon: FudiIcons.home),
  _NavItem(label: 'Explorar', icon: FudiIcons.search),
  _NavItem(label: 'Perfil', icon: FudiIcons.user),
];

const _consumerRoutes = [
  RouteNames.homePath,
  RouteNames.explorePath,
  RouteNames.profilePath,
];

const _businessItems = [
  _NavItem(label: 'Productos', icon: FudiIcons.package_),
  _NavItem(label: 'Pedidos', icon: FudiIcons.shoppingBag),
  _NavItem(label: 'Gestión', icon: FudiIcons.building2),
];

const _businessRoutes = [
  RouteNames.businessProductsPath,
  RouteNames.businessOrdersPath,
  RouteNames.businessLocationsPath,
];

// ── Helpers ───────────────────────────────────────────────────────────────────

int _calculateSelectedIndex(String location, AppMode mode) {
  final routes = mode == AppMode.consumer ? _consumerRoutes : _businessRoutes;

  for (int i = 0; i < routes.length; i++) {
    final route = routes[i];
    if (route == '/' || route == '/business') {
      if (location == route) return i;
    } else {
      if (location.startsWith(route)) return i;
    }
  }

  if (mode == AppMode.consumer) {
    if (location.startsWith('/orders') ||
        location.startsWith('/favorites') ||
        location.startsWith('/payment-methods') ||
        location.startsWith('/saved-addresses')) {
      return 2;
    }
  } else if (mode == AppMode.business) {
    if (location.startsWith('/business')) return 2;
  }

  return 0;
}

// ── Widget ────────────────────────────────────────────────────────────────────

class FudiBottomNav extends ConsumerStatefulWidget {
  const FudiBottomNav({super.key});

  @override
  ConsumerState<FudiBottomNav> createState() => _FudiBottomNavState();
}

class _FudiBottomNavState extends ConsumerState<FudiBottomNav>
    with SingleTickerProviderStateMixin {
  static const _duration = Duration(milliseconds: 400);

  /// Cuánto se ensancha la píldora en el punto máximo del recorrido,
  /// como fracción de su ancho normal (0.18 = +18% en el pico).
  static const _stretchFactor = 0.18;

  late AnimationController _controller;
  late Animation<double> _pillAnim;
  late Animation<double> _stretchAnim;

  /// Posición desde la que arranca la animación actual.
  double _fromLeft = -1; // -1 = todavía no inicializado

  /// Posición destino de la animación actual.
  double _toLeft = -1;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _duration);
    _pillAnim = const AlwaysStoppedAnimation(0.0);

    // Estiramiento: 0 → 1 en la primera mitad del recorrido, 1 → 0 en la
    // segunda. No depende del layout, así que se puede armar una sola vez.
    _stretchAnim = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 0.0,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.0,
          end: 0.0,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 50,
      ),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Lanza la animación hacia [targetLeft].
  /// Parte del valor interpolado actual para soportar interrupciones en vuelo.
  void _animateTo(double targetLeft) {
    if (_toLeft == targetLeft) return;

    final startLeft = _fromLeft < 0 ? targetLeft : _pillAnim.value;

    _fromLeft = startLeft;
    _toLeft = targetLeft;

    _pillAnim = Tween<double>(begin: startLeft, end: targetLeft).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
    );

    _controller.reset();
    unawaited(_controller.forward());

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final appMode = ref.watch(appModeProvider);
    final location = GoRouterState.of(context).matchedLocation;

    final items = appMode == AppMode.consumer ? _consumerItems : _businessItems;
    final currentIndex = _calculateSelectedIndex(location, appMode);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: FudiColors.borderSolid)),
      ),
      constraints: const BoxConstraints(maxWidth: 480),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final itemWidth = constraints.maxWidth / items.length;
          final pillWidth = itemWidth * 0.8;
          final targetLeft =
              currentIndex * itemWidth + (itemWidth - pillWidth) / 2;

          if (_toLeft != targetLeft) {
            if (_fromLeft < 0) {
              _fromLeft = targetLeft;
              _toLeft = targetLeft;
              _pillAnim = AlwaysStoppedAnimation(targetLeft);
            } else {
              WidgetsBinding.instance.addPostFrameCallback(
                (_) => _animateTo(targetLeft),
              );
            }
          }

          return AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final animLeft = _pillAnim.value;

              // Ancho extra en el pico del recorrido, repartido a ambos
              // lados para que el estiramiento quede centrado en la píldora.
              final stretchExtra =
                  pillWidth * _stretchFactor * _stretchAnim.value;
              final animatedPillWidth = pillWidth + stretchExtra;
              final animatedLeft = animLeft - stretchExtra / 2;

              return SizedBox(
                height: 64,
                child: Stack(
                  children: [
                    // ── CAPA 1: iconos muted siempre visibles (fondo) ──────
                    Row(
                      children: List.generate(items.length, (index) {
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => _onTap(context, index, appMode),
                            behavior: HitTestBehavior.opaque,
                            child: SizedBox(
                              height: 64,
                              child: Center(
                                child: Icon(
                                  items[index].icon,
                                  size: 28,
                                  color: FudiColors.mutedForeground,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),

                    // ── CAPA 2: píldora deslizante ─────────────────────────
                    Positioned(
                      left: animatedLeft,
                      width: animatedPillWidth,
                      top: 12,
                      bottom: 12,
                      child: IgnorePointer(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: FudiSpacing.sm,
                          ),
                          decoration: BoxDecoration(
                            color: FudiColors.foreground,
                            borderRadius: BorderRadius.circular(FudiRadius.md),
                          ),
                        ),
                      ),
                    ),

                    // ── CAPA 3: ventana-máscara con contenido "clavado" ────
                    //
                    // La ventana (ClipRect) se mueve y se estira junto con
                    // la píldora. El Transform.translate compensa ese
                    // movimiento con -animLeft (usando la posición SIN
                    // estirar, para que el contenido no se distorsione),
                    // de modo que el Row interior queda absolutamente fijo
                    // respecto a la pantalla. El efecto resultante: la
                    // píldora "revela" el texto blanco que ya estaba ahí,
                    // sin que el contenido salte ni se deforme.
                    Positioned(
                      left: animatedLeft,
                      width: animatedPillWidth,
                      top: 0,
                      bottom: 0,
                      child: IgnorePointer(
                        child: ClipRect(
                          child: OverflowBox(
                            alignment: Alignment.centerLeft,
                            minWidth: constraints.maxWidth,
                            maxWidth: constraints.maxWidth,
                            child: Transform.translate(
                              offset: Offset(-animLeft, 0),
                              child: SizedBox(
                                width: constraints.maxWidth,
                                height: 64,
                                child: Row(
                                  children: List.generate(items.length, (i) {
                                    return Expanded(
                                      child: Center(
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              items[i].icon,
                                              size: 24,
                                              color: Colors.white,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              items[i].label,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _onTap(BuildContext context, int index, AppMode mode) {
    final routes = mode == AppMode.consumer ? _consumerRoutes : _businessRoutes;
    if (index < routes.length) context.go(routes[index]);
  }
}

// ── Modelo ────────────────────────────────────────────────────────────────────

class _NavItem {
  const _NavItem({required this.label, required this.icon});
  final String label;
  final IconData icon;
}
