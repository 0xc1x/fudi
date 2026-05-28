import 'package:flutter/material.dart';
import 'fudi_colors.dart';
import 'fudi_spacing.dart';
import 'atoms/icons/fudi_icons.dart';

/// Visualización de calificación con estrellas.
class FudiStarRating extends StatelessWidget {
  const FudiStarRating({
    super.key,
    required this.rating,
    this.maxRating = 5,
    this.size = 16,
    this.color = FudiColors.ring,
    this.showText = false,
    this.onTap,
  });

  final double rating;
  final int maxRating;
  final double size;
  final Color color;
  final bool showText;
  final ValueChanged<int>? onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(maxRating, (index) {
            IconData icon;
            if (index < rating.floor()) {
              icon = FudiIcons.star;
            } else if (index < rating && (rating - index) >= 0.5) {
              icon = FudiIcons.starHalf;
            } else {
              icon = FudiIcons.star; // Lucide star es outline por defecto si no se rellena
            }
            final star = Icon(icon, size: size, color: color);
            if (onTap == null) {
              return star;
            }
            return InkWell(
              onTap: () => onTap!(index + 1),
              borderRadius: BorderRadius.circular(FudiRadius.full),
              child: Padding(
                padding: const EdgeInsets.all(2),
                child: star,
              ),
            );
          }),
        ),
        if (showText) ...[
          const SizedBox(width: FudiSpacing.xs),
          Text(
            rating.toStringAsFixed(1),
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ],
    );
  }
}
