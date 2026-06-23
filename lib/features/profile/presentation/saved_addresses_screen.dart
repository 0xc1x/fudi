import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/ui/fudi_colors.dart';
import '../../../core/ui/fudi_info_banner.dart';
import '../../../core/ui/fudi_spacing.dart';
import '../../../core/ui/fudi_sticky_page_header.dart';
import '../../../core/ui/fudi_surface_card.dart';
import '../../../core/ui/fudi_typography.dart';
import '../../../core/ui/atoms/icons/fudi_icons.dart';
import '../domain/saved_address_model.dart';
import 'address_map_picker_screen.dart';
import 'profile_providers.dart';

IconData _typeIcon(AddressType type) {
  switch (type) {
    case AddressType.home:
      return FudiIcons.home;
    case AddressType.work:
      return Icons.work_outline_rounded;
    case AddressType.other:
      return FudiIcons.mapPin;
  }
}

String _housingTypeLabel(HousingType? type) {
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

IconData _housingTypeIcon(HousingType? type) {
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
              IconButton(
                icon: const Icon(FudiIcons.chevronLeft),
                onPressed: () => context.pop(),
              ),
              const Icon(FudiIcons.mapPin, size: 20, color: FudiColors.primary),
            ],
          ),
        ),
      ),
      body: addressesAsync.when(
        data: (addresses) => _AddressListContent(addresses: addresses),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ErrorState(error: error),
      ),
    );
  }
}

// ─── Error State ────────────────────────────────────────────────────

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(FudiSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              FudiIcons.alertCircle,
              size: 48,
              color: FudiColors.mutedForeground,
            ),
            const SizedBox(height: FudiSpacing.lg),
            Text(
              'No se pudieron cargar las direcciones',
              style: FudiTypography.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: FudiSpacing.sm),
            Text(
              error.toString(),
              style: FudiTypography.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
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
        FilledButton.icon(
          onPressed: () => _showAddAddressSheet(context, ref),
          icon: const Icon(FudiIcons.plus, size: 20),
          label: const Text('Agregar dirección'),
          style: FilledButton.styleFrom(
            backgroundColor: FudiColors.primary,
            foregroundColor: FudiColors.primaryForeground,
            minimumSize: const Size.fromHeight(56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(FudiRadius.xl),
            ),
            textStyle: FudiTypography.labelMedium,
          ),
        ),

        const SizedBox(height: FudiSpacing.lg),

        const FudiInfoBanner(
          message:
              '📍 Guarda tus direcciones para encontrar ofertas cerca de ti más rápidamente',
        ),

        const SizedBox(height: FudiSpacing.lg),

        if (addresses.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: FudiSpacing.xxl),
            child: Column(
              children: [
                const Icon(
                  FudiIcons.mapPin,
                  size: 64,
                  color: FudiColors.mutedForeground,
                ),
                const SizedBox(height: FudiSpacing.lg),
                Text(
                  'No tienes direcciones guardadas',
                  style: FudiTypography.bodyLarge,
                ),
                const SizedBox(height: FudiSpacing.sm),
                Text(
                  'Agrega una dirección para encontrar ofertas cerca de ti',
                  style: FudiTypography.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

        ...addresses.map(
          (address) => Padding(
            padding: const EdgeInsets.only(bottom: FudiSpacing.md),
            child: _AddressCard(address: address),
          ),
        ),
      ],
    );
  }
}

// ─── Address Card ───────────────────────────────────────────────────

class _AddressCard extends ConsumerWidget {
  const _AddressCard({required this.address});

  final SavedAddressModel address;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FudiSurfaceCard(
      padding: const EdgeInsets.all(FudiSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(FudiRadius.xl),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      FudiColors.primary.withValues(alpha: 0.2),
                      FudiColors.accent.withValues(alpha: 0.2),
                    ],
                  ),
                ),
                child: Icon(
                  _typeIcon(address.type),
                  color: FudiColors.primary,
                  size: 20,
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
                            address.label,
                            style: FudiTypography.labelSmall,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (address.housingType != null) ...[
                          const SizedBox(width: FudiSpacing.sm),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: FudiSpacing.sm,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: FudiColors.muted,
                              borderRadius: BorderRadius.circular(
                                FudiRadius.md,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _housingTypeIcon(address.housingType),
                                  size: 12,
                                  color: FudiColors.mutedForeground,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _housingTypeLabel(address.housingType),
                                  style: FudiTypography.bodySmall.copyWith(
                                    fontSize: 11,
                                    color: FudiColors.mutedForeground,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      address.address,
                      style: FudiTypography.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (address.references != null &&
                        address.references!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.info_outline,
                            size: 14,
                            color: FudiColors.mutedForeground,
                          ),
                          const SizedBox(width: 4),
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

              const SizedBox(width: FudiSpacing.sm),

              SizedBox(
                width: 32,
                height: 32,
                child: IconButton(
                  onPressed: () => _confirmDelete(context, ref),
                  icon: const Icon(
                    FudiIcons.delete,
                    size: 16,
                    color: FudiColors.destructive,
                  ),
                  padding: EdgeInsets.zero,
                  style: IconButton.styleFrom(
                    backgroundColor: FudiColors.muted,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(FudiRadius.full),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: FudiSpacing.md),

          address.isDefault
              ? Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: FudiSpacing.md,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: FudiColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(FudiRadius.md),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        FudiIcons.checkCircle,
                        size: 16,
                        color: FudiColors.primary,
                      ),
                      const SizedBox(width: FudiSpacing.xs),
                      Text(
                        'Dirección predeterminada',
                        style: FudiTypography.bodySmall.copyWith(
                          color: FudiColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                )
              : InkWell(
                  onTap: () => _setDefault(ref),
                  borderRadius: BorderRadius.circular(FudiRadius.md),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: FudiSpacing.md,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: FudiColors.muted,
                      borderRadius: BorderRadius.circular(FudiRadius.md),
                    ),
                    child: Text(
                      'Establecer como predeterminada',
                      style: FudiTypography.bodySmall.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
        ],
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
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: FudiColors.destructive,
            ),
            child: const Text('Eliminar'),
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

// ─── Add Address Bottom Sheet ───────────────────────────────────────

void _showAddAddressSheet(BuildContext context, WidgetRef ref) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(FudiRadius.xxl)),
    ),
    builder: (_) => const _AddAddressSheet(),
  );
}

class _AddAddressSheet extends ConsumerStatefulWidget {
  const _AddAddressSheet();

  @override
  ConsumerState<_AddAddressSheet> createState() => _AddAddressSheetState();
}

class _AddAddressSheetState extends ConsumerState<_AddAddressSheet> {
  final _labelController = TextEditingController();
  final _addressController = TextEditingController();
  final _referencesController = TextEditingController();
  AddressType _selectedType = AddressType.home;
  HousingType? _selectedHousingType;
  LatLng? _pickedLocation;
  bool _isSaving = false;

  @override
  void dispose() {
    _labelController.dispose();
    _addressController.dispose();
    _referencesController.dispose();
    super.dispose();
  }

  void _onTypeSelected(AddressType type) {
    setState(() => _selectedType = type);
    if (_labelController.text.isEmpty) {
      final defaults = {
        AddressType.home: 'Casa',
        AddressType.work: 'Trabajo',
        AddressType.other: '',
      };
      final label = defaults[type] ?? '';
      if (label.isNotEmpty) {
        _labelController.text = label;
      }
    }
  }

  Future<void> _pickOnMap() async {
    final result = await Navigator.push<AddressMapPickerResult>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            AddressMapPickerScreen(initialLocation: _pickedLocation),
      ),
    );

    if (result != null) {
      setState(() {
        _pickedLocation = result.latLng;
        if (result.address != null && result.address!.isNotEmpty) {
          _addressController.text = result.address!;
        }
      });
    }
  }

  Future<void> _save() async {
    final label = _labelController.text.trim();
    final address = _addressController.text.trim();

    if (label.isEmpty || address.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Completa al menos la etiqueta y la dirección'),
        ),
      );
      return;
    }

    if (_pickedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona la ubicación en el mapa')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      await ref
          .read(consumerProfileRepositoryProvider)
          .saveAddress(
            label: label,
            address: address,
            latitude: _pickedLocation!.latitude,
            longitude: _pickedLocation!.longitude,
            type: _selectedType,
            references: _referencesController.text.trim().isNotEmpty
                ? _referencesController.text.trim()
                : null,
            housingType: _selectedHousingType,
          );

      ref.invalidate(savedAddressesProvider);
      ref.invalidate(userSelectedAddressProvider);

      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al guardar: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: FudiColors.background,
              border: Border(bottom: BorderSide(color: FudiColors.borderSolid)),
            ),
            padding: const EdgeInsets.all(FudiSpacing.lg),
            child: Row(
              children: [
                Expanded(
                  child: Text('Agregar dirección', style: FudiTypography.h3),
                ),
                SizedBox(
                  width: 40,
                  height: 40,
                  child: IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(FudiIcons.x, size: 20),
                    padding: EdgeInsets.zero,
                    style: IconButton.styleFrom(
                      backgroundColor: FudiColors.muted,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(FudiRadius.full),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(FudiSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Etiqueta', style: FudiTypography.labelSmall),
                  const SizedBox(height: FudiSpacing.sm),
                  TextField(
                    controller: _labelController,
                    decoration: InputDecoration(
                      hintText: 'Casa, Trabajo, Gimnasio...',
                      filled: true,
                      fillColor: FudiColors.inputBackground,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(FudiRadius.xl),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(FudiRadius.xl),
                        borderSide: const BorderSide(
                          color: FudiColors.primary,
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: FudiSpacing.lg,
                        vertical: FudiSpacing.md,
                      ),
                    ),
                  ),

                  const SizedBox(height: FudiSpacing.lg),

                  Text('Tipo', style: FudiTypography.labelSmall),
                  const SizedBox(height: FudiSpacing.sm),
                  Row(
                    children: [
                      Expanded(
                        child: _TypeButton(
                          icon: FudiIcons.home,
                          label: 'Casa',
                          isSelected: _selectedType == AddressType.home,
                          onTap: () => _onTypeSelected(AddressType.home),
                        ),
                      ),
                      const SizedBox(width: FudiSpacing.sm),
                      Expanded(
                        child: _TypeButton(
                          icon: Icons.work_outline_rounded,
                          label: 'Trabajo',
                          isSelected: _selectedType == AddressType.work,
                          onTap: () => _onTypeSelected(AddressType.work),
                        ),
                      ),
                      const SizedBox(width: FudiSpacing.sm),
                      Expanded(
                        child: _TypeButton(
                          icon: FudiIcons.mapPin,
                          label: 'Otro',
                          isSelected: _selectedType == AddressType.other,
                          onTap: () => _onTypeSelected(AddressType.other),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: FudiSpacing.lg),

                  Text(
                    'Ubicación en el mapa',
                    style: FudiTypography.labelSmall,
                  ),
                  const SizedBox(height: FudiSpacing.sm),
                  OutlinedButton.icon(
                    onPressed: _pickOnMap,
                    icon: Icon(
                      _pickedLocation != null
                          ? Icons.check_circle
                          : Icons.map_outlined,
                      size: 20,
                      color: _pickedLocation != null
                          ? FudiColors.primary
                          : null,
                    ),
                    label: Text(
                      _pickedLocation != null
                          ? 'Ubicación seleccionada'
                          : 'Seleccionar en el mapa',
                    ),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(FudiRadius.xl),
                      ),
                      side: BorderSide(
                        color: _pickedLocation != null
                            ? FudiColors.primary
                            : FudiColors.borderSolid,
                        width: _pickedLocation != null ? 2 : 1,
                      ),
                      backgroundColor: _pickedLocation != null
                          ? FudiColors.primary.withValues(alpha: 0.05)
                          : null,
                      foregroundColor: _pickedLocation != null
                          ? FudiColors.primary
                          : FudiColors.foreground,
                    ),
                  ),

                  const SizedBox(height: FudiSpacing.lg),

                  Text('Dirección', style: FudiTypography.labelSmall),
                  const SizedBox(height: FudiSpacing.sm),
                  TextField(
                    controller: _addressController,
                    decoration: InputDecoration(
                      hintText: 'Calle, número, piso...',
                      filled: true,
                      fillColor: FudiColors.inputBackground,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(FudiRadius.xl),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(FudiRadius.xl),
                        borderSide: const BorderSide(
                          color: FudiColors.primary,
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: FudiSpacing.lg,
                        vertical: FudiSpacing.md,
                      ),
                    ),
                  ),

                  const SizedBox(height: FudiSpacing.lg),

                  Text('Tipo de vivienda', style: FudiTypography.labelSmall),
                  const SizedBox(height: FudiSpacing.sm),
                  SizedBox(
                    height: 44,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: HousingType.values.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(width: FudiSpacing.sm),
                      itemBuilder: (context, index) {
                        final ht = HousingType.values[index];
                        final isSelected = _selectedHousingType == ht;
                        return _HousingTypeChip(
                          icon: _housingTypeIcon(ht),
                          label: _housingTypeLabel(ht),
                          isSelected: isSelected,
                          onTap: () => setState(() {
                            _selectedHousingType = isSelected ? null : ht;
                          }),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: FudiSpacing.lg),

                  Text('Referencias', style: FudiTypography.labelSmall),
                  const SizedBox(height: FudiSpacing.sm),
                  TextField(
                    controller: _referencesController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: 'Portón verde, 3er piso, frente al parque...',
                      filled: true,
                      fillColor: FudiColors.inputBackground,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(FudiRadius.xl),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(FudiRadius.xl),
                        borderSide: const BorderSide(
                          color: FudiColors.primary,
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: FudiSpacing.lg,
                        vertical: FudiSpacing.md,
                      ),
                    ),
                  ),

                  const SizedBox(height: FudiSpacing.xxl),

                  FilledButton(
                    onPressed: _isSaving ? null : _save,
                    style: FilledButton.styleFrom(
                      backgroundColor: FudiColors.primary,
                      foregroundColor: FudiColors.primaryForeground,
                      minimumSize: const Size.fromHeight(56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(FudiRadius.xl),
                      ),
                      textStyle: FudiTypography.labelMedium,
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: FudiColors.primaryForeground,
                            ),
                          )
                        : const Text('Guardar dirección'),
                  ),

                  const SizedBox(height: FudiSpacing.lg),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Type Selector Button ───────────────────────────────────────────

class _TypeButton extends StatelessWidget {
  const _TypeButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(FudiRadius.xl),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: FudiSpacing.md),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? FudiColors.primary : FudiColors.borderSolid,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(FudiRadius.xl),
          color: isSelected ? FudiColors.primary.withValues(alpha: 0.05) : null,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? FudiColors.primary : FudiColors.foreground,
            ),
            const SizedBox(height: FudiSpacing.xs),
            Text(
              label,
              style: FudiTypography.bodySmall.copyWith(
                fontWeight: FontWeight.w500,
                color: isSelected ? FudiColors.primary : FudiColors.foreground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Housing Type Chip ──────────────────────────────────────────────

class _HousingTypeChip extends StatelessWidget {
  const _HousingTypeChip({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: FudiSpacing.md,
          vertical: FudiSpacing.sm,
        ),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? FudiColors.primary : FudiColors.borderSolid,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(FudiRadius.full),
          color: isSelected ? FudiColors.primary.withValues(alpha: 0.05) : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected
                  ? FudiColors.primary
                  : FudiColors.mutedForeground,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: FudiTypography.bodySmall.copyWith(
                color: isSelected ? FudiColors.primary : FudiColors.foreground,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
