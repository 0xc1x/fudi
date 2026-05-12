import 'package:meta/meta.dart';

/// Typed model for user properties sent to analytics trackers.
///
/// These properties identify and segment users across Firebase Analytics
/// and Mixpanel. Only non-PII data is allowed — no names, emails, or
/// phone numbers.
///
/// See `docs/ai/ANALYTICS.md` → User Properties for the canonical list.
@immutable
class UserProperties {
  final String? userId;
  final String? role;
  final String? city;
  final DateTime? signupDate;
  final int? totalOrders;
  final double? totalSaved;
  final List<String>? favoriteCategories;
  final int? notificationRadiusKm;
  final bool? isBusiness;
  final String? businessId;

  const UserProperties({
    this.userId,
    this.role,
    this.city,
    this.signupDate,
    this.totalOrders,
    this.totalSaved,
    this.favoriteCategories,
    this.notificationRadiusKm,
    this.isBusiness,
    this.businessId,
  });

  /// Converts to a flat map suitable for Firebase Analytics `setUserProperty`
  /// and Mixpanel `getPeople().set()`.
  ///
  /// Null values are omitted — trackers only receive what's explicitly set.
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};

    if (userId != null) map['user_id'] = userId!;
    if (role != null) map['role'] = role!;
    if (city != null) map['city'] = city!;
    if (signupDate != null) map['signup_date'] = signupDate!.toIso8601String();
    if (totalOrders != null) map['total_orders'] = totalOrders!;
    if (totalSaved != null) map['total_saved'] = totalSaved!;
    if (favoriteCategories != null) {
      map['favorite_categories'] = favoriteCategories!;
    }
    if (notificationRadiusKm != null) {
      map['notification_radius_km'] = notificationRadiusKm!;
    }
    if (isBusiness != null) map['is_business'] = isBusiness!;
    if (businessId != null) map['business_id'] = businessId!;

    return map;
  }

  /// Creates a copy with optionally overridden fields.
  UserProperties copyWith({
    String? userId,
    String? role,
    String? city,
    DateTime? signupDate,
    int? totalOrders,
    double? totalSaved,
    List<String>? favoriteCategories,
    int? notificationRadiusKm,
    bool? isBusiness,
    String? businessId,
  }) {
    return UserProperties(
      userId: userId ?? this.userId,
      role: role ?? this.role,
      city: city ?? this.city,
      signupDate: signupDate ?? this.signupDate,
      totalOrders: totalOrders ?? this.totalOrders,
      totalSaved: totalSaved ?? this.totalSaved,
      favoriteCategories: favoriteCategories ?? this.favoriteCategories,
      notificationRadiusKm: notificationRadiusKm ?? this.notificationRadiusKm,
      isBusiness: isBusiness ?? this.isBusiness,
      businessId: businessId ?? this.businessId,
    );
  }

  @override
  String toString() => 'UserProperties(${toMap()})';
}
