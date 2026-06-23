import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/ui/fudi_colors.dart';
import '../../../../core/ui/fudi_typography.dart';
import '../../../../core/ui/fudi_spacing.dart';
import '../../../../core/ui/atoms/icons/fudi_icons.dart';
import '../../../../core/utils/reverse_geocode.dart';
import '../../../../core/utils/map_style.dart';

class MapPickerResult {
  const MapPickerResult({
    required this.coordinates,
    required this.address,
    this.zone,
  });

  final LatLng coordinates;
  final String address;
  final String? zone;
}

class MapPickerScreen extends ConsumerStatefulWidget {
  const MapPickerScreen({super.key, this.initialLocation});

  final LatLng? initialLocation;

  @override
  ConsumerState<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends ConsumerState<MapPickerScreen> {
  late LatLng _currentLocation;
  GoogleMapController? _mapController;
  bool _loading = true;
  String _currentAddress = '';

  @override
  void initState() {
    super.initState();
    _currentLocation =
        widget.initialLocation ??
        const LatLng(-0.22985, -78.52495);
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    if (widget.initialLocation != null) {
      await _reverseGeocode(_currentLocation);
      setState(() => _loading = false);
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
      _currentLocation = LatLng(position.latitude, position.longitude);
      await _reverseGeocode(_currentLocation);
      if (mounted) setState(() => _loading = false);

      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(_currentLocation, 16),
      );
    } catch (e) {
      debugPrint('Error obteniendo ubicación: $e');
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No se pudo obtener tu ubicación actual. Puedes mover el mapa manualmente.',
            ),
          ),
        );
      }
    }
  }

  String? _zone;

  Future<void> _reverseGeocode(LatLng location) async {
    final result = await reverseGeocode(
      latitude: location.latitude,
      longitude: location.longitude,
    );
    if (result.displayName.isNotEmpty) {
      _currentAddress = result.displayName;
      _zone = result.bestZoneName.isNotEmpty ? result.bestZoneName : null;
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ubica tu local', style: FudiTypography.h4),
        leading: IconButton(
          icon: const Icon(FudiIcons.chevronLeft),
          onPressed: () => Navigator.pop(context),
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
              onCameraMove: (position) {
                _currentLocation = position.target;
              },
              onCameraIdle: () => _reverseGeocode(_currentLocation),
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
              padding: const EdgeInsets.all(FudiSpacing.md),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_currentAddress.isNotEmpty) ...[
                    Row(
                      children: [
                        const Icon(
                          FudiIcons.mapPin,
                          size: 16,
                          color: FudiColors.primary,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            _currentAddress,
                            style: FudiTypography.bodySmall,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: FudiSpacing.sm),
                  ],
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_currentAddress.isEmpty) {
                          await _reverseGeocode(_currentLocation);
                        }
                        if (context.mounted) {
                          Navigator.pop(
                            context,
                            MapPickerResult(
                              coordinates: _currentLocation,
                              address: _currentAddress,
                              zone: _zone,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: FudiColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Confirmar ubicación',
                        style: TextStyle(fontWeight: FontWeight.bold),
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
