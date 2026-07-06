import 'package:flutter/material.dart';
import '../fudi_theme.dart';
import '../fudi_spacing.dart';
import '../fudi_typography.dart';
import 'icons/fudi_icons.dart';

class FudiDatePickerTile extends StatelessWidget {
  const FudiDatePickerTile({
    required this.label,
    required this.date,
    required this.onTap,
    super.key,
  });

  final String label;
  final DateTime date;
  final VoidCallback onTap;

  String _formatDate() {
    const months = [
      '',
      'ene',
      'feb',
      'mar',
      'abr',
      'may',
      'jun',
      'jul',
      'ago',
      'sep',
      'oct',
      'nov',
      'dic',
    ];
    return '${date.day} ${months[date.month]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: FudiTypography.labelSmall),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(FudiRadius.lg),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).extension<FudiThemeExtension>()?.borderSolid ??
                    Theme.of(context).dividerColor,
              ),
              borderRadius: BorderRadius.circular(FudiRadius.lg),
            ),
            child: Row(
              children: [
                const Icon(FudiIcons.calendar, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _formatDate(),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}