enum UserRole {
  user,
  business,
  admin;

  static UserRole fromString(String? value) {
    switch (value) {
      case 'business':
        return UserRole.business;
      case 'admin':
        return UserRole.admin;
      case 'user':
      default:
        return UserRole.user;
    }
  }
}

class UserProfile {
  const UserProfile({
    required this.id,
    required this.email,
    required this.role,
    this.fullName,
    this.avatarUrl,
    this.phone,
    this.city,
    this.analyticsConsentGranted = false,
  });

  final String id;
  final String email;
  final UserRole role;
  final String? fullName;
  final String? avatarUrl;
  final String? phone;
  final String? city;
  final bool analyticsConsentGranted;

  bool get isBusiness => role == UserRole.business;
  bool get isAdmin => role == UserRole.admin;
}
