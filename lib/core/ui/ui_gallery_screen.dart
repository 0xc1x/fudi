import 'package:flutter/material.dart';
import 'fudi_colors.dart';
import 'fudi_spacing.dart';
import 'fudi_typography.dart';
import 'fudi_logo.dart';
import 'fudi_scaffold.dart';
import 'fudi_star_rating.dart';
import 'cards/deal_card.dart';
import 'cards/order_card.dart';
import 'cards/business_card.dart';

/// Pantalla de galería para visualizar y probar los componentes de la UI.
class UiGalleryScreen extends StatelessWidget {
  const UiGalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FudiScaffold(
      title: 'Fudi UI Gallery',
      body: ListView(
        padding: const EdgeInsets.all(FudiSpacing.lg),
        children: [
          _Section(
            title: 'Logo',
            child: const FudiLogo(size: FudiLogoSize.lg),
          ),

          _Section(
            title: 'Typography',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('H1 Heading', style: FudiTypography.h1),
                Text('H2 Heading', style: FudiTypography.h2),
                Text('H3 Heading', style: FudiTypography.h3),
                Text('H4 Heading', style: FudiTypography.h4),
                const SizedBox(height: 10),
                Text('Body Large', style: FudiTypography.bodyLarge),
                Text('Body Medium', style: FudiTypography.bodyMedium),
                Text('Body Small', style: FudiTypography.bodySmall),
                const SizedBox(height: 10),
                Text('Label Medium', style: FudiTypography.labelMedium),
                Text('Label Small', style: FudiTypography.labelSmall),
              ],
            ),
          ),

          _Section(
            title: 'Star Rating',
            child: Column(
              children: const [
                FudiStarRating(rating: 4.5, showText: true, size: 24),
                SizedBox(height: 8),
                FudiStarRating(rating: 3.2, showText: true),
                SizedBox(height: 8),
                FudiStarRating(rating: 5, size: 12),
              ],
            ),
          ),

          _Section(
            title: 'Deal Card',
            child: DealCard(
              imageUrl:
                  'https://images.unsplash.com/photo-1509440159596-0249088772ff?q=80&w=400',
              businessName: 'Panadería La Esperanza',
              originalPrice: 15.00,
              discountedPrice: 7.50,
              rating: 4.8,
              distance: '0.4 km',
              availableQuantity: 3,
              pickupUntil: const TimeOfDay(hour: 19, minute: 0),
              categoryLabel: 'BAKERY',
              onTap: () {},
            ),
          ),

          _Section(
            title: 'Order Card',
            child: Column(
              children: [
                OrderCard(
                  orderNumber: '2026-001',
                  businessName: 'Cafe Central',
                  status: 'completed',
                  date: DateTime.now().subtract(const Duration(days: 1)),
                  totalPrice: 12.50,
                  imageUrl:
                      'https://images.unsplash.com/photo-1509042239860-f550ce710b93?q=80&w=200',
                  onTap: () {},
                ),
                const SizedBox(height: 8),
                OrderCard(
                  orderNumber: '2026-002',
                  businessName: 'Burger Joint',
                  status: 'ready',
                  date: DateTime.now(),
                  totalPrice: 8.99,
                  imageUrl:
                      'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?q=80&w=200',
                  onTap: () {},
                ),
              ],
            ),
          ),

          _Section(
            title: 'Business Card',
            child: BusinessCard(
              imageUrl:
                  'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?q=80&w=200',
              name: 'Restaurante El Gourmet',
              type: 'Comida Italiana',
              rating: 4.2,
              distance: '1.2 km',
              onTap: () {},
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: FudiSpacing.md),
          child: Text(
            title.toUpperCase(),
            style: FudiTypography.labelSmall.copyWith(
              color: FudiColors.mutedForeground,
              letterSpacing: 1.2,
            ),
          ),
        ),
        child,
        const Divider(height: FudiSpacing.xxl),
      ],
    );
  }
}
