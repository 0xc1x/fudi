import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/error/user_friendly_message.dart';
import '../../../../core/ui/fudi_colors.dart';
import '../../../../core/ui/atoms/icons/fudi_icons.dart';
import '../../../../core/ui/fudi_spacing.dart';
import '../../../../core/ui/fudi_typography.dart';
import '../../domain/business_location.dart';
import '../business_providers.dart';
import 'map_picker_screen.dart';

class BusinessLocationCreateScreen extends ConsumerStatefulWidget {
  const BusinessLocationCreateScreen({super.key});

  @override
  ConsumerState<BusinessLocationCreateScreen> createState() =>
      _BusinessLocationCreateScreenState();
}

class _BusinessLocationCreateScreenState
    extends ConsumerState<BusinessLocationCreateScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();

  LatLng? _selectedLocation;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona la ubicación en el mapa'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final business = ref.read(currentBusinessProvider).value;
      if (business == null) throw Exception('Negocio no encontrado');

      final repo = ref.read(businessLocationRepositoryProvider);

      final location = BusinessLocation(
        id: '',
        businessId: business.id,
        name: _nameController.text,
        address: _addressController.text,
        phone: _phoneController.text.isNotEmpty ? _phoneController.text : null,
        latitude: _selectedLocation!.latitude,
        longitude: _selectedLocation!.longitude,
      );

      await repo.upsertLocation(location);

      if (mounted) {
        ref.invalidate(businessLocationsProvider(business.id));
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(userFriendlyMessage(e)),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FudiColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(FudiIcons.chevronLeft),
          onPressed: () => context.pop(),
        ),
        title: const Text('Nueva sucursal', style: FudiTypography.h4),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(FudiSpacing.md),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [_buildBasicInfoSection(), const SizedBox(height: 100)],
          ),
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(FudiSpacing.md),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: FudiColors.border)),
        ),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isSubmitting ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: FudiColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isSubmitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'Crear sucursal',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Container(
      padding: const EdgeInsets.all(FudiSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: FudiColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Información de la sucursal',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildField(
            label: 'Nombre de la sucursal *',
            controller: _nameController,
            hint: 'Ej: Sucursal Centro',
          ),
          const SizedBox(height: 16),
          _buildField(
            label: 'Dirección *',
            controller: _addressController,
            hint: 'Selecciona en el mapa',
            icon: FudiIcons.mapPin,
            suffix: TextButton(
              onPressed: () async {
                final LatLng? result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        MapPickerScreen(initialLocation: _selectedLocation),
                  ),
                );
                if (result != null) {
                  setState(() => _selectedLocation = result);
                  try {
                    final placemarks = await geo.placemarkFromCoordinates(
                      result.latitude,
                      result.longitude,
                    );
                    if (placemarks.isNotEmpty) {
                      final p = placemarks.first;
                      _addressController.text = [
                        p.street,
                        p.subLocality,
                        p.locality,
                      ].where((s) => s != null && s.isNotEmpty).join(', ');
                    }
                  } catch (_) {}
                  setState(() {});
                }
              },
              child: const Text('Pin en mapa', style: TextStyle(fontSize: 12)),
            ),
          ),
          const SizedBox(height: 16),
          _buildField(
            label: 'Teléfono',
            controller: _phoneController,
            hint: 'Ej: 0987654321',
            icon: FudiIcons.phone,
            keyboardType: TextInputType.phone,
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required String hint,
    IconData? icon,
    TextInputType? keyboardType,
    Widget? suffix,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 16, color: FudiColors.mutedForeground),
                  const SizedBox(width: 8),
                ],
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            suffix ?? const SizedBox.shrink(),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: FudiColors.background.withValues(alpha: 0.5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          validator: (value) =>
              (value == null || value.isEmpty) && label.contains('*')
              ? 'Campo requerido'
              : null,
        ),
      ],
    );
  }
}
