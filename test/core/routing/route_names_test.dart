import 'package:flutter_test/flutter_test.dart';
import 'package:fudi/core/routing/route_names.dart';

void main() {
  group('RouteNames', () {
    group('auth routes', () {
      test('login name and path are consistent', () {
        expect(RouteNames.login, 'login');
        expect(RouteNames.loginPath, '/login');
      });

      test('signup name and path are consistent', () {
        expect(RouteNames.signup, 'signup');
        expect(RouteNames.signupPath, '/signup');
      });
    });

    group('consumer routes', () {
      test('home path is root', () {
        expect(RouteNames.homePath, '/');
      });

      test('explore path is correct', () {
        expect(RouteNames.explorePath, '/explore');
      });

      test('product path includes parameter', () {
        expect(RouteNames.productPath, '/product/:id');
      });

      test('checkout path includes parameter', () {
        expect(RouteNames.checkoutPath, '/checkout/:id');
      });

      test('order detail path includes parameter', () {
        expect(RouteNames.orderDetailPath, '/orders/:id');
      });

      test('favorites path is correct', () {
        expect(RouteNames.favoritesPath, '/favorites');
      });
    });

    group('profile routes', () {
      test('profile paths are nested correctly', () {
        expect(RouteNames.profilePath, '/profile');
        expect(RouteNames.profileEditPath, '/profile/edit');
        expect(RouteNames.profileNotificationsPath, '/profile/notifications');
        expect(RouteNames.profileSettingsPath, '/profile/settings');
      });
    });

    group('business routes', () {
      test('all business routes start with /business', () {
        expect(RouteNames.businessPath, '/business');
        expect(RouteNames.businessOrdersPath, '/business/orders');
        expect(RouteNames.businessProductsPath, '/business/products');
        expect(RouteNames.businessStatisticsPath, '/business/statistics');
        expect(RouteNames.businessPaymentsPath, '/business/payments');
        expect(RouteNames.businessCouponsPath, '/business/coupons');
        expect(RouteNames.businessLocationsPath, '/business/locations');
        expect(RouteNames.businessNotificationsPath, '/business/notifications');
        expect(RouteNames.businessEditPath, '/business/edit');
        expect(RouteNames.businessProfilePath, '/business/profile');
        expect(RouteNames.businessHelpPath, '/business/help');
      });

      test('business detail routes include parameter', () {
        expect(RouteNames.businessOrderDetailPath, '/business/orders/:id');
        expect(RouteNames.businessProductDetailPath, '/business/products/:id');
        expect(
          RouteNames.businessProductEditPath,
          '/business/products/:id/edit',
        );
        expect(RouteNames.businessPaymentDetailPath, '/business/payments/:id');
        expect(RouteNames.businessCouponEditPath, '/business/coupons/:id/edit');
        expect(
          RouteNames.businessLocationDetailPath,
          '/business/locations/:id',
        );
        expect(
          RouteNames.businessLocationEditPath,
          '/business/locations/:id/edit',
        );
      });
    });

    group('shared routes', () {
      test('informational routes are correct', () {
        expect(RouteNames.forBusinessPath, '/for-business');
        expect(RouteNames.howItWorksPath, '/how-it-works');
        expect(RouteNames.helpPath, '/help');
        expect(RouteNames.aboutPath, '/about');
        expect(RouteNames.termsPath, '/terms');
        expect(RouteNames.privacyPath, '/privacy');
        expect(RouteNames.landingPath, '/landing');
      });
    });

    group('completeness', () {
      test('every name has a corresponding path', () {
        final names = [
          RouteNames.login,
          RouteNames.signup,
          RouteNames.home,
          RouteNames.explore,
          RouteNames.product,
          RouteNames.checkout,
          RouteNames.reviewOrder,
          RouteNames.orders,
          RouteNames.orderDetail,
          RouteNames.favorites,
          RouteNames.paymentMethods,
          RouteNames.savedAddresses,
          RouteNames.profile,
          RouteNames.profileEdit,
          RouteNames.profileNotifications,
          RouteNames.profileSettings,
          RouteNames.business,
          RouteNames.businessOrders,
          RouteNames.businessProducts,
          RouteNames.businessStatistics,
          RouteNames.businessPayments,
          RouteNames.businessCoupons,
          RouteNames.businessLocations,
          RouteNames.businessNotifications,
          RouteNames.businessEdit,
          RouteNames.businessProfile,
          RouteNames.businessHelp,
          RouteNames.forBusiness,
          RouteNames.howItWorks,
          RouteNames.help,
          RouteNames.about,
          RouteNames.terms,
          RouteNames.privacy,
          RouteNames.landing,
        ];

        final paths = [
          RouteNames.loginPath,
          RouteNames.signupPath,
          RouteNames.homePath,
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
          RouteNames.businessPath,
          RouteNames.businessOrdersPath,
          RouteNames.businessProductsPath,
          RouteNames.businessStatisticsPath,
          RouteNames.businessPaymentsPath,
          RouteNames.businessCouponsPath,
          RouteNames.businessLocationsPath,
          RouteNames.businessNotificationsPath,
          RouteNames.businessEditPath,
          RouteNames.businessProfilePath,
          RouteNames.businessHelpPath,
          RouteNames.forBusinessPath,
          RouteNames.howItWorksPath,
          RouteNames.helpPath,
          RouteNames.aboutPath,
          RouteNames.termsPath,
          RouteNames.privacyPath,
          RouteNames.landingPath,
        ];

        expect(names.length, paths.length);
      });
    });
  });
}
