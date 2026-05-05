import 'package:flutter_test/flutter_test.dart';
import 'package:fudi/core/routing/route_guards.dart';

void main() {
  group('RouteGuards', () {
    group('_pathMatches', () {
      test('exact path matches', () {
        expect(RouteGuards.pathMatches('/login', '/login'), true);
        expect(RouteGuards.pathMatches('/login', '/signup'), false);
      });

      test('parameterized path matches concrete path', () {
        expect(RouteGuards.pathMatches('/product/:id', '/product/abc123'), true);
        expect(RouteGuards.pathMatches('/orders/:id', '/orders/xyz'), true);
      });

      test('different segment counts do not match', () {
        expect(RouteGuards.pathMatches('/product', '/product/abc'), false);
      });

      test('business nested routes match', () {
        expect(RouteGuards.pathMatches('/business/products/:id', '/business/products/abc'), true);
        expect(RouteGuards.pathMatches('/business/products/:id/edit', '/business/products/abc/edit'), true);
      });

      test('root path matches itself', () {
        expect(RouteGuards.pathMatches('/', '/'), true);
      });
    });

    group('public routes', () {
      test('login is public', () {
        expect(RouteGuards.isPublicRoute('/login'), true);
      });

      test('signup is public', () {
        expect(RouteGuards.isPublicRoute('/signup'), true);
      });

      test('landing is public', () {
        expect(RouteGuards.isPublicRoute('/landing'), true);
      });

      test('for-business is public', () {
        expect(RouteGuards.isPublicRoute('/for-business'), true);
      });

      test('home is public', () {
        expect(RouteGuards.isPublicRoute('/'), true);
      });

      test('explore is NOT public', () {
        expect(RouteGuards.isPublicRoute('/explore'), false);
      });

      test('profile is NOT public', () {
        expect(RouteGuards.isPublicRoute('/profile'), false);
      });
    });

    group('business routes detection', () {
      test('/business is a business route', () {
        expect(RouteGuards.isBusinessRoute('/business'), true);
      });

      test('/business/orders is a business route', () {
        expect(RouteGuards.isBusinessRoute('/business/orders'), true);
      });

      test('/explore is NOT a business route', () {
        expect(RouteGuards.isBusinessRoute('/explore'), false);
      });
    });
  });
}
