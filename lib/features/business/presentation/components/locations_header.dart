import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/ui/fudi_colors.dart';
import '../../../../core/ui/fudi_pressable_scale.dart';
import '../../../../core/ui/fudi_spacing.dart';
import '../../../../core/ui/fudi_typography.dart';
import '../../../../core/ui/atoms/icons/fudi_icons.dart';

class LocationsHeader extends StatelessWidget {
  const LocationsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text('Mis Locales', style: FudiTypography.h4)),
        FudiPressableScale(
          onTap: () => context.push(RouteNames.businessLocationCreatePath),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: FudiSpacing.md,
              vertical: FudiSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: FudiColors.primary,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(FudiIcons.plus, size: 16, color: Colors.white),
                const SizedBox(width: 4),
                Text('Agregar', style: FudiTypography.labelSmall.copyWith(color: Colors.white)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
