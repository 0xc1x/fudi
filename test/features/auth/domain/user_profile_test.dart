import 'package:flutter_test/flutter_test.dart';
import 'package:fudi/features/auth/domain/user_profile.dart';

void main() {
  group('UserRole.fromString', () {
    test('mapea roles validos', () {
      expect(UserRole.fromString('user'), UserRole.user);
      expect(UserRole.fromString('business'), UserRole.business);
      expect(UserRole.fromString('admin'), UserRole.admin);
    });

    test('desconocido o null cae a user', () {
      expect(UserRole.fromString(null), UserRole.user);
      expect(UserRole.fromString('superadmin'), UserRole.user);
      expect(UserRole.fromString(''), UserRole.user);
    });
  });

  group('UserProfile', () {
    const profile = UserProfile(
      id: 'u-1',
      email: 'a@fudi.com',
      role: UserRole.business,
      fullName: 'Restaurante',
      analyticsConsentGranted: true,
    );

    test('getters por rol', () {
      expect(profile.isBusiness, isTrue);
      expect(profile.isAdmin, isFalse);
      const admin = UserProfile(id: 'u-2', email: 'a@fudi.com', role: UserRole.admin);
      expect(admin.isAdmin, isTrue);
      expect(admin.isBusiness, isFalse);
      const normal =
          UserProfile(id: 'u-3', email: 'a@fudi.com', role: UserRole.user);
      expect(normal.isBusiness, isFalse);
      expect(normal.isAdmin, isFalse);
    });

    test('valores por defecto', () {
      const p = UserProfile(id: 'u-4', email: 'a@fudi.com', role: UserRole.user);
      expect(p.analyticsConsentGranted, isFalse);
      expect(p.fullName, isNull);
      expect(p.avatarUrl, isNull);
      expect(p.phone, isNull);
      expect(p.city, isNull);
    });
  });
}