import '../../offers/domain/offer.dart';

/// Domain model for a business profile.
///
/// Represents the full business data shown on the Business Profile screen.
/// This is a richer model than [BusinessInfo] (used in offer cards) because
/// the profile screen needs all contact details, description, hours, etc.
class BusinessProfile {
  const BusinessProfile({
    required this.id,
    required this.name,
    required this.type,
    required this.address,
    required this.rating,
    this.imageUrl,
    this.coverImageUrl,
    this.description,
    this.phone,
    this.email,
    this.website,
    this.latitude,
    this.longitude,
    this.reviewCount = 0,
    this.totalRescued = 0,
    this.memberSince,
    this.hours = const [],
    this.reviews = const [],
  });

  final String id;
  final String name;
  final String type;
  final String address;
  final double rating;

  final String? imageUrl;
  final String? coverImageUrl;
  final String? description;
  final String? phone;
  final String? email;
  final String? website;
  final double? latitude;
  final double? longitude;

  final int reviewCount;
  final int totalRescued;
  final String? memberSince;
  final List<BusinessHours> hours;
  final List<BusinessReview> reviews;

  /// Helper to convert to [BusinessInfo] (lighter version for offer cards).
  BusinessInfo toInfo() {
    return BusinessInfo(
      id: id,
      name: name,
      type: type,
      address: address,
      imageUrl: imageUrl,
      latitude: latitude,
      longitude: longitude,
      rating: rating,
    );
  }
}

/// A single day's opening hours for a business.
class BusinessHours {
  const BusinessHours({
    required this.day,
    required this.hours,
  });

  /// Display label, e.g. "Lunes - Viernes"
  final String day;

  /// Display label, e.g. "6:00 - 21:00" or "Cerrado"
  final String hours;
}

/// A review left by a user for a business.
class BusinessReview {
  const BusinessReview({
    required this.id,
    required this.userName,
    required this.rating,
    required this.date,
    this.comment,
    this.productName,
  });

  final String id;
  final String userName;
  final int rating;
  final DateTime date;
  final String? comment;
  final String? productName;
}
