import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import '../../../../core/error/user_friendly_message.dart';
import '../../../../core/ui/fudi_colors.dart';
import '../../../../core/ui/fudi_pressable_scale.dart';
import '../../../../core/ui/fudi_spacing.dart';
import '../../../../core/ui/fudi_typography.dart';
import '../../../../core/ui/atoms/icons/fudi_icons.dart';
import '../../../../core/utils/reverse_geocode.dart';
import '../../../../core/utils/map_style.dart';
import '../../../auth/presentation/auth_state_provider.dart';
import '../../domain/business_location.dart';
import '../../domain/business_profile.dart';
import '../business_profile_providers.dart';
import '../business_providers.dart';
import 'map_picker_screen.dart';

const _businessTypes = [
  ('restaurant', 'Restaurante'),
  ('bakery', 'Panadería'),
  ('cafe', 'Cafetería'),
  ('grocery', 'Supermercado'),
  ('other', 'Otro'),
];

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

  LatLng _selectedLocation = const LatLng(-0.22985, -78.52495);
  String _selectedBusinessType = 'restaurant';
  String? _zone;
  bool _isSubmitting = false;
  bool _hasSelectedLocation = false;

  GoogleMapController? _mapController;
  bool _mapLoading = true;
  Timer? _geoDebounce;

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _mapController?.dispose();
    _geoDebounce?.cancel();
    super.dispose();
  }

  Future<void> _determinePosition() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) setState(() => _mapLoading = false);
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) setState(() => _mapLoading = false);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) setState(() => _mapLoading = false);
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
      _selectedLocation = LatLng(position.latitude, position.longitude);
      if (mounted) setState(() => _mapLoading = false);
      await _reverseGeocode(_selectedLocation);
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(_selectedLocation, 16),
      );
    } catch (_) {
      if (mounted) setState(() => _mapLoading = false);
    }
  }

  Future<void> _reverseGeocode(LatLng location) async {
    final result = await reverseGeocode(
      latitude: location.latitude,
      longitude: location.longitude,
    );
    if (result.displayName.isNotEmpty && mounted) {
      setState(() {
        _addressController.text = result.displayName;
        _zone = result.bestZoneName.isNotEmpty ? result.bestZoneName : null;
      });
    }
  }

  void _onCameraMove(CameraPosition position) {
    _selectedLocation = position.target;
    _hasSelectedLocation = true;
    _geoDebounce?.cancel();
    _geoDebounce = Timer(const Duration(milliseconds: 600), () {
      if (mounted) _reverseGeocode(_selectedLocation);
    });
  }

  void _openFullMap() {
    Navigator.push<MapPickerResult>(
      context,
      MaterialPageRoute(
        builder: (_) => MapPickerScreen(
          initialLocation: _hasSelectedLocation ? _selectedLocation : null,
        ),
      ),
    ).then((result) {
      if (result != null && mounted) {
        setState(() {
          _selectedLocation = result.coordinates;
          _hasSelectedLocation = true;
          if (result.address.isNotEmpty) {
            _addressController.text = result.address;
          }
          _zone = result.zone;
        });
        _mapController?.animateCamera(
          CameraUpdate.newLatLng(_selectedLocation),
        );
      }
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_hasSelectedLocation) {
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
      var business = ref.read(currentBusinessProvider).value;

      if (business == null) {
        final authState = ref.read(authSessionNotifierProvider);
        final userId = authState.session?.user.id;
        if (userId == null) throw Exception('Usuario no encontrado');

        final businessRepo = ref.read(businessProfileRepositoryProvider);
        await businessRepo.createBusiness(
          BusinessProfile(
            id: '',
            name: _nameController.text,
            type: _selectedBusinessType,
            address: _addressController.text,
            phone: _phoneController.text.isNotEmpty
                ? _phoneController.text
                : null,
            latitude: _selectedLocation.latitude,
            longitude: _selectedLocation.longitude,
            zone: _zone,
            rating: 0.0,
          ),
          userId,
        );

        ref.invalidate(userBusinessesProvider);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Negocio creado correctamente'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
          context.pop();
        }
        return;
      }

      final repo = ref.read(businessLocationRepositoryProvider);
      final location = BusinessLocation(
        id: '',
        businessId: business.id,
        name: _nameController.text,
        address: _addressController.text,
        phone: _phoneController.text.isNotEmpty ? _phoneController.text : null,
        latitude: _selectedLocation.latitude,
        longitude: _selectedLocation.longitude,
        zone: _zone,
      );

      await repo.upsertLocation(location);

      if (mounted) {
        ref.invalidate(businessLocationsProvider(business.id));
        context.pop();
      }
    } catch (e, st) {
      Sentry.captureException(e, stackTrace: st);
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
        leading: FudiPressableScale(
          onTap: () => context.pop(),
          child: Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(shape: BoxShape.circle),
            child: const Icon(FudiIcons.chevronLeft),
          ),
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
            children: [
              _buildBusinessInfoSection(),
              const SizedBox(height: FudiSpacing.md),
              _buildMapSection(),
              const SizedBox(height: FudiSpacing.md),
              _buildContactSection(),
              const SizedBox(height: 120),
            ],
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

  Widget _buildBusinessInfoSection() {
    return Container(
      padding: const EdgeInsets.all(FudiSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(FudiRadius.lg),
        border: Border.all(color: FudiColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Información del negocio',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildField(
            label: 'Nombre de la sucursal *',
            controller: _nameController,
            hint: 'Ej: Sucursal Centro',
            icon: FudiIcons.storefront,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _selectedBusinessType,
            decoration: InputDecoration(
              labelText: 'Tipo de negocio *',
              filled: true,
              fillColor: FudiColors.background.withValues(alpha: 0.5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(FudiRadius.md),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            items: _businessTypes.map((t) {
              return DropdownMenuItem(
                value: t.$1,
                child: Row(
                  children: [
                    Icon(
                      _typeIcon(t.$1),
                      size: 18,
                      color: FudiColors.mutedForeground,
                    ),
                    const SizedBox(width: 8),
                    Text(t.$2),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _selectedBusinessType = value);
              }
            },
            validator: (value) =>
                value == null ? 'Selecciona un tipo de negocio' : null,
          ),
        ],
      ),
    );
  }

  Widget _buildMapSection() {
    return GestureDetector(
      onTap: _openFullMap,
      child: Container(
        height: 280,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(FudiRadius.lg),
          border: Border.all(color: FudiColors.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            if (_mapLoading)
              const Center(child: CircularProgressIndicator())
            else
              GoogleMap(
                style: kMapStyleNoPoi,
                initialCameraPosition: CameraPosition(
                  target: _selectedLocation,
                  zoom: 16,
                ),
                onMapCreated: (controller) => _mapController = controller,
                onCameraMove: _onCameraMove,
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                mapToolbarEnabled: false,
              ),
            Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 35),
                child: Icon(
                  Icons.location_on,
                  size: 48,
                  color: FudiColors.primary,
                ),
              ),
            ),
            Positioned(
              top: FudiSpacing.sm,
              right: FudiSpacing.sm,
              child: FloatingActionButton.small(
                onPressed: () async {
                  await _determinePosition();
                  _openFullMap();
                },
                backgroundColor: Colors.white,
                heroTag: null,
                child: const Icon(
                  Icons.open_in_full,
                  color: FudiColors.primary,
                  size: 20,
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                ),
                child: Row(
                  children: [
                    const Icon(
                      FudiIcons.mapPin,
                      size: 16,
                      color: FudiColors.mutedForeground,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _addressController.text.isNotEmpty
                            ? _addressController.text
                            : 'Presioná para abrir el mapa',
                        style: FudiTypography.bodySmall.copyWith(
                          color: _addressController.text.isNotEmpty
                              ? FudiColors.foreground
                              : FudiColors.mutedForeground,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Icon(
                      Icons.open_in_full,
                      size: 14,
                      color: FudiColors.mutedForeground,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactSection() {
    return Container(
      padding: const EdgeInsets.all(FudiSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(FudiRadius.lg),
        border: Border.all(color: FudiColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Contacto',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildField(
            label: 'Dirección *',
            controller: _addressController,
            hint: 'Se actualiza automáticamente con el mapa',
            icon: FudiIcons.mapPin,
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          _buildField(
            label: 'Teléfono',
            controller: _phoneController,
            hint: 'Ej: +593 987654321',
            icon: FudiIcons.phone,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[+\d\s()-]')),
            ],
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
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: FudiColors.background.withValues(alpha: 0.5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(FudiRadius.md),
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

  IconData _typeIcon(String type) {
    return switch (type) {
      'restaurant' => Icons.restaurant,
      'bakery' => Icons.bakery_dining,
      'cafe' => Icons.local_cafe,
      'grocery' => Icons.shopping_cart,
      _ => Icons.store,
    };
  }
}
