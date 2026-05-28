/// Route name constants for type-safe navigation.
///
/// Use these instead of raw path strings to prevent typos and
/// enable IDE refactoring support. Every route in the app MUST
/// have a corresponding constant here.
///
/// Usage:
/// ```dart
/// context.goNamed(RouteNames.home);
/// context.go(RouteNames.homePath);
/// ```
///
/// Naming convention:
/// - Constants use camelCase
/// - Path constants use the exact GoRouter path
/// - Grouped by feature/role for discoverability
class RouteNames {
  RouteNames._();

  // ─── Auth ───────────────────────────────────────────────────────

  static const login = 'login';
  static const loginPath = '/login';

  static const signup = 'signup';
  static const signupPath = '/signup';

  static const updatePassword = 'update-password';
  static const updatePasswordPath = '/update-password';

  // ─── Consumer ───────────────────────────────────────────────────

  static const home = 'home';
  static const homePath = '/';

  static const explore = 'explore';
  static const explorePath = '/explore';

  static const product = 'product';
  static const productPath = '/product/:id';

  static const checkout = 'checkout';
  static const checkoutPath = '/checkout/:id';

  static const reviewOrder = 'review-order';
  static const reviewOrderPath = '/review-order/:id';

  static const orders = 'orders';
  static const ordersPath = '/orders';

  static const orderDetail = 'order-detail';
  static const orderDetailPath = '/orders/:id';

  static const favorites = 'favorites';
  static const favoritesPath = '/favorites';

  static const paymentMethods = 'payment-methods';
  static const paymentMethodsPath = '/payment-methods';

  static const savedAddresses = 'saved-addresses';
  static const savedAddressesPath = '/saved-addresses';

  // ─── Profile ────────────────────────────────────────────────────

  static const profile = 'profile';
  static const profilePath = '/profile';

  static const profileEdit = 'profile-edit';
  static const profileEditPath = '/profile/edit';

  static const profileNotifications = 'profile-notifications';
  static const profileNotificationsPath = '/profile/notifications';

  static const profileSettings = 'profile-settings';
  static const profileSettingsPath = '/profile/settings';

  // ─── Business ───────────────────────────────────────────────────

  static const business = 'business';
  static const businessPath = '/business';

  static const businessProfileView = 'business-profile-view';
  static const businessProfileViewPath = '/business-profile/:id';

  static const businessOrders = 'business-orders';
  static const businessOrdersPath = '/business/orders';

  static const businessOrderDetail = 'business-order-detail';
  static const businessOrderDetailPath = '/business/orders/:id';

  static const businessProducts = 'business-products';
  static const businessProductsPath = '/business/products';

  static const businessProductCreate = 'business-product-create';
  static const businessProductCreatePath = '/business/products/create';

  static const businessProductDetail = 'business-product-detail';
  static const businessProductDetailPath = '/business/products/:id';

  static const businessProductEdit = 'business-product-edit';
  static const businessProductEditPath = '/business/products/:id/edit';

  static const businessStatistics = 'business-statistics';
  static const businessStatisticsPath = '/business/statistics';

  static const businessPayments = 'business-payments';
  static const businessPaymentsPath = '/business/payments';

  static const businessPaymentDetail = 'business-payment-detail';
  static const businessPaymentDetailPath = '/business/payments/:id';

  static const businessCoupons = 'business-coupons';
  static const businessCouponsPath = '/business/coupons';

  static const businessCouponEdit = 'business-coupon-edit';
  static const businessCouponEditPath = '/business/coupons/:id/edit';

  static const businessCouponCreate = 'business-coupon-create';
  static const businessCouponCreatePath = '/business/coupons/create';

  static const businessLocations = 'business-locations';
  static const businessLocationsPath = '/business/locations';

  static const businessLocationCreate = 'business-location-create';
  static const businessLocationCreatePath = '/business/locations/create';

  static const businessLocationDetail = 'business-location-detail';
  static const businessLocationDetailPath = '/business/locations/:id';

  static const businessLocationEdit = 'business-location-edit';
  static const businessLocationEditPath = '/business/locations/:id/edit';

  static const businessNotifications = 'business-notifications';
  static const businessNotificationsPath = '/business/notifications';

  static const businessEdit = 'business-edit';
  static const businessEditPath = '/business/edit';

  static const businessProfile = 'business-profile';
  static const businessProfilePath = '/business/profile';

  static const businessHelp = 'business-help';
  static const businessHelpPath = '/business/help';

  // ─── Shared / Informational ─────────────────────────────────────

  static const forBusiness = 'for-business';
  static const forBusinessPath = '/for-business';

  static const howItWorks = 'how-it-works';
  static const howItWorksPath = '/how-it-works';

  static const help = 'help';
  static const helpPath = '/help';

  static const about = 'about';
  static const aboutPath = '/about';

  static const terms = 'terms';
  static const termsPath = '/terms';

  static const privacy = 'privacy';
  static const privacyPath = '/privacy';

  static const landing = 'landing';
  static const landingPath = '/landing';
}
