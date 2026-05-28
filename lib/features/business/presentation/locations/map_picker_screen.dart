import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/ui/fudi_colors.dart';
import '../../../../core/ui/fudi_typography.dart';
import '../../../../core/ui/fudi_spacing.dart';
import '../../../../core/ui/atoms/icons/fudi_icons.dart';

class MapPickerScreen extends StatefulWidget {
  const MapPickerScreen({super.key, this.initialLocation});

  final LatLng? initialLocation;

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  late LatLng _currentLocation;
  GoogleMapController? _mapController;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _currentLocation =
        widget.initialLocation ??
        const LatLng(-0.22985, -78.52495); // Default to Quito
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    if (widget.initialLocation != null) {
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
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
        _loading = false;
      });

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
              initialCameraPosition: CameraPosition(
                target: _currentLocation,
                zoom: 16,
              ),
              onMapCreated: (controller) => _mapController = controller,
              onCameraMove: (position) {
                _currentLocation = position.target;
              },
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
            ),

          if (!_loading)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(
                  bottom: 35,
                ), // Adjust for pin center
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
                children: [
                  const Text(
                    'Mueve el mapa para ubicar el pin en la entrada de tu local',
                    textAlign: TextAlign.center,
                    style: FudiTypography.bodySmall,
                  ),
                  const SizedBox(height: FudiSpacing.md),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context, _currentLocation);
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
