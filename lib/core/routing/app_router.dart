import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../../features/auth/presentation/auth_state_provider.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/signup_screen.dart';
import '../../features/auth/presentation/update_password_screen.dart';
import '../../features/business/presentation/business_profile_screen.dart';
import '../../features/business/presentation/business_edit_screen.dart';
import '../../features/business/presentation/business_management_profile_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/offers/presentation/product_detail_screen.dart';
import '../../features/orders/presentation/checkout_screen.dart';
import '../../features/orders/presentation/review_order_screen.dart';
import '../../features/explore/presentation/explore_screen.dart';
import '../../features/orders/presentation/order_history_screen.dart';
import '../../features/orders/presentation/order_detail_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/profile/presentation/profile_edit_screen.dart';
import '../../features/favorites/presentation/favorites_screen.dart';
import '../../features/profile/presentation/saved_addresses_screen.dart';
import '../../features/profile/presentation/payment_methods_screen.dart';
import '../../features/profile/presentation/notification_settings_screen.dart';
import '../../features/profile/presentation/general_settings_screen.dart';
import '../../features/landing/presentation/landing_screen.dart';
import '../../features/landing/presentation/about_screen.dart';
import '../../features/landing/presentation/help_center_screen.dart';
import '../../features/landing/presentation/terms_screen.dart';
import '../../features/landing/presentation/privacy_screen.dart';
import '../../features/landing/presentation/how_it_works_screen.dart';
import '../../features/landing/presentation/for_business_screen.dart';
import '../../features/business/presentation/dashboard/business_dashboard_screen.dart';
import '../../features/business/presentation/catalog/business_products_screen.dart';
import '../../features/business/presentation/catalog/business_product_form_screen.dart';
import '../../features/business/presentation/catalog/business_product_detail_screen.dart';
import '../../features/business/presentation/orders/business_orders_screen.dart';
import '../../features/business/presentation/orders/business_order_detail_screen.dart';
import '../../features/business/presentation/locations/business_location_create_screen.dart';
import '../../features/business/presentation/locations/business_locations_screen.dart';
import '../../features/business/presentation/locations/business_location_detail_screen.dart';
import '../../features/business/presentation/locations/business_location_edit_screen.dart';
import '../../features/business/presentation/payments/business_payments_screen.dart';
import '../../features/business/presentation/payments/business_payment_detail_screen.dart';
import '../../features/business/presentation/coupons/business_coupons_screen.dart';
import '../../features/business/presentation/coupons/business_coupon_edit_screen.dart';
import '../../features/business/presentation/notifications/business_notifications_screen.dart';
import '../../features/business/presentation/help/business_help_screen.dart';
import '../observability/sentry_breadcrumb.dart';
import '../ui/fudi_scaffold.dart';
import '../ui/ui_gallery_screen.dart';
import 'route_guards.dart';
import 'route_names.dart';

final _hideBottomNavPaths = {
  RouteNames.productPath,
  RouteNames.checkoutPath,
  RouteNames.orderDetailPath,
  RouteNames.reviewOrderPath,
  RouteNames.businessProfileViewPath,
  RouteNames.profileEditPath,
  RouteNames.profileNotificationsPath,
  RouteNames.profileSettingsPath,
  RouteNames.paymentMethodsPath,
  RouteNames.savedAddressesPath,
  RouteNames.helpPath,
  RouteNames.aboutPath,
  RouteNames.termsPath,
  RouteNames.privacyPath,
  RouteNames.howItWorksPath,
  RouteNames.forBusinessPath,
  RouteNames.businessProductDetailPath,
  RouteNames.businessProductCreatePath,
  RouteNames.businessProductEditPath,
  RouteNames.businessLocationCreatePath,
  RouteNames.businessLocationEditPath,
  RouteNames.businessCouponCreatePath,
  RouteNames.businessCouponEditPath,
};

bool _shouldHideBottomNav(GoRouterState state) {
  final location = state.matchedLocation;
  for (final path in _hideBottomNavPaths) {
    if (path.contains('/:id')) {
      final base = path.substring(0, path.indexOf('/:id'));
      if (location == base) continue;
      if (location.startsWith('$base/')) return true;
    } else {
      if (location.startsWith(path)) return true;
    }
  }
  return false;
}

final _hideAppBarPaths = {
  RouteNames.homePath,
  RouteNames.explorePath,
  RouteNames.ordersPath,
  RouteNames.favoritesPath,
  RouteNames.profilePath,
  RouteNames.businessProductsPath,
};

bool _shouldHideAppBar(GoRouterState state) {
  return _hideAppBarPaths.contains(state.matchedLocation);
}

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
        builder: (context, state) => const LandingScreen(),
      ),
      GoRoute(
        path: '/ui-gallery',
        builder: (context, state) => const UiGalleryScreen(),
      ),

      // ─── Shell para Consumidor (con BottomNav condicional) ─────
      ShellRoute(
        builder: (context, state, child) => FudiScaffold(
          showBottomNav: !_shouldHideBottomNav(state),
          showAppBar: !_shouldHideAppBar(state),
          body: child,
        ),
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
            builder: (context, state) => const FavoritesScreen(),
          ),
          GoRoute(
            path: RouteNames.profilePath,
            name: RouteNames.profile,
            builder: (context, state) => const ProfileScreen(),
          ),

          // ─── Rutas de Detalle (dentro del Shell, sin BottomNav) ──
          GoRoute(
            path: RouteNames.businessProfileViewPath,
            name: RouteNames.businessProfileView,
            builder: (context, state) =>
                BusinessProfileScreen(businessId: state.pathParameters['id']!),
          ),
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
          GoRoute(
            path: RouteNames.profileNotificationsPath,
            name: RouteNames.profileNotifications,
            builder: (context, state) => const NotificationSettingsScreen(),
          ),
          GoRoute(
            path: RouteNames.profileSettingsPath,
            name: RouteNames.profileSettings,
            builder: (context, state) => const GeneralSettingsScreen(),
          ),
          GoRoute(
            path: RouteNames.paymentMethodsPath,
            name: RouteNames.paymentMethods,
            builder: (context, state) => const PaymentMethodsScreen(),
          ),
          GoRoute(
            path: RouteNames.savedAddressesPath,
            name: RouteNames.savedAddresses,
            builder: (context, state) => const SavedAddressesScreen(),
          ),

          // Rutas informativas
          GoRoute(
            path: RouteNames.aboutPath,
            name: RouteNames.about,
            builder: (context, state) => const AboutScreen(),
          ),
          GoRoute(
            path: RouteNames.helpPath,
            name: RouteNames.help,
            builder: (context, state) => const HelpCenterScreen(),
          ),
          GoRoute(
            path: RouteNames.termsPath,
            name: RouteNames.terms,
            builder: (context, state) => const TermsScreen(),
          ),
          GoRoute(
            path: RouteNames.privacyPath,
            name: RouteNames.privacy,
            builder: (context, state) => const PrivacyScreen(),
          ),
          GoRoute(
            path: RouteNames.howItWorksPath,
            name: RouteNames.howItWorks,
            builder: (context, state) => const HowItWorksScreen(),
          ),
          GoRoute(
            path: RouteNames.forBusinessPath,
            name: RouteNames.forBusiness,
            builder: (context, state) => const ForBusinessScreen(),
          ),
        ],
      ),

      // ─── Shell para Negocio (con BottomNav) ──────────────────────
      ShellRoute(
        builder: (context, state, child) => FudiScaffold(
          showBottomNav: !_shouldHideBottomNav(state),
          showAppBar: !_shouldHideAppBar(state),
          body: child,
        ),
        routes: [
          GoRoute(
            path: RouteNames.businessProductsPath,
            name: RouteNames.businessProducts,
            builder: (context, state) => const BusinessProductsScreen(),
            routes: [
              GoRoute(
                path: 'create',
                name: RouteNames.businessProductCreate,
                builder: (context, state) => const BusinessProductFormScreen(),
              ),
              GoRoute(
                path: ':id',
                name: RouteNames.businessProductDetail,
                builder: (context, state) => BusinessProductDetailScreen(
                  productId: state.pathParameters['id']!,
                ),
              ),
              GoRoute(
                path: 'edit/:id',
                name: RouteNames.businessProductEdit,
                builder: (context, state) => BusinessProductFormScreen(
                  productId: state.pathParameters['id'],
                ),
              ),
            ],
          ),
          GoRoute(
            path: RouteNames.businessOrdersPath,
            name: RouteNames.businessOrders,
            builder: (context, state) => const BusinessOrdersScreen(),
            routes: [
              GoRoute(
                path: ':id',
                name: RouteNames.businessOrderDetail,
                builder: (context, state) => BusinessOrderDetailScreen(
                  orderId: state.pathParameters['id']!,
                ),
              ),
            ],
          ),
          GoRoute(
            path: RouteNames.businessLocationsPath,
            name: RouteNames.businessLocations,
            builder: (context, state) => const BusinessLocationsScreen(),
            routes: [
              GoRoute(
                path: 'create',
                name: RouteNames.businessLocationCreate,
                builder: (context, state) =>
                    const BusinessLocationCreateScreen(),
              ),
              GoRoute(
                path: ':id',
                name: RouteNames.businessLocationDetail,
                builder: (context, state) => BusinessLocationDetailScreen(
                  locationId: state.pathParameters['id']!,
                ),
              ),
              GoRoute(
                path: ':id/edit',
                name: RouteNames.businessLocationEdit,
                builder: (context, state) => BusinessLocationEditScreen(
                  locationId: state.pathParameters['id'],
                ),
              ),
            ],
          ),
          GoRoute(
            path: RouteNames.businessStatisticsPath,
            name: RouteNames.businessStatistics,
            builder: (context, state) => const BusinessDashboardScreen(),
          ),
          GoRoute(
            path: RouteNames.businessPaymentsPath,
            name: RouteNames.businessPayments,
            builder: (context, state) => const BusinessPaymentsScreen(),
            routes: [
              GoRoute(
                path: ':id',
                name: RouteNames.businessPaymentDetail,
                builder: (context, state) => BusinessPaymentDetailScreen(
                  payoutId: state.pathParameters['id']!,
                ),
              ),
            ],
          ),
          GoRoute(
            path: RouteNames.businessCouponsPath,
            name: RouteNames.businessCoupons,
            builder: (context, state) => const BusinessCouponsScreen(),
            routes: [
              GoRoute(
                path: 'create',
                name: RouteNames.businessCouponCreate,
                builder: (context, state) => const BusinessCouponEditScreen(),
              ),
              GoRoute(
                path: 'edit/:id',
                name: RouteNames.businessCouponEdit,
                builder: (context, state) => BusinessCouponEditScreen(
                  couponId: state.pathParameters['id'],
                ),
              ),
            ],
          ),
          GoRoute(
            path: RouteNames.businessNotificationsPath,
            name: RouteNames.businessNotifications,
            builder: (context, state) => const BusinessNotificationsScreen(),
          ),
          GoRoute(
            path: RouteNames.businessProfilePath,
            name: RouteNames.businessProfile,
            builder: (context, state) =>
                const BusinessManagementProfileScreen(),
          ),
          GoRoute(
            path: RouteNames.businessEditPath,
            name: RouteNames.businessEdit,
            builder: (context, state) => const BusinessEditScreen(),
          ),
          GoRoute(
            path: RouteNames.businessHelpPath,
            name: RouteNames.businessHelp,
            builder: (context, state) => const BusinessHelpScreen(),
          ),
        ],
      ),
    ],
  );
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
