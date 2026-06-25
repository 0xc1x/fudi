import 'package:flutter/material.dart';

import '../fudi_colors.dart';
import '../fudi_spacing.dart';

class FudiStatCard extends StatelessWidget {
  const FudiStatCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(FudiSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(FudiRadius.xl),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 20,
            color: FudiColors.primary.withValues(alpha: 0.6),
          ),
          const SizedBox(height: FudiSpacing.xs),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: FudiColors.primary,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: FudiColors.primary.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}
