import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/ui/fudi_colors.dart';
import '../../../../core/ui/fudi_spacing.dart';
import '../../../../core/ui/fudi_surface_card.dart';
import '../../../../core/ui/fudi_typography.dart';
import '../../../../core/ui/atoms/icons/fudi_icons.dart';
import '../../../../core/ui/atoms/fudi_status_badge.dart';
import '../../domain/business_location.dart';

class LocationCard extends StatelessWidget {
  const LocationCard({super.key, required this.location});

  final BusinessLocation location;

  @override
  Widget build(BuildContext context) {
    return FudiSurfaceCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(FudiSpacing.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: FudiColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(FudiRadius.lg),
                  ),
                  child: const Icon(
                    FudiIcons.storefront,
                    color: FudiColors.primary,
                    size: 32,
                  ),
                ),
                const SizedBox(width: FudiSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              location.name,
                              style: FudiTypography.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          FudiStatusBadge.active(isActive: location.isActive),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            FudiIcons.mapPin,
                            size: 14,
                            color: FudiColors.mutedForeground,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              location.address,
                              style: FudiTypography.bodySmall.copyWith(
                                color: FudiColors.mutedForeground,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (location.phone != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              FudiIcons.phone,
                              size: 14,
                              color: FudiColors.mutedForeground,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              location.phone!,
                              style: FudiTypography.bodySmall.copyWith(
                                color: FudiColors.mutedForeground,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: FudiColors.muted.withValues(alpha: 0.3),
              border: Border(top: BorderSide(color: FudiColors.borderSolid)),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(FudiRadius.xl),
                bottomRight: Radius.circular(FudiRadius.xl),
              ),
            ),
            child: InkWell(
              onTap: () => context.push('/business/locations/${location.id}'),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(FudiRadius.xl),
                bottomRight: Radius.circular(FudiRadius.xl),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: FudiSpacing.md,
                  vertical: FudiSpacing.sm + 2,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Ver detalles y configuración',
                      style: FudiTypography.bodySmall.copyWith(
                        color: FudiColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Icon(
                      FudiIcons.chevronRight,
                      size: 16,
                      color: FudiColors.primary,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
