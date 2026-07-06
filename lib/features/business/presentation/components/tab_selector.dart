import 'package:flutter/material.dart';
import '../../../../core/ui/fudi_colors.dart';
import '../../../../core/ui/fudi_spacing.dart';
import '../../../../core/ui/fudi_theme.dart';
import '../../../../core/ui/fudi_typography.dart';

class TabSelector extends StatelessWidget {
  const TabSelector({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onTabChanged,
  });

  final List<TabData> tabs;
  final int selectedIndex;
  final ValueChanged<int> onTabChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeExt = theme.extension<FudiThemeExtension>();
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(FudiRadius.xl),
        border: Border.all(color: themeExt?.borderSolid ?? FudiColors.borderSolid),
      ),
      child: Row(
        children: List.generate(tabs.length, (i) {
          final tab = tabs[i];
          return Expanded(
            child: _TabButton(
              label: tab.label,
              count: tab.count,
              isActive: selectedIndex == i,
              onTap: () => onTabChanged(i),
            ),
          );
        }),
      ),
    );
  }
}

class TabData {
  const TabData({required this.label, this.count});

  final String label;
  final int? count;
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    this.count,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final int? count;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final displayLabel = count != null ? '$label ($count)' : label;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? FudiColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(FudiRadius.lg),
        ),
        child: Text(
          displayLabel,
          textAlign: TextAlign.center,
          style: FudiTypography.labelSmall.copyWith(
            color: isActive ? FudiColors.primaryForeground : colorScheme.onSurfaceVariant,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
