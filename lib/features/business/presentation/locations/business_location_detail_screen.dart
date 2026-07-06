import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/ui/atoms/icons/fudi_icons.dart';
import '../../../../core/ui/fudi_colors.dart';
import '../../../../core/ui/fudi_theme.dart';
import '../../../../core/ui/fudi_pressable_scale.dart';
import '../../../../core/ui/fudi_spacing.dart';
import '../../../../core/ui/fudi_surface_card.dart';
import '../../../../core/ui/fudi_typography.dart';
import '../../domain/business_location.dart';
import '../business_providers.dart';

class BusinessLocationDetailScreen extends ConsumerWidget {
  const BusinessLocationDetailScreen({
    required this.locationId,
    super.key,
  });

  final String locationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locationAsync = ref.watch(businessLocationProvider(locationId));
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: Semantics(
          label: 'Volver',
          button: true,
          child: FudiPressableScale(
            onTap: () => context.pop(),
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Icon(FudiIcons.arrowLeft, size: 20),
            ),
          ),
        ),
        title: const Text('Detalle de sucursal'),
      ),
      body: locationAsync.when(
        data: (location) => _DetailContent(location: location),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(FudiSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(FudiIcons.alertTriangle,
                    size: 48, color: colorScheme.onSurfaceVariant),
                const SizedBox(height: FudiSpacing.md),
                Text(
                  'No pudimos cargar esta sucursal',
                  textAlign: TextAlign.center,
                  style: FudiTypography.bodyMedium.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: FudiSpacing.lg),
                FudiPressableScale(
                  onTap: () =>
                      ref.invalidate(businessLocationProvider(locationId)),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: FudiSpacing.lg,
                      vertical: FudiSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: FudiColors.primary,
                      borderRadius: BorderRadius.circular(FudiRadius.md),
                    ),
                    child: Text(
                      'Reintentar',
                      style: FudiTypography.bodyMedium.copyWith(
                        color: FudiColors.primaryForeground,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailContent extends StatelessWidget {
  const _DetailContent({required this.location});

  final BusinessLocation location;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(FudiSpacing.md),
      children: [
        _InfoCard(location: location),
        const SizedBox(height: FudiSpacing.md),
        _ActionsCard(locationId: location.id),
        const SizedBox(height: FudiSpacing.md),
        _LocationMeta(location: location),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.location});

  final BusinessLocation location;

  @override
  Widget build(BuildContext context) {
    return FudiSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: FudiColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(FudiRadius.sm),
                ),
                child: const Icon(
                  Icons.store_rounded,
                  color: FudiColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: FudiSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      location.name,
                      style: FudiTypography.h3.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _StatusChip(isActive: location.isActive),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: FudiSpacing.lg),
          const Divider(height: 1),
          const SizedBox(height: FudiSpacing.lg),
          _InfoRow(
            icon: Icons.location_on_outlined,
            label: 'Dirección',
            value: location.address,
          ),
          if (location.phone != null) ...[
            const SizedBox(height: FudiSpacing.md),
            _InfoRow(
              icon: Icons.phone_outlined,
              label: 'Teléfono',
              value: location.phone!,
            ),
          ],
          if (location.zone != null) ...[
            const SizedBox(height: FudiSpacing.md),
            _InfoRow(
              icon: Icons.map_outlined,
              label: 'Zona',
              value: location.zone!,
            ),
          ],
          if (location.isHeadquarter) ...[
            const SizedBox(height: FudiSpacing.md),
            Row(
              children: [
                const Icon(Icons.star_rounded,
                    size: 16, color: FudiColors.warning),
                const SizedBox(width: FudiSpacing.xs),
                Text(
                  'Sucursal principal',
                  style: FudiTypography.bodySmall.copyWith(
                    color: FudiColors.warning,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
          if (location.hasCoordinates) ...[
            const SizedBox(height: FudiSpacing.md),
            _InfoRow(
              icon: Icons.pin_drop_outlined,
              label: 'Coordenadas',
              value:
                  '${location.latitude!.toStringAsFixed(6)}, ${location.longitude!.toStringAsFixed(6)}',
            ),
          ],
          if (location.createdAt != null) ...[
            const SizedBox(height: FudiSpacing.md),
            _InfoRow(
              icon: Icons.calendar_today_outlined,
              label: 'Creada',
              value: _formatDate(location.createdAt!),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.isActive});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final themeExt = Theme.of(context).extension<FudiThemeExtension>();
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isActive
            ? FudiColors.success.withValues(alpha: 0.15)
            : (themeExt?.mutedBackground ?? FudiColors.muted),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        isActive ? 'Activa' : 'Inactiva',
        style: FudiTypography.bodySmall.copyWith(
          color: isActive ? FudiColors.success : colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: colorScheme.onSurfaceVariant),
        const SizedBox(width: FudiSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: FudiTypography.bodySmall.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: FudiTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActionsCard extends StatelessWidget {
  const _ActionsCard({required this.locationId});

  final String locationId;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return FudiSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Acciones',
            style: FudiTypography.labelSmall.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: FudiSpacing.md),
          Semantics(
            label: 'Editar sucursal',
            button: true,
            child: FudiPressableScale(
              onTap: () => context.push('/business/locations/$locationId/edit'),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: FudiColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(FudiRadius.sm),
                    ),
                    child: const Icon(Icons.edit_outlined,
                        size: 18, color: FudiColors.primary),
                  ),
                  const SizedBox(width: FudiSpacing.md),
                  Text(
                    'Editar información',
                    style: FudiTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.chevron_right_rounded,
                      color: colorScheme.onSurfaceVariant),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LocationMeta extends StatelessWidget {
  const _LocationMeta({required this.location});

  final BusinessLocation location;

  @override
  Widget build(BuildContext context) {
    return FudiSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Información del sistema',
            style: FudiTypography.labelSmall.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: FudiSpacing.md),
          _MetaRow(label: 'ID', value: location.id),
          const SizedBox(height: FudiSpacing.sm),
          _MetaRow(label: 'ID negocio', value: location.businessId),
        ],
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: FudiTypography.bodySmall.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: SelectableText(
            value,
            style: FudiTypography.bodySmall.copyWith(
              fontFamily: 'monospace',
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}
