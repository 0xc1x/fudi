import 'package:flutter/material.dart';

import '../../features/business/domain/business_profile.dart';
import 'fudi_colors.dart';
import 'fudi_spacing.dart';
import 'fudi_typography.dart';
import 'fudi_surface_card.dart';
import 'atoms/icons/fudi_icons.dart';

class FudiOpeningHoursCard extends StatelessWidget {
  const FudiOpeningHoursCard({
    required this.hours,
    this.title = 'Horario de atención',
    super.key,
  });

  final String title;
  final List<BusinessHours> hours;

  @override
  Widget build(BuildContext context) {
    return FudiSurfaceCard(
      padding: const EdgeInsets.all(FudiSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(FudiIcons.clock, size: 20, color: FudiColors.primary),
              const SizedBox(width: FudiSpacing.sm),
              Text(
                title,
                style: FudiTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: FudiSpacing.md),
          ...hours.map(
            (h) => Padding(
              padding: const EdgeInsets.only(bottom: FudiSpacing.sm),
              child: _HoursRow(day: h.day, hours: h.hours),
            ),
          ),
        ],
      ),
    );
  }
}

class _HoursRow extends StatelessWidget {
  const _HoursRow({required this.day, required this.hours});

  final String day;
  final String hours;

  @override
  Widget build(BuildContext context) {
    final isClosed = hours == 'Cerrado';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: FudiSpacing.sm),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: FudiColors.borderSolid)),
        ),
        child: Padding(
          padding: const EdgeInsets.only(bottom: FudiSpacing.sm),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                day,
                style: FudiTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                hours,
                style: FudiTypography.bodySmall.copyWith(
                  color: isClosed
                      ? FudiColors.destructive
                      : FudiColors.mutedForeground,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
