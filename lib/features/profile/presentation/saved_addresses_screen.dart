import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/ui/fudi_colors.dart';
import '../../../core/ui/fudi_empty_state.dart';
import '../../../core/ui/fudi_error_state.dart';
import '../../../core/ui/fudi_info_banner.dart';
import '../../../core/ui/fudi_pressable_scale.dart';
import '../../../core/ui/fudi_spacing.dart';
import '../../../core/ui/fudi_sticky_page_header.dart';
import '../../../core/ui/fudi_typography.dart';
import '../../../core/ui/atoms/icons/fudi_icons.dart';
import '../domain/saved_address_model.dart';
import 'components/add_address_sheet.dart';
import 'components/saved_address_card.dart';
import 'profile_providers.dart';

class SavedAddressesScreen extends ConsumerWidget {
  const SavedAddressesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final addressesAsync = ref.watch(savedAddressesProvider);

    return Scaffold(
      backgroundColor: FudiColors.background,
      appBar: FudiStickyPageHeader(
        title: 'Direcciones',
        leading: Padding(
          padding: const EdgeInsets.only(left: FudiSpacing.xs),
          child: FudiPressableScale(
            onTap: () => context.pop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: FudiColors.borderSolid),
              ),
              child: const Icon(
                FudiIcons.chevronLeft,
                size: 18,
                color: FudiColors.foreground,
              ),
            ),
          ),
        ),
      ),
      body: addressesAsync.when(
        data: (addresses) => _AddressListContent(addresses: addresses),
        loading: () =>
            const Center(child: CircularProgressIndicator.adaptive()),
        error: (error, _) => FudiErrorState(
          message: error.toString(),
          onRetry: () => ref.invalidate(savedAddressesProvider),
        ),
      ),
    );
  }
}

// ─── Address List Content ───────────────────────────────────────────

class _AddressListContent extends ConsumerWidget {
  const _AddressListContent({required this.addresses});

  final List<SavedAddressModel> addresses;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        FudiSpacing.xl,
        FudiSpacing.lg,
        FudiSpacing.xl,
        FudiSpacing.xxl,
      ),
      children: [
        // Botón de Acción Principal Superior (Estilo Brutalita Minimal)
        FudiPressableScale(
          onTap: () => showAddAddressSheet(context, ref),
          child: Container(
            width: double.infinity,
            height: 54,
            decoration: BoxDecoration(
              color: FudiColors.foreground,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(FudiIcons.plus, size: 18, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  'Nueva dirección',
                  style: FudiTypography.labelMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: FudiSpacing.xl),

        const FudiInfoBanner(
          message:
              'Guardar tus ubicaciones te ayuda a rescatar comida más rápido antes de que se agote.',
        ),

        const SizedBox(height: FudiSpacing.xl),

        if (addresses.isEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Column(
              children: [
                const FudiEmptyState(
                  icon: FudiIcons.mapPin,
                  iconSize: 56,
                  title: 'Sin direcciones aún',
                  description:
                      'Configura tus lugares frecuentes para geolocalizar packs sorpresa cerca de ti.',
                  padding: EdgeInsets.zero,
                ),
                const SizedBox(height: FudiSpacing.xl),
                FudiPressableScale(
                  onTap: () => showAddAddressSheet(context, ref),
                  child: Text(
                    'Configurar primera dirección',
                    style: FudiTypography.bodyMedium.copyWith(
                      color: FudiColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ] else ...[
          // Subtítulo de Sección Limpio
          Text(
            'Tus ubicaciones guardadas'.toUpperCase(),
            style: FudiTypography.labelSmall.copyWith(
              color: FudiColors.mutedForeground,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: FudiSpacing.md),

          // Render Dinámico con animaciones y soporte Swipe-to-Delete
          ...addresses.map(
            (address) => TweenAnimationBuilder<double>(
              key: ValueKey('${address.id}-${address.isDefault}'),
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 20 * (1 - value)),
                    child: child,
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.only(bottom: FudiSpacing.sm),
                child: address.isDefault
                    ? SavedAddressCard(address: address)
                    : ClipRRect(
                        // CORRECCIÓN: Forzamos un recorte redondeado externo de la misma proporción
                        // que la card para que el fondo no se asome plano por los bordes izquierdos.
                        borderRadius: BorderRadius.circular(20),
                        child: Dismissible(
                          key: Key(address.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            decoration: const BoxDecoration(
                              color: FudiColors.destructiveSurface,
                            ),
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 24),
                            child: const Icon(
                              Icons.delete_outline_rounded,
                              color: FudiColors.destructiveVibrant,
                              size: 22,
                            ),
                          ),
                          confirmDismiss: (direction) async {
                            final confirmed = await showModalBottomSheet<bool>(
                              context: context,
                              backgroundColor: Colors.white,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(24),
                                ),
                              ),
                              builder: (ctx) => Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  24,
                                  24,
                                  24,
                                  32,
                                ),
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
                                          borderRadius: BorderRadius.circular(
                                            2,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    Text(
                                      '¿Eliminar dirección?',
                                      style: FudiTypography.headlineSmall
                                          .copyWith(
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
                                            onTap: () =>
                                                Navigator.of(ctx).pop(false),
                                            child: Container(
                                              height: 48,
                                              decoration: BoxDecoration(
                                                color: FudiColors.surfaceMuted,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  'Cancelar',
                                                  style: FudiTypography
                                                      .labelSmall
                                                      .copyWith(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: FudiPressableScale(
                                            onTap: () =>
                                                Navigator.of(ctx).pop(true),
                                            child: Container(
                                              height: 48,
                                              decoration: BoxDecoration(
                                                color: FudiColors
                                                    .destructiveVibrant,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  'Eliminar',
                                                  style: FudiTypography
                                                      .labelSmall
                                                      .copyWith(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
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
                            return confirmed ?? false;
                          },
                          onDismissed: (direction) {
                            unawaited(
                              ref
                                  .read(consumerProfileRepositoryProvider)
                                  .deleteAddress(address.id)
                                  .then((_) {
                                    ref.invalidate(savedAddressesProvider);
                                    ref.invalidate(userSelectedAddressProvider);
                                  }),
                            );
                          },
                          child: SavedAddressCard(address: address),
                        ),
                      ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
