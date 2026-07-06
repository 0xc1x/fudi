import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/ui/fudi_colors.dart';
import '../../../core/ui/fudi_theme.dart';
import '../../../core/ui/fudi_spacing.dart';
import '../../../core/ui/fudi_typography.dart';
import '../../../core/ui/atoms/icons/fudi_icons.dart';

class BusinessCard extends StatefulWidget {
  const BusinessCard({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.type,
    required this.rating,
    required this.distance,
    this.onTap,
  });

  final String imageUrl;
  final String name;
  final String type;
  final double rating;
  final String distance;
  final VoidCallback? onTap;

  @override
  State<BusinessCard> createState() => _BusinessCardState();
}

class _BusinessCardState extends State<BusinessCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressController;
  late final Animation<double> _pressScale;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      reverseDuration: const Duration(milliseconds: 200),
    );
    _pressScale = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    unawaited(_pressController.forward());
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    unawaited(_pressController.reverse());
    widget.onTap?.call();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    unawaited(_pressController.reverse());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeExt = theme.extension<FudiThemeExtension>();

    return AnimatedBuilder(
      animation: _pressScale,
      builder: (context, child) =>
          Transform.scale(scale: _pressScale.value, child: child),
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: themeExt?.cardBg ?? theme.cardTheme.color ?? theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(FudiRadius.sm),
            boxShadow: [
              BoxShadow(
                color: themeExt?.surfaceShadow ?? FudiColors.foreground.withValues(alpha: 0.08),
                blurRadius: _isPressed ? 4 : 16,
                spreadRadius: _isPressed ? 0 : -2,
                offset: Offset(0, _isPressed ? 1 : 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(FudiRadius.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [_buildImage(), _buildContent()],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    final theme = Theme.of(context);
    final themeExt = theme.extension<FudiThemeExtension>();
    final resolvedMutedBg = themeExt?.mutedBackground ?? theme.colorScheme.surfaceContainerLow;

    return Stack(
      children: [
        CachedNetworkImage(
          imageUrl: widget.imageUrl,
          height: 140,
          width: double.infinity,
          fit: BoxFit.cover,
          placeholder: (context, url) => Shimmer.fromColors(
            baseColor: resolvedMutedBg,
            highlightColor: theme.colorScheme.surface.withValues(alpha: 0.6),
            child: Container(height: 140, color: resolvedMutedBg),
          ),
          errorWidget: (context, url, error) => Container(
            height: 140,
            color: resolvedMutedBg,
            child: Center(
              child: Icon(
                FudiIcons.imageOff,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
        ),

        // ── Badge de rating — pill blanca esquina superior izquierda ────
        if (widget.rating > 0)
          Positioned(
            top: FudiSpacing.sm,
            left: FudiSpacing.sm,
            child: _RatingBadge(rating: widget.rating),
          ),

        // ── Badge de distancia — pill blanca esquina superior derecha ───
        Positioned(
          bottom: FudiSpacing.sm,
          left: FudiSpacing.sm,
          child: _DistanceBadge(distance: widget.distance),
        ),
      ],
    );
  }

  Widget _buildContent() {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.name,
            style: FudiTypography.h3.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              letterSpacing: -0.3,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            widget.type.toUpperCase(),
            style: FudiTypography.bodySmall.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              fontSize: 12,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Badges ────────────────────────────────────────────────────────────────────

class _RatingBadge extends StatelessWidget {
  const _RatingBadge({required this.rating});

  final double rating;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _Pill(
      children: [
        const Icon(Icons.star_rounded, color: FudiColors.green, size: 14),
        const SizedBox(width: 3),
        Text(
          rating.toStringAsFixed(1),
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _DistanceBadge extends StatelessWidget {
  const _DistanceBadge({required this.distance});

  final String distance;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _Pill(
      children: [
        Icon(
          FudiIcons.mapPin,
          size: 12,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
        ),
        const SizedBox(width: 3),
        Text(
          distance,
          style: TextStyle(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeExt = theme.extension<FudiThemeExtension>();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(FudiRadius.sm),
        boxShadow: [
          BoxShadow(
            color: themeExt?.surfaceShadow ?? FudiColors.foreground.withValues(alpha: 0.08),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: children),
    );
  }
}

// ── Skeleton ──────────────────────────────────────────────────────────────────

class BusinessCardSkeleton extends StatelessWidget {
  const BusinessCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeExt = theme.extension<FudiThemeExtension>();
    final resolvedMutedBg = themeExt?.mutedBackground ?? theme.colorScheme.surfaceContainerLow;

    return Shimmer.fromColors(
      baseColor: resolvedMutedBg,
      highlightColor: theme.colorScheme.surface,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: resolvedMutedBg,
          borderRadius: BorderRadius.circular(FudiRadius.sm),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(FudiRadius.sm),
              ),
              child: Container(height: 140, color: resolvedMutedBg),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(height: 16, width: 140, color: resolvedMutedBg),
                  const SizedBox(height: 8),
                  Container(height: 10, width: 80, color: resolvedMutedBg),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
