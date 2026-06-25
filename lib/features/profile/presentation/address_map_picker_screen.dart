import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/ui/fudi_colors.dart';
import '../../../core/ui/fudi_spacing.dart';
import '../../../core/ui/fudi_pressable_scale.dart';
import '../../../core/ui/fudi_typography.dart';
import '../../../core/ui/atoms/icons/fudi_icons.dart';
import '../../../core/utils/map_style.dart';

class AddressMapPickerResult {
  const AddressMapPickerResult({required this.latLng, this.address});

  final LatLng latLng;
  final String? address;
}

class AddressMapPickerScreen extends StatefulWidget {
  const AddressMapPickerScreen({super.key, this.initialLocation});

  final LatLng? initialLocation;

  @override
  State<AddressMapPickerScreen> createState() => _AddressMapPickerScreenState();
}

class _AddressMapPickerScreenState extends State<AddressMapPickerScreen> {
  late LatLng _currentLocation;
  GoogleMapController? _mapController;
  bool _loading = true;
  String? _resolvedAddress;
  bool _isResolving = false;

  @override
  void initState() {
    super.initState();
    _currentLocation =
        widget.initialLocation ?? const LatLng(-0.22985, -78.52495);
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    if (widget.initialLocation != null) {
      setState(() => _loading = false);
      _resolveAddress(widget.initialLocation!);
      return;
    }

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() => _loading = false);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() => _loading = false);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() => _loading = false);
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
      final latLng = LatLng(position.latitude, position.longitude);
      setState(() {
        _currentLocation = latLng;
        _loading = false;
      });

      _mapController?.animateCamera(CameraUpdate.newLatLngZoom(latLng, 16));
      _resolveAddress(latLng);
    } catch (e) {
      debugPrint('Error obteniendo ubicación: $e');
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No se pudo obtener tu ubicación. Mueve el mapa manualmente.',
            ),
          ),
        );
      }
    }
  }

  Future<void> _resolveAddress(LatLng latLng) async {
    setState(() => _isResolving = true);
    try {
      final placemarks = await placemarkFromCoordinates(
        latLng.latitude,
        latLng.longitude,
      );
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        final parts = [
          p.street,
          p.subLocality,
          p.locality,
          p.administrativeArea,
        ].where((s) => s != null && s.isNotEmpty).toList();
        setState(() => _resolvedAddress = parts.join(', '));
      }
    } catch (_) {
      setState(() => _resolvedAddress = null);
    } finally {
      setState(() => _isResolving = false);
    }
  }

  void _onCameraMove(CameraPosition position) {
    _currentLocation = position.target;
  }

  void _onCameraIdle() {
    _resolveAddress(_currentLocation);
  }

  void _confirm() {
    Navigator.pop(
      context,
      AddressMapPickerResult(
        latLng: _currentLocation,
        address: _resolvedAddress,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Selecciona tu ubicación', style: FudiTypography.h4),
        leading: FudiPressableScale(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(color: FudiColors.muted, shape: BoxShape.circle),
            child: const Icon(FudiIcons.chevronLeft, size: 20),
          ),
        ),
      ),
      body: Stack(
        children: [
          if (_loading)
            const Center(child: CircularProgressIndicator())
          else
            GoogleMap(
              style: kMapStyleNoPoi,
              initialCameraPosition: CameraPosition(
                target: _currentLocation,
                zoom: 16,
              ),
              onMapCreated: (controller) => _mapController = controller,
              onCameraMove: _onCameraMove,
              onCameraIdle: _onCameraIdle,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
            ),

          if (!_loading)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 35),
                child: Icon(
                  Icons.location_on,
                  size: 50,
                  color: FudiColors.primary,
                ),
              ),
            ),

          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(FudiSpacing.lg),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(FudiRadius.xxl),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isResolving)
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else if (_resolvedAddress != null)
                    Text(
                      _resolvedAddress!,
                      textAlign: TextAlign.center,
                      style: FudiTypography.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    )
                  else
                    Text(
                      'Mueve el mapa para seleccionar la ubicación',
                      textAlign: TextAlign.center,
                      style: FudiTypography.bodySmall.copyWith(
                        color: FudiColors.mutedForeground,
                      ),
                    ),
                  const SizedBox(height: FudiSpacing.md),
                  SizedBox(
                    width: double.infinity,
                    child: FudiPressableScale(
                      onTap: _confirm,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: FudiColors.primary,
                          borderRadius: BorderRadius.circular(FudiRadius.xl),
                        ),
                        child: const Center(child: Text('Confirmar ubicación', style: TextStyle(color: Colors.white))),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            top: FudiSpacing.md,
            right: FudiSpacing.md,
            child: FloatingActionButton.small(
              onPressed: _determinePosition,
              backgroundColor: Colors.white,
              child: const Icon(Icons.my_location, color: FudiColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}
