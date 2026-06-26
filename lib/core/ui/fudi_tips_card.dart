import 'package:flutter/material.dart';

import 'fudi_spacing.dart';
import 'fudi_typography.dart';

class FudiTipsCard extends StatelessWidget {
  const FudiTipsCard({
    required this.tips,
    this.title = 'Consejos',
    super.key,
  });

  final String title;
  final List<String> tips;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(FudiSpacing.lg),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(FudiRadius.xxl),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: FudiTypography.labelSmall.copyWith(
              color: const Color(0xFF1E3A5F),
            ),
          ),
          const SizedBox(height: FudiSpacing.sm),
          ...tips.map(_tip),
        ],
      ),
    );
  }

  Widget _tip(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: FudiSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: FudiTypography.bodySmall.copyWith(
              color: const Color(0xFF1D4ED8),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: FudiTypography.bodySmall.copyWith(
                color: const Color(0xFF1D4ED8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
