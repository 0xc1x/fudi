import 'package:image_picker/image_picker.dart';
import '../../offers/domain/offer.dart';

/// Repository for business-side catalog management.
abstract class BusinessCatalogRepository {
  /// Fetches all offers for a specific business, including inactive ones.
  Future<List<Offer>> getBusinessOffers(String businessId);

  /// Creates a new offer for a business.
  Future<Offer> createOffer(Offer offer, {XFile? imageFile});

  /// Updates an existing offer.
  Future<Offer> updateOffer(Offer offer, {XFile? imageFile});

  /// Deletes an offer (or marks it as deleted).
  Future<void> deleteOffer(String offerId);

  /// Toggles the active status of an offer.
  Future<void> toggleOfferStatus(String offerId, bool isActive);
}
