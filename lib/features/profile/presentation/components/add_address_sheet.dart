import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/ui/fudi_colors.dart';
import '../../../../core/ui/fudi_pressable_scale.dart';
import '../../../../core/ui/fudi_selectable_chips_bar.dart';
import '../../../../core/ui/fudi_spacing.dart';
import '../../../../core/ui/fudi_typography.dart';
import '../../../../core/ui/atoms/icons/fudi_icons.dart';
import '../../domain/saved_address_model.dart';
import '../address_map_picker_screen.dart';
import '../profile_providers.dart';
import 'saved_address_card.dart';

// ─── Show Bottom Sheet ──────────────────────────────────────────────

void showAddAddressSheet(BuildContext context, WidgetRef ref) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(FudiRadius.xxl)),
    ),
    builder: (_) => const AddAddressSheet(),
  );
}

// ─── Add Address Sheet ──────────────────────────────────────────────

class AddAddressSheet extends ConsumerStatefulWidget {
  const AddAddressSheet({super.key});

  @override
  ConsumerState<AddAddressSheet> createState() => _AddAddressSheetState();
}

class _AddAddressSheetState extends ConsumerState<AddAddressSheet> {
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
                  child: FudiPressableScale(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: FudiColors.muted,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(FudiIcons.x, size: 20),
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
                        child: AddressTypeButton(
                          icon: FudiIcons.home,
                          label: 'Casa',
                          isSelected: _selectedType == AddressType.home,
                          onTap: () => _onTypeSelected(AddressType.home),
                        ),
                      ),
                      const SizedBox(width: FudiSpacing.sm),
                      Expanded(
                        child: AddressTypeButton(
                          icon: Icons.work_outline_rounded,
                          label: 'Trabajo',
                          isSelected: _selectedType == AddressType.work,
                          onTap: () => _onTypeSelected(AddressType.work),
                        ),
                      ),
                      const SizedBox(width: FudiSpacing.sm),
                      Expanded(
                        child: AddressTypeButton(
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
                  FudiPressableScale(
                    onTap: _pickOnMap,
                    child: Container(
                      width: double.infinity,
                      height: 52,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _pickedLocation != null
                              ? FudiColors.primary
                              : FudiColors.borderSolid,
                          width: _pickedLocation != null ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(FudiRadius.xl),
                        color: _pickedLocation != null
                            ? FudiColors.primary.withValues(alpha: 0.05)
                            : null,
                      ),
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _pickedLocation != null
                                  ? Icons.check_circle
                                  : Icons.map_outlined,
                              size: 20,
                              color: _pickedLocation != null
                                  ? FudiColors.primary
                                  : FudiColors.foreground,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _pickedLocation != null
                                  ? 'Ubicación seleccionada'
                                  : 'Seleccionar en el mapa',
                              style: TextStyle(
                                color: _pickedLocation != null
                                    ? FudiColors.primary
                                    : FudiColors.foreground,
                              ),
                            ),
                          ],
                        ),
                      ),
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
                  FudiSelectableChipsBar<HousingType>(
                    items: HousingType.values,
                    selectedItem: _selectedHousingType,
                    labelBuilder: addressHousingTypeLabel,
                    iconBuilder: (ht) => Icon(
                      addressHousingTypeIcon(ht),
                      size: 16,
                    ),
                    onSelected: (ht) => setState(() {
                      _selectedHousingType =
                          _selectedHousingType == ht ? null : ht;
                    }),
                    height: 44,
                    padding: EdgeInsets.zero,
                    horizontalChipPadding: FudiSpacing.md,
                    activeColor: FudiColors.primary,
                    activeTextColor: FudiColors.primaryForeground,
                    inactiveColor: FudiColors.muted,
                    inactiveTextColor: FudiColors.foreground,
                    borderColor: FudiColors.borderSolid,
                    borderRadius: FudiRadius.full,
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

                  FudiPressableScale(
                    onTap: _isSaving ? null : _save,
                    child: Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        color: FudiColors.primary,
                        borderRadius: BorderRadius.circular(FudiRadius.xl),
                      ),
                      child: Center(
                        child: _isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: FudiColors.primaryForeground,
                                ),
                              )
                            : const Text('Guardar dirección', style: TextStyle(color: FudiColors.primaryForeground)),
                      ),
                    ),
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

class AddressTypeButton extends StatelessWidget {
  const AddressTypeButton({
    super.key,
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
    return FudiPressableScale(
      onTap: onTap,
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
