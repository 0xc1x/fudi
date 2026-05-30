import 'package:flutter/material.dart';
import 'fudi_colors.dart';
import 'fudi_spacing.dart';
import 'atoms/icons/fudi_icons.dart';

class FudiStarRating extends StatelessWidget {
  const FudiStarRating({
    super.key,
    required this.rating,
    this.maxRating = 5,
    this.size = 16,
    this.activeColor = const Color(0xFFFACC15),
    this.inactiveColor = FudiColors.mutedForeground,
    this.showText = false,
    this.onTap,
  });

  final double rating;
  final int maxRating;
  final double size;
  final Color activeColor;
  final Color inactiveColor;
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
            final isFull = index < rating.floor();
            final isHalf = !isFull && index < rating && (rating - index) >= 0.5;

            final IconData icon;
            final Color color;
            if (isFull || isHalf) {
              icon = isHalf ? FudiIcons.starHalf : FudiIcons.star;
              color = activeColor;
            } else {
              icon = FudiIcons.starOutline;
              color = inactiveColor;
            }

            final star = Icon(icon, size: size, color: color);

            if (onTap == null) return star;

            return InkWell(
              onTap: () => onTap!(index + 1),
              borderRadius: BorderRadius.circular(FudiRadius.full),
              child: Padding(
                padding: const EdgeInsets.all(4),
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
