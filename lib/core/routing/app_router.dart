import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../observability/sentry_breadcrumb.dart';
import 'route_guards.dart';
import 'route_names.dart';

/// Application router configuration with all 40+ routes and guards.
///
/// Route structure follows docs/ai/IMPLEMENTATION_PLAN.md Phase 1.5:
/// - Auth routes: /login, /signup
/// - Consumer routes: /, /explore, /product/:id, /checkout/:id, etc.
/// - Profile routes: /profile, /profile/edit, etc.
/// - Business routes: /business/* (all under /business prefix)
/// - Shared routes: /for-business, /how-it-works, /help, etc.
///
/// Guards (from route_guards.dart):
/// 1. Auth guard: unauthenticated → /login
/// 2. Role guard: wrong role → appropriate home
///
/// All screens use placeholder widgets until their real implementations
/// are built in Phases 3–6.
GoRouter createAppRouter() {
  return GoRouter(
    initialLocation: RouteNames.homePath,
    debugLogDiagnostics: true,
    redirect: RouteGuards.combinedGuard,
    observers: [
      _SentryRouteObserver(),
    ],
    routes: [
      // ─── Auth ────────────────────────────────────────────────────
      GoRoute(
        path: RouteNames.loginPath,
        name: RouteNames.login,
        builder: (context, state) => const _PlaceholderScreen(title: 'Login'),
      ),
      GoRoute(
        path: RouteNames.signupPath,
        name: RouteNames.signup,
        builder: (context, state) => const _PlaceholderScreen(title: 'Signup'),
      ),

      // ─── Consumer ────────────────────────────────────────────────
      GoRoute(
        path: RouteNames.homePath,
        name: RouteNames.home,
        builder: (context, state) => const _PlaceholderScreen(title: 'Fudi Home'),
      ),
      GoRoute(
        path: RouteNames.explorePath,
        name: RouteNames.explore,
        builder: (context, state) => const _PlaceholderScreen(title: 'Explore'),
      ),
      GoRoute(
        path: RouteNames.productPath,
        name: RouteNames.product,
        builder: (context, state) => _PlaceholderScreen(
          title: 'Product Detail',
          subtitle: 'ID: ${state.pathParameters['id']}',
        ),
      ),
      GoRoute(
        path: RouteNames.checkoutPath,
        name: RouteNames.checkout,
        builder: (context, state) => _PlaceholderScreen(
          title: 'Checkout',
          subtitle: 'ID: ${state.pathParameters['id']}',
        ),
      ),
      GoRoute(
        path: RouteNames.reviewOrderPath,
        name: RouteNames.reviewOrder,
        builder: (context, state) => _PlaceholderScreen(
          title: 'Review Order',
          subtitle: 'ID: ${state.pathParameters['id']}',
        ),
      ),
      GoRoute(
        path: RouteNames.ordersPath,
        name: RouteNames.orders,
        builder: (context, state) => const _PlaceholderScreen(title: 'My Orders'),
      ),
      GoRoute(
        path: RouteNames.orderDetailPath,
        name: RouteNames.orderDetail,
        builder: (context, state) => _PlaceholderScreen(
          title: 'Order Detail',
          subtitle: 'ID: ${state.pathParameters['id']}',
        ),
      ),
      GoRoute(
        path: RouteNames.favoritesPath,
        name: RouteNames.favorites,
        builder: (context, state) => const _PlaceholderScreen(title: 'Favorites'),
      ),
      GoRoute(
        path: RouteNames.paymentMethodsPath,
        name: RouteNames.paymentMethods,
        builder: (context, state) => const _PlaceholderScreen(title: 'Payment Methods'),
      ),
      GoRoute(
        path: RouteNames.savedAddressesPath,
        name: RouteNames.savedAddresses,
        builder: (context, state) => const _PlaceholderScreen(title: 'Saved Addresses'),
      ),

      // ─── Profile ─────────────────────────────────────────────────
      GoRoute(
        path: RouteNames.profilePath,
        name: RouteNames.profile,
        builder: (context, state) => const _PlaceholderScreen(title: 'Profile'),
      ),
      GoRoute(
        path: RouteNames.profileEditPath,
        name: RouteNames.profileEdit,
        builder: (context, state) => const _PlaceholderScreen(title: 'Edit Profile'),
      ),
      GoRoute(
        path: RouteNames.profileNotificationsPath,
        name: RouteNames.profileNotifications,
        builder: (context, state) => const _PlaceholderScreen(title: 'Notification Settings'),
      ),
      GoRoute(
        path: RouteNames.profileSettingsPath,
        name: RouteNames.profileSettings,
        builder: (context, state) => const _PlaceholderScreen(title: 'General Settings'),
      ),

      // ─── Business ────────────────────────────────────────────────
      GoRoute(
        path: RouteNames.businessPath,
        name: RouteNames.business,
        builder: (context, state) => const _PlaceholderScreen(title: 'Business Dashboard'),
      ),
      GoRoute(
        path: RouteNames.businessOrdersPath,
        name: RouteNames.businessOrders,
        builder: (context, state) => const _PlaceholderScreen(title: 'Business Orders'),
      ),
      GoRoute(
        path: RouteNames.businessOrderDetailPath,
        name: RouteNames.businessOrderDetail,
        builder: (context, state) => _PlaceholderScreen(
          title: 'Business Order Detail',
          subtitle: 'ID: ${state.pathParameters['id']}',
        ),
      ),
      GoRoute(
        path: RouteNames.businessProductsPath,
        name: RouteNames.businessProducts,
        builder: (context, state) => const _PlaceholderScreen(title: 'Business Products'),
      ),
      GoRoute(
        path: RouteNames.businessProductDetailPath,
        name: RouteNames.businessProductDetail,
        builder: (context, state) => _PlaceholderScreen(
          title: 'Business Product Detail',
          subtitle: 'ID: ${state.pathParameters['id']}',
        ),
      ),
      GoRoute(
        path: RouteNames.businessProductEditPath,
        name: RouteNames.businessProductEdit,
        builder: (context, state) => _PlaceholderScreen(
          title: 'Edit Product',
          subtitle: 'ID: ${state.pathParameters['id']}',
        ),
      ),
      GoRoute(
        path: RouteNames.businessStatisticsPath,
        name: RouteNames.businessStatistics,
        builder: (context, state) => const _PlaceholderScreen(title: 'Business Statistics'),
      ),
      GoRoute(
        path: RouteNames.businessPaymentsPath,
        name: RouteNames.businessPayments,
        builder: (context, state) => const _PlaceholderScreen(title: 'Business Payments'),
      ),
      GoRoute(
        path: RouteNames.businessPaymentDetailPath,
        name: RouteNames.businessPaymentDetail,
        builder: (context, state) => _PlaceholderScreen(
          title: 'Payment Detail',
          subtitle: 'ID: ${state.pathParameters['id']}',
        ),
      ),
      GoRoute(
        path: RouteNames.businessCouponsPath,
        name: RouteNames.businessCoupons,
        builder: (context, state) => const _PlaceholderScreen(title: 'Business Coupons'),
      ),
      GoRoute(
        path: RouteNames.businessCouponEditPath,
        name: RouteNames.businessCouponEdit,
        builder: (context, state) => _PlaceholderScreen(
          title: 'Edit Coupon',
          subtitle: 'ID: ${state.pathParameters['id']}',
        ),
      ),
      GoRoute(
        path: RouteNames.businessLocationsPath,
        name: RouteNames.businessLocations,
        builder: (context, state) => const _PlaceholderScreen(title: 'Business Locations'),
      ),
      GoRoute(
        path: RouteNames.businessLocationDetailPath,
        name: RouteNames.businessLocationDetail,
        builder: (context, state) => _PlaceholderScreen(
          title: 'Location Detail',
          subtitle: 'ID: ${state.pathParameters['id']}',
        ),
      ),
      GoRoute(
        path: RouteNames.businessLocationEditPath,
        name: RouteNames.businessLocationEdit,
        builder: (context, state) => _PlaceholderScreen(
          title: 'Edit Location',
          subtitle: 'ID: ${state.pathParameters['id']}',
        ),
      ),
      GoRoute(
        path: RouteNames.businessNotificationsPath,
        name: RouteNames.businessNotifications,
        builder: (context, state) => const _PlaceholderScreen(title: 'Business Notifications'),
      ),
      GoRoute(
        path: RouteNames.businessEditPath,
        name: RouteNames.businessEdit,
        builder: (context, state) => const _PlaceholderScreen(title: 'Edit Business'),
      ),
      GoRoute(
        path: RouteNames.businessProfilePath,
        name: RouteNames.businessProfile,
        builder: (context, state) => const _PlaceholderScreen(title: 'Business Profile'),
      ),
      GoRoute(
        path: RouteNames.businessHelpPath,
        name: RouteNames.businessHelp,
        builder: (context, state) => const _PlaceholderScreen(title: 'Business Help'),
      ),

      // ─── Shared / Informational ──────────────────────────────────
      GoRoute(
        path: RouteNames.forBusinessPath,
        name: RouteNames.forBusiness,
        builder: (context, state) => const _PlaceholderScreen(title: 'For Business'),
      ),
      GoRoute(
        path: RouteNames.howItWorksPath,
        name: RouteNames.howItWorks,
        builder: (context, state) => const _PlaceholderScreen(title: 'How It Works'),
      ),
      GoRoute(
        path: RouteNames.helpPath,
        name: RouteNames.help,
        builder: (context, state) => const _PlaceholderScreen(title: 'Help Center'),
      ),
      GoRoute(
        path: RouteNames.aboutPath,
        name: RouteNames.about,
        builder: (context, state) => const _PlaceholderScreen(title: 'About Fudi'),
      ),
      GoRoute(
        path: RouteNames.termsPath,
        name: RouteNames.terms,
        builder: (context, state) => const _PlaceholderScreen(title: 'Terms of Service'),
      ),
      GoRoute(
        path: RouteNames.privacyPath,
        name: RouteNames.privacy,
        builder: (context, state) => const _PlaceholderScreen(title: 'Privacy Policy'),
      ),
      GoRoute(
        path: RouteNames.landingPath,
        name: RouteNames.landing,
        builder: (context, state) => const _PlaceholderScreen(title: 'Fudi Landing'),
      ),
    ],
  );
}

/// Temporary placeholder screen until real feature screens are built.
///
/// Each placeholder shows the screen name and optional subtitle (e.g. route
/// parameters). These will be replaced by real implementations in Phases 3–6.
class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen({required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            const SizedBox(height: 16),
            Text(
              '🚧 Placeholder — implement in Phase 3–6',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom route observer that adds Sentry breadcrumbs for navigation.
///
/// This complements the SentryNavigatorObserver by also adding
/// structured breadcrumbs via our SentryBreadcrumb utility, which
/// includes the 'navigation' category and from/to data.
class _SentryRouteObserver extends RouteObserver<PageRoute<dynamic>> {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    if (route is PageRoute) {
      SentryBreadcrumb.navigation(
        previousRoute?.settings.name ?? '/',
        route.settings.name ?? route.settings.path,
      );
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    if (route is PageRoute && previousRoute is PageRoute) {
      SentryBreadcrumb.navigation(
        route.settings.name ?? '/',
        previousRoute.settings.name ?? previousRoute.settings.path,
      );
    }
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute is PageRoute) {
      SentryBreadcrumb.navigation(
        oldRoute?.settings.name ?? '/',
        newRoute.settings.name ?? newRoute.settings.path,
      );
    }
  }
}
