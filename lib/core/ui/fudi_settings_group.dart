import 'package:flutter/material.dart';

import 'fudi_colors.dart';
import 'fudi_spacing.dart';
import 'fudi_typography.dart';
import 'fudi_settings_item.dart';

class FudiSettingsGroup extends StatelessWidget {
  const FudiSettingsGroup({
    super.key,
    required this.title,
    required this.items,
  });

  final String title;
  final List<FudiSettingsItem> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: FudiTypography.h2),
        const SizedBox(height: FudiSpacing.md),
        Container(
          decoration: BoxDecoration(
            color: FudiColors.background,
            borderRadius: BorderRadius.circular(FudiRadius.xl),
            border: Border.all(color: FudiColors.borderSolid),
          ),
          child: Column(
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return Column(
                children: [
                  item,
                  if (index < items.length - 1)
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: FudiColors.borderSolid,
                      indent: FudiSpacing.lg + 20 + FudiSpacing.md,
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
