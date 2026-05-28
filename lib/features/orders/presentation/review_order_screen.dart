import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/error/user_friendly_message.dart';
import '../../../core/ui/fudi_bottom_action_bar.dart';
import '../../../core/ui/fudi_colors.dart';
import '../../../core/ui/fudi_info_banner.dart';
import '../../../core/ui/atoms/icons/fudi_icons.dart';
import '../../../core/ui/fudi_spacing.dart';
import '../../../core/ui/fudi_sticky_page_header.dart';
import '../../../core/ui/fudi_surface_card.dart';
import '../../../core/ui/fudi_star_rating.dart';
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
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, _) => Scaffold(
        appBar: const FudiStickyPageHeader(title: 'Dejar reseña'),
        body: Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildContent(BuildContext context, OrderModel order) {
    ref.listen(submitReviewProvider, (previous, next) {
      next.whenOrNull(
        data: (_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Reseña publicada exitosamente')),
          );
          Navigator.of(context).pop();
        },
    error: (error, _) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(userFriendlyMessage(error)),
          backgroundColor: FudiColors.destructive,
        ),
      );
    },
      );
    });

    final submitReview = ref.watch(submitReviewProvider);
    final isSubmitting = submitReview.isLoading;

    return Scaffold(
      appBar: const FudiStickyPageHeader(title: 'Dejar reseña'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(FudiSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _OrderSummaryCard(order: order),
            const SizedBox(height: FudiSpacing.lg),
            _RatingSection(
              title: '¿Cómo estuvo el producto?',
              subtitle: _ratingLabel(
                rating: _productRating,
                empty: 'Toca las estrellas para calificar',
              ),
              value: _productRating,
              onChanged: (value) => setState(() => _productRating = value),
            ),
            const SizedBox(height: FudiSpacing.lg),
            _RatingSection(
              title: '¿Cómo fue tu experiencia con el negocio?',
              subtitle: _ratingLabel(
                rating: _businessRating,
                empty: 'Califica el servicio y la recogida',
              ),
              value: _businessRating,
              onChanged: (value) => setState(() => _businessRating = value),
            ),
            const SizedBox(height: FudiSpacing.lg),
            FudiSurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Cuéntanos más (opcional)', style: FudiTypography.labelSmall),
                  const SizedBox(height: FudiSpacing.md),
                  TextField(
                    controller: _commentController,
                    maxLength: 500,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: '¿Qué te gustó más? ¿Algo que podría mejorar?',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(FudiRadius.lg),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: FudiSpacing.lg),
            FudiSurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Agregar foto (opcional)', style: FudiTypography.labelSmall),
                  const SizedBox(height: FudiSpacing.md),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(FudiSpacing.xl),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(FudiRadius.lg),
                      border: Border.all(
                        color: FudiColors.borderSolid,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.camera_alt_outlined,
                          size: 40,
                          color: FudiColors.mutedForeground,
                        ),
                        const SizedBox(height: FudiSpacing.sm),
                        Text(
                          'Próximamente podrás adjuntar fotos desde esta pantalla.',
                          textAlign: TextAlign.center,
                          style: FudiTypography.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: FudiSpacing.lg),
            const FudiInfoBanner(
              title: 'Consejos para tu reseña',
              message:
                  'Sé específico sobre la calidad del producto, la variedad disponible y la experiencia de recogida.',
              icon: FudiIcons.star,
              backgroundColor: Color(0xFFEFF6FF),
              borderColor: Color(0xFFBFDBFE),
              foregroundColor: Color(0xFF1D4ED8),
            ),
            const SizedBox(height: 120),
          ],
        ),
      ),
      bottomNavigationBar: FudiBottomActionBar(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: isSubmitting || _productRating == 0 || _businessRating == 0
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
                style: FilledButton.styleFrom(
                  backgroundColor: FudiColors.primary,
                  minimumSize: const Size.fromHeight(56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(FudiRadius.lg),
                  ),
                ),
                child: isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'Publicar reseña',
                        style: FudiTypography.labelMedium.copyWith(
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            if (_productRating == 0 || _businessRating == 0) ...[
              const SizedBox(height: FudiSpacing.sm),
              Text(
                'Por favor califica el producto y el negocio',
                style: FudiTypography.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _ratingLabel({required int rating, required String empty}) {
    return switch (rating) {
      1 => 'Malo',
      2 => 'Regular',
      3 => 'Bueno',
      4 => 'Muy bueno',
      5 => 'Excelente',
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
      child: Padding(
        padding: const EdgeInsets.all(FudiSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(FudiRadius.lg),
                  child: order.offerImageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: order.offerImageUrl!,
                          width: 64,
                          height: 64,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          width: 64,
                          height: 64,
                          color: FudiColors.muted,
                          alignment: Alignment.center,
                          child: const Icon(Icons.restaurant_rounded),
                        ),
                ),
                const SizedBox(width: FudiSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(order.businessName, style: FudiTypography.labelMedium),
                      const SizedBox(height: FudiSpacing.xs),
                      Text(order.offerTitle, style: FudiTypography.bodySmall),
                      const SizedBox(height: FudiSpacing.xs),
                      Text(
                        order.orderNumber,
                        style: FudiTypography.bodySmall.copyWith(
                          color: FudiColors.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: FudiSpacing.md),
            const Divider(),
            _SummaryRow(label: 'Estado', value: order.status.label),
            const Divider(),
            _SummaryRow(
              label: 'Total pagado',
              value: '\$${order.price.toStringAsFixed(0)}',
              isBold: true,
            ),
          ],
        ),
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
          Text(title, style: FudiTypography.labelSmall),
          const SizedBox(height: FudiSpacing.md),
          Center(
            child: FudiStarRating(
              rating: value.toDouble(),
              size: 32,
              showText: false,
              onTap: onChanged,
            ),
          ),
          const SizedBox(height: FudiSpacing.sm),
          Center(
            child: Text(
              subtitle,
              style: FudiTypography.bodySmall,
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: FudiTypography.bodyMedium),
          Text(
            value,
            style:
                (isBold
                        ? FudiTypography.labelMedium
                        : FudiTypography.bodyMedium)
                    .copyWith(color: isBold ? FudiColors.primary : null),
          ),
        ],
      ),
    );
  }
}
