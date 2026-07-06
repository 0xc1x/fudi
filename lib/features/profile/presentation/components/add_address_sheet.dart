import 'dart:async';

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
  unawaited(showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    // CRUCIAL: Transparente aquí para que se vea el radio del Container hijo
    backgroundColor: Colors.transparent,
    barrierColor: FudiColors.foreground.withValues(alpha: 0.5),
    builder: (_) => const AddAddressSheet(),
  ));
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
    if (_labelController.text.isEmpty ||
        _labelController.text == 'Casa' ||
        _labelController.text == 'Trabajo') {
      final defaults = {
        AddressType.home: 'Casa',
        AddressType.work: 'Trabajo',
        AddressType.other: '',
      };
      _labelController.text = defaults[type] ?? '';
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
          _addressController.text = result.address ?? '';
        }
      });
    }
  }

  Future<void> _save() async {
    final label = _labelController.text.trim();
    final address = _addressController.text.trim();

    if (label.isEmpty || address.isEmpty) {
      _showSnackBar('Completa los campos obligatorios.', isError: true);
      return;
    }

    if (_pickedLocation == null) {
      _showSnackBar('Por favor, selecciona el mapa.', isError: true);
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
      if (mounted) _showSnackBar('Error: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: isError
            ? FudiColors.destructiveVibrant
            : FudiColors.success,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(FudiSpacing.lg),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Text(
          message,
          style: const TextStyle(
            color: FudiColors.primaryForeground,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    // Decorador alternativo basado en bloques integrados sin bordes toscos
    InputDecoration blockInputDecoration({
      required String hint,
      required IconData icon,
    }) {
      return InputDecoration(
        hintText: hint,
        hintStyle: FudiTypography.bodyMedium.copyWith(
          color: FudiColors.mutedForeground.withValues(alpha: 0.7),
        ),
        prefixIcon: Icon(
          icon,
          size: 20,
          color: FudiColors.foreground.withValues(alpha: 0.6),
        ),
        filled: true,
        fillColor: FudiColors.inputBackground.withValues(alpha: 0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: FudiColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: FudiSpacing.lg,
          vertical: FudiSpacing.md,
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: DecoratedBox(
        // DISEÑO NUEVO: Contenedor con curvas garantizadas y fondo sólido limpio
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Indicador visual superior (Pill/Notch) para UX de arrastre
              const SizedBox(height: 12),
              Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: FudiColors.borderSolid,
                  borderRadius: BorderRadius.circular(2.5),
                ),
              ),

              // Encabezado simplificado
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  FudiSpacing.xl,
                  FudiSpacing.md,
                  FudiSpacing.xl,
                  FudiSpacing.xs,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '¿Dónde entregamos?',
                      style: FudiTypography.h3.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    FudiPressableScale(
                      onTap: () => Navigator.of(context).pop(),
                      child: const CircleAvatar(
                        radius: 16,
                        backgroundColor: FudiColors.inputBackground,
                        child: Icon(
                          FudiIcons.x,
                          size: 14,
                          color: FudiColors.foreground,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Flexible(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(FudiSpacing.xl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // DISEÑO NUEVO: Selector de tipo horizontal segmentado integrado
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: FudiColors.inputBackground.withValues(
                            alpha: 0.6,
                          ),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: SegmentedTypeButton(
                                label: 'Casa',
                                isSelected: _selectedType == AddressType.home,
                                onTap: () => _onTypeSelected(AddressType.home),
                              ),
                            ),
                            Expanded(
                              child: SegmentedTypeButton(
                                label: 'Trabajo',
                                isSelected: _selectedType == AddressType.work,
                                onTap: () => _onTypeSelected(AddressType.work),
                              ),
                            ),
                            Expanded(
                              child: SegmentedTypeButton(
                                label: 'Otro',
                                isSelected: _selectedType == AddressType.other,
                                onTap: () => _onTypeSelected(AddressType.other),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: FudiSpacing.xl),

                      // Campo: Nombre/Etiqueta
                      Text(
                        'Nombre de esta dirección',
                        style: FudiTypography.labelSmall.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: FudiSpacing.xs),
                      TextField(
                        controller: _labelController,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: blockInputDecoration(
                          hint: 'Ej. Casa de campo, Mi Ofi...',
                          icon: Icons.edit_outlined,
                        ),
                      ),

                      const SizedBox(height: FudiSpacing.lg),

                      // DISEÑO NUEVO: Tarjeta de acción de mapa estilizada como feature
                      FudiPressableScale(
                        onTap: _pickOnMap,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(FudiSpacing.md),
                          decoration: BoxDecoration(
                            color: _pickedLocation != null
                                ? FudiColors.primary.withValues(alpha: 0.06)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _pickedLocation != null
                                  ? FudiColors.primary
                                  : FudiColors.borderSolid,
                              width: _pickedLocation != null ? 2 : 1.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: _pickedLocation != null
                                      ? FudiColors.primary
                                      : FudiColors.inputBackground,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  _pickedLocation != null
                                      ? Icons.pin_drop
                                      : Icons.map_outlined,
                                  color: _pickedLocation != null
                                      ? FudiColors.primaryForeground
                                      : FudiColors.foreground,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: FudiSpacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _pickedLocation != null
                                          ? '¡Ubicación detectada!'
                                          : 'Ubicar en el mapa',
                                      style: FudiTypography.bodyMedium.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      _pickedLocation != null
                                          ? 'Coordenadas registradas de forma exacta'
                                          : 'Toca para abrir el GPS',
                                      style: FudiTypography.bodySmall.copyWith(
                                        color: FudiColors.mutedForeground,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.chevron_right,
                                color: FudiColors.mutedForeground.withValues(
                                  alpha: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: FudiSpacing.lg),

                      // Campo: Dirección
                      Text(
                        'Dirección exacta',
                        style: FudiTypography.labelSmall.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: FudiSpacing.xs),
                      TextField(
                        controller: _addressController,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: blockInputDecoration(
                          hint: 'Calle, número, apartamento...',
                          icon: FudiIcons.mapPin,
                        ),
                      ),

                      const SizedBox(height: FudiSpacing.lg),

                      // Campo: Tipo de Vivienda
                      Text(
                        'Tipo de vivienda',
                        style: FudiTypography.labelSmall.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: FudiSpacing.xs),
                      FudiSelectableChipsBar<HousingType>(
                        items: HousingType.values,
                        selectedItem: _selectedHousingType,
                        labelBuilder: addressHousingTypeLabel,
                        iconBuilder: (ht) =>
                            Icon(addressHousingTypeIcon(ht), size: 14),
                        onSelected: (ht) => setState(() {
                          _selectedHousingType = _selectedHousingType == ht
                              ? null
                              : ht;
                        }),
                        padding: EdgeInsets.zero,
                        horizontalChipPadding: FudiSpacing.md,
                        activeColor: FudiColors.foreground,
                        activeTextColor: FudiColors.primaryForeground,
                        inactiveColor: FudiColors.inputBackground.withValues(
                          alpha: 0.5,
                        ),
                        inactiveTextColor: FudiColors.foreground,
                        borderColor: Colors.transparent,
                        borderRadius: FudiRadius.full,
                      ),

                      const SizedBox(height: FudiSpacing.lg),

                      // Campo: Referencias
                      Text(
                        'Referencias o indicaciones adicionales',
                        style: FudiTypography.labelSmall.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: FudiSpacing.xs),
                      TextField(
                        controller: _referencesController,
                        maxLines: 2,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: blockInputDecoration(
                          hint: 'Ej. Frente al portón blanco, timbre roto...',
                          icon: Icons.notes_outlined,
                        ),
                      ),

                      const SizedBox(height: FudiSpacing.xxl),

                      // Botón Principal de Guardado Neo-minimalista
                      FudiPressableScale(
                        onTap: _isSaving ? null : _save,
                        child: Container(
                          width: double.infinity,
                          height: 54,
                          decoration: BoxDecoration(
                            color: FudiColors.primary,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Center(
                            child: _isSaving
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: FudiColors.primaryForeground,
                                    ),
                                  )
                                : Text(
                                    'Confirmar Dirección',
                                    style: FudiTypography.labelMedium.copyWith(
                                      color: FudiColors.primaryForeground,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(height: FudiSpacing.sm),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Componente Nuevo: Botón Segmentado de Tipo ─────────────────────

class SegmentedTypeButton extends StatelessWidget {
  const SegmentedTypeButton({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FudiPressableScale(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).colorScheme.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: FudiColors.foreground.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: FudiTypography.bodyMedium.copyWith(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected
                  ? FudiColors.foreground
                  : FudiColors.mutedForeground,
            ),
          ),
        ),
      ),
    );
  }
}
