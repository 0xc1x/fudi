class FavoriteOffer {
  const FavoriteOffer({
    required this.favoriteId,
    required this.offerId,
    required this.businessName,
    required this.address,
    required this.category,
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
  final String? category;
  final String title;
  final double rating;
  final double discountedPrice;
  final double originalPrice;
  final String? imageUrl;

  double get totalSaved => originalPrice - discountedPrice;
}
