import 'package:flutter/material.dart';
import '../../../../core/ui/atoms/icons/fudi_icons.dart';
import '../../../../core/ui/fudi_colors.dart';
import '../../../../core/ui/fudi_spacing.dart';
import '../../domain/business_profile.dart';

class BusinessSelector extends StatelessWidget {
  const BusinessSelector({
    super.key,
    required this.business,
    required this.allBusinesses,
    required this.onSelected,
  });

  final BusinessProfile business;
  final List<BusinessProfile> allBusinesses;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    if (allBusinesses.length <= 1) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(FudiIcons.mapPin, size: 14, color: FudiColors.primary),
          const SizedBox(width: 4),
          Text(
            business.name,
            style: const TextStyle(
              fontSize: 12,
              color: Color.fromARGB(255, 144, 191, 25),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
    }

    return PopupMenuButton<String>(
      onSelected: onSelected,
      offset: const Offset(0, 32),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(FudiRadius.md),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(FudiIcons.mapPin, size: 14, color: FudiColors.primary),
          const SizedBox(width: 4),
          Text(
            business.name,
            style: const TextStyle(
              fontSize: 12,
              color: FudiColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Icon(
            FudiIcons.chevronDown,
            size: 14,
            color: FudiColors.primary,
          ),
        ],
      ),
      itemBuilder: (context) => allBusinesses
          .map(
            (b) => PopupMenuItem(
              value: b.id,
              child: Row(
                children: [
                  Icon(
                    FudiIcons.mapPin,
                    size: 16,
                    color: b.id == business.id
                        ? FudiColors.primary
                        : FudiColors.mutedForeground,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    b.name,
                    style: TextStyle(
                      fontWeight: b.id == business.id
                          ? FontWeight.bold
                          : FontWeight.normal,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}
