import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/ui/fudi_colors.dart';
import '../../../../core/ui/fudi_pressable_scale.dart';
import '../../../../core/ui/fudi_spacing.dart';
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
      return 'Dpto';
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
      return Icons.apartment_rounded;
    case HousingType.house:
      return Icons.home_outlined;
    case HousingType.office:
      return Icons.work_outline_rounded;
    case HousingType.building:
      return Icons.business_rounded;
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

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(FudiRadius.xxl),
        border: Border.all(color: FudiColors.borderSolid),
        boxShadow: [
          BoxShadow(
            color: FudiColors.foreground.withValues(alpha: 0.015),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(FudiSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Contenedor del Icono Principal del Tipo de Dirección
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isDefault
                      ? FudiColors.primary.withValues(alpha: 0.08)
                      : FudiColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  addressTypeIcon(address.type),
                  color: isDefault ? FudiColors.primary : FudiColors.foreground,
                  size: 22,
                ),
              ),
              const SizedBox(width: FudiSpacing.md),

              // Bloque Textual Principal
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            address.label,
                            style: FudiTypography.labelMedium.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (address.housingType != null) ...[
                          const SizedBox(width: 8),
                          _buildHousingBadge(address.housingType!),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      address.address,
                      style: FudiTypography.bodyMedium.copyWith(
                        color: FudiColors.mutedForeground,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Referencias Estilizadas
                    if (address.references != null &&
                        address.references!.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: FudiColors.surfaceMuted,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.turn_left_rounded,
                              size: 14,
                              color: FudiColors.mutedForeground,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                address.references!,
                                style: FudiTypography.bodySmall.copyWith(
                                  color: FudiColors.mutedForeground,
                                  fontSize: 11,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: FudiSpacing.xs),
          const Divider(height: 1, color: FudiColors.surfaceMuted),
          const SizedBox(height: FudiSpacing.xs),

          // Fila Inferior Unificada de Acciones (Fin del desorden de Positioned)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: isDefault
                      ? _buildDefaultBadge()
                      : _buildSetDefaultButton(ref),
                ),
              ),
              if (!isDefault) ...[
                const SizedBox(width: FudiSpacing.md),
                FudiPressableScale(
                  scaleEnd: 0.9,
                  onTap: () => _confirmDelete(context, ref),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: FudiColors.destructiveSurface,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.delete_outline_rounded,
                      size: 18,
                      color: FudiColors.destructiveVibrant,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHousingBadge(HousingType type) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: FudiColors.surfaceMuted,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            addressHousingTypeIcon(type),
            size: 11,
            color: FudiColors.mutedForeground,
          ),
          const SizedBox(width: 4),
          Text(
            addressHousingTypeLabel(type).toUpperCase(),
            style: FudiTypography.labelSmall.copyWith(
              fontSize: 9,
              color: FudiColors.mutedForeground,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultBadge() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.check_circle_rounded,
          size: 16,
          color: FudiColors.success,
        ),
        const SizedBox(width: 6),
        Text(
          'Ubicación activa',
          style: FudiTypography.labelSmall.copyWith(
            color: FudiColors.success,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildSetDefaultButton(WidgetRef ref) {
    return Align(
      alignment: Alignment.centerLeft,
      child: FudiPressableScale(
        onTap: () => _setDefault(ref),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Text(
            'Usar como predeterminada',
            style: FudiTypography.labelSmall.copyWith(
              fontWeight: FontWeight.bold,
              color: FudiColors.primary,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: FudiColors.borderSolid,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '¿Eliminar dirección?',
              style: FudiTypography.headlineSmall.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'La ubicación "${address.label}" dejará de estar disponible para tus pedidos rápidos.',
              style: FudiTypography.bodyMedium.copyWith(
                color: FudiColors.mutedForeground,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: FudiPressableScale(
                    onTap: () => Navigator.of(ctx).pop(false),
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: FudiColors.surfaceMuted,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          'Cancelar',
                          style: FudiTypography.labelSmall.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FudiPressableScale(
                    onTap: () => Navigator.of(ctx).pop(true),
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: FudiColors.destructiveVibrant,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                          child: Text(
                            'Eliminar',
                            style: FudiTypography.labelSmall.copyWith(
                              color: FudiColors.primaryForeground,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
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
