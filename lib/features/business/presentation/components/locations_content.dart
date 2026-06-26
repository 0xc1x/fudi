import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/ui/fudi_colors.dart';
import '../../../../core/ui/fudi_spacing.dart';
import '../../../../core/ui/fudi_typography.dart';
import '../../../../core/ui/fudi_empty_state.dart';
import '../../../../core/ui/atoms/icons/fudi_icons.dart';
import '../../domain/business_location.dart';
import '../../domain/business_profile.dart';
import 'business_info_card.dart';
import 'location_card.dart';
import 'locations_header.dart';
import 'logout_button.dart';
import 'quick_actions_grid.dart';
import 'settings_section.dart';

class LocationsContent extends ConsumerWidget {
  const LocationsContent({
    super.key,
    required this.business,
    required this.locations,
  });

  final BusinessProfile business;
  final List<BusinessLocation> locations;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          backgroundColor: FudiColors.background,
          title: const Text('Gestión', style: FudiTypography.h2),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(FudiSpacing.md),
          sliver: SliverList.list(
            children: [
              BusinessInfoCard(business: business),
              const SizedBox(height: FudiSpacing.md),
              const LocationsHeader(),
              const SizedBox(height: FudiSpacing.sm),
              ..._buildLocationCards(context),
              const SizedBox(height: FudiSpacing.lg),
              const Text('Accesos rápidos', style: FudiTypography.h4),
              const SizedBox(height: FudiSpacing.sm),
              const QuickActionsGrid(),
              const SizedBox(height: FudiSpacing.lg),
              const SettingsSection(),
              const SizedBox(height: FudiSpacing.md),
              const LogoutButton(),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildLocationCards(BuildContext context) {
    if (locations.isEmpty) {
      return [
        FudiEmptyState(
          icon: FudiIcons.mapPin,
          title: 'Aún no hay locales',
          description: 'Crea tu primer local para empezar',
          actionLabel: 'Crear local',
          onAction: () => context.push(RouteNames.businessLocationCreatePath),
        ),
      ];
    }
    return locations
        .map(
          (location) => Padding(
            padding: const EdgeInsets.only(bottom: FudiSpacing.md),
            child: LocationCard(location: location),
          ),
        )
        .toList();
  }
}
