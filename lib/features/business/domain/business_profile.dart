import '../../offers/domain/offer.dart';

class BusinessProfile {
  const BusinessProfile({
    required this.id,
    required this.name,
    required this.type,
    required this.rating,
    this.imageUrl,
    this.coverImageUrl,
    this.description,
    this.phone,
    this.email,
    this.website,
    this.businessLocationId,
    this.address,
    this.latitude,
    this.longitude,
    this.zone,
    this.reviewCount = 0,
    this.totalRescued = 0,
    this.memberSince,
    this.hours = const [],
    this.reviews = const [],
  });

  final String id;
  final String name;
  final String type;
  final double rating;

  final String? imageUrl;
  final String? coverImageUrl;
  final String? description;
  final String? phone;
  final String? email;
  final String? website;

  final String? businessLocationId;
  final String? address;
  final double? latitude;
  final double? longitude;
  final String? zone;

  final int reviewCount;
  final int totalRescued;
  final String? memberSince;
  final List<BusinessHours> hours;
  final List<BusinessReview> reviews;

  BusinessInfo toInfo() {
    return BusinessInfo(
      id: id,
      name: name,
      type: type,
      address: address ?? '',
      imageUrl: imageUrl,
      rating: rating,
      latitude: latitude,
      longitude: longitude,
    );
  }
}

class BusinessHours {
  const BusinessHours({required this.day, required this.hours});

  final String day;
  final String hours;
}

class BusinessReview {
  const BusinessReview({
    required this.id,
    required this.userName,
    required this.productRating,
    required this.businessRating,
    required this.date,
    this.comment,
    this.productName,
  });

  final String id;
  final String userName;
  final int productRating;
  final int businessRating;
  final DateTime date;
  final String? comment;
  final String? productName;
}
