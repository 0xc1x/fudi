import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/ui/fudi_colors.dart';
import '../../../core/ui/fudi_spacing.dart';

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
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.96,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onTap?.call();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Opacity(
              opacity: _scaleAnimation.value < 1.0 ? 0.92 : 1.0,
              child: Container(
                decoration: BoxDecoration(
                  color: FudiColors.card,
                  border: Border.all(
                    color: FudiColors.foreground.withValues(alpha: 0.24),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(FudiRadius.sm),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(FudiRadius.sm),
                      ),
                      child: CachedNetworkImage(
                        imageUrl: widget.imageUrl,
                        height: 140,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) => Container(
                          height: 140,
                          color: FudiColors.background.withValues(alpha: 0.24),
                          child: const Icon(
                            Icons.bakery_dining,
                            color: FudiColors.background,
                            size: 40,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.name,
                              style: const TextStyle(
                                color: FudiColors.foreground,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.3,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.type.toUpperCase(),
                              style: TextStyle(
                                color: FudiColors.foreground.withValues(
                                  alpha: 0.5,
                                ),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const Spacer(),
                            if (widget.rating > 0)
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.star_rounded,
                                        color: FudiColors.green,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        widget.rating.toStringAsFixed(1),
                                        style: const TextStyle(
                                          color: FudiColors.foreground,
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.location_on_outlined,
                                        color: FudiColors.foreground.withValues(
                                          alpha: 0.6,
                                        ),
                                        size: 14,
                                      ),
                                      const SizedBox(width: 2),
                                      Text(
                                        widget.distance,
                                        style: TextStyle(
                                          color: FudiColors.foreground
                                              .withValues(alpha: 0.6),
                                          fontSize: 13,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
