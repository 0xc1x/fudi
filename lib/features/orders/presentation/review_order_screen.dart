import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/user_friendly_message.dart';
import '../../../core/ui/atoms/icons/fudi_icons.dart';
import '../../../core/ui/fudi_bottom_action_bar.dart';
import '../../../core/ui/fudi_colors.dart';
import '../../../core/ui/fudi_info_banner.dart';
import '../../../core/ui/fudi_pressable_scale.dart';
import '../../../core/ui/fudi_spacing.dart';
import '../../../core/ui/fudi_star_rating.dart';
import '../../../core/ui/fudi_sticky_page_header.dart';
import '../../../core/ui/fudi_surface_card.dart';
import '../../../core/ui/fudi_typography.dart';
import '../domain/order_model.dart';
import '../presentation/order_providers.dart';

class ReviewOrderScreen extends ConsumerStatefulWidget {
  const ReviewOrderScreen({required this.id, super.key});

  final String id;

  @override
  ConsumerState<ReviewOrderScreen> createState() => _ReviewOrderScreenState();
}

class _ReviewOrderScreenState extends ConsumerState<ReviewOrderScreen> {
  final _commentController = TextEditingController();
  int _productRating = 0;
  int _businessRating = 0;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orderAsync = ref.watch(orderDetailProvider(widget.id));

    return orderAsync.when(
      data: (order) => _buildContent(context, order),
      loading: () => Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: const Center(
          child: CircularProgressIndicator(color: FudiColors.primary),
        ),
      ),
      error: (error, _) => Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: const FudiStickyPageHeader(title: 'Calificar experiencia'),
        body: const Center(
          child: Text(
            'Hubo un problema al cargar el formulario',
            style: FudiTypography.bodyMedium,
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, OrderModel order) {
    ref.listen(submitReviewProvider, (previous, next) {
      next.whenOrNull(
        data: (_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Reseña publicada exitosamente'),
              behavior: SnackBarBehavior.floating,
              backgroundColor: FudiColors.ecoGreen,
            ),
          );
          Navigator.of(context).pop();
        },
        error: (error, _) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(userFriendlyMessage(error)),
              backgroundColor: FudiColors.destructive,
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      );
    });

    final submitReview = ref.watch(submitReviewProvider);
    final isSubmitting = submitReview.isLoading;
    final canSubmit =
        _productRating > 0 && _businessRating > 0 && !isSubmitting;

    return Scaffold(
      backgroundColor: FudiColors.background,
      appBar: const FudiStickyPageHeader(title: 'Calificar pedido'),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(FudiSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _OrderSummaryCard(order: order),
              const SizedBox(height: FudiSpacing.md),
              _RatingSection(
                title: '¿Cómo estuvo el pack de productos?',
                subtitle: _ratingLabel(
                  rating: _productRating,
                  empty: 'Toca las estrellas para calificar',
                ),
                value: _productRating,
                onChanged: (value) => setState(() => _productRating = value),
              ),
              const SizedBox(height: FudiSpacing.md),
              _RatingSection(
                title: '¿Cómo fue la atención en el negocio?',
                subtitle: _ratingLabel(
                  rating: _businessRating,
                  empty: 'Califica la velocidad y el trato',
                ),
                value: _businessRating,
                onChanged: (value) => setState(() => _businessRating = value),
              ),
              const SizedBox(height: FudiSpacing.md),
              FudiSurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Déjanos tus comentarios (Opcional)',
                      style: FudiTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: FudiSpacing.sm),
                    TextField(
                      controller: _commentController,
                      maxLength: 500,
                      maxLines: 4,
                      style: FudiTypography.bodyMedium,
                      decoration: InputDecoration(
                        hintText:
                            '¿Qué fue lo que más te gustó? ¿Algún aspecto a mejorar?',
                        hintStyle: FudiTypography.bodyMedium.copyWith(
                          color: FudiColors.mutedForeground.withValues(
                            alpha: 0.6,
                          ),
                        ),
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surface,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: FudiColors.border,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: FudiColors.primary,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: FudiSpacing.md),
              FudiSurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Evidencias fotográficas',
                      style: FudiTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: FudiSpacing.sm),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: FudiSpacing.xl,
                        horizontal: FudiSpacing.md,
                      ),
                      decoration: BoxDecoration(
                        color: FudiColors.background,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
          color: FudiColors.border,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.camera_alt_outlined,
                            size: 32,
                            color: FudiColors.mutedForeground.withValues(
                              alpha: 0.7,
                            ),
                          ),
                          const SizedBox(height: FudiSpacing.xs),
                          Text(
                            'Adjuntar fotos próximamente',
                            style: FudiTypography.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                              color: FudiColors.mutedForeground,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: FudiSpacing.md),
              const FudiInfoBanner(
                title: 'Reseñas transparentes',
                message:
                    'Sé lo más honesto posible. Tu opinión es valiosa para la comunidad de rescate de alimentos.',
                icon: FudiIcons.star,
                backgroundColor: FudiColors.infoSurface,
                borderColor: FudiColors.infoSurfaceBorder,
                foregroundColor: FudiColors.infoForeground,
              ),
              const SizedBox(height: 140),
            ],
          ),
        ),
      ),
      bottomNavigationBar: FudiBottomActionBar(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              child: FudiPressableScale(
                onTap: !canSubmit
                    ? null
                    : () => ref
                          .read(submitReviewProvider.notifier)
                          .submit(
                            orderId: order.id,
                            businessId: order.businessId,
                            productRating: _productRating,
                            businessRating: _businessRating,
                            comment: _commentController.text,
                          ),
                child: Container(
                  width: double.infinity,
                  height: 52,
                  decoration: BoxDecoration(
                    color: canSubmit ? FudiColors.primary : FudiColors.muted,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: FudiColors.primaryForeground,
                            ),
                          )
                        : Text(
                            'Publicar reseña',
                            style: FudiTypography.labelMedium.copyWith(
                              color: FudiColors.primaryForeground,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ),
            ),
            if (_productRating == 0 || _businessRating == 0) ...[
              const SizedBox(height: FudiSpacing.sm),
              Text(
                'Por favor selecciona las estrellas obligatorias',
                style: FudiTypography.bodySmall.copyWith(
                  color: FudiColors.destructive,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _ratingLabel({required int rating, required String empty}) {
    return switch (rating) {
      1 => 'Muy insatisfecho',
      2 => 'Algo insatisfecho',
      3 => 'Aceptable y bien',
      4 => 'Muy buen producto',
      5 => 'Excelente pack y atención',
      _ => empty,
    };
  }
}

class _OrderSummaryCard extends StatelessWidget {
  const _OrderSummaryCard({required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    return FudiSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: order.offerImageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: order.offerImageUrl!,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        width: 60,
                        height: 60,
                        color: FudiColors.background,
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.restaurant_rounded,
                          color: FudiColors.mutedForeground,
                        ),
                      ),
              ),
              const SizedBox(width: FudiSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.businessName,
                      style: FudiTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      order.offerTitle,
                      style: FudiTypography.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      order.orderNumber,
                      style: FudiTypography.bodySmall.copyWith(
                        color: FudiColors.mutedForeground,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: FudiSpacing.md),
          const Divider(color: FudiColors.border, thickness: 0.5),
          const SizedBox(height: FudiSpacing.xs),
          _SummaryRow(
            label: 'Total abonado',
            value: '\$${order.price.toStringAsFixed(2)}',
            isBold: true,
          ),
        ],
      ),
    );
  }
}

class _RatingSection extends StatelessWidget {
  const _RatingSection({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return FudiSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: FudiTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: FudiSpacing.md),
          Center(
            child: FudiStarRating(
              rating: value.toDouble(),
              size: 36,
              onTap: onChanged,
            ),
          ),
          const SizedBox(height: FudiSpacing.sm),
          Center(
            child: Text(
              subtitle,
              style: FudiTypography.bodySmall.copyWith(
                color: value > 0
                    ? FudiColors.primary
                    : FudiColors.mutedForeground,
                fontWeight: value > 0 ? FontWeight.bold : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.isBold = false,
  });

  final String label;
  final String value;
  final bool isBold;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: FudiTypography.bodyMedium.copyWith(
            color: FudiColors.mutedForeground,
          ),
        ),
        Text(
          value,
          style: FudiTypography.bodyMedium.copyWith(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: isBold ? FudiColors.primary : FudiColors.foreground,
          ),
        ),
      ],
    );
  }
}
