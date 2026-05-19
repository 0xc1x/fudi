import 'package:flutter/material.dart';

import 'fudi_colors.dart';
import 'fudi_spacing.dart';

class FudiBottomActionBar extends StatelessWidget {
  const FudiBottomActionBar({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: FudiColors.background,
        border: Border(top: BorderSide(color: FudiColors.borderSolid)),
        boxShadow: [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(
        FudiSpacing.lg,
        FudiSpacing.md,
        FudiSpacing.lg,
        FudiSpacing.lg,
      ),
      child: SafeArea(top: false, child: child),
    );
  }
}
