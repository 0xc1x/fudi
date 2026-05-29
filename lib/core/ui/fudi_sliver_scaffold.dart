import 'package:flutter/material.dart';
import 'fudi_colors.dart';
import 'fudi_spacing.dart';
import 'fudi_typography.dart';
import 'fudi_bottom_nav.dart';

/// A premium scaffold that natively supports Slivers and a collapsing branded header.
class FudiSliverScaffold extends StatelessWidget {
  const FudiSliverScaffold({
    required this.slivers,
    required this.title,
    super.key,
    this.subtitle,
    this.showBottomNav = false,
    this.floatingActionButton,
    this.actions,
    this.leading,
  });

  final List<Widget> slivers;
  final String title;
  final String? subtitle;
  final bool showBottomNav;
  final Widget? floatingActionButton;
  final List<Widget>? actions;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FudiColors.background,
      body: SafeArea(
        top: false, // Allows full scroll under the status bar
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              expandedHeight: 130.0,
              backgroundColor: FudiColors.background,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              scrolledUnderElevation: 0,
              leading: leading,
              actions: actions,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(
                  left: FudiSpacing.lg,
                  bottom: FudiSpacing.md,
                  right: FudiSpacing.lg,
                ),
                centerTitle: false,
                title: LayoutBuilder(
                  builder: (context, constraints) {
                    // Check if expanded or collapsed to adjust subtitle display and scale
                    final isCollapsed = constraints.maxHeight <= kToolbarHeight + MediaQuery.of(context).padding.top;
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          style: isCollapsed 
                              ? FudiTypography.h4.copyWith(color: FudiColors.foreground)
                              : FudiTypography.h2.copyWith(color: FudiColors.foreground),
                        ),
                        if (subtitle != null && !isCollapsed) ...[
                          const SizedBox(height: 2),
                          Text(
                            subtitle!,
                            style: FudiTypography.bodySmall.copyWith(
                              color: FudiColors.mutedForeground,
                              fontSize: 10, // Tiny caption during scroll
                            ),
                          ),
                        ],
                      ],
                    );
                  },
                ),
              ),
            ),
            ...slivers,
          ],
        ),
      ),
      bottomNavigationBar: showBottomNav ? const FudiBottomNav() : null,
      floatingActionButton: floatingActionButton,
    );
  }
}
