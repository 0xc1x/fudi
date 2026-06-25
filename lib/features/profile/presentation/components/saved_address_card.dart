import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/ui/fudi_colors.dart';
import '../../../../core/ui/fudi_pressable_scale.dart';
import '../../../../core/ui/fudi_spacing.dart';
import '../../../../core/ui/fudi_surface_card.dart';
import '../../../../core/ui/fudi_typography.dart';
import '../../../../core/ui/atoms/icons/fudi_icons.dart';
import '../../domain/saved_address_model.dart';
import '../profile_providers.dart';

// ─── Helpers ────────────────────────────────────────────────────────

IconData addressTypeIcon(AddressType type) {
  switch (type) {
    case AddressType.home:
      return FudiIcons.home;
    case AddressType.work:
      return Icons.work_outline_rounded;
    case AddressType.other:
      return FudiIcons.mapPin;
  }
}

String addressHousingTypeLabel(HousingType? type) {
  if (type == null) return '';
  switch (type) {
    case HousingType.apartment:
      return 'Apartamento';
    case HousingType.house:
      return 'Casa';
    case HousingType.office:
      return 'Oficina';
    case HousingType.building:
      return 'Edificio';
    case HousingType.other:
      return 'Otro';
  }
}

IconData addressHousingTypeIcon(HousingType? type) {
  if (type == null) return Icons.home_work_outlined;
  switch (type) {
    case HousingType.apartment:
      return Icons.apartment;
    case HousingType.house:
      return Icons.home_outlined;
    case HousingType.office:
      return Icons.work_outline_rounded;
    case HousingType.building:
      return Icons.business;
    case HousingType.other:
      return Icons.home_work_outlined;
  }
}

// ─── Saved Address Card ─────────────────────────────────────────────

class SavedAddressCard extends ConsumerWidget {
  const SavedAddressCard({super.key, required this.address});

  final SavedAddressModel address;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDefault = address.isDefault;

    return FudiSurfaceCard(
      padding: EdgeInsets.zero, // Usamos Stack con padding interno
      child: Stack(
        children: [
          // Contenido principal
          Padding(
            padding: const EdgeInsets.all(FudiSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icono principal
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(FudiRadius.xl),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            FudiColors.primary.withValues(alpha: 0.15),
                            FudiColors.accent.withValues(alpha: 0.12),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: FudiColors.primary.withValues(alpha: 0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        addressTypeIcon(address.type),
                        color: FudiColors.primary,
                        size: 26,
                      ),
                    ),

                    const SizedBox(width: FudiSpacing.md),

                    // Información
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            address.label,
                            style: FudiTypography.labelMedium.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            address.address,
                            style: FudiTypography.bodyMedium,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (address.references != null &&
                              address.references!.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(
                                  Icons.info_outline_rounded,
                                  size: 15,
                                  color: FudiColors.mutedForeground,
                                ),
                                const SizedBox(width: 5),
                                Expanded(
                                  child: Text(
                                    'Ref: ${address.references}',
                                    style: FudiTypography.bodySmall.copyWith(
                                      color: FudiColors.mutedForeground,
                                      fontStyle: FontStyle.italic,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
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

                const SizedBox(height: FudiSpacing.lg),

                // Badge predeterminado o botón
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: isDefault
                      ? _buildDefaultBadge()
                      : _buildSetDefaultButton(ref),
                ),
              ],
            ),
          ),

          // Badge de tipo de vivienda - Esquina superior derecha
          if (address.housingType != null)
            Positioned(
              top: FudiSpacing.lg,
              right: FudiSpacing.lg,
              child: _buildHousingBadge(address.housingType!),
            ),

          // Botón eliminar - Esquina inferior derecha (más grande)
          Positioned(
            bottom: FudiSpacing.lg,
            right: FudiSpacing.lg,
            child: FudiPressableScale(
              scaleEnd: 0.85,
              onTap: () => _confirmDelete(context, ref),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: FudiColors.muted,
                  shape: BoxShape.circle,
                  border: Border.all(color: FudiColors.border, width: 1),
                ),
                child: Icon(
                  FudiIcons.delete,
                  size: 22,
                  color: FudiColors.destructive,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHousingBadge(HousingType type) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: FudiSpacing.sm + 2,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: FudiColors.muted.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(FudiRadius.lg),
        border: Border.all(color: FudiColors.border.withValues(alpha: 0.6)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            addressHousingTypeIcon(type),
            size: 14,
            color: FudiColors.mutedForeground,
          ),
          const SizedBox(width: 5),
          Text(
            addressHousingTypeLabel(type),
            style: FudiTypography.bodySmall.copyWith(
              fontSize: 12,
              color: FudiColors.mutedForeground,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: FudiSpacing.md,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: FudiColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(FudiRadius.lg),
        border: Border.all(
          color: FudiColors.primary.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(FudiIcons.checkCircle, size: 18, color: FudiColors.primary),
          const SizedBox(width: FudiSpacing.xs),
          Text(
            'Dirección predeterminada',
            style: FudiTypography.bodySmall.copyWith(
              color: FudiColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSetDefaultButton(WidgetRef ref) {
    return FudiPressableScale(
      onTap: () => _setDefault(ref),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: FudiSpacing.md,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: FudiColors.muted,
          borderRadius: BorderRadius.circular(FudiRadius.lg),
          border: Border.all(color: FudiColors.border),
        ),
        child: Text(
          'Establecer como predeterminada',
          style: FudiTypography.bodySmall.copyWith(
            fontWeight: FontWeight.w600,
            color: FudiColors.foreground,
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar dirección'),
        content: Text(
          '¿Estás seguro de que deseas eliminar "${address.label}"?',
        ),
        actions: [
          FudiPressableScale(
            onTap: () => Navigator.of(ctx).pop(false),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: FudiColors.primary),
              ),
            ),
          ),
          FudiPressableScale(
            onTap: () => Navigator.of(ctx).pop(true),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: FudiColors.destructive,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Eliminar',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref
          .read(consumerProfileRepositoryProvider)
          .deleteAddress(address.id);
      ref.invalidate(savedAddressesProvider);
      ref.invalidate(userSelectedAddressProvider);
    }
  }

  Future<void> _setDefault(WidgetRef ref) async {
    await ref
        .read(consumerProfileRepositoryProvider)
        .setDefaultAddress(address.id);
    ref.invalidate(savedAddressesProvider);
    ref.invalidate(userSelectedAddressProvider);
  }
}
