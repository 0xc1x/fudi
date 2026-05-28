import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/route_names.dart';
import '../../../core/ui/fudi_colors.dart';
import '../../../core/ui/atoms/icons/fudi_icons.dart';
import '../../../core/ui/fudi_spacing.dart';
import '../../../core/ui/fudi_surface_card.dart';
import '../../../core/ui/fudi_typography.dart';
import 'business_providers.dart';
import 'components/no_business_prompt.dart';

class BusinessManagementProfileScreen extends ConsumerWidget {
  const BusinessManagementProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final businessAsync = ref.watch(currentBusinessProvider);
    return Scaffold(
      backgroundColor: FudiColors.muted,
      appBar: AppBar(
        title: const Text('Perfil de Negocio', style: FudiTypography.h4),
      ),
      body: businessAsync.when(
        data: (business) {
          if (business == null) return const NoBusinessPrompt();
          return ListView(
            padding: const EdgeInsets.all(FudiSpacing.lg),
            children: [
              FudiSurfaceCard(
                padding: const EdgeInsets.all(FudiSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(business.name, style: FudiTypography.h2),
                    const SizedBox(height: FudiSpacing.xs),
                    Text(business.type, style: FudiTypography.bodySmall),
                    const SizedBox(height: FudiSpacing.md),
                    Text(
                      business.description ?? 'Sin descripción registrada',
                      style: FudiTypography.bodyMedium,
                    ),
                    const SizedBox(height: FudiSpacing.md),
                    FilledButton.icon(
                      onPressed: () =>
                          context.push(RouteNames.businessEditPath),
                      icon: const Icon(Icons.edit_rounded),
                      label: const Text('Editar perfil'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: FudiSpacing.md),
              FudiSurfaceCard(
                padding: const EdgeInsets.all(FudiSpacing.md),
                child: Column(
                  children: [
                    _Info(icon: FudiIcons.mapPin, value: business.address),
                    if (business.phone != null)
                      _Info(icon: FudiIcons.phone, value: business.phone!),
                    if (business.email != null)
                      _Info(icon: FudiIcons.mail, value: business.email!),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
      ),
    );
  }
}

class _Info extends StatelessWidget {
  const _Info({required this.icon, required this.value});
  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: FudiSpacing.sm),
      child: Row(
        children: [
          Icon(icon, size: 18, color: FudiColors.primary),
          const SizedBox(width: FudiSpacing.sm),
          Expanded(child: Text(value, style: FudiTypography.bodyMedium)),
        ],
      ),
    );
  }
}
