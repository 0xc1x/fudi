import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../../../../core/error/user_friendly_message.dart';
import '../../../../core/ui/atoms/icons/fudi_icons.dart';
import '../../../../core/ui/fudi_colors.dart';
import '../../../../core/ui/fudi_pressable_scale.dart';
import '../../../../core/ui/fudi_spacing.dart';
import '../../../../core/ui/fudi_typography.dart';
import '../../../../core/utils/map_style.dart';
import '../../../../core/utils/reverse_geocode.dart';
import '../../../auth/presentation/auth_state_provider.dart';
import '../../domain/business_location.dart';
import '../../domain/business_profile.dart';
import '../business_profile_providers.dart';
import '../business_providers.dart';
import 'map_picker_screen.dart';

const _businessTypes = [
  ('restaurant', 'Restaurante', Icons.restaurant_rounded),
  ('bakery', 'Panadería', Icons.bakery_dining_rounded),
  ('cafe', 'Cafetería', Icons.local_cafe_rounded),
  ('grocery', 'Supermercado', Icons.shopping_bag_outlined),
  ('other', 'Otro', Icons.storefront_rounded),
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
    unawaited(_determinePosition());
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
      unawaited(_mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(_selectedLocation, 16),
      ));
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
      if (mounted) unawaited(_reverseGeocode(_selectedLocation));
    });
  }

  void _openFullMap() {
    unawaited(Navigator.push<MapPickerResult>(
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
        unawaited(_mapController?.animateCamera(
          CameraUpdate.newLatLng(_selectedLocation),
        ));
      }
    }));
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_hasSelectedLocation) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecciona la ubicación en el mapa'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final business = ref.read(currentBusinessProvider).value;

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
              backgroundColor: FudiColors.success,
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
      unawaited(Sentry.captureException(e, stackTrace: st));
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: Center(
          child: FudiPressableScale(
            onTap: () => context.pop(),
            child: Container(
              width: 38,
              height: 38,
              decoration: const BoxDecoration(
                color: FudiColors.background,
                shape: BoxShape.circle,
              ),
              child: const Icon(FudiIcons.chevronLeft, size: 18, color: FudiColors.foreground),
            ),
          ),
        ),
        title: Text(
          'Nueva sucursal',
          style: FudiTypography.h4.copyWith(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: FudiSpacing.lg, vertical: FudiSpacing.xl),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Detalles Básicos',
                  style: FudiTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: FudiColors.foreground,
                  ),
                ),
                const SizedBox(height: FudiSpacing.md),
                _buildField(
                  label: 'Nombre de la sucursal',
                  controller: _nameController,
                  hint: 'Ej: Sucursal Cumbayá / Mall del Sol',
                  icon: FudiIcons.storefront,
                  isRequired: true,
                ),
                const SizedBox(height: FudiSpacing.lg),
                
                Text(
                  'Tipo de Establecimiento',
                  style: FudiTypography.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: FudiColors.mutedForeground,
                  ),
                ),
                const SizedBox(height: FudiSpacing.sm),
                _buildBusinessTypeSelector(),
                
                const SizedBox(height: FudiSpacing.xl),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Ubicación Geográfica',
                      style: FudiTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: FudiColors.foreground,
                      ),
                    ),
                    Text(
                      '* Requerido',
                      style: FudiTypography.bodySmall.copyWith(
                        color: FudiColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: FudiSpacing.md),
                _buildMapSection(),
                
                const SizedBox(height: FudiSpacing.xl),
                Text(
                  'Información de Contacto',
                  style: FudiTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: FudiColors.foreground,
                  ),
                ),
                const SizedBox(height: FudiSpacing.md),
                _buildField(
                  label: 'Dirección Completa',
                  controller: _addressController,
                  hint: 'Asigna la ubicación usando el mapa superior',
                  icon: FudiIcons.mapPin,
                  isRequired: true,
                  maxLines: 2,
                ),
                const SizedBox(height: FudiSpacing.lg),
                _buildField(
                  label: 'Teléfono de contacto (Opcional)',
                  controller: _phoneController,
                  hint: 'Ej: +593 98 765 4321',
                  icon: FudiIcons.phone,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[+\d\s()-]')),
                  ],
                ),
                const SizedBox(height: 140),
              ],
            ),
          ),
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.only(
          left: FudiSpacing.lg,
          right: FudiSpacing.lg,
          top: FudiSpacing.md,
          bottom: FudiSpacing.xl,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, -4),
            )
          ],
          border: const Border(top: BorderSide(color: FudiColors.border, width: 0.5)),
        ),
        child: SizedBox(
          width: double.infinity,
          child: FudiPressableScale(
            onTap: _isSubmitting ? null : _submit,
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                color: _isSubmitting ? FudiColors.muted : FudiColors.primary,
                borderRadius: BorderRadius.circular(FudiRadius.md),
              ),
              alignment: Alignment.center,
              child: _isSubmitting
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      'Confirmar y Crear Sucursal',
                      style: FudiTypography.bodyMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBusinessTypeSelector() {
    return SizedBox(
      height: 42,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _businessTypes.length,
        itemBuilder: (context, index) {
          final type = _businessTypes[index];
          final isSelected = _selectedBusinessType == type.$1;
          return Padding(
            padding: const EdgeInsets.only(right: FudiSpacing.sm),
            child: ChoiceChip(
              label: Row(
                children: [
                  Icon(
                    type.$3,
                    size: 16,
                    color: isSelected ? Colors.white : FudiColors.mutedForeground,
                  ),
                  const SizedBox(width: 6),
                  Text(type.$2),
                ],
              ),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() => _selectedBusinessType = type.$1);
                }
              },
              selectedColor: FudiColors.primary,
              backgroundColor: FudiColors.background,
              labelStyle: FudiTypography.bodySmall.copyWith(
                color: isSelected ? Colors.white : FudiColors.foreground,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(FudiRadius.sm),
                side: BorderSide(
                  color: isSelected ? FudiColors.primary : FudiColors.border,
                ),
              ),
              showCheckmark: false,
              elevation: 0,
              pressElevation: 0,
            ),
          );
        },
      ),
    );
  }

  Widget _buildMapSection() {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(FudiRadius.md),
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
          const Center(
            child: Padding(
              padding: EdgeInsets.only(bottom: 24),
              child: Icon(
                Icons.location_on_rounded,
                size: 40,
                color: FudiColors.primary,
              ),
            ),
          ),
          Positioned(
            top: FudiSpacing.sm,
            right: FudiSpacing.sm,
            child: FudiPressableScale(
              onTap: () async {
                await _determinePosition();
                _openFullMap();
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 6,
                    )
                  ],
                ),
                child: const Icon(
                  Icons.fullscreen_rounded,
                  color: FudiColors.foreground,
                  size: 20,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: FudiSpacing.sm,
            left: FudiSpacing.sm,
            right: FudiSpacing.sm,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: FudiSpacing.sm, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(FudiRadius.sm),
                border: Border.all(color: FudiColors.border.withValues(alpha: 0.5)),
              ),
              child: Row(
                children: [
                  const Icon(
                    FudiIcons.mapPin,
                    size: 14,
                    color: FudiColors.primary,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      _addressController.text.isNotEmpty
                          ? _addressController.text
                          : 'Arrastra el mapa para ubicar la sucursal',
                      style: FudiTypography.bodySmall.copyWith(
                        fontSize: 11,
                        color: _addressController.text.isNotEmpty
                            ? FudiColors.foreground
                            : FudiColors.mutedForeground,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
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
    bool isRequired = false,
    bool readOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label${isRequired ? ' *' : ''}',
          style: FudiTypography.bodySmall.copyWith(
            fontWeight: FontWeight.w600,
            color: FudiColors.mutedForeground,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          maxLines: maxLines,
          readOnly: readOnly,
          style: FudiTypography.bodyMedium.copyWith(color: FudiColors.foreground),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: FudiTypography.bodyMedium.copyWith(color: FudiColors.mutedForeground.withValues(alpha: 0.7)),
            filled: true,
            fillColor: readOnly ? FudiColors.background.withValues(alpha: 0.3) : Colors.white,
            prefixIcon: icon != null 
                ? Icon(icon, size: 18, color: FudiColors.mutedForeground.withValues(alpha: 0.7))
                : null,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: FudiSpacing.md,
              vertical: FudiSpacing.sm + 2,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(FudiRadius.sm),
              borderSide: const BorderSide(color: FudiColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(FudiRadius.sm),
              borderSide: const BorderSide(color: FudiColors.primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(FudiRadius.sm),
              borderSide: const BorderSide(color: Colors.redAccent),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(FudiRadius.sm),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
            ),
          ),
          validator: (value) =>
              (value == null || value.trim().isEmpty) && isRequired
              ? 'Este campo es obligatorio'
              : null,
        ),
      ],
    );
  }
}