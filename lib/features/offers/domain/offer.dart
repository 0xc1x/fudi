import 'package:flutter/material.dart';

class BusinessInfo {
  const BusinessInfo({
    required this.id,
    required this.name,
    required this.type,
    required this.rating,
    required this.address,
    this.imageUrl,
    this.latitude,
    this.longitude,
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
  final int reviewCount;
}

class Offer {
  const Offer({
    required this.id,
    required this.businessId,
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
    this.description,
    this.imageUrl,
    this.category,
    this.includes,
    this.allergens,
  });

  final String id;
  final String businessId;
  final BusinessInfo business;
  final String title;
  final String? description;
  final String? imageUrl;
  final String? category;
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

  double get discountPercentage =>
      ((originalPrice - discountedPrice) / originalPrice * 100);

  TimeOfDay get pickupUntilTimeOfDay =>
      TimeOfDay(hour: pickupEnd.hour, minute: pickupEnd.minute);

  bool get isExpired => DateTime.now().isAfter(pickupEnd);

  bool get isOutOfStock => stock <= 0;

  bool get isAvailable => isActive && !isExpired && !isOutOfStock;

  String get categoryLabel {
    if (category == null) return '';
    return category![0].toUpperCase() + category!.substring(1);
  }
}
