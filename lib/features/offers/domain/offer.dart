import 'package:flutter/material.dart';
import 'offer_category.dart';

class BusinessInfo {
  const BusinessInfo({
    required this.id,
    required this.name,
    required this.type,
    required this.rating,
    required this.address,
    this.businessLocationId,
    this.imageUrl,
    this.latitude,
    this.longitude,
    this.zone,
    this.reviewCount = 0,
  });

  final String id;
  final String name;
  final String type;
  final String? imageUrl;
  final double? latitude;
  final double? longitude;
  final double rating;
  final String address;
  final String? businessLocationId;
  final String? zone;
  final int reviewCount;
}

class BusinessSummary {
  const BusinessSummary({
    required this.id,
    required this.name,
    required this.type,
    required this.address,
    this.imageUrl,
    this.latitude,
    this.longitude,
    this.businessLocationId,
    this.zone,
    this.rating = 0,
    this.reviewCount = 0,
    this.activeDealsCount = 0,
    this.distanceKm,
  });

  final String id;
  final String name;
  final String type;
  final String? imageUrl;
  final double? latitude;
  final double? longitude;
  final double rating;
  final String address;
  final String? businessLocationId;
  final String? zone;
  final int reviewCount;
  final int activeDealsCount;
  final double? distanceKm;
}

class Offer {
  const Offer({
    required this.id,
    required this.businessId,
    required this.businessLocationId,
    required this.business,
    required this.title,
    required this.originalPrice,
    required this.discountedPrice,
    required this.stock,
    required this.initialStock,
    required this.pickupStart,
    required this.pickupEnd,
    required this.isActive,
    this.rating = 0,
    this.reviewCount = 0,
    this.createdAt,
    this.description,
    this.imageUrl,
    this.category,
    this.includes,
    this.allergens,
  });

  final String id;
  final String businessId;
  final String businessLocationId;
  final BusinessInfo business;
  final String title;
  final String? description;
  final String? imageUrl;
  final OfferCategory? category;
  final String? includes;
  final String? allergens;
  final double originalPrice;
  final double discountedPrice;
  final int stock;
  final int initialStock;
  final DateTime pickupStart;
  final DateTime pickupEnd;
  final bool isActive;
  final double rating;
  final int reviewCount;
  final DateTime? createdAt;

  double get discountPercentage =>
      originalPrice > 0 ? ((originalPrice - discountedPrice) / originalPrice * 100) : 0;

  String get categoryLabel => category?.dbValue ?? '';

  TimeOfDay get pickupUntilTimeOfDay =>
      TimeOfDay(hour: pickupEnd.hour, minute: pickupEnd.minute);

  bool get isAvailable =>
      isActive && stock > 0 && DateTime.now().isBefore(pickupEnd);

  bool get isOutOfStock => stock <= 0;

  bool get isExpired => DateTime.now().isAfter(pickupEnd);
}
