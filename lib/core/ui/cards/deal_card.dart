import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../fudi_colors.dart';
import '../fudi_spacing.dart';
import '../fudi_typography.dart';
import '../atoms/icons/fudi_icons.dart';

class DealCard extends StatefulWidget {
  const DealCard({
    super.key,
    required this.imageUrl,
    required this.businessName,
    required this.originalPrice,
    required this.discountedPrice,
    required this.rating,
    required this.distance,
    required this.availableQuantity,
    required this.pickupUntil,
    this.categoryLabel,
    this.onTap,
    this.isFavorite = false,
    this.onFavoriteToggle,
  });

  final String imageUrl;
  final String businessName;
  final double originalPrice;
  final double discountedPrice;
  final double rating;
  final String distance;
  final int availableQuantity;
  final TimeOfDay pickupUntil;
  final String? categoryLabel;
  final VoidCallback? onTap;
  final bool isFavorite;
  final VoidCallback? onFavoriteToggle;

  @override
  State<DealCard> createState() => _DealCardState();
}

class _DealCardState extends State<DealCard>
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
    _pressScale = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    setState(() => _isPressed = true);
    _pressController.forward();
  }

  void _onTapUp(TapUpDetails _) {
    setState(() => _isPressed = false);
    _pressController.reverse();
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
    _pressController.reverse();
  }

  int get _discountPercent => widget.originalPrice > 0
      ? ((1 - widget.discountedPrice / widget.originalPrice) * 100).round()
      : 0;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pressScale,
      builder: (context, child) =>
          Transform.scale(scale: _pressScale.value, child: child),
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: FudiColors.card,
            borderRadius: BorderRadius.circular(FudiRadius.lg),
            border: Border.all(
              color: _isPressed
                  ? FudiColors.border.withValues(alpha: 0.25)
                  : FudiColors.border.withValues(alpha: 0.09),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                // La sombra se aplana al presionar — feedback sutil de "hundido"
                color: FudiColors.primary.withValues(
                  alpha: _isPressed ? 0.01 : 0.03,
                ),
                blurRadius: _isPressed ? 4 : 12,
                spreadRadius: _isPressed ? 0 : -2,
                offset: Offset(0, _isPressed ? 1 : 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(FudiRadius.lg - 1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [_buildImage(), _buildContent(context)],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    return Stack(
      children: [
        CachedNetworkImage(
          imageUrl: widget.imageUrl,
          height: 200,
          width: double.infinity,
          fit: BoxFit.cover,
          placeholder: (context, url) => Shimmer.fromColors(
            baseColor: FudiColors.muted,
            highlightColor: Colors.white,
            child: Container(height: 250, color: FudiColors.muted),
          ),
          errorWidget: (context, url, error) => Container(
            height: 250,
            color: FudiColors.muted,
            child: const Icon(
              FudiIcons.imageOff,
              color: FudiColors.mutedForeground,
            ),
          ),
        ),
        if (_discountPercent > 0)
          Positioned(
            top: FudiSpacing.sm,
            right: FudiSpacing.sm,
            child: _DiscountBadge(percent: _discountPercent),
          ),
        if (widget.availableQuantity <= 3)
          Positioned(
            bottom: FudiSpacing.sm,
            left: FudiSpacing.sm,
            child: _LowStockBadge(count: widget.availableQuantity),
          ),
        Positioned(
          top: FudiSpacing.sm,
          left: FudiSpacing.sm,
          child: _FavoriteButton(
            isFavorite: widget.isFavorite,
            onToggle: widget.onFavoriteToggle,
          ),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: FudiSpacing.md,
        right: FudiSpacing.md,
        top: FudiSpacing.md,
        bottom: 0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  widget.businessName,
                  style: FudiTypography.h3.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (widget.rating > 0) ...[
                const SizedBox(width: FudiSpacing.sm),
                _RatingPill(rating: widget.rating),
              ],
            ],
          ),
          const SizedBox(height: FudiSpacing.xs),
          Row(
            children: [
              const Icon(
                FudiIcons.mapPin,
                size: 14,
                color: FudiColors.mutedForeground,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  widget.distance,
                  style: FudiTypography.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 1),
          Divider(
            height: 1,
            color: FudiColors.borderSolid.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 1),
          Container(
            margin: const EdgeInsets.only(bottom: FudiSpacing.sm),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        FudiIcons.clock,
                        size: 14,
                        color: FudiColors.primary,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          'Recoge antes de ${widget.pickupUntil.format(context)}',
                          style: FudiTypography.bodySmall.copyWith(
                            fontWeight: FontWeight.w600,
                            color: FudiColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: FudiSpacing.sm),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '\$${widget.originalPrice.toStringAsFixed(2)}',
                      style: FudiTypography.priceOriginal.copyWith(height: 1.0),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '\$${widget.discountedPrice.toStringAsFixed(2)}',
                      style: FudiTypography.priceLarge.copyWith(height: 1.0),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
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

// ── Badges sin cambios ────────────────────────────────────────────────────────

class _DiscountBadge extends StatelessWidget {
  const _DiscountBadge({required this.percent});
  final int percent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(FudiRadius.full),
      ),
      child: Text(
        '-$percent%',
        style: const TextStyle(
          color: FudiColors.primary,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _LowStockBadge extends StatelessWidget {
  const _LowStockBadge({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: FudiColors.destructive,
        borderRadius: BorderRadius.circular(FudiRadius.full),
      ),
      child: Text(
        'Solo quedan $count!',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _RatingPill extends StatelessWidget {
  const _RatingPill({required this.rating});
  final double rating;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: FudiColors.secondary,
        borderRadius: BorderRadius.circular(FudiRadius.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(FudiIcons.star, size: 14, color: FudiColors.primary),
          const SizedBox(width: 2),
          Text(
            rating.toStringAsFixed(1),
            style: FudiTypography.bodySmall.copyWith(
              color: FudiColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Botón favorito con animación propia ───────────────────────────────────────

class _FavoriteButton extends StatefulWidget {
  const _FavoriteButton({required this.isFavorite, this.onToggle});

  final bool isFavorite;
  final VoidCallback? onToggle;

  @override
  State<_FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<_FavoriteButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _scale = TweenSequence<double>([
      // Comprime
      TweenSequenceItem(
        tween: Tween(
          begin: 1.0,
          end: 0.7,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 30,
      ),
      // Rebote exagerado — el corazón "late"
      TweenSequenceItem(
        tween: Tween(
          begin: 0.7,
          end: 1.35,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 45,
      ),
      // Asentarse
      TweenSequenceItem(
        tween: Tween(
          begin: 1.35,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.elasticOut)),
        weight: 25,
      ),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(_FavoriteButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isFavorite != widget.isFavorite) {
      _controller.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onToggle,
      // Absorbe el tap para que no lo propague a la card
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _scale,
        builder: (context, child) =>
            Transform.scale(scale: _scale.value, child: child),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            // El fondo cambia de blanco a rojo suave al marcar favorito
            color: widget.isFavorite
                ? FudiColors.destructive.withValues(alpha: 0.12)
                : Colors.white,
            shape: BoxShape.circle,
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            widget.isFavorite ? FudiIcons.favorites : FudiIcons.heartOutline,
            size: 18,
            color: widget.isFavorite
                ? FudiColors.destructive
                : FudiColors.mutedForeground,
          ),
        ),
      ),
    );
  }
}
