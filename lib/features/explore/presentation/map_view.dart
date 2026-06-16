import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/ui/fudi_colors.dart';
import '../../../core/ui/atoms/icons/fudi_icons.dart';
import '../../../core/ui/fudi_spacing.dart';
import '../../../core/ui/fudi_typography.dart';
import '../../../core/ui/fudi_star_rating.dart';
import '../../offers/domain/offer.dart';
import '../../offers/presentation/offer_providers.dart';
import '../../profile/presentation/profile_providers.dart';
import 'fudi_filters.dart';

class ExploreMapView extends ConsumerStatefulWidget {
  const ExploreMapView({
    super.key,
    this.onBack,
    this.filters = const FudiFilterState(),
    this.onFiltersChanged,
  });

  final VoidCallback? onBack;
  final FudiFilterState filters;
  final ValueChanged<FudiFilterState>? onFiltersChanged;

  @override
  ConsumerState<ExploreMapView> createState() => _ExploreMapViewState();
}

class _ExploreMapViewState extends ConsumerState<ExploreMapView> {
  GoogleMapController? _mapController;
  Offer? _selectedOffer;
  Set<Marker> _markers = {};
  bool _mapReady = false;
  final Map<String, BitmapDescriptor> _markerCache = {};

  static const _ecuadorCenter = CameraPosition(
    target: LatLng(-1.8312, -78.1834),
    zoom: 6,
  );

  CameraPosition get _initialCameraPosition {
    final selectedAddress = ref.read(userSelectedAddressProvider);
    if (selectedAddress != null) {
      return CameraPosition(
        target: LatLng(selectedAddress.latitude, selectedAddress.longitude),
        zoom: 14,
      );
    }
    return _ecuadorCenter;
  }

  @override
  Widget build(BuildContext context) {
    final offersAsync = ref.watch(filteredOffersProvider);

    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: _initialCameraPosition,
            onMapCreated: _onMapCreated,
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            compassEnabled: false,
            onCameraMove: (_) {},
            onTap: (_) {
              if (_selectedOffer != null) {
                setState(() => _selectedOffer = null);
              }
            },
          ),

          Positioned(
            top: MediaQuery.of(context).padding.top + FudiSpacing.sm,
            left: FudiSpacing.lg,
            right: FudiSpacing.lg,
            child: _MapHeader(
              offerCount:
                  offersAsync.whenOrNull(data: (offers) => offers.length) ?? 0,
              filters: widget.filters,
              onBack: () {
                if (widget.onBack != null) {
                  widget.onBack!();
                } else {
                  context.pop();
                }
              },
              onFilterTap: () => FudiFiltersSheet.show(
                context,
                currentFilters: widget.filters,
                onApply: (f) {
                  widget.onFiltersChanged?.call(f);
                  ref
                      .read(filteredOffersProvider.notifier)
                      .applyFilters(
                        category: f.category,
                        maxPrice: f.maxPrice,
                        maxDistanceKm: f.maxDistanceKm,
                        searchQuery: f.searchQuery,
                      );
                },
              ),
            ),
          ),

          Positioned(
            top: MediaQuery.of(context).padding.top + 60,
            right: FudiSpacing.lg,
            child: _MapZoomControls(onZoomIn: _zoomIn, onZoomOut: _zoomOut),
          ),

          Positioned(
            bottom: _selectedOffer != null ? 220 : 100,
            right: FudiSpacing.lg,
            child: _MyLocationButton(onPress: _goToMyLocation),
          ),

          if (!_mapReady) const Center(child: CircularProgressIndicator()),

          offersAsync.when(
            data: (offers) {
              if (_mapReady) {
                _updateMarkers(offers);
              }
              return const SizedBox.shrink();
            },
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
          ),

          if (_selectedOffer != null)
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + FudiSpacing.lg,
              left: FudiSpacing.lg,
              right: FudiSpacing.lg,
              child: _SelectedOfferCard(
                offer: _selectedOffer!,
                onClose: () => setState(() => _selectedOffer = null),
                onReserve: () => context.push('/product/${_selectedOffer!.id}'),
              ),
            ),

          if (_selectedOffer == null)
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + FudiSpacing.lg,
              left: FudiSpacing.lg,
              child: _MapLegend(),
            ),
        ],
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    setState(() => _mapReady = true);
  }

  void _updateMarkers(List<Offer> offers) {
    final newMarkers = <Marker>{};
    for (final offer in offers) {
      if (offer.business.latitude == null || offer.business.longitude == null) {
        continue;
      }
      final position = LatLng(
        offer.business.latitude!,
        offer.business.longitude!,
      );
      final isSelected = _selectedOffer?.id == offer.id;
      newMarkers.add(
        Marker(
          markerId: MarkerId(offer.id),
          position: position,
          onTap: () => setState(() => _selectedOffer = offer),
          icon:
              _markerCache['${offer.id}_$isSelected'] ??
              BitmapDescriptor.defaultMarker,
          anchor: const Offset(0.5, 1.0),
          infoWindow: InfoWindow(
            title: '\$${offer.discountedPrice.toStringAsFixed(2)}',
            snippet: offer.business.name,
          ),
        ),
      );
    }
    if (newMarkers.length != _markers.length ||
        newMarkers.any((m) => !_markers.contains(m))) {
      setState(() => _markers = newMarkers);
    }
    _generateMarkerIcons(offers);
  }

  Future<void> _generateMarkerIcons(List<Offer> offers) async {
    final offersToGenerate = offers.where((o) {
      if (o.business.latitude == null || o.business.longitude == null) {
        return false;
      }
      final isSelected = _selectedOffer?.id == o.id;
      return !_markerCache.containsKey('${o.id}_$isSelected');
    }).toList();

    if (offersToGenerate.isEmpty) return;

    for (final offer in offersToGenerate) {
      final isSelected = _selectedOffer?.id == offer.id;
      final key = '${offer.id}_$isSelected';
      if (_markerCache.containsKey(key)) continue;

      final descriptor = await _createPriceMarkerBitmap(
        price: '\$${offer.discountedPrice.toStringAsFixed(0)}',
        isSelected: isSelected,
      );
      _markerCache[key] = descriptor;
    }

    final updatedMarkers = <Marker>{};
    for (final offer in offers) {
      if (offer.business.latitude == null || offer.business.longitude == null) {
        continue;
      }
      final isSelected = _selectedOffer?.id == offer.id;
      final key = '${offer.id}_$isSelected';
      updatedMarkers.add(
        Marker(
          markerId: MarkerId(offer.id),
          position: LatLng(offer.business.latitude!, offer.business.longitude!),
          onTap: () => setState(() => _selectedOffer = offer),
          icon: _markerCache[key] ?? BitmapDescriptor.defaultMarker,
          anchor: const Offset(0.5, 1.0),
          infoWindow: InfoWindow(
            title: '\$${offer.discountedPrice.toStringAsFixed(2)}',
            snippet: offer.business.name,
          ),
        ),
      );
    }
    if (mounted) {
      setState(() => _markers = updatedMarkers);
    }
  }

  Future<BitmapDescriptor> _createPriceMarkerBitmap({
    required String price,
    required bool isSelected,
  }) async {
    final dpr = ui.PlatformDispatcher.instance.views.first.devicePixelRatio;
    final textPainter = TextPainter(
      text: TextSpan(
        text: price,
        style: TextStyle(
          color: isSelected ? Colors.white : FudiColors.primary,
          fontSize: 13,
          fontWeight: FontWeight.w800,
        ),
      ),
      textDirection: ui.TextDirection.ltr,
    )..layout();

    final textWidth = textPainter.width;
    final pillWidth = textWidth + 20;
    final pillHeight = 28.0;
    final arrowHeight = 10.0;
    final totalHeight = pillHeight + arrowHeight;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    final pillRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, pillWidth, pillHeight),
      const Radius.circular(14),
    );

    final bgPaint = Paint()
      ..color = isSelected ? FudiColors.primary : Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawRRect(pillRect, bgPaint);

    if (!isSelected) {
      final borderPaint = Paint()
        ..color = FudiColors.primary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      canvas.drawRRect(pillRect, borderPaint);
    }

    final arrowPath = Path();
    final arrowBaseY = pillHeight - 1;
    arrowPath.moveTo(pillWidth / 2 - 6, arrowBaseY);
    arrowPath.lineTo(pillWidth / 2, arrowBaseY + arrowHeight);
    arrowPath.lineTo(pillWidth / 2 + 6, arrowBaseY);
    arrowPath.close();
    canvas.drawPath(
      arrowPath,
      Paint()..color = isSelected ? FudiColors.primary : Colors.white,
    );

    if (!isSelected) {
      final arrowBorderLeft = Path();
      arrowBorderLeft.moveTo(pillWidth / 2 - 6, arrowBaseY);
      arrowBorderLeft.lineTo(pillWidth / 2, arrowBaseY + arrowHeight);
      canvas.drawPath(
        arrowBorderLeft,
        Paint()
          ..color = FudiColors.primary
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0,
      );
    }

    textPainter.paint(
      canvas,
      Offset(
        (pillWidth - textWidth) / 2,
        (pillHeight - textPainter.height) / 2,
      ),
    );

    final picture = recorder.endRecording();
    final image = await picture.toImage(
      (pillWidth * dpr).ceil(),
      (totalHeight * dpr).ceil(),
    );
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();

    return BitmapDescriptor.bytes(byteData!.buffer.asUint8List());
  }

  void _zoomIn() {
    _mapController?.animateCamera(CameraUpdate.zoomIn());
  }

  void _zoomOut() {
    _mapController?.animateCamera(CameraUpdate.zoomOut());
  }

  void _goToMyLocation() {
    final position = ref
        .read(userLocationProvider)
        .whenOrNull(data: (pos) => pos);
    if (position != null && _mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(position.latitude, position.longitude),
          15,
        ),
      );
    }
  }
}

class _MapHeader extends StatelessWidget {
  const _MapHeader({
    required this.offerCount,
    required this.onBack,
    required this.filters,
    required this.onFilterTap,
  });

  final int offerCount;
  final VoidCallback onBack;
  final FudiFilterState filters;
  final VoidCallback onFilterTap;

  @override
  Widget build(BuildContext context) {
    final subtitle = <String>[];
    if (filters.category != null) {
      subtitle.add(filters.category!);
    }
    if (filters.maxDistanceKm != null) {
      subtitle.add('${filters.maxDistanceKm!.toInt()} km');
    }
    if (filters.maxPrice != null) {
      subtitle.add('Max \$${filters.maxPrice!.toStringAsFixed(0)}');
    }

    return Container(
      decoration: BoxDecoration(
        color: FudiColors.background,
        borderRadius: BorderRadius.circular(FudiRadius.lg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: FudiSpacing.md,
        vertical: FudiSpacing.sm,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: FudiColors.muted,
                shape: BoxShape.circle,
              ),
              child: const Icon(FudiIcons.chevronLeft, size: 24),
            ),
          ),
          const SizedBox(width: FudiSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Mapa de ofertas', style: FudiTypography.labelMedium),
                if (subtitle.isNotEmpty)
                  Text(
                    subtitle.join(' · '),
                    style: FudiTypography.bodySmall.copyWith(
                      color: FudiColors.mutedForeground,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: FudiSpacing.md,
              vertical: FudiSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: FudiColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(FudiRadius.full),
            ),
            child: Text(
              '$offerCount ofertas',
              style: FudiTypography.bodySmall.copyWith(
                color: FudiColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: FudiSpacing.sm),
          GestureDetector(
            onTap: onFilterTap,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: filters.hasActiveFilters
                    ? FudiColors.primary.withValues(alpha: 0.1)
                    : FudiColors.muted,
                shape: BoxShape.circle,
                border: filters.hasActiveFilters
                    ? Border.all(color: FudiColors.primary, width: 1.5)
                    : null,
              ),
              child: Icon(
                FudiIcons.slidersHorizontal,
                size: 20,
                color: filters.hasActiveFilters
                    ? FudiColors.primary
                    : FudiColors.mutedForeground,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapZoomControls extends StatelessWidget {
  const _MapZoomControls({required this.onZoomIn, required this.onZoomOut});

  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: FudiColors.background,
        borderRadius: BorderRadius.circular(FudiRadius.lg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _ZoomButton(icon: FudiIcons.zoomIn, onTap: onZoomIn),
          Divider(height: 1, color: FudiColors.borderSolid),
          _ZoomButton(icon: FudiIcons.zoomOut, onTap: onZoomOut),
        ],
      ),
    );
  }
}

class _ZoomButton extends StatelessWidget {
  const _ZoomButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 40,
      child: IconButton(
        icon: Icon(icon, size: 20),
        onPressed: onTap,
        splashRadius: 20,
        padding: EdgeInsets.zero,
      ),
    );
  }
}

class _MyLocationButton extends StatelessWidget {
  const _MyLocationButton({required this.onPress});

  final VoidCallback onPress;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: FudiColors.background,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: const Icon(
          FudiIcons.navigation,
          size: 24,
          color: FudiColors.primary,
        ),
        onPressed: onPress,
        style: IconButton.styleFrom(
          backgroundColor: FudiColors.background,
          shape: const CircleBorder(),
        ),
      ),
    );
  }
}

class _SelectedOfferCard extends StatelessWidget {
  const _SelectedOfferCard({
    required this.offer,
    required this.onClose,
    required this.onReserve,
  });

  final Offer offer;
  final VoidCallback onClose;
  final VoidCallback onReserve;

  @override
  Widget build(BuildContext context) {
    final discountPercent = offer.discountPercentage.round();

    return Container(
      decoration: BoxDecoration(
        color: FudiColors.background,
        borderRadius: BorderRadius.circular(FudiRadius.xl),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(FudiSpacing.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: FudiColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(FudiRadius.lg),
                  ),
                  child: Stack(
                    children: [
                      const Center(
                        child: Icon(
                          FudiIcons.mapPin,
                          size: 32,
                          color: FudiColors.primary,
                        ),
                      ),
                      if (discountPercent > 0)
                        Positioned(
                          top: 4,
                          right: 4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: FudiColors.primary,
                              borderRadius: BorderRadius.circular(
                                FudiRadius.full,
                              ),
                            ),
                            child: Text(
                              '-$discountPercent%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: FudiSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        offer.business.name,
                        style: FudiTypography.labelMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: FudiSpacing.xs),
                      Row(
                        children: [
                          if (offer.rating > 0) ...[
                            FudiStarRating(
                              rating: offer.rating,
                              showText: true,
                            ),
                            const SizedBox(width: FudiSpacing.sm),
                          ],
                          Text(
                            offer.business.address,
                            style: FudiTypography.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      const SizedBox(height: FudiSpacing.xs),
                      Row(
                        children: [
                          const Icon(
                            FudiIcons.clock,
                            size: 14,
                            color: FudiColors.accent,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatPickupWindow(offer),
                            style: FudiTypography.bodySmall.copyWith(
                              color: FudiColors.accent,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: FudiSpacing.sm),
                      Row(
                        children: [
                          Text(
                            '\$${offer.discountedPrice.toStringAsFixed(2)}',
                            style: FudiTypography.price,
                          ),
                          const SizedBox(width: FudiSpacing.sm),
                          Text(
                            '\$${offer.originalPrice.toStringAsFixed(2)}',
                            style: FudiTypography.priceOriginal,
                          ),
                        ],
                      ),
                      if (offer.stock <= 3) ...[
                        const SizedBox(height: FudiSpacing.xs),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: FudiSpacing.sm,
                            vertical: FudiSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: FudiColors.destructive.withValues(
                              alpha: 0.1,
                            ),
                            borderRadius: BorderRadius.circular(FudiRadius.sm),
                            border: Border.all(
                              color: FudiColors.destructive.withValues(
                                alpha: 0.2,
                              ),
                            ),
                          ),
                          child: Text(
                            'Solo quedan ${offer.stock} disponibles!',
                            style: FudiTypography.bodySmall.copyWith(
                              color: FudiColors.destructive,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: FudiSpacing.sm,
            right: FudiSpacing.sm,
            child: GestureDetector(
              onTap: onClose,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: FudiColors.background,
                  shape: BoxShape.circle,
                  border: Border.all(color: FudiColors.borderSolid),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: const Icon(FudiIcons.x, size: 16),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                FudiSpacing.md,
                0,
                FudiSpacing.md,
                FudiSpacing.md,
              ),
              child: FilledButton(
                onPressed: onReserve,
                style: FilledButton.styleFrom(
                  backgroundColor: FudiColors.primary,
                  minimumSize: const Size.fromHeight(44),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(FudiRadius.lg),
                  ),
                ),
                child: Text(
                  'Reservar ahora',
                  style: FudiTypography.labelSmall.copyWith(
                    color: FudiColors.primaryForeground,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatPickupWindow(Offer offer) {
    final start =
        '${offer.pickupStart.hour.toString().padLeft(2, '0')}:${offer.pickupStart.minute.toString().padLeft(2, '0')}';
    final end =
        '${offer.pickupEnd.hour.toString().padLeft(2, '0')}:${offer.pickupEnd.minute.toString().padLeft(2, '0')}';
    return '$start - $end';
  }
}

class _MapLegend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(FudiSpacing.md),
      decoration: BoxDecoration(
        color: FudiColors.background.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(FudiRadius.lg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: const BoxDecoration(
              color: FudiColors.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: FudiSpacing.sm),
          Text('Ofertas disponibles', style: FudiTypography.bodySmall),
        ],
      ),
    );
  }
}
