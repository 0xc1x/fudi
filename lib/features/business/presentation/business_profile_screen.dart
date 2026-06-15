import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/ui/fudi_colors.dart';
import '../../../core/ui/atoms/icons/fudi_icons.dart';
import '../../../core/ui/fudi_spacing.dart';
import '../../../core/ui/fudi_surface_card.dart';
import '../../../core/ui/fudi_typography.dart';
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
                FilledButton(
                  onPressed: () => context.go('/'),
                  style: FilledButton.styleFrom(
                    backgroundColor: FudiColors.primary,
                  ),
                  child: const Text('Volver al inicio'),
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
                          _CircleButton(
                            onTap: () => context.pop(),
                            icon: FudiIcons.chevronLeft,
                          ),
                          Row(
                            children: [
                              _CircleButton(
                                onTap: () =>
                                    setState(() => _isFavorite = !_isFavorite),
                                icon: _isFavorite
                                    ? FudiIcons.heart
                                    : FudiIcons.heartOutline,
                                iconColor: _isFavorite
                                    ? const Color(0xFFEF4444)
                                    : FudiColors.foreground,
                              ),
                              const SizedBox(width: 8),
                              _CircleButton(
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
                                      _StarRating(rating: profile.rating),
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

                        // Opening Hours
                        if (profile.hours.isNotEmpty) ...[
                          _OpeningHoursCard(hours: profile.hours),
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
          _ContactRow(
            icon: FudiIcons.mapPin,
            label: 'Dirección',
            value: profile.address,
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
            _ContactRow(
              icon: FudiIcons.phone,
              label: 'Teléfono',
              value: profile.phone!,
              isLink: true,
              onTap: () => _launchUrl('tel:${profile.phone}'),
            ),
          ],
          // Email
          if (profile.email != null && profile.email!.isNotEmpty) ...[
            const SizedBox(height: FudiSpacing.lg),
            _ContactRow(
              icon: FudiIcons.mail,
              label: 'Email',
              value: profile.email!,
              isLink: true,
              onTap: () => _launchUrl('mailto:${profile.email}'),
            ),
          ],
          // Website
          if (profile.website != null && profile.website!.isNotEmpty) ...[
            const SizedBox(height: FudiSpacing.lg),
            _ContactRow(
              icon: Icons.language_rounded,
              label: 'Sitio web',
              value: profile.website!,
              isLink: true,
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
class _OpeningHoursCard extends StatelessWidget {
  const _OpeningHoursCard({required this.hours});

  final List<BusinessHours> hours;

  @override
  Widget build(BuildContext context) {
    return FudiSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(FudiIcons.clock, size: 20, color: FudiColors.primary),
              const SizedBox(width: FudiSpacing.sm),
              Text('Horario', style: FudiTypography.labelMedium),
            ],
          ),
          const SizedBox(height: FudiSpacing.lg),
          ...hours.map(
            (h) => Padding(
              padding: const EdgeInsets.only(bottom: FudiSpacing.md),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    h.day,
                    style: FudiTypography.bodyMedium.copyWith(
                      color: FudiColors.mutedForeground,
                    ),
                  ),
                  Text(h.hours, style: FudiTypography.labelSmall),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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
              child: GestureDetector(
                onTap: () {
                  // TODO: Navigate to full reviews screen
                },
                child: Text(
                  'Ver todas las reseñas (${profile.reviewCount})',
                  style: FudiTypography.bodyMedium.copyWith(
                    color: FudiColors.primary,
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
            profile.address,
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
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () =>
                    _openMaps(profile.latitude!, profile.longitude!),
                style: FilledButton.styleFrom(
                  backgroundColor: FudiColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: FudiSpacing.md),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(FudiRadius.lg),
                  ),
                ),
                child: Text(
                  'Abrir en Google Maps',
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

// ─── Shared Widgets ──────────────────────────────────────────────

/// Floating circle button used in the cover image overlay.
class _CircleButton extends StatelessWidget {
  const _CircleButton({
    required this.onTap,
    required this.icon,
    this.iconColor,
  });

  final VoidCallback onTap;
  final IconData icon;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, size: 20, color: iconColor ?? FudiColors.foreground),
      ),
    );
  }
}

/// Inline star rating display (read-only).
class _StarRating extends StatelessWidget {
  const _StarRating({required this.rating}) : size = 16;

  final double rating;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final starValue = i + 1;
        if (rating >= starValue) {
          return Icon(
            Icons.star_rounded,
            size: size,
            color: const Color(0xFFFACC15),
          );
        } else if (rating >= starValue - 0.5) {
          return Icon(
            Icons.star_half_rounded,
            size: size,
            color: const Color(0xFFFACC15),
          );
        }
        return Icon(
          Icons.star_outline_rounded,
          size: size,
          color: const Color(0xFFFACC15),
        );
      }),
    );
  }
}

/// Contact info row with icon, label, and value.
class _ContactRow extends StatelessWidget {
  const _ContactRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isLink = false,
    this.onTap,
    this.trailing,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool isLink;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: FudiColors.primary),
        const SizedBox(width: FudiSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: FudiTypography.labelSmall),
              const SizedBox(height: 2),
              if (isLink && onTap != null)
                GestureDetector(
                  onTap: onTap,
                  child: Text(
                    value,
                    style: FudiTypography.bodyMedium.copyWith(
                      color: FudiColors.primary,
                    ),
                  ),
                )
              else
                Text(
                  value,
                  style: FudiTypography.bodyMedium.copyWith(
                    color: FudiColors.mutedForeground,
                  ),
                ),
              if (trailing != null) ...[const SizedBox(height: 4), trailing!],
            ],
          ),
        ),
      ],
    );
  }
}

/// Tappable text link (e.g. "Cómo llegar →").
class _TextLink extends StatelessWidget {
  const _TextLink({required this.text, required this.onTap});

  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        text,
        style: FudiTypography.bodyMedium.copyWith(color: FudiColors.primary),
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
