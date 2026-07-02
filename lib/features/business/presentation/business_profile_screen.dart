import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart'; // <--- Corregido con 's'
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/ui/fudi_colors.dart';
import '../../../core/ui/fudi_pressable_scale.dart';
import '../../../core/ui/atoms/icons/fudi_icons.dart';
import '../../../core/ui/atoms/fudi_heart_button.dart';
import '../../../core/ui/atoms/fudi_circle_button.dart';
import '../../../core/ui/atoms/fudi_info_row.dart';
import '../../../core/utils/map_style.dart';
import '../../../core/ui/fudi_spacing.dart';
import '../../../core/ui/fudi_typography.dart';
import '../../../core/ui/fudi_opening_hours_card.dart';
import '../domain/business_profile.dart';
import 'business_profile_providers.dart';

/// Business Profile Screen — shown when a consumer taps
/// "Ver perfil del negocio" (from product detail) or
/// "Ver negocio" (from order detail).
class BusinessProfileScreen extends ConsumerWidget {
  const BusinessProfileScreen({required this.businessId, super.key});

  final String businessId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(businessProfileProvider(businessId));

    return profileAsync.when(
      data: (profile) => _BusinessProfileContent(profile: profile),
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator.adaptive()),
      ),
      error: (error, _) => Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(FudiSpacing.xl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  FudiIcons.mapPin,
                  size: 64,
                  color: FudiColors.mutedForeground,
                ),
                const SizedBox(height: FudiSpacing.md),
                const Text(
                  'Negocio no encontrado',
                  style: FudiTypography.headlineSmall,
                ),
                const SizedBox(height: FudiSpacing.xs),
                Text(
                  'No pudimos encontrar este establecimiento en este momento.',
                  textAlign: TextAlign.center,
                  style: FudiTypography.bodyMedium.copyWith(
                    color: FudiColors.mutedForeground,
                  ),
                ),
                const SizedBox(height: FudiSpacing.xl),
                FudiPressableScale(
                  onTap: () => context.go('/'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: FudiColors.foreground,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: const Text(
                      'Volver al inicio',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BusinessProfileContent extends ConsumerStatefulWidget {
  const _BusinessProfileContent({required this.profile});
  final BusinessProfile profile;

  @override
  ConsumerState<_BusinessProfileContent> createState() =>
      _BusinessProfileContentState();
}

class _BusinessProfileContentState
    extends ConsumerState<_BusinessProfileContent> {
  bool _isFavorite = false;

  @override
  Widget build(BuildContext context) {
    final profile = widget.profile;

    return Scaffold(
      backgroundColor: FudiColors.surfaceBackground,
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── AppBar Cinematográfico Inmersivo ───────────────────────────
              SliverAppBar(
                expandedHeight: 240,
                pinned: true,
                elevation: 0,
                backgroundColor: FudiColors.surfaceBackground,
                automaticallyImplyLeading: false,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      profile.coverImageUrl != null
                          ? CachedNetworkImage(
                              imageUrl: profile.coverImageUrl!,
                              fit: BoxFit.cover,
                            )
                          : Container(color: FudiColors.primary),
                      const Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black38,
                                Colors.transparent,
                                FudiColors.surfaceBackground,
                              ],
                              stops: [0.0, 0.4, 1.0],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Bloque Principal de Información de Cabecera ────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: FudiSpacing.xl,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Fila con el Logo Flotante Reubicado y Nombre/Categoría
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Transform.translate(
                            offset: Offset.zero,
                            child: Container(
                              width: 86,
                              height: 86,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(
                                  FudiRadius.xxl,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.06),
                                    blurRadius: FudiRadius.sm,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(4),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(
                                  FudiRadius.xl,
                                ),
                                child: profile.imageUrl != null
                                    ? CachedNetworkImage(
                                        imageUrl: profile.imageUrl!,
                                        fit: BoxFit.cover,
                                      )
                                    : Container(
                                        color: FudiColors.muted,
                                        child: const Icon(
                                          Icons.store,
                                          color: FudiColors.mutedForeground,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                          const SizedBox(width: FudiSpacing.md),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: FudiColors.primary.withValues(
                                        alpha: 0.1,
                                      ),
                                      borderRadius: BorderRadius.circular(
                                        FudiRadius.xs,
                                      ),
                                    ),
                                    child: Text(
                                      profile.type.toUpperCase(),
                                      style: FudiTypography.labelSmall.copyWith(
                                        color: FudiColors.primary,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    profile.name,
                                    style: FudiTypography.headlineMedium
                                        .copyWith(
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: -0.8,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Calificación y Reseñas Consolidadas en Línea Limpia
                      Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            color: FudiColors.yellow,
                            size: 20,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            profile.rating.toStringAsFixed(1),
                            style: FudiTypography.bodyMedium.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '(${profile.reviewCount} valoraciones de la comunidad)',
                            style: FudiTypography.bodySmall.copyWith(
                              color: FudiColors.mutedForeground,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: FudiSpacing.xl),

                      // ── Módulos de Información / Tarjetas Limpias ───────────────────
                      _StatsCard(profile: profile),
                      const SizedBox(height: FudiSpacing.lg),

                      if (profile.description != null &&
                          profile.description!.isNotEmpty) ...[
                        _AboutCard(description: profile.description!),
                        const SizedBox(height: FudiSpacing.lg),
                      ],

                      _ContactInfoCard(profile: profile),
                      const SizedBox(height: FudiSpacing.lg),

                      if (profile.hours.isNotEmpty) ...[
                        FudiOpeningHoursCard(
                          hours: profile.hours,
                          title: 'Horarios comerciales',
                        ),
                        const SizedBox(height: FudiSpacing.lg),
                      ],

                      _ReviewsCard(profile: profile),
                      const SizedBox(height: FudiSpacing.lg),

                      _LocationCard(profile: profile),
                      const SizedBox(height: 48),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ── Controles Superiores Flotantes (Volver, Favorito y Compartir) ───
          Positioned(
            top: MediaQuery.of(context).padding.top + 6,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                FudiCircleButton(
                  // <--- Corregido de FCircleButton a FudiCircleButton
                  onTap: () => context.pop(),
                  icon: FudiIcons.chevronLeft,
                ),
                Row(
                  children: [
                    FudiHeartButton(
                      isFavorite: _isFavorite,
                      onTap: () => setState(() => _isFavorite = !_isFavorite),
                    ),
                    const SizedBox(width: 8),
                    FudiCircleButton(onTap: () {}, icon: Icons.share_rounded),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Tarjetas Modulares y Optimizadas ─────────────────────────────

class _StatsCard extends StatelessWidget {
  const _StatsCard({required this.profile});
  final BusinessProfile profile;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(FudiSpacing.xl),
      decoration: BoxDecoration(
        color: FudiColors.surfaceSuccess,
        borderRadius: BorderRadius.circular(FudiRadius.xxl),
        border: Border.all(color: FudiColors.surfaceSuccessBorder),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                FudiIcons.leaf,
                color: FudiColors.successDark,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                '${profile.totalRescued}',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: FudiColors.successDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: FudiSpacing.xs),
          Text(
            'Comidas rescatadas del desperdicio',
            style: FudiTypography.labelSmall.copyWith(
              color: FudiColors.success,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          if (profile.memberSince != null) ...[
            const SizedBox(height: 8),
            Text(
              'Aliado Fudi desde ${profile.memberSince}',
              style: FudiTypography.bodySmall.copyWith(
                color: FudiColors.success.withValues(alpha: 0.8),
                fontSize: 11,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _AboutCard extends StatelessWidget {
  const _AboutCard({required this.description});
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(FudiSpacing.xl),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(FudiRadius.xxl),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Acerca del local',
            style: FudiTypography.labelMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: FudiSpacing.sm),
          Text(
            description,
            style: FudiTypography.bodyMedium.copyWith(
              color: FudiColors.mutedForeground,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactInfoCard extends StatelessWidget {
  const _ContactInfoCard({required this.profile});
  final BusinessProfile profile;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(FudiSpacing.xl),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(FudiRadius.xxl),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Información de contacto',
            style: FudiTypography.labelMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: FudiSpacing.lg),
          FudiInfoRow(
            icon: FudiIcons.mapPin,
            label: 'Dirección',
            text: profile.address ?? 'No disponible',
            iconSize: 18,
            trailing: profile.latitude != null && profile.longitude != null
                ? _TextLink(
                    text: 'Indicaciones →',
                    onTap: () =>
                        _openMaps(profile.latitude!, profile.longitude!),
                  )
                : null,
          ),
          if (profile.phone != null && profile.phone!.isNotEmpty) ...[
            const SizedBox(height: FudiSpacing.md),
            FudiInfoRow(
              icon: FudiIcons.phone,
              label: 'Teléfono',
              text: profile.phone!,
              isLink: true,
              iconSize: 18,
              onTap: () => _launchUrl('tel:${profile.phone}'),
            ),
          ],
          if (profile.email != null && profile.email!.isNotEmpty) ...[
            const SizedBox(height: FudiSpacing.md),
            FudiInfoRow(
              icon: FudiIcons.mail,
              label: 'Email',
              text: profile.email!,
              isLink: true,
              iconSize: 18,
              onTap: () => _launchUrl('mailto:${profile.email}'),
            ),
          ],
          if (profile.website != null && profile.website!.isNotEmpty) ...[
            const SizedBox(height: FudiSpacing.md),
            FudiInfoRow(
              icon: Icons.language_rounded,
              label: 'Sitio web',
              text: profile.website!,
              isLink: true,
              iconSize: 18,
              onTap: () {
                var url = profile.website!;
                if (!url.startsWith('http')) url = 'https://$url';
                unawaited(_launchUrl(url));
              },
            ),
          ],
        ],
      ),
    );
  }
}

class _ReviewsCard extends StatelessWidget {
  const _ReviewsCard({required this.profile});
  final BusinessProfile profile;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(FudiSpacing.xl),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(FudiRadius.xxl),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Reseñas',
                style: FudiTypography.labelMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: FudiColors.surfaceWarning,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      size: 14,
                      color: FudiColors.yellowDark,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      profile.rating.toStringAsFixed(1),
                      style: FudiTypography.labelSmall.copyWith(
                        color: FudiColors.yellowDark,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: FudiSpacing.lg),
          if (profile.reviews.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: FudiSpacing.lg),
              child: Center(
                child: Text(
                  'Este negocio aún no tiene opiniones.',
                  style: FudiTypography.bodyMedium.copyWith(
                    color: FudiColors.mutedForeground,
                  ),
                ),
              ),
            )
          else
            ...profile.reviews.map((review) => _ReviewItem(review: review)),
          if (profile.reviewCount > 3)
            Center(
              child: FudiPressableScale(
                onTap: () {},
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: FudiSpacing.sm),
                  child: Text(
                    'Ver las ${profile.reviewCount} reseñas anteriores',
                    style: FudiTypography.bodyMedium.copyWith(
                      color: FudiColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ReviewItem extends StatelessWidget {
  const _ReviewItem({required this.review});
  final BusinessReview review;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: FudiSpacing.md),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: FudiColors.surfaceMuted)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: FudiColors.surfaceMuted,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              FudiIcons.user,
              size: 16,
              color: FudiColors.mutedForeground,
            ),
          ),
          const SizedBox(width: FudiSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      review.userName,
                      style: FudiTypography.labelSmall.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${review.date.day}/${review.date.month}',
                      style: FudiTypography.bodySmall.copyWith(
                        color: FudiColors.mutedForeground,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(
                      Icons.fastfood_rounded,
                      size: 12,
                      color: FudiColors.yellow,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Pack: ${review.productRating}',
                      style: FudiTypography.bodySmall,
                    ),
                    const SizedBox(width: 12),
                    const Icon(
                      Icons.storefront_rounded,
                      size: 12,
                      color: FudiColors.yellow,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Atención: ${review.businessRating}',
                      style: FudiTypography.bodySmall,
                    ),
                  ],
                ),
                if (review.comment != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    review.comment!,
                    style: FudiTypography.bodyMedium.copyWith(
                      color: FudiColors.mutedForeground,
                      height: 1.4,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LocationCard extends StatelessWidget {
  const _LocationCard({required this.profile});
  final BusinessProfile profile;

  @override
  Widget build(BuildContext context) {
    final hasCoords = profile.latitude != null && profile.longitude != null;

    return Container(
      padding: const EdgeInsets.all(FudiSpacing.xl),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Geolocalización',
            style: FudiTypography.labelMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: FudiSpacing.xs),
          Text(
            profile.address ?? '',
            style: FudiTypography.bodyMedium.copyWith(
              color: FudiColors.mutedForeground,
            ),
          ),
          if (hasCoords) ...[
            const SizedBox(height: FudiSpacing.lg),
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: SizedBox(
                width: double.infinity,
                height: 180,
                child: GoogleMap(
                  style: kMapStyleNoPoi,
                  initialCameraPosition: CameraPosition(
                    target: LatLng(profile.latitude!, profile.longitude!),
                    zoom: 15,
                  ),
                  markers: {
                    Marker(
                      markerId: MarkerId(profile.id),
                      position: LatLng(profile.latitude!, profile.longitude!),
                    ),
                  },
                  // El EagerGestureRecognizer absorbe los eventos táctiles directamente aquí
                  gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                    Factory<OneSequenceGestureRecognizer>(
                      () => EagerGestureRecognizer(),
                    ),
                  }.toList().toSet(),
                  zoomControlsEnabled: false,
                  mapToolbarEnabled: false,
                  myLocationButtonEnabled: false,
                  compassEnabled: false,
                  onTap: (_) =>
                      _openMaps(profile.latitude!, profile.longitude!),
                ),
              ),
            ),
            const SizedBox(height: FudiSpacing.md),
            FudiPressableScale(
              onTap: () => _openMaps(profile.latitude!, profile.longitude!),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: FudiColors.foreground,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'Trazar ruta en Maps',
                  textAlign: TextAlign.center,
                  style: FudiTypography.labelSmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TextLink extends StatelessWidget {
  const _TextLink({required this.text, required this.onTap});
  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FudiPressableScale(
      onTap: onTap,
      child: Text(
        text,
        style: FudiTypography.bodyMedium.copyWith(
          color: FudiColors.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// ─── Controladores URL Launcher / Mapas ─────────────────────────

Future<void> _openMaps(double lat, double lng) async {
  final uri = Uri.parse('https://maps.google.com/?q=$lat,$lng');
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

Future<void> _launchUrl(String url) async {
  final uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
