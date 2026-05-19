import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/ui/fudi_colors.dart';
import '../../../core/ui/fudi_icons.dart';
import '../../../core/ui/fudi_spacing.dart';
import '../../../core/ui/fudi_typography.dart';
import '../../../core/ui/fudi_sticky_page_header.dart';
import '../../../core/ui/fudi_surface_card.dart';
import '../../../core/ui/fudi_bottom_action_bar.dart';
import 'profile_providers.dart';

class SavedAddressesScreen extends ConsumerWidget {
  const SavedAddressesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final addressesAsync = ref.watch(savedAddressesProvider);

    return Scaffold(
      appBar: const FudiStickyPageHeader(title: 'Mis Direcciones'),
      body: addressesAsync.when(
        data: (addresses) {
          if (addresses.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(FudiIcons.mapPin, size: 64, color: FudiColors.mutedForeground),
                  const SizedBox(height: FudiSpacing.md),
                  Text('No tienes direcciones guardadas', style: FudiTypography.bodyLarge),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(FudiSpacing.lg),
            itemCount: addresses.length,
            separatorBuilder: (_, _) => const SizedBox(height: FudiSpacing.md),
            itemBuilder: (context, index) {
              final address = addresses[index];
              return FudiSurfaceCard(
                child: ListTile(
                  leading: const Icon(FudiIcons.mapPin, color: FudiColors.primary),
                  title: Row(
                    children: [
                      Text(address.label, style: FudiTypography.labelSmall),
                      if (address.isDefault) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: FudiColors.secondary,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text('PRINCIPAL', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: FudiColors.primary)),
                        ),
                      ],
                    ],
                  ),
                  subtitle: Text(address.address, style: FudiTypography.bodySmall),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: FudiColors.destructive),
                    onPressed: () => _deleteAddress(ref, address.id),
                  ),
                  onTap: () => _setDefault(ref, address.id),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
      bottomNavigationBar: FudiBottomActionBar(
        child: FilledButton(
          onPressed: () => _addAddress(context),
          style: FilledButton.styleFrom(
            backgroundColor: FudiColors.primary,
            minimumSize: const Size.fromHeight(56),
          ),
          child: const Text('Agregar nueva dirección'),
        ),
      ),
    );
  }

  void _deleteAddress(WidgetRef ref, String id) {
    ref.read(consumerProfileRepositoryProvider).deleteAddress(id);
    ref.invalidate(savedAddressesProvider);
  }

  void _setDefault(WidgetRef ref, String id) {
    ref.read(consumerProfileRepositoryProvider).setDefaultAddress(id);
    ref.invalidate(savedAddressesProvider);
  }

  void _addAddress(BuildContext context) {
    // Implement address picker or form
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Funcionalidad en desarrollo')));
  }
}
