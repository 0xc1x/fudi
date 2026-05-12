import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../../features/auth/presentation/auth_state_provider.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/signup_screen.dart';
import '../../features/auth/presentation/update_password_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/offers/presentation/product_detail_screen.dart';
import '../../features/orders/presentation/checkout_screen.dart';
import '../../features/orders/presentation/review_order_screen.dart';
import '../../features/explore/presentation/explore_screen.dart';
import '../../features/orders/presentation/order_history_screen.dart';
import '../../features/orders/presentation/order_detail_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/profile/presentation/profile_edit_screen.dart';
import '../observability/sentry_breadcrumb.dart';
import '../ui/fudi_scaffold.dart';
import '../ui/ui_gallery_screen.dart';
import 'route_guards.dart';
import 'route_names.dart';

/// Configuración del router con ShellRoute para navegación persistente.
GoRouter createAppRouter(
  AuthSessionNotifier authSessionNotifier,
  Listenable refreshListenable,
) {
  return GoRouter(
    initialLocation: RouteNames.homePath,
    debugLogDiagnostics: true,
    refreshListenable: refreshListenable,
    redirect: (context, state) {
      if (authSessionNotifier.hasPendingPasswordRecovery &&
          state.matchedLocation != RouteNames.updatePasswordPath) {
        return RouteNames.updatePasswordPath;
      }

      return RouteGuards.combinedGuard(
        context,
        state,
        authSessionNotifier.currentAuthState,
        sessionNotifier: authSessionNotifier,
      );
    },
    observers: [SentryNavigatorObserver(), _SentryRouteObserver()],
    routes: [
      // ─── Rutas sin BottomNav ─────────────────────────────────────
      GoRoute(
        path: RouteNames.loginPath,
        name: RouteNames.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RouteNames.signupPath,
        name: RouteNames.signup,
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: RouteNames.updatePasswordPath,
        name: RouteNames.updatePassword,
        builder: (context, state) => const UpdatePasswordScreen(),
      ),
      GoRoute(
        path: RouteNames.landingPath,
        name: RouteNames.landing,
        builder: (context, state) =>
            const _PlaceholderScreen(title: 'Fudi Landing'),
      ),
      GoRoute(
        path: '/ui-gallery',
        builder: (context, state) => const UiGalleryScreen(),
      ),

      // ─── Shell para Consumidor (con BottomNav) ───────────────────
      ShellRoute(
        builder: (context, state, child) =>
            FudiScaffold(showBottomNav: true, body: child),
        routes: [
          GoRoute(
            path: RouteNames.homePath,
            name: RouteNames.home,
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: RouteNames.explorePath,
            name: RouteNames.explore,
            builder: (context, state) => const ExploreScreen(),
          ),
          GoRoute(
            path: RouteNames.ordersPath,
            name: RouteNames.orders,
            builder: (context, state) => const OrderHistoryScreen(),
          ),
          GoRoute(
            path: RouteNames.favoritesPath,
            name: RouteNames.favorites,
            builder: (context, state) =>
                const _PlaceholderScreen(title: 'Favoritos'),
          ),
          GoRoute(
            path: RouteNames.profilePath,
            name: RouteNames.profile,
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),

      // ─── Shell para Negocio (con BottomNav) ──────────────────────
      ShellRoute(
        builder: (context, state, child) =>
            FudiScaffold(showBottomNav: true, body: child),
        routes: [
          GoRoute(
            path: RouteNames.businessProductsPath,
            name: RouteNames.businessProducts,
            builder: (context, state) =>
                const _PlaceholderScreen(title: 'Mis Productos'),
          ),
          GoRoute(
            path: RouteNames.businessOrdersPath,
            name: RouteNames.businessOrders,
            builder: (context, state) =>
                const _PlaceholderScreen(title: 'Pedidos Recibidos'),
          ),
          GoRoute(
            path: RouteNames.businessLocationsPath,
            name: RouteNames.businessLocations,
            builder: (context, state) =>
                const _PlaceholderScreen(title: 'Gestión de Locales'),
          ),
          // Sub-rutas de Business (sin tab propio, se acceden desde Gestión)
          GoRoute(
            path: RouteNames.businessStatisticsPath,
            name: RouteNames.businessStatistics,
            builder: (context, state) =>
                const _PlaceholderScreen(title: 'Estadísticas'),
          ),
          GoRoute(
            path: RouteNames.businessPaymentsPath,
            name: RouteNames.businessPayments,
            builder: (context, state) =>
                const _PlaceholderScreen(title: 'Pagos y Payouts'),
          ),
          GoRoute(
            path: RouteNames.businessProfilePath,
            name: RouteNames.businessProfile,
            builder: (context, state) =>
                const _PlaceholderScreen(title: 'Perfil de Negocio'),
          ),
        ],
      ),

      // ─── Rutas de Detalle (sin BottomNav por defecto) ─────────────
      GoRoute(
        path: RouteNames.productPath,
        name: RouteNames.product,
        builder: (context, state) =>
            ProductDetailScreen(id: state.pathParameters['id']!),
      ),
      GoRoute(
        path: RouteNames.checkoutPath,
        name: RouteNames.checkout,
        builder: (context, state) =>
            CheckoutScreen(offerId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: RouteNames.orderDetailPath,
        name: RouteNames.orderDetail,
        builder: (context, state) =>
            OrderDetailScreen(id: state.pathParameters['id']!),
      ),
      GoRoute(
        path: RouteNames.reviewOrderPath,
        name: RouteNames.reviewOrder,
        builder: (context, state) =>
            ReviewOrderScreen(id: state.pathParameters['id']!),
      ),

      // Perfil extendido
      GoRoute(
        path: RouteNames.profileEditPath,
        name: RouteNames.profileEdit,
        builder: (context, state) => const ProfileEditScreen(),
      ),

      // Otras rutas informativas...
      GoRoute(
        path: RouteNames.aboutPath,
        name: RouteNames.about,
        builder: (context, state) =>
            const _PlaceholderScreen(title: 'Sobre Fudi'),
      ),
    ],
  );
}

class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen({required this.title});

  final String title;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 16),
            const Text('🚧 Implementación en curso...'),
          ],
        ),
      ),
    );
  }
}

class _SentryRouteObserver extends RouteObserver<PageRoute<dynamic>> {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    if (route is PageRoute) {
      SentryBreadcrumb.navigation(
        previousRoute?.settings.name ?? '/',
        route.settings.name ?? 'unknown',
      );
    }
  }
}
