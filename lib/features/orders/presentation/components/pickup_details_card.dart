import 'package:flutter/material.dart';

import '../../../../core/ui/fudi_colors.dart';
import '../../../../core/ui/fudi_spacing.dart';
import '../../../../core/ui/fudi_surface_card.dart';
import '../../../../core/ui/fudi_typography.dart';
import '../../../offers/domain/offer.dart';

class PickupDetailsCard extends StatelessWidget {
  const PickupDetailsCard({required this.offer});

  final Offer offer;

  @override
  Widget build(BuildContext context) {
    final timeFormat = MaterialLocalizations.of(context);
    final untilTime = timeFormat.formatTimeOfDay(offer.pickupUntilTimeOfDay);

    return FudiSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Detalles de recogida', style: FudiTypography.labelMedium),
          const SizedBox(height: FudiSpacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.location_on, size: 20, color: FudiColors.primary),
              const SizedBox(width: FudiSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dirección de recogida',
                      style: FudiTypography.labelSmall,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      offer.business.address,
                      style: FudiTypography.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: FudiSpacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.schedule, size: 20, color: FudiColors.primary),
              const SizedBox(width: FudiSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Horario de recogida',
                      style: FudiTypography.labelSmall,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Hoy antes de $untilTime',
                      style: FudiTypography.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
