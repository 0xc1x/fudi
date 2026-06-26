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
import '../../../core/ui/fudi_surface_card.dart';
import '../../../core/ui/fudi_typography.dart';
import '../../../core/ui/fudi_star_rating.dart';
import '../../../core/ui/fudi_opening_hours_card.dart';
import '../domain/business_profile.dart';
import 'business_profile_providers.dart';

/// Business Profile Screen — shown when a consumer taps
/// "Ver perfil del negocio" (from product detail) or
/// "Ver negocio" (from order detail).
///
/// Route: `/business-profile/:id`
/// Navigation: `context.push()` (detail screen pattern)
class BusinessProfileScreen extends ConsumerWidget {
  const BusinessProfileScreen({required this.businessId, super.key});

  final String businessId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(businessProfileProvider(businessId));

    return profileAsync.when(
      data: (profile) => _BusinessProfileContent(profile: profile),
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, _) => Scaffold(
        appBar: AppBar(),
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
                Text(
                  'Negocio no encontrado',
                  style: FudiTypography.headlineSmall,
                ),
                const SizedBox(height: FudiSpacing.xs),
                Text(
                  'No pudimos encontrar este negocio',
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
                      color: FudiColors.primary,
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

// ─── Main Content ────────────────────────────────────────────────

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
      backgroundColor: FudiColors.muted,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    SizedBox(
                      height: 220,
                      width: double.infinity,
                      child: profile.coverImageUrl != null
                          ? CachedNetworkImage(
                              imageUrl: profile.coverImageUrl!,
                              fit: BoxFit.cover,
                              errorWidget: (_, _, _) => Container(
                                color: FudiColors.primary,
                                child: const Icon(
                                  Icons.store,
                                  size: 64,
                                  color: Colors.white,
                                ),
                              ),
                            )
                          : Container(
                              color: FudiColors.primary,
                              child: const Icon(
                                Icons.store,
                                size: 64,
                                color: Colors.white,
                              ),
                            ),
                    ),
                    Positioned(
                      top: MediaQuery.of(context).padding.top + 12,
                      left: 16,
                      right: 16,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          FudiCircleButton(
                            onTap: () => context.pop(),
                            icon: FudiIcons.chevronLeft,
                          ),
                          Row(
                            children: [
                              FudiHeartButton(
                                isFavorite: _isFavorite,
                                onTap: () =>
                                    setState(() => _isFavorite = !_isFavorite),
                              ),
                              const SizedBox(width: 8),
                              FudiCircleButton(
                                onTap: () {},
                                icon: Icons.share_rounded,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: -50,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: FudiColors.background,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(FudiRadius.xxl),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x0D000000),
                              blurRadius: 10,
                              offset: Offset(0, -4),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(FudiSpacing.lg),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Business Logo
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  FudiRadius.lg,
                                ),
                                border: Border.all(
                                  color: Colors.white,
                                  width: 4,
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x1A000000),
                                    blurRadius: 8,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(
                                  FudiRadius.lg - 4,
                                ),
                                child: profile.imageUrl != null
                                    ? CachedNetworkImage(
                                        imageUrl: profile.imageUrl!,
                                        fit: BoxFit.cover,
                                        errorWidget: (_, _, _) => Container(
                                          color: FudiColors.muted,
                                          child: const Icon(
                                            Icons.store,
                                            size: 32,
                                            color: FudiColors.mutedForeground,
                                          ),
                                        ),
                                      )
                                    : Container(
                                        color: FudiColors.muted,
                                        child: const Icon(
                                          Icons.store,
                                          size: 32,
                                          color: FudiColors.mutedForeground,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(width: FudiSpacing.md),
                            // Business Information
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    profile.name,
                                    style: FudiTypography.h2.copyWith(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 24,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    profile.type,
                                    style: FudiTypography.bodyMedium.copyWith(
                                      color: FudiColors.mutedForeground,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      FudiStarRating(rating: profile.rating),
                                      const SizedBox(width: 8),
                                      Text(
                                        profile.rating.toStringAsFixed(1),
                                        style: FudiTypography.labelSmall,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '(${profile.reviewCount} reseñas)',
                                        style: FudiTypography.bodySmall,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ─── Content Sections ─────────────────────────────
              SliverToBoxAdapter(
                child: Transform.translate(
                  offset: const Offset(0, 10),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: FudiSpacing.lg,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Stats card
                        _StatsCard(profile: profile),
                        const SizedBox(height: FudiSpacing.lg),

                        // About section
                        if (profile.description != null &&
                            profile.description!.isNotEmpty) ...[
                          _AboutCard(description: profile.description!),
                          const SizedBox(height: FudiSpacing.lg),
                        ],

                        // Contact Information
                        _ContactInfoCard(profile: profile),
                        const SizedBox(height: FudiSpacing.lg),

                        if (profile.hours.isNotEmpty) ...[
                          FudiOpeningHoursCard(hours: profile.hours, title: 'Horario'),
                          const SizedBox(height: FudiSpacing.lg),
                        ],

                        // Reviews
                        _ReviewsCard(profile: profile),
                        const SizedBox(height: FudiSpacing.lg),

                        // Map / Location
                        _LocationCard(profile: profile),
                        const SizedBox(height: FudiSpacing.xxl + 16),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Section Cards ───────────────────────────────────────────────

/// Green stats card showing total rescued and member since.
class _StatsCard extends StatelessWidget {
  const _StatsCard({required this.profile});

  final BusinessProfile profile;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(FudiSpacing.lg),
      margin: const EdgeInsets.only(top: FudiSpacing.xxl + FudiSpacing.lg),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(FudiRadius.xxl),
        border: Border.all(color: const Color(0xFFBBF7D0)),
      ),
      child: Column(
        children: [
          Text(
            '${profile.totalRescued}',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Color(0xFF15803D),
            ),
          ),
          const SizedBox(height: FudiSpacing.sm),
          Text(
            'Comidas rescatadas del desperdicio',
            style: FudiTypography.bodySmall.copyWith(
              color: const Color(0xFF16A34A),
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
          if (profile.memberSince != null) ...[
            const SizedBox(height: 12),
            Text(
              'Miembro desde ${profile.memberSince}',
              style: FudiTypography.bodySmall.copyWith(
                color: const Color(0xFF16A34A),
                fontSize: 11,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// About / description card.
class _AboutCard extends StatelessWidget {
  const _AboutCard({required this.description});

  final String description;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FudiSurfaceCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Acerca de', style: FudiTypography.labelMedium),
            const SizedBox(height: FudiSpacing.sm),
            Text(
              description,
              style: FudiTypography.bodyMedium.copyWith(
                color: FudiColors.mutedForeground,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Contact information card with address, phone, email, website.
class _ContactInfoCard extends StatelessWidget {
  const _ContactInfoCard({required this.profile});

  final BusinessProfile profile;

  @override
  Widget build(BuildContext context) {
    return FudiSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Información de contacto', style: FudiTypography.labelMedium),
          const SizedBox(height: FudiSpacing.lg),
          // Address
          FudiInfoRow(
            icon: FudiIcons.mapPin,
            label: 'Dirección',
            text: profile.address ?? '',
            iconSize: 20,
            trailing: profile.latitude != null && profile.longitude != null
                ? _TextLink(
                    text: 'Cómo llegar →',
                    onTap: () =>
                        _openMaps(profile.latitude!, profile.longitude!),
                  )
                : null,
          ),
          // Phone
          if (profile.phone != null && profile.phone!.isNotEmpty) ...[
            const SizedBox(height: FudiSpacing.lg),
            FudiInfoRow(
              icon: FudiIcons.phone,
              label: 'Teléfono',
              text: profile.phone!,
              isLink: true,
              iconSize: 20,
              onTap: () => _launchUrl('tel:${profile.phone}'),
            ),
          ],
          // Email
          if (profile.email != null && profile.email!.isNotEmpty) ...[
            const SizedBox(height: FudiSpacing.lg),
            FudiInfoRow(
              icon: FudiIcons.mail,
              label: 'Email',
              text: profile.email!,
              isLink: true,
              iconSize: 20,
              onTap: () => _launchUrl('mailto:${profile.email}'),
            ),
          ],
          // Website
          if (profile.website != null && profile.website!.isNotEmpty) ...[
            const SizedBox(height: FudiSpacing.lg),
            FudiInfoRow(
              icon: Icons.language_rounded,
              label: 'Sitio web',
              text: profile.website!,
              isLink: true,
              iconSize: 20,
              onTap: () {
                var url = profile.website!;
                if (!url.startsWith('http')) url = 'https://$url';
                _launchUrl(url);
              },
            ),
          ],
        ],
      ),
    );
  }
}

/// Opening hours card.

/// Reviews card with star rating summary and individual reviews.
class _ReviewsCard extends StatelessWidget {
  const _ReviewsCard({required this.profile});

  final BusinessProfile profile;

  @override
  Widget build(BuildContext context) {
    return FudiSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Reseñas', style: FudiTypography.labelMedium),
              Row(
                children: [
                  const Icon(
                    Icons.star_rounded,
                    size: 16,
                    color: Color(0xFFFACC15),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    profile.rating.toStringAsFixed(1),
                    style: FudiTypography.labelSmall,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '(${profile.reviewCount})',
                    style: FudiTypography.bodySmall,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: FudiSpacing.lg),
          if (profile.reviews.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: FudiSpacing.lg),
              child: Center(
                child: Text(
                  'Aún no hay reseñas',
                  style: FudiTypography.bodyMedium.copyWith(
                    color: FudiColors.mutedForeground,
                  ),
                ),
              ),
            )
          else
            ...profile.reviews.map(
              (review) => Padding(
                padding: const EdgeInsets.only(bottom: FudiSpacing.lg),
                child: _ReviewItem(review: review),
              ),
            ),
          if (profile.reviewCount > 3)
            Center(
              child: FudiPressableScale(
                onTap: () {
                  // TODO: Navigate to full reviews screen
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: FudiSpacing.sm),
                  child: Text(
                    'Ver todas las reseñas (${profile.reviewCount})',
                    style: FudiTypography.bodyMedium.copyWith(
                      color: FudiColors.primary,
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

/// A single review item.
class _ReviewItem extends StatelessWidget {
  const _ReviewItem({required this.review});

  final BusinessReview review;

  @override
  Widget build(BuildContext context) {
    final dateStr = _formatDate(review.date);

    return Container(
      padding: const EdgeInsets.only(bottom: FudiSpacing.lg),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: FudiColors.borderSolid)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar circle
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: FudiColors.secondary,
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
                    Text(review.userName, style: FudiTypography.labelSmall),
                    Text(dateStr, style: FudiTypography.bodySmall),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      size: 14,
                      color: Color(0xFFFACC15),
                    ),
                    const SizedBox(width: 2),
                    Text(
                      'Producto ${review.productRating}',
                      style: FudiTypography.bodySmall,
                    ),
                    const SizedBox(width: FudiSpacing.sm),
                    const Icon(
                      Icons.store_rounded,
                      size: 14,
                      color: Color(0xFFFACC15),
                    ),
                    const SizedBox(width: 2),
                    Text(
                      'Negocio ${review.businessRating}',
                      style: FudiTypography.bodySmall,
                    ),
                  ],
                ),
                if (review.productName != null) ...[
                  const SizedBox(height: 2),
                  Text(review.productName!, style: FudiTypography.bodySmall),
                ],
                if (review.comment != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    review.comment!,
                    style: FudiTypography.bodyMedium.copyWith(
                      color: FudiColors.mutedForeground,
                      height: 1.5,
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

  String _formatDate(DateTime dt) {
    const months = [
      '',
      'ene',
      'feb',
      'mar',
      'abr',
      'may',
      'jun',
      'jul',
      'ago',
      'sep',
      'oct',
      'nov',
      'dic',
    ];
    return '${dt.day} ${months[dt.month]}';
  }
}

/// Location / map placeholder card.
class _LocationCard extends ConsumerWidget {
  const _LocationCard({required this.profile});

  final BusinessProfile profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasCoords = profile.latitude != null && profile.longitude != null;

    return FudiSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Ubicación', style: FudiTypography.labelMedium),
          const SizedBox(height: FudiSpacing.md),
          Text(
            profile.address ?? '',
            style: FudiTypography.bodyMedium.copyWith(
              color: FudiColors.mutedForeground,
            ),
          ),
          if (hasCoords) ...[
            const SizedBox(height: FudiSpacing.lg),
            ClipRRect(
              borderRadius: BorderRadius.circular(FudiRadius.xl),
              child: SizedBox(
                width: double.infinity,
                height: 192,
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
                      infoWindow: InfoWindow(title: profile.name),
                    ),
                  },
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
                padding: const EdgeInsets.symmetric(vertical: FudiSpacing.md),
                decoration: BoxDecoration(
                  color: FudiColors.primary,
                  borderRadius: BorderRadius.circular(FudiRadius.lg),
                ),
                child: Text(
                  'Abrir en Google Maps',
                  textAlign: TextAlign.center,
                  style: FudiTypography.labelSmall.copyWith(
                    color: Colors.white,
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

/// Contact info row with icon, label, and value.
/// Tappable text link (e.g. "Cómo llegar →").
class _TextLink extends StatelessWidget {
  const _TextLink({required this.text, required this.onTap});

  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FudiPressableScale(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Text(
          text,
          style: FudiTypography.bodyMedium.copyWith(color: FudiColors.primary),
        ),
      ),
    );
  }
}

// ─── URL Launchers ───────────────────────────────────────────────

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
