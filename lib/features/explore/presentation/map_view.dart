import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/ui/fudi_colors.dart';
import '../../../core/ui/atoms/icons/fudi_icons.dart';
import '../../../core/utils/map_style.dart';
import '../../../core/ui/fudi_spacing.dart';
import '../../../core/ui/fudi_typography.dart';
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
  bool _cameraInitialized = false;
  bool _markersDirty = true;
  List<Offer> _lastOffers = [];
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
  void initState() {
    super.initState();
    ref.listenManual(filteredOffersProvider, (_, next) {
      next.whenOrNull(data: (offers) {
        if (_mapReady) {
          _lastOffers = offers;
          _markersDirty = true;
          _syncMarkers();
        }
      });
    });
  }

  void _syncMarkers() {
    if (!_markersDirty || !_mapReady) return;
    _markersDirty = false;

    final offers = _lastOffers;
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
          onTap: () => _onMarkerTap(offer),
          icon:
              _markerCache['${offer.id}_$isSelected'] ??
              BitmapDescriptor.defaultMarker,
          anchor: const Offset(0.5, 1.0),
          infoWindow: InfoWindow(
            title: offer.title,
            snippet: offer.business.name,
          ),
        ),
      );
    }
    setState(() => _markers = newMarkers);
    _generateMarkerIcons(offers);
    _fitCameraToMarkers(newMarkers);
  }

  @override
  Widget build(BuildContext context) {
    final offersAsync = ref.watch(filteredOffersProvider);
    final hasOffers = offersAsync.whenOrNull(data: (o) => o.isNotEmpty) ?? false;

    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            style: kMapStyleNoPoi,
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
                _markerCache.clear();
                _markersDirty = true;
                _syncMarkers();
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
            bottom: _selectedOffer != null ? 360 : 100,
            right: FudiSpacing.lg,
            child: _MyLocationButton(onPress: _goToMyLocation),
          ),

          if (!_mapReady) const Center(child: CircularProgressIndicator()),

          if (_mapReady && !hasOffers)
            Positioned(
              top: MediaQuery.of(context).padding.top + 120,
              left: FudiSpacing.lg,
              right: FudiSpacing.lg,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: FudiSpacing.lg,
                    vertical: FudiSpacing.md,
                  ),
                  decoration: BoxDecoration(
                    color: FudiColors.background.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(FudiRadius.lg),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Text(
                    'No hay ofertas disponibles en esta zona',
                    style: FudiTypography.bodyMedium.copyWith(
                      color: FudiColors.mutedForeground,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),

          if (_selectedOffer != null)
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + FudiSpacing.lg,
              left: FudiSpacing.lg,
              right: FudiSpacing.lg,
              child: _SelectedOfferCard(
                offer: _selectedOffer!,
                onClose: () {
                  setState(() => _selectedOffer = null);
                },
                onReserve: () => context.push('/product/${_selectedOffer!.id}'),
                onTap: () => context.push('/product/${_selectedOffer!.id}'),
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
    if (_lastOffers.isNotEmpty) {
      _markersDirty = true;
      _syncMarkers();
    }
  }

  void _onMarkerTap(Offer offer) {
    setState(() => _selectedOffer = offer);

    _markerCache.clear();
    _markersDirty = true;
    _syncMarkers();
  }

  void _fitCameraToMarkers(Set<Marker> markers) {
    if (markers.isEmpty || _mapController == null || _cameraInitialized) return;

    double? minLat, maxLat, minLng, maxLng;
    for (final m in markers) {
      final lat = m.position.latitude;
      final lng = m.position.longitude;
      minLat = (minLat == null || lat < minLat) ? lat : minLat;
      maxLat = (maxLat == null || lat > maxLat) ? lat : maxLat;
      minLng = (minLng == null || lng < minLng) ? lng : minLng;
      maxLng = (maxLng == null || lng > maxLng) ? lng : maxLng;
    }

    final bounds = LatLngBounds(
      southwest: LatLng(minLat!, minLng!),
      northeast: LatLng(maxLat!, maxLng!),
    );

    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 60),
    );
    _cameraInitialized = true;
  }

  Future<void> _generateMarkerIcons(List<Offer> offers) async {
    final offersToGenerate = <Offer>{};
    for (final offer in offers) {
      if (offer.business.latitude == null || offer.business.longitude == null) {
        continue;
      }
      final isSelected = _selectedOffer?.id == offer.id;
      if (!_markerCache.containsKey('${offer.id}_$isSelected')) {
        offersToGenerate.add(offer);
      }
    }

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
          onTap: () => _onMarkerTap(offer),
          icon: _markerCache[key] ?? BitmapDescriptor.defaultMarker,
          anchor: const Offset(0.5, 1.0),
          infoWindow: InfoWindow(
            title: offer.title,
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
      subtitle.add(filters.category!.dbValue);
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
    this.onTap,
  });

  final Offer offer;
  final VoidCallback onClose;
  final VoidCallback onReserve;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final discountPercent = offer.discountPercentage.round();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image ──────────────────────────────────────────
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(FudiRadius.xl),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 140,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (offer.imageUrl != null && offer.imageUrl!.isNotEmpty)
                      CachedNetworkImage(
                        imageUrl: offer.imageUrl!,
                        height: 140,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (_, _) => Container(
                          color: FudiColors.muted,
                          child: const Center(
                            child: Icon(
                              FudiIcons.imageOff,
                              color: FudiColors.mutedForeground,
                              size: 32,
                            ),
                          ),
                        ),
                        errorWidget: (_, _, _) => Container(
                          color: FudiColors.muted,
                          child: const Center(
                            child: Icon(
                              FudiIcons.imageOff,
                              color: FudiColors.mutedForeground,
                              size: 32,
                            ),
                          ),
                        ),
                      )
                    else
                      Container(
                        color: FudiColors.primary.withValues(alpha: 0.08),
                        child: const Center(
                          child: Icon(
                            FudiIcons.imageOff,
                            size: 40,
                            color: FudiColors.primary,
                          ),
                        ),
                      ),

                    // Discount badge
                    if (discountPercent > 0)
                      Positioned(
                        top: FudiSpacing.sm,
                        left: FudiSpacing.sm,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
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
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),

                    // Close button
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
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: const Icon(
                            FudiIcons.x,
                            size: 16,
                          ),
                        ),
                      ),
                    ),

                    // Gradient overlay for readability
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Container(
                        height: 60,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.4),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Content ────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                FudiSpacing.md,
                FudiSpacing.sm,
                FudiSpacing.md,
                FudiSpacing.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Offer title
                  Text(
                    offer.title,
                    style: FudiTypography.labelMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: FudiSpacing.xs),

                  // Business name + rating
                  Row(
                    children: [
                      Icon(
                        FudiIcons.store,
                        size: 14,
                        color: FudiColors.mutedForeground,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          offer.business.name,
                          style: FudiTypography.bodySmall.copyWith(
                            color: FudiColors.mutedForeground,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (offer.rating > 0) ...[
                        const SizedBox(width: FudiSpacing.sm),
                        Icon(
                          FudiIcons.star,
                          size: 14,
                          color: FudiColors.warning,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          offer.rating.toStringAsFixed(1),
                          style: FudiTypography.bodySmall.copyWith(
                            color: FudiColors.warning,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: FudiSpacing.xs),

                  // Pickup window
                  Row(
                    children: [
                      Icon(
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

                  // Prices
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
                      const Spacer(),
                      Text(
                        '${offer.stock} disponibles',
                        style: FudiTypography.bodySmall.copyWith(
                          color: offer.stock <= 3
                              ? FudiColors.destructive
                              : FudiColors.mutedForeground,
                          fontWeight: offer.stock <= 3
                              ? FontWeight.w700
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: FudiSpacing.md),

                  // Reserve button
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: onReserve,
                      style: FilledButton.styleFrom(
                        backgroundColor: FudiColors.primary,
                        minimumSize: const Size.fromHeight(46),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(FudiRadius.lg),
                        ),
                      ),
                      child: Text(
                        'Ver detalle',
                        style: FudiTypography.labelSmall.copyWith(
                          color: FudiColors.primaryForeground,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
