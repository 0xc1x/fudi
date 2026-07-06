import 'package:flutter/material.dart';

import '../../../../core/ui/fudi_colors.dart';
import '../../../../core/ui/fudi_spacing.dart';
import '../../../../core/ui/fudi_surface_card.dart';
import '../../../../core/ui/fudi_typography.dart';
import '../../../offers/domain/offer.dart';

class PickupDetailsCard extends StatelessWidget {
  const PickupDetailsCard({super.key, required this.offer});

  final Offer offer;

  @override
  Widget build(BuildContext context) {
    final timeFormat = MaterialLocalizations.of(context);
    final untilTime = timeFormat.formatTimeOfDay(offer.pickupUntilTimeOfDay);

    return FudiSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Detalles de recogida', style: FudiTypography.labelMedium),
          const SizedBox(height: FudiSpacing.sm),
          _buildItem(
            icon: Icons.location_on_rounded,
            title: 'Dirección del local',
            subtitle: offer.business.address,
          ),
          const SizedBox(height: FudiSpacing.sm),
          _buildItem(
            icon: Icons.alarm_rounded,
            title: 'Límite de retiro',
            subtitle: 'Hoy antes de $untilTime',
            highlight: true,
          ),
        ],
      ),
    );
  }

  Widget _buildItem({
    required IconData icon,
    required String title,
    required String subtitle,
    bool highlight = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(FudiSpacing.sm),
      decoration: BoxDecoration(
        color: highlight ? FudiColors.destructiveSurface : FudiColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: highlight ? FudiColors.destructiveSurface : FudiColors.borderSolid,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 16,
            color: highlight ? FudiColors.destructive : FudiColors.primary,
          ),
          const SizedBox(width: FudiSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: FudiTypography.labelSmall.copyWith(
                    fontSize: 11,
                    color: FudiColors.mutedForeground,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: FudiTypography.bodySmall.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
