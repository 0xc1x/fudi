import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/domain/app_mode.dart';
import '../../features/auth/presentation/app_mode_provider.dart';
import '../routing/route_names.dart';
import 'fudi_colors.dart';
import 'fudi_icons.dart';
import 'fudi_spacing.dart';

/// Navegación inferior de Fudi.
///
/// Replica fielmente el BottomNav del mockup React:
/// - 3 tabs por modo (Consumer / Business)
/// - Custom nav bar (no Material NavigationBar)
/// - border-top separador, max-width 480px centrado
/// - Mismo icono en ambos estados, solo cambia el color
/// - Color activo: FudiColors.primary, inactivo: FudiColors.mutedForeground
class FudiBottomNav extends ConsumerWidget {
  const FudiBottomNav({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appMode = ref.watch(appModeProvider);
    final location = GoRouterState.of(context).matchedLocation;

    final items = appMode == AppMode.consumer ? _consumerItems : _businessItems;

    final currentIndex = _calculateSelectedIndex(location, appMode);

    return Container(
      decoration: const BoxDecoration(
        color: FudiColors.background,
        border: Border(
          top: BorderSide(color: FudiColors.borderSolid, width: 1),
        ),
      ),
      constraints: const BoxConstraints(maxWidth: 480),
      child: SizedBox(
        height: 64,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(items.length, (index) {
            final item = items[index];
            final isActive = index == currentIndex;

            return _NavTab(
              icon: item.icon,
              label: item.label,
              isActive: isActive,
              onTap: () => _onTap(context, index, appMode),
            );
          }),
        ),
      ),
    );
  }

  void _onTap(BuildContext context, int index, AppMode mode) {
    final routes = mode == AppMode.consumer ? _consumerRoutes : _businessRoutes;
    if (index < routes.length) {
      context.go(routes[index]);
    }
  }

  int _calculateSelectedIndex(String location, AppMode mode) {
    final routes = mode == AppMode.consumer ? _consumerRoutes : _businessRoutes;

    for (int i = 0; i < routes.length; i++) {
      final route = routes[i];
      // Exact match for root paths
      if (route == '/' || route == '/business') {
        if (location == route) return i;
      } else {
        // Prefix match for sub-paths
        if (location.startsWith(route)) return i;
      }
    }

    // Fallback: sub-rutas que pertenecen a un tab padre
    if (mode == AppMode.consumer) {
      // /orders, /favorites, /payment-methods, /saved-addresses
      // son sub-páginas de Perfil en el mockup
      if (location.startsWith('/orders') ||
          location.startsWith('/favorites') ||
          location.startsWith('/payment-methods') ||
          location.startsWith('/saved-addresses')) {
        return 2; // Índice del tab "Perfil"
      }
    } else if (mode == AppMode.business) {
      // /business/statistics, /business/payments, /business/profile, /business/coupons
      // son sub-páginas de Gestión en el mockup
      if (location.startsWith('/business')) {
        return 2; // Índice del tab "Gestión"
      }
    }

    return 0;
  }

  // ─── Consumer Tabs (3) ────────────────────────────────────────

  static const _consumerItems = [
    _NavItem(label: 'Inicio', icon: FudiIcons.home),
    _NavItem(label: 'Explorar', icon: FudiIcons.search),
    _NavItem(label: 'Perfil', icon: FudiIcons.user),
  ];

  static const _consumerRoutes = [
    RouteNames.homePath,
    RouteNames.explorePath,
    RouteNames.profilePath,
  ];

  // ─── Business Tabs (3) ────────────────────────────────────────

  static const _businessItems = [
    _NavItem(label: 'Productos', icon: FudiIcons.package_),
    _NavItem(label: 'Pedidos', icon: FudiIcons.shoppingBag),
    _NavItem(label: 'Gestión', icon: FudiIcons.building2),
  ];

  static const _businessRoutes = [
    RouteNames.businessProductsPath,
    RouteNames.businessOrdersPath,
    RouteNames.businessLocationsPath,
  ];
}

/// Tab individual del BottomNav.
///
/// Usa el MISMO icono para ambos estados (activo/inactivo),
/// solo cambia el color — igual que el mockup React.
class _NavTab extends StatelessWidget {
  const _NavTab({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isActive ? FudiColors.primary : FudiColors.mutedForeground;

    return Expanded(
      child: Semantics(
        button: true,
        label: label,
        selected: isActive,
        child: InkWell(
          onTap: onTap,
          customBorder: const StadiumBorder(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 24, color: color),
              const SizedBox(height: FudiSpacing.xs),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.w500 : FontWeight.w400,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Modelo interno para un item de navegación.
class _NavItem {
  final String label;
  final IconData icon;

  const _NavItem({required this.label, required this.icon});
}
