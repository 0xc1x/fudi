import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../observability/sentry_breadcrumb.dart';
import 'route_names.dart';

/// Route guard logic for authentication and role-based access.
///
/// GoRouter uses a `redirect` function rather than traditional route guards.
/// This keeps all guard logic centralized, testable, and deterministic.
///
/// Guard priority (from AGENTS.md):
/// 1. Security and permissions
/// 2. Business correctness
/// 3. Operability and observability
///
/// Rules:
/// - Unauthenticated users → can only access public routes
/// - Authenticated users with role `user` → consumer routes
/// - Authenticated users with role `business` → business routes
/// - Authenticated users with role `admin` → admin routes (web-first)
/// - Authenticated users trying to access /login or /signup → redirect home
class RouteGuards {
  RouteGuards._();

  /// Public routes accessible without authentication.
  static const _publicRoutes = {
    RouteNames.loginPath,
    RouteNames.signupPath,
    RouteNames.landingPath,
    RouteNames.forBusinessPath,
    RouteNames.howItWorksPath,
    RouteNames.helpPath,
    RouteNames.aboutPath,
    RouteNames.termsPath,
    RouteNames.privacyPath,
  };

  /// Routes that require the `user` (consumer) role.
  static const _consumerOnlyRoutes = {
    RouteNames.explorePath,
    RouteNames.productPath,
    RouteNames.checkoutPath,
    RouteNames.reviewOrderPath,
    RouteNames.ordersPath,
    RouteNames.orderDetailPath,
    RouteNames.favoritesPath,
    RouteNames.paymentMethodsPath,
    RouteNames.savedAddressesPath,
    RouteNames.profilePath,
    RouteNames.profileEditPath,
    RouteNames.profileNotificationsPath,
    RouteNames.profileSettingsPath,
  };

  /// Routes that require the `business` role.
  /// All start with /business prefix.
  static const _businessOnlyRoutes = {
    RouteNames.businessPath,
    RouteNames.businessOrdersPath,
    RouteNames.businessOrderDetailPath,
    RouteNames.businessProductsPath,
    RouteNames.businessProductDetailPath,
    RouteNames.businessProductEditPath,
    RouteNames.businessStatisticsPath,
    RouteNames.businessPaymentsPath,
    RouteNames.businessPaymentDetailPath,
    RouteNames.businessCouponsPath,
    RouteNames.businessCouponEditPath,
    RouteNames.businessLocationsPath,
    RouteNames.businessLocationDetailPath,
    RouteNames.businessLocationEditPath,
    RouteNames.businessNotificationsPath,
    RouteNames.businessEditPath,
    RouteNames.businessProfilePath,
    RouteNames.businessHelpPath,
  };

  /// Auth guard: redirects unauthenticated users to login.
  ///
  /// - If not authenticated and trying to access a protected route → /login
  /// - If authenticated and trying to access /login or /signup → / (home)
  /// - Otherwise → no redirect (null)
  static String? authGuard(GoRouterState state) {
    final session = Supabase.instanceClient.auth.currentSession;
    final isAuthenticated = session != null;
    final currentPath = state.matchedLocation;

    // Authenticated users should not see login/signup
    if (isAuthenticated && (currentPath == RouteNames.loginPath || currentPath == RouteNames.signupPath)) {
      return RouteNames.homePath;
    }

    // Unauthenticated users can only access public routes
    if (!isAuthenticated && !isPublicRoute(currentPath)) {
      return RouteNames.loginPath;
    }

    return null; // No redirect needed
  }

  /// Role guard: redirects users who lack the required role.
  ///
  /// - Consumer (`user`) trying to access business routes → / (home)
  /// - Business trying to access consumer routes → /business
  /// - Admin can access all routes
  /// - Otherwise → no redirect (null)
  static String? roleGuard(GoRouterState state) {
    final session = Supabase.instanceClient.auth.currentSession;
    if (session == null) return null; // Let authGuard handle this

    final currentPath = state.matchedLocation;

    // Get role from user metadata (set during signup)
    final userMetadata = Supabase.instanceClient.auth.currentUser?.userMetadata;
    final role = userMetadata?['role'] as String? ?? 'user';

    // Admin can access everything
    if (role == 'admin') return null;

    // Consumer trying to access business routes
    if (role == 'user' && isBusinessRoute(currentPath)) {
      return RouteNames.homePath;
    }

    // Business trying to access consumer-only routes
    if (role == 'business' && isConsumerOnlyRoute(currentPath)) {
      return RouteNames.businessPath;
    }

    return null; // No redirect needed
  }

  /// Combined redirect function for GoRouter.
  ///
  /// Applies auth guard first, then role guard. This is the function
  /// you pass to GoRouter's `redirect` parameter.
  ///
  /// Also adds a Sentry navigation breadcrumb for observability.
  static String? combinedGuard(GoRouterState state) {
    // Auth check takes priority
    final authRedirect = authGuard(state);
    if (authRedirect != null) {
      SentryBreadcrumb.navigation(
        state.matchedLocation,
        authRedirect,
        role: 'guest',
      );
      return authRedirect;
    }

    // Then role check
    final roleRedirect = roleGuard(state);
    if (roleRedirect != null) {
      final userMetadata = Supabase.instanceClient.auth.currentUser?.userMetadata;
      final role = userMetadata?['role'] as String? ?? 'user';
      SentryBreadcrumb.navigation(
        state.matchedLocation,
        roleRedirect,
        role: role,
      );
      return roleRedirect;
    }

    return null; // Access granted
  }

  // ─── Route classification helpers ──────────────────────────────

  static bool isPublicRoute(String path) {
    // Exact match for public routes
    if (_publicRoutes.contains(path)) return true;

    // Home is public (shows different content for guest vs user)
    if (path == RouteNames.homePath) return true;

    return false;
  }

  static bool isBusinessRoute(String path) {
    return path.startsWith('/business');
  }

  static bool isConsumerOnlyRoute(String path) {
    for (final consumerPath in _consumerOnlyRoutes) {
      if (pathMatches(consumerPath, path)) {
        return true;
      }
    }
    return false;
  }

  /// Checks if a concrete path matches a route pattern with parameters.
  ///
  /// e.g., pattern '/product/:id' matches path '/product/abc123'
  static bool pathMatches(String pattern, String path) {
    final patternSegments = pattern.split('/');
    final pathSegments = path.split('/');

    if (patternSegments.length != pathSegments.length) return false;

    for (var i = 0; i < patternSegments.length; i++) {
      final patternSeg = patternSegments[i];
      final pathSeg = pathSegments[i];

      // If the pattern segment is a parameter (starts with ':'), it matches anything
      if (patternSeg.startsWith(':')) continue;

      // Otherwise, exact match required
      if (patternSeg != pathSeg) return false;
    }

    return true;
  }
}
