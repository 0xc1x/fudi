import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'fudi_colors.dart';
import 'fudi_icons.dart';
import 'fudi_spacing.dart';
import 'fudi_typography.dart';

class FudiStickyPageHeader extends StatelessWidget
    implements PreferredSizeWidget {
  const FudiStickyPageHeader({
    required this.title,
    super.key,
    this.subtitle,
    this.leading,
    this.actions,
    this.onBack,
    this.bottom,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final List<Widget>? actions;
  final VoidCallback? onBack;
  final PreferredSizeWidget? bottom;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: FudiColors.background,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shadowColor: Colors.transparent,
      scrolledUnderElevation: 0,
      leadingWidth: 72,
      leading: leading ?? _BackButton(onTap: onBack),
      titleSpacing: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title, style: FudiTypography.labelMedium),
          if (subtitle != null)
            Text(subtitle!, style: FudiTypography.bodySmall),
        ],
      ),
      actions: actions,
      bottom: bottom,
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0));
}

class _BackButton extends StatelessWidget {
  const _BackButton({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: FudiSpacing.md),
      child: Center(
        child: InkWell(
          onTap: onTap ?? () => context.pop(),
          borderRadius: BorderRadius.circular(FudiRadius.full),
          child: Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: FudiColors.muted,
              shape: BoxShape.circle,
            ),
            child: const Icon(FudiIcons.chevronLeft, size: 20),
          ),
        ),
      ),
    );
  }
}
