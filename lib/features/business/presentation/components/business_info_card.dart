import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/ui/fudi_colors.dart';
import '../../../../core/ui/fudi_pressable_scale.dart';
import '../../../../core/ui/fudi_spacing.dart';
import '../../../../core/ui/fudi_surface_card.dart';
import '../../../../core/ui/fudi_typography.dart';
import '../../../../core/ui/atoms/icons/fudi_icons.dart';
import '../../domain/business_profile.dart';

class BusinessInfoCard extends StatelessWidget {
  const BusinessInfoCard({super.key, required this.business});

  final BusinessProfile business;

  @override
  Widget build(BuildContext context) {
    return FudiSurfaceCard(
      padding: const EdgeInsets.all(FudiSpacing.md),
      child: Column(
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(FudiRadius.lg),
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: FudiColors.primary.withValues(alpha: 0.2),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(FudiRadius.lg),
                  ),
                  child: business.imageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: business.imageUrl!,
                          fit: BoxFit.cover,
                          width: 64,
                          height: 64,
                          errorWidget: (_, _, _) => const _LogoFallback(),
                          placeholder: (_, _) => const _LogoFallback(),
                        )
                      : const _LogoFallback(),
                ),
              ),
              const SizedBox(width: FudiSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(business.name, style: FudiTypography.h3),
                    Text(business.type, style: FudiTypography.bodySmall),
                  ],
                ),
              ),
              FudiPressableScale(
                onTap: () => context.push(RouteNames.businessEditPath),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(shape: BoxShape.circle),
                  child: const Icon(FudiIcons.store, color: FudiColors.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: FudiSpacing.md),
          const Divider(height: 1, color: FudiColors.mutedForeground),
          const SizedBox(height: FudiSpacing.md),
          Row(
            children: [
              Expanded(
                child: _StatItem(
                  value: business.totalRescued.toString(),
                  label: 'Comidas rescatadas',
                  color: FudiColors.primary,
                ),
              ),
              Expanded(
                child: _StatItem(
                  value: business.rating.toStringAsFixed(1),
                  label: 'Rating',
                  color: Colors.orange,
                ),
              ),
              Expanded(
                child: _StatItem(
                  value: '${business.reviewCount}',
                  label: 'Reseñas',
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.value,
    required this.label,
    required this.color,
  });

  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: FudiTypography.h2.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: FudiTypography.bodySmall.copyWith(
            color: FudiColors.mutedForeground,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _LogoFallback extends StatelessWidget {
  const _LogoFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: FudiColors.primary.withValues(alpha: 0.1),
      child: const Icon(
        FudiIcons.storefront,
        color: FudiColors.primary,
        size: 32,
      ),
    );
  }
}
