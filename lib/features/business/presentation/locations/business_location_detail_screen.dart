import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/ui/fudi_colors.dart';
import '../../../../core/ui/atoms/icons/fudi_icons.dart';
import '../../../../core/ui/fudi_spacing.dart';
import '../../../../core/ui/fudi_surface_card.dart';
import '../../../../core/ui/fudi_typography.dart';
import '../../domain/business_location.dart';
import '../../domain/business_profile.dart';
import '../../domain/business_stats.dart';
import '../business_providers.dart';
import '../business_profile_providers.dart';

class BusinessLocationDetailScreen extends ConsumerWidget {
  const BusinessLocationDetailScreen({required this.locationId, super.key});

  final String locationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locationAsync = ref.watch(businessLocationProvider(locationId));
    return Scaffold(
      backgroundColor: FudiColors.muted,
      body: locationAsync.when(
        data: (location) {
          final profileAsync = ref.watch(
            businessProfileProvider(location.businessId),
          );
          final statsAsync = ref.watch(
            businessStatsProvider(location.businessId),
          );
          return profileAsync.when(
            data: (profile) => _DetailContent(
              location: location,
              profile: profile,
              statsAsync: statsAsync,
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, _) => _DetailContent(
              location: location,
              profile: null,
              statsAsync: statsAsync,
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
      ),
    );
  }
}

class _DetailContent extends ConsumerWidget {
  const _DetailContent({
    required this.location,
    this.profile,
    required this.statsAsync,
  });

  final BusinessLocation location;
  final BusinessProfile? profile;
  final AsyncValue<BusinessStats> statsAsync;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          backgroundColor: FudiColors.background,
          leading: Padding(
            padding: const EdgeInsets.all(FudiSpacing.sm),
            child: InkWell(
              onTap: () => context.pop(),
              borderRadius: BorderRadius.circular(FudiRadius.full),
              child: Container(
                decoration: BoxDecoration(
                  color: FudiColors.muted,
                  shape: BoxShape.circle,
                ),
                child: const Icon(FudiIcons.arrowLeft, size: 20),
              ),
            ),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Detalle del local', style: FudiTypography.h3),
              Text(
                location.isActive ? 'Activo' : 'Inactivo',
                style: FudiTypography.bodySmall.copyWith(
                  color: location.isActive
                      ? Colors.green
                      : FudiColors.mutedForeground,
                ),
              ),
            ],
          ),
        ),
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HeroImage(location: location, profile: profile),
              Padding(
                padding: const EdgeInsets.all(FudiSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _StatsGrid(statsAsync: statsAsync),
                    const SizedBox(height: FudiSpacing.md),
                    _ActionButtons(location: location),
                    const SizedBox(height: FudiSpacing.md),
                    _LocationInfoCard(location: location, profile: profile),
                    const SizedBox(height: FudiSpacing.md),
                    if (profile != null && profile!.hours.isNotEmpty)
                      _OpeningHoursCard(hours: profile!.hours),
                    if (profile != null && profile!.hours.isNotEmpty)
                      const SizedBox(height: FudiSpacing.md),
                    _PerformanceCard(
                      location: location,
                      statsAsync: statsAsync,
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HeroImage extends StatelessWidget {
  const _HeroImage({required this.location, this.profile});

  final BusinessLocation location;
  final BusinessProfile? profile;

  @override
  Widget build(BuildContext context) {
    final imageUrl = profile?.coverImageUrl ?? profile?.imageUrl;
    return SizedBox(
      height: 220,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (imageUrl != null)
            CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              errorWidget: (_, _, _) => _ImageFallback(),
              placeholder: (_, _) => _ImageFallback(),
            )
          else
            const _ImageFallback(),
          if (!location.isActive)
            Container(
              color: Colors.black.withValues(alpha: 0.5),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: FudiSpacing.md,
                    vertical: FudiSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(FudiRadius.full),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        FudiIcons.eyeOff,
                        size: 16,
                        color: FudiColors.destructive,
                      ),
                      const SizedBox(width: FudiSpacing.sm),
                      const Text(
                        'Local inactivo',
                        style: TextStyle(fontWeight: FontWeight.w600),
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

class _ImageFallback extends StatelessWidget {
  const _ImageFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: FudiColors.primary.withValues(alpha: 0.1),
      child: const Icon(
        FudiIcons.storefront,
        size: 64,
        color: FudiColors.primary,
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.statsAsync});

  final AsyncValue<BusinessStats> statsAsync;

  @override
  Widget build(BuildContext context) {
    final stats = statsAsync.value;
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: FudiIcons.package_,
            value: '${stats?.ordersCount ?? 0}',
            label: 'Ventas',
            iconColor: FudiColors.primary,
            valueColor: FudiColors.primary,
          ),
        ),
        const SizedBox(width: FudiSpacing.sm),
        Expanded(
          child: _StatCard(
            icon: FudiIcons.user,
            value: '${stats?.rescuedCount ?? 0}',
            label: 'Rescatadas',
            iconColor: Colors.green,
            valueColor: Colors.green,
          ),
        ),
        const SizedBox(width: FudiSpacing.sm),
        Expanded(
          child: _StatCard(
            icon: FudiIcons.star,
            value: stats != null ? stats.avgRating.toStringAsFixed(1) : '0.0',
            label: 'Rating',
            iconColor: Colors.orange,
            valueColor: Colors.orange,
          ),
        ),
        const SizedBox(width: FudiSpacing.sm),
        Expanded(
          child: _StatCard(
            icon: FudiIcons.trendingUp,
            value: '${stats?.topProducts.length ?? 0}',
            label: 'Productos',
            iconColor: Colors.blue,
            valueColor: Colors.blue,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.iconColor,
    required this.valueColor,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color iconColor;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return FudiSurfaceCard(
      padding: const EdgeInsets.all(FudiSpacing.sm),
      child: Column(
        children: [
          Icon(icon, size: 20, color: iconColor),
          const SizedBox(height: 4),
          Text(
            value,
            style: FudiTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: valueColor,
              fontSize: 16,
            ),
          ),
          Text(
            label,
            style: FudiTypography.bodySmall.copyWith(
              color: FudiColors.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButtons extends ConsumerWidget {
  const _ActionButtons({required this.location});

  final BusinessLocation location;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Expanded(
          child: FilledButton.icon(
            onPressed: () =>
                context.push('/business/locations/${location.id}/edit'),
            icon: const Icon(FudiIcons.store, size: 16),
            label: const Text('Editar'),
            style: FilledButton.styleFrom(
              backgroundColor: FudiColors.primary,
              foregroundColor: FudiColors.primaryForeground,
              padding: const EdgeInsets.symmetric(vertical: FudiSpacing.md),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(FudiRadius.xl),
              ),
            ),
          ),
        ),
        const SizedBox(width: FudiSpacing.sm),
        Expanded(
          child: location.isActive
              ? OutlinedButton.icon(
                  onPressed: () async {
                    await ref
                        .read(businessLocationRepositoryProvider)
                        .toggleLocationStatus(location.id, false);
                    ref.invalidate(businessLocationProvider(location.id));
                    ref.invalidate(
                      businessLocationsProvider(location.businessId),
                    );
                  },
                  icon: const Icon(FudiIcons.eyeOff, size: 16),
                  label: const Text('Desactivar'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: FudiSpacing.md,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(FudiRadius.xl),
                    ),
                  ),
                )
              : FilledButton.icon(
                  onPressed: () async {
                    await ref
                        .read(businessLocationRepositoryProvider)
                        .toggleLocationStatus(location.id, true);
                    ref.invalidate(businessLocationProvider(location.id));
                    ref.invalidate(
                      businessLocationsProvider(location.businessId),
                    );
                  },
                  icon: const Icon(FudiIcons.eye, size: 16),
                  label: const Text('Activar'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: FudiSpacing.md,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(FudiRadius.xl),
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}

class _LocationInfoCard extends StatelessWidget {
  const _LocationInfoCard({required this.location, this.profile});

  final BusinessLocation location;
  final BusinessProfile? profile;

  @override
  Widget build(BuildContext context) {
    return FudiSurfaceCard(
      padding: const EdgeInsets.all(FudiSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(location.name, style: FudiTypography.h2),
          const SizedBox(height: FudiSpacing.md),
          _LabeledInfoRow(
            icon: FudiIcons.mapPin,
            label: 'Dirección',
            value: location.address,
          ),
          if (location.phone?.isNotEmpty == true) ...[
            const SizedBox(height: FudiSpacing.md),
            _LabeledInfoRow(
              icon: FudiIcons.phone,
              label: 'Teléfono',
              value: location.phone!,
            ),
          ],
          if (profile?.email != null) ...[
            const SizedBox(height: FudiSpacing.md),
            _LabeledInfoRow(
              icon: FudiIcons.mail,
              label: 'Email',
              value: profile!.email!,
            ),
          ],
        ],
      ),
    );
  }
}

class _LabeledInfoRow extends StatelessWidget {
  const _LabeledInfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: FudiColors.primary),
        const SizedBox(width: FudiSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: FudiTypography.bodySmall.copyWith(
                  color: FudiColors.mutedForeground,
                ),
              ),
              const SizedBox(height: 2),
              Text(value, style: FudiTypography.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }
}

class _OpeningHoursCard extends StatelessWidget {
  const _OpeningHoursCard({required this.hours});

  final List<BusinessHours> hours;

  @override
  Widget build(BuildContext context) {
    return FudiSurfaceCard(
      padding: const EdgeInsets.all(FudiSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(FudiIcons.clock, size: 20, color: FudiColors.primary),
              const SizedBox(width: FudiSpacing.sm),
              Text(
                'Horario de atención',
                style: FudiTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: FudiSpacing.md),
          ...hours.map(
            (h) => Padding(
              padding: const EdgeInsets.only(bottom: FudiSpacing.sm),
              child: _HoursRow(day: h.day, hours: h.hours),
            ),
          ),
        ],
      ),
    );
  }
}

class _HoursRow extends StatelessWidget {
  const _HoursRow({required this.day, required this.hours});

  final String day;
  final String hours;

  @override
  Widget build(BuildContext context) {
    final isLast = hours == 'Cerrado';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: FudiSpacing.sm),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: FudiColors.borderSolid)),
        ),
        child: Padding(
          padding: const EdgeInsets.only(bottom: FudiSpacing.sm),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                day,
                style: FudiTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                hours,
                style: FudiTypography.bodySmall.copyWith(
                  color: isLast
                      ? FudiColors.destructive
                      : FudiColors.mutedForeground,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PerformanceCard extends StatelessWidget {
  const _PerformanceCard({required this.location, required this.statsAsync});

  final BusinessLocation location;
  final AsyncValue<BusinessStats> statsAsync;

  @override
  Widget build(BuildContext context) {
    final stats = statsAsync.value;
    final salesCount = stats?.ordersCount ?? 0;
    final rescuedCount = stats?.rescuedCount ?? 0;
    final avgRating = stats?.avgRating ?? 0.0;
    final activeProducts = stats?.topProducts.length ?? 0;
    final monthlyAvg = salesCount > 0 ? (salesCount / 12).round() : 0;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(FudiRadius.xl),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            FudiColors.primary,
            FudiColors.primary.withValues(alpha: 0.8),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: FudiColors.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(FudiSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resumen de rendimiento',
              style: FudiTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: FudiSpacing.sm),
            Text(
              'Este local ha realizado $salesCount ventas y ha rescatado $rescuedCount comidas, con una calificación promedio de ${avgRating.toStringAsFixed(1)} estrellas.',
              style: FudiTypography.bodySmall.copyWith(
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
            const SizedBox(height: FudiSpacing.md),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Productos activos',
                        style: FudiTypography.bodySmall.copyWith(
                          color: Colors.white.withValues(alpha: 0.75),
                        ),
                      ),
                      Text(
                        '$activeProducts',
                        style: FudiTypography.h2.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Promedio mensual',
                        style: FudiTypography.bodySmall.copyWith(
                          color: Colors.white.withValues(alpha: 0.75),
                        ),
                      ),
                      Text(
                        '$monthlyAvg ventas',
                        style: FudiTypography.h2.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
