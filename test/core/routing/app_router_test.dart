import 'package:flutter_test/flutter_test.dart';
import 'package:fudi/core/routing/route_names.dart';

void main() {
  group('RouteNames', () {
    test('all path constants start with /', () {
      final paths = [
        RouteNames.loginPath,
        RouteNames.signupPath,
        RouteNames.updatePasswordPath,
        RouteNames.homePath,
        RouteNames.explorePath,
        RouteNames.productPath,
        RouteNames.checkoutPath,
        RouteNames.ordersPath,
        RouteNames.orderDetailPath,
        RouteNames.reviewOrderPath,
        RouteNames.favoritesPath,
        RouteNames.allOffersPath,
        RouteNames.allBusinessesPath,
        RouteNames.profilePath,
        RouteNames.profileEditPath,
        RouteNames.profileNotificationsPath,
        RouteNames.profileSettingsPath,
        RouteNames.paymentMethodsPath,
        RouteNames.savedAddressesPath,
        RouteNames.businessProfileViewPath,
        RouteNames.businessPath,
        RouteNames.businessProductsPath,
        RouteNames.businessOrdersPath,
        RouteNames.businessLocationsPath,
        RouteNames.businessStatisticsPath,
        RouteNames.businessPaymentsPath,
        RouteNames.businessCouponsPath,
        RouteNames.businessNotificationsPath,
        RouteNames.businessProfilePath,
        RouteNames.businessEditPath,
        RouteNames.businessHelpPath,
        RouteNames.landingPath,
        RouteNames.aboutPath,
        RouteNames.helpPath,
        RouteNames.termsPath,
        RouteNames.privacyPath,
        RouteNames.howItWorksPath,
        RouteNames.forBusinessPath,
      ];

      for (final path in paths) {
        expect(path.startsWith('/'), isTrue, reason: '$path should start with /');
      }
    });

    test('route name and path constants are consistent', () {
      expect(RouteNames.login, 'login');
      expect(RouteNames.loginPath, '/login');
      expect(RouteNames.home, 'home');
      expect(RouteNames.homePath, '/');
      expect(RouteNames.product, 'product');
      expect(RouteNames.productPath, '/product/:id');
    });
  });
}
