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
import '../../../core/ui/atoms/icons/fudi_icons.dart';
import '../domain/saved_address_model.dart';
import 'components/add_address_sheet.dart';
import 'components/saved_address_card.dart';
import 'profile_providers.dart';

// ─── Screen ─────────────────────────────────────────────────────────

class SavedAddressesScreen extends ConsumerWidget {
  const SavedAddressesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final addressesAsync = ref.watch(savedAddressesProvider);

    return Scaffold(
      appBar: FudiStickyPageHeader(
        title: 'Direcciones guardadas',
        leading: Padding(
          padding: const EdgeInsets.only(left: FudiSpacing.xs),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              FudiPressableScale(
                onTap: () => context.pop(),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(color: FudiColors.muted, shape: BoxShape.circle),
                  child: const Icon(FudiIcons.chevronLeft, size: 20),
                ),
              ),
              const Icon(FudiIcons.mapPin, size: 20, color: FudiColors.primary),
            ],
          ),
        ),
      ),
      body: addressesAsync.when(
        data: (addresses) => _AddressListContent(addresses: addresses),
        loading: () => const Center(child: CircularProgressIndicator()),
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
      padding: const EdgeInsets.fromLTRB(
        FudiSpacing.lg,
        FudiSpacing.lg,
        FudiSpacing.lg,
        FudiSpacing.xxl + FudiSpacing.lg,
      ),
      children: [
        FudiPressableScale(
          onTap: () => showAddAddressSheet(context, ref),
          child: Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              color: FudiColors.primary,
              borderRadius: BorderRadius.circular(FudiRadius.xl),
            ),
            child: const Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(FudiIcons.plus, size: 20, color: FudiColors.primaryForeground),
                  SizedBox(width: 8),
                  Text('Agregar dirección', style: TextStyle(color: FudiColors.primaryForeground)),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: FudiSpacing.lg),

        const FudiInfoBanner(
          message:
              'Guarda tus direcciones para encontrar ofertas cerca de ti más rápidamente',
        ),

        const SizedBox(height: FudiSpacing.lg),

        if (addresses.isEmpty)
          const FudiEmptyState(
            icon: FudiIcons.mapPin,
            iconSize: 64,
            title: 'No tienes direcciones guardadas',
            description: 'Agrega una dirección para encontrar ofertas cerca de ti',
            padding: EdgeInsets.symmetric(vertical: FudiSpacing.xxl),
          ),

        ...addresses.map(
          (address) => TweenAnimationBuilder<double>(
            key: ValueKey('${address.id}-${address.isDefault}'),
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, -30 * (1 - value)),
                  child: child,
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.only(bottom: FudiSpacing.md),
              child: SavedAddressCard(address: address),
            ),
          ),
        ),
      ],
    );
  }
}
