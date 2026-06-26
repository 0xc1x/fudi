import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../fudi_colors.dart';
import '../fudi_spacing.dart';
import '../fudi_typography.dart';
import '../atoms/icons/fudi_icons.dart';
import '../atoms/fudi_discount_badge.dart';
import '../atoms/fudi_low_stock_badge.dart';
import '../atoms/fudi_heart_button.dart';

class DealCard extends StatefulWidget {
  const DealCard({
    super.key,
    required this.imageUrl,
    required this.offerTitle,
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
  final String offerTitle;
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
        onTapDown: (_) {
          setState(() => _isPressed = true);
          _pressController.forward();
        },
        onTapUp: (_) {
          setState(() => _isPressed = false);
          _pressController.reverse();
        },
        onTapCancel: () {
          setState(() => _isPressed = false);
          _pressController.reverse();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: FudiColors.card,
            borderRadius: BorderRadius.circular(FudiRadius.lg),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: _isPressed ? 0.04 : 0.08),
                blurRadius: _isPressed ? 4 : 16,
                spreadRadius: _isPressed ? 0 : -2,
                offset: Offset(0, _isPressed ? 1 : 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(FudiRadius.lg),
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
        // ── Imagen principal ─────────────────────────────────────────────
        CachedNetworkImage(
          imageUrl: widget.imageUrl,
          height: 160,
          width: double.infinity,
          fit: BoxFit.cover,
          placeholder: (context, url) => Shimmer.fromColors(
            baseColor: FudiColors.muted,
            highlightColor: Colors.white.withValues(alpha: 0.6),
            child: Container(height: 160, color: FudiColors.muted),
          ),
          errorWidget: (context, url, error) => Container(
            height: 160,
            color: FudiColors.muted,
            child: const Center(
              child: Icon(
                FudiIcons.imageOff,
                color: FudiColors.mutedForeground,
              ),
            ),
          ),
        ),

        // ── Badge de descuento — pill roja esquina superior derecha ──────
        if (_discountPercent > 0)
          Positioned(
            top: FudiSpacing.sm,
            right: FudiSpacing.sm,
            child: FudiDiscountBadge(percent: _discountPercent),
          ),

        // ── Badge de stock bajo — esquina inferior izquierda ────────────
        if (widget.availableQuantity <= 3)
          Positioned(
            bottom: FudiSpacing.sm,
            left: FudiSpacing.sm,
            child: FudiLowStockBadge(
              label: 'Solo quedan ${widget.availableQuantity}',
            ),
          ),

        // ── Botón corazón — esquina superior izquierda ───────────────────
        Positioned(
          top: FudiSpacing.sm,
          left: FudiSpacing.sm,
          child: FudiHeartButton(
            isFavorite: widget.isFavorite,
            onTap: widget.onFavoriteToggle ?? () {},
            size: 30,
            iconSize: 18,
            activeColor: FudiColors.destructive,
            inactiveColor: FudiColors.mutedForeground,
            activeBackground: FudiColors.destructive.withValues(alpha: 0.12),
            inactiveBackground: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        FudiSpacing.md,
        FudiSpacing.sm + 2,
        FudiSpacing.md,
        FudiSpacing.md,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // ── Columna izquierda: 4/5 — datos sin precio ─────────────────
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.offerTitle,
                  style: FudiTypography.h3.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      FudiIcons.mapPin,
                      size: 12,
                      color: FudiColors.mutedForeground,
                    ),
                    const SizedBox(width: 3),
                    Flexible(
                      child: Text(
                        '${widget.distance} · ${widget.businessName}',
                        style: FudiTypography.bodySmall.copyWith(
                          color: FudiColors.mutedForeground,
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Recoge antes de las ${widget.pickupUntil.format(context)}',
                  style: FudiTypography.bodySmall.copyWith(
                    color: FudiColors.mutedForeground,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: FudiSpacing.sm),

          // ── Columna derecha: 1/5 — precio ────────────────────────────
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '\$${widget.originalPrice.toStringAsFixed(2)}',
                  style: FudiTypography.bodySmall.copyWith(
                    decoration: TextDecoration.lineThrough,
                    decorationColor: FudiColors.mutedForeground,
                    color: FudiColors.mutedForeground,
                    fontSize: 12,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  '\$${widget.discountedPrice.toStringAsFixed(2)}',
                  style: FudiTypography.priceLarge.copyWith(
                    color: FudiColors.primary,
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                    height: 1.0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DealCardSkeleton extends StatelessWidget {
  const DealCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: FudiColors.muted,
      highlightColor: Colors.white,
      child: Material(
        color: FudiColors.muted,
        borderRadius: BorderRadius.circular(FudiRadius.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(height: 200, color: FudiColors.muted),
            const Padding(
              padding: EdgeInsets.all(FudiSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 14,
                    width: 160,
                    child: DecoratedBox(
                      decoration: BoxDecoration(color: FudiColors.muted),
                    ),
                  ),
                  SizedBox(height: 8),
                  SizedBox(
                    height: 10,
                    width: 100,
                    child: DecoratedBox(
                      decoration: BoxDecoration(color: FudiColors.muted),
                    ),
                  ),
                  SizedBox(height: 12),
                  SizedBox(
                    height: 10,
                    width: 200,
                    child: DecoratedBox(
                      decoration: BoxDecoration(color: FudiColors.muted),
                    ),
                  ),
                  SizedBox(height: 12),
                  SizedBox(
                    height: 1,
                    child: DecoratedBox(
                      decoration: BoxDecoration(color: FudiColors.muted),
                    ),
                  ),
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        height: 14,
                        width: 80,
                        child: DecoratedBox(
                          decoration: BoxDecoration(color: FudiColors.muted),
                        ),
                      ),
                      SizedBox(
                        height: 32,
                        width: 90,
                        child: DecoratedBox(
                          decoration: BoxDecoration(color: FudiColors.muted),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
