import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/ui/atoms/icons/fudi_icons.dart';
import '../../../../core/ui/fudi_colors.dart';
import '../../../../core/ui/fudi_spacing.dart';
import '../../../../core/ui/fudi_theme.dart';
import '../../../offers/domain/offer.dart';

class ProductImage extends StatelessWidget {
  const ProductImage({
    super.key,
    required this.offer,
    this.width = 80,
    this.height,
    this.borderRadius,
  });

  final Offer offer;
  final double width;
  final double? height;
  final BorderRadiusGeometry? borderRadius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final themeExt = theme.extension<FudiThemeExtension>();
    final effectiveHeight = height ?? width;
    return Container(
      width: width,
      height: effectiveHeight,
      decoration: BoxDecoration(
        borderRadius: borderRadius ?? BorderRadius.circular(FudiRadius.sm),
        color: themeExt?.mutedBackground ?? FudiColors.muted,
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          SizedBox(
            width: width,
            height: effectiveHeight,
            child: offer.imageUrl != null
                ? CachedNetworkImage(
                    imageUrl: offer.imageUrl!,
                    width: width,
                    height: effectiveHeight,
                    fit: BoxFit.cover,
                    errorWidget: (_, _, _) => Center(
                      child: Icon(
                        FudiIcons.package_,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  )
                : Center(
                    child: Icon(
                      FudiIcons.package_,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
          ),
          if (!offer.isActive)
            Positioned.fill(
              child: Container(
                color: colorScheme.onSurface.withValues(alpha: 0.54),
                child: const Center(
                  child: Icon(FudiIcons.eyeOff, color: FudiColors.primaryForeground, size: 24),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
