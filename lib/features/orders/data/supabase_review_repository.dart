import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/error/data_exceptions.dart';

class SupabaseReviewRepository {
  SupabaseReviewRepository({required SupabaseClient supabaseClient})
    : _supabaseClient = supabaseClient;

  final SupabaseClient _supabaseClient;

  Future<void> submitReview({
    required String orderId,
    required String businessId,
    required int productRating,
    required int businessRating,
    String? comment,
  }) async {
    final userId = _supabaseClient.auth.currentUser?.id;
    if (userId == null) {
      throw const UnknownDataException(
        message: 'Debes iniciar sesión para publicar una reseña',
      );
    }

    final sanitizedComment = comment?.trim();
    final mergedComment = [
      if (sanitizedComment != null && sanitizedComment.isNotEmpty)
        sanitizedComment,
      'Calificación producto: $productRating/5',
      'Calificación negocio: $businessRating/5',
    ].join('\n');

    final averageRating = ((productRating + businessRating) / 2).round().clamp(
      1,
      5,
    );

    await _supabaseClient.from('reviews').upsert({
      'user_id': userId,
      'order_id': orderId,
      'business_id': businessId,
      'rating': averageRating,
      'comment': mergedComment,
    }, onConflict: 'user_id,order_id');
  }
}
