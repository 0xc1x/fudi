import 'package:flutter/material.dart';
import 'fudi_colors.dart';
import 'fudi_spacing.dart';

/// Visualización de calificación con estrellas.
class FudiStarRating extends StatelessWidget {
  const FudiStarRating({
    super.key,
    required this.rating,
    this.maxRating = 5,
    this.size = 16,
    this.color = FudiColors.ring,
    this.showText = false,
  });

  final double rating;
  final int maxRating;
  final double size;
  final Color color;
  final bool showText;

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
              icon = Icons.star_rounded;
            } else if (index < rating && (rating - index) >= 0.5) {
              icon = Icons.star_half_rounded;
            } else {
              icon = Icons.star_outline_rounded;
            }
            return Icon(
              icon,
              size: size,
              color: color,
            );
          }),
        ),
        if (showText) ...[
          const SizedBox(width: FudiSpacing.xs),
          Text(
            rating.toStringAsFixed(1),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}
