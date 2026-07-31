import '../../offers/domain/category.dart';

class FavoriteOffer {
  const FavoriteOffer({
    required this.favoriteId,
    required this.offerId,
    required this.businessName,
    required this.address,
    this.zone,
    this.categories = const [],
    required this.title,
    required this.rating,
    required this.discountedPrice,
    required this.originalPrice,
    required this.imageUrl,
  });

  final String favoriteId;
  final String offerId;
  final String businessName;
  final String address;
  final String? zone;
  final List<Category> categories;
  final String title;
  final double rating;
  final double discountedPrice;
  final double originalPrice;
  final String? imageUrl;

  String get categoryLabel => categories.map((c) => c.name).join(', ');

  double get totalSaved => originalPrice - discountedPrice;
}
