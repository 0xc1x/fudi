import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/route_names.dart';
import '../../../../core/ui/fudi_colors.dart';
import '../../../../core/ui/fudi_icons.dart';
import '../../../../core/ui/fudi_spacing.dart';
import '../../../../core/ui/fudi_surface_card.dart';
import '../../../../core/ui/fudi_typography.dart';
import '../../../auth/presentation/auth_state_provider.dart';
import '../../domain/business_location.dart';
import '../../domain/business_profile.dart';
import '../business_providers.dart';
import '../components/no_business_prompt.dart';

class BusinessLocationsScreen extends ConsumerWidget {
  const BusinessLocationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final businessAsync = ref.watch(currentBusinessProvider);
    return Scaffold(
      backgroundColor: FudiColors.muted,
      body: businessAsync.when(
        data: (business) {
          if (business == null) return const NoBusinessPrompt();
          final locationsAsync = ref.watch(
            businessLocationsProvider(business.id),
          );
          return locationsAsync.when(
            data: (locations) =>
                _Content(business: business, locations: locations),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('$e')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
      ),
    );
  }
}

class _Content extends ConsumerWidget {
  const _Content({required this.business, required this.locations});

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
              _BusinessInfoCard(business: business),
              const SizedBox(height: FudiSpacing.md),
              _LocationsHeader(locations: locations),
              const SizedBox(height: FudiSpacing.sm),
              ..._buildLocationCards(context),
              const SizedBox(height: FudiSpacing.lg),
              const Text('Accesos rápidos', style: FudiTypography.h4),
              const SizedBox(height: FudiSpacing.sm),
              _QuickActionsGrid(),
              const SizedBox(height: FudiSpacing.lg),
              _SettingsSection(),
              const SizedBox(height: FudiSpacing.md),
              _LogoutButton(),
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
        _EmptyCard(
          icon: FudiIcons.mapPin,
          title: 'Aún no hay locales',
          action: 'Crear local',
          onTap: () =>
              context.push(RouteNames.businessLocationCreatePath),
        ),
      ];
    }
    return locations
        .map((location) => Padding(
              padding: const EdgeInsets.only(bottom: FudiSpacing.md),
              child: _LocationCard(location: location),
            ))
        .toList();
  }
}

class _BusinessInfoCard extends StatelessWidget {
  const _BusinessInfoCard({required this.business});

  final BusinessProfile business;

  @override
  Widget build(BuildContext context) {
    return FudiSurfaceCard(
      padding: const EdgeInsets.all(FudiSpacing.md),
      child: Column(
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(FudiRadius.lg),
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: FudiColors.primary.withValues(alpha: 0.2),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(FudiRadius.lg),
                  ),
                  child: business.imageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: business.imageUrl!,
                          fit: BoxFit.cover,
                          width: 64,
                          height: 64,
                          errorWidget: (_, _, _) => const _LogoFallback(),
                          placeholder: (_, _) => const _LogoFallback(),
                        )
                      : const _LogoFallback(),
                ),
              ),
              const SizedBox(width: FudiSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(business.name, style: FudiTypography.h3),
                    Text(business.type, style: FudiTypography.bodySmall),
                  ],
                ),
              ),
              IconButton(
                onPressed: () =>
                    context.push(RouteNames.businessEditPath),
                icon: const Icon(FudiIcons.store, color: FudiColors.primary),
              ),
            ],
          ),
          const SizedBox(height: FudiSpacing.md),
          const Divider(height: 1),
          const SizedBox(height: FudiSpacing.md),
          Row(
            children: [
              Expanded(
                child: _StatItem(
                  value: business.totalRescued.toString(),
                  label: 'Comidas rescatadas',
                  color: FudiColors.primary,
                ),
              ),
              Expanded(
                child: _StatItem(
                  value: business.rating.toStringAsFixed(1),
                  label: 'Rating',
                  color: Colors.orange,
                ),
              ),
              Expanded(
                child: _StatItem(
                  value: '${business.reviewCount}',
                  label: 'Reseñas',
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.value,
    required this.label,
    required this.color,
  });

  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: FudiTypography.h2.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: FudiTypography.bodySmall.copyWith(
            color: FudiColors.mutedForeground,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _LogoFallback extends StatelessWidget {
  const _LogoFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: FudiColors.primary.withValues(alpha: 0.1),
      child: const Icon(
        FudiIcons.storefront,
        color: FudiColors.primary,
        size: 32,
      ),
    );
  }
}

class _LocationsHeader extends StatelessWidget {
  const _LocationsHeader({required this.locations});

  final List<BusinessLocation> locations;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text('Mis Locales', style: FudiTypography.h4),
        ),
        FilledButton.icon(
          onPressed: () =>
              context.push(RouteNames.businessLocationCreatePath),
          icon: const Icon(FudiIcons.plus, size: 16),
          label: const Text('Agregar'),
          style: FilledButton.styleFrom(
            backgroundColor: FudiColors.primary,
            foregroundColor: FudiColors.primaryForeground,
            padding: const EdgeInsets.symmetric(
              horizontal: FudiSpacing.md,
              vertical: FudiSpacing.sm,
            ),
            textStyle: FudiTypography.labelSmall,
          ),
        ),
      ],
    );
  }
}

class _LocationCard extends StatelessWidget {
  const _LocationCard({required this.location});

  final BusinessLocation location;

  @override
  Widget build(BuildContext context) {
    return FudiSurfaceCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(FudiSpacing.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: FudiColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(FudiRadius.lg),
                  ),
                  child: const Icon(
                    FudiIcons.storefront,
                    color: FudiColors.primary,
                    size: 32,
                  ),
                ),
                const SizedBox(width: FudiSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              location.name,
                              style: FudiTypography.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          _StatusBadge(active: location.isActive),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            FudiIcons.mapPin,
                            size: 14,
                            color: FudiColors.mutedForeground,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              location.address,
                              style: FudiTypography.bodySmall.copyWith(
                                color: FudiColors.mutedForeground,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (location.phone != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              FudiIcons.phone,
                              size: 14,
                              color: FudiColors.mutedForeground,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              location.phone!,
                              style: FudiTypography.bodySmall.copyWith(
                                color: FudiColors.mutedForeground,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: FudiColors.muted.withValues(alpha: 0.3),
              border: Border(
                top: BorderSide(color: FudiColors.borderSolid),
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(FudiRadius.xl),
                bottomRight: Radius.circular(FudiRadius.xl),
              ),
            ),
            child: InkWell(
              onTap: () =>
                  context.push('/business/locations/${location.id}'),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(FudiRadius.xl),
                bottomRight: Radius.circular(FudiRadius.xl),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: FudiSpacing.md,
                  vertical: FudiSpacing.sm + 2,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Ver detalles y configuración',
                      style: FudiTypography.bodySmall.copyWith(
                        color: FudiColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Icon(
                      FudiIcons.chevronRight,
                      size: 16,
                      color: FudiColors.primary,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: active
            ? const Color(0xFFDCFCE7)
            : FudiColors.muted,
        borderRadius: BorderRadius.circular(FudiRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: active
                  ? const Color(0xFF16A34A)
                  : FudiColors.mutedForeground,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            active ? 'Activo' : 'Inactivo',
            style: FudiTypography.bodySmall.copyWith(
              color: active
                  ? const Color(0xFF15803D)
                  : FudiColors.mutedForeground,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionsGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final items = [
      _QuickActionData(
        icon: FudiIcons.trendingUp,
        title: 'Estadísticas',
        subtitle: 'Ver análisis',
        path: RouteNames.businessStatisticsPath,
      ),
      _QuickActionData(
        icon: FudiIcons.bell,
        title: 'Notificaciones',
        subtitle: 'Configurar',
        path: RouteNames.businessNotificationsPath,
      ),
      _QuickActionData(
        icon: FudiIcons.creditCard,
        title: 'Pagos',
        subtitle: 'Ver historial',
        path: RouteNames.businessPaymentsPath,
      ),
      _QuickActionData(
        icon: FudiIcons.tag,
        title: 'Cupones',
        subtitle: 'Gestionar',
        path: RouteNames.businessCouponsPath,
      ),
      _QuickActionData(
        icon: FudiIcons.helpCircle,
        title: 'Ayuda',
        subtitle: 'Centro de ayuda',
        path: RouteNames.businessHelpPath,
      ),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: FudiSpacing.md,
      mainAxisSpacing: FudiSpacing.md,
      childAspectRatio: 1.6,
      children: items.map((item) {
        return FudiSurfaceCard(
          padding: const EdgeInsets.all(FudiSpacing.md),
          child: InkWell(
            onTap: () => context.push(item.path),
            borderRadius: BorderRadius.circular(FudiRadius.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(item.icon, color: FudiColors.primary, size: 28),
                const SizedBox(height: FudiSpacing.sm),
                Text(
                  item.title,
                  style: FudiTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  item.subtitle,
                  style: FudiTypography.bodySmall.copyWith(
                    color: FudiColors.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FudiSurfaceCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              FudiSpacing.md,
              FudiSpacing.md,
              FudiSpacing.md,
              FudiSpacing.sm,
            ),
            child: Text('Configuración', style: FudiTypography.h4),
          ),
          const Divider(height: 1),
          _SettingsItem(
            icon: FudiIcons.settings,
            title: 'Configuración general',
            onTap: () => context.push('/profile/settings'),
          ),
          _SettingsItem(
            icon: FudiIcons.bell,
            title: 'Notificaciones',
            onTap: () =>
                context.push(RouteNames.businessNotificationsPath),
          ),
          _SettingsItem(
            icon: FudiIcons.creditCard,
            title: 'Métodos de cobro',
            onTap: () =>
                context.push(RouteNames.businessPaymentsPath),
          ),
          _SettingsItem(
            icon: FudiIcons.helpCircle,
            title: 'Centro de ayuda',
            showBorder: false,
            onTap: () => context.push(RouteNames.businessHelpPath),
          ),
        ],
      ),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  const _SettingsItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.showBorder = true,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool showBorder;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: FudiSpacing.md,
          vertical: FudiSpacing.md,
        ),
        decoration: BoxDecoration(
          border: showBorder
              ? Border(
                  top: BorderSide(color: FudiColors.borderSolid),
                )
              : null,
        ),
        child: Row(
          children: [
            Icon(icon, color: FudiColors.primary, size: 20),
            const SizedBox(width: FudiSpacing.md),
            Expanded(
              child: Text(
                title,
                style: FudiTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              FudiIcons.chevronRight,
              size: 20,
              color: FudiColors.mutedForeground,
            ),
          ],
        ),
      ),
    );
  }
}

class _LogoutButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return OutlinedButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Cerrar sesión'),
            content: const Text(
              '¿Estás seguro de que quieres cerrar sesión?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  ref
                      .read(authControllerProvider.notifier)
                      .signOut();
                },
                style: FilledButton.styleFrom(
                  backgroundColor: FudiColors.destructive,
                ),
                child: const Text('Cerrar sesión'),
              ),
            ],
          ),
        );
      },
      style: OutlinedButton.styleFrom(
        foregroundColor: FudiColors.destructive,
        side: BorderSide(color: FudiColors.destructive),
        padding: const EdgeInsets.symmetric(vertical: FudiSpacing.md),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(FudiRadius.xl),
        ),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(FudiIcons.logOut, size: 20),
          SizedBox(width: FudiSpacing.sm),
          Text('Cerrar sesión'),
        ],
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({
    required this.icon,
    required this.title,
    required this.action,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FudiSurfaceCard(
      padding: const EdgeInsets.all(FudiSpacing.xl),
      child: Column(
        children: [
          Icon(icon, size: 48, color: FudiColors.mutedForeground),
          const SizedBox(height: FudiSpacing.md),
          Text(title, style: FudiTypography.h4),
          TextButton(onPressed: onTap, child: Text(action)),
        ],
      ),
    );
  }
}

class _QuickActionData {
  const _QuickActionData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.path,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String path;
}
