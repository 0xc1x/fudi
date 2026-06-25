import 'package:flutter/material.dart';
import 'fudi_colors.dart';
import 'fudi_pressable_scale.dart';
import 'fudi_spacing.dart';
import 'fudi_typography.dart';

/// Un modelo de dato mínimo para alimentar [FudiInfoChipsBar].
class FudiInfoChipItem {
  const FudiInfoChipItem({
    required this.label,
    this.icon,
    this.count,
    this.onTap,
  });

  /// Texto principal del chip.
  final String label;

  /// Icono opcional mostrado a la izquierda del label.
  final IconData? icon;

  /// Número opcional mostrado como badge a la derecha del label.
  final int? count;

  /// Callback opcional al pulsar el chip.
  final VoidCallback? onTap;
}

/// Barra horizontal de chips **informativos** (no seleccionables).
///
/// Úsalo para listas de zonas, tags o cualquier colección donde cada chip
/// muestra información (icono + label + badge) en lugar de representar
/// un estado de selección.
///
/// ```dart
/// FudiInfoChipsBar(
///   items: areas
///       .map((a) => FudiInfoChipItem(
///             label: a.name,
///             icon: FudiIcons.mapPin,
///             count: a.deals,
///             onTap: () => _navigateToArea(a),
///           ))
///       .toList(),
/// )
/// ```
class FudiInfoChipsBar extends StatelessWidget {
  const FudiInfoChipsBar({
    super.key,
    required this.items,
    this.chipColor,
    this.iconColor,
    this.labelColor,
    this.badgeBackgroundColor,
    this.badgeTextColor,
    this.borderRadius = FudiRadius.md,
    this.height = 40.0,
    this.padding = const EdgeInsets.symmetric(horizontal: FudiSpacing.lg),
    this.chipHorizontalPadding = FudiSpacing.md,
  });

  final List<FudiInfoChipItem> items;

  /// Color de fondo del chip. Por defecto: verde semi-transparente.
  final Color? chipColor;

  /// Color del icono. Por defecto: [FudiColors.primary].
  final Color? iconColor;

  /// Color del texto del label. Por defecto: hereda el tema oscuro/claro.
  final Color? labelColor;

  /// Color de fondo del badge numérico. Por defecto: verde con baja opacidad.
  final Color? badgeBackgroundColor;

  /// Color del texto dentro del badge. Por defecto: [FudiColors.primary].
  final Color? badgeTextColor;

  /// Radio de borde del chip. Por defecto: completamente redondeado.
  final double borderRadius;

  /// Alto del contenedor que envuelve el [ListView].
  final double height;

  /// Padding del [ListView] (márgenes laterales de la barra).
  final EdgeInsets padding;

  /// Padding horizontal interno de cada chip.
  final double chipHorizontalPadding;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: padding,
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: FudiSpacing.sm),
        itemBuilder: (context, index) => FudiInfoChip(
          item: items[index],
          chipColor: chipColor,
          iconColor: iconColor,
          labelColor: labelColor,
          badgeBackgroundColor: badgeBackgroundColor,
          badgeTextColor: badgeTextColor,
          borderRadius: borderRadius,
          horizontalPadding: chipHorizontalPadding,
        ),
      ),
    );
  }
}

/// Chip informativo individual con icono, label y badge opcionales.
///
/// Se puede usar directamente si necesitas construir la lista de forma
/// personalizada sin [FudiInfoChipsBar].
class FudiInfoChip extends StatelessWidget {
  const FudiInfoChip({
    super.key,
    required this.item,
    this.chipColor,
    this.iconColor,
    this.labelColor,
    this.badgeBackgroundColor,
    this.badgeTextColor,
    this.borderRadius = FudiRadius.xs,
    this.horizontalPadding = FudiSpacing.md,
  });

  final FudiInfoChipItem item;
  final Color? chipColor;
  final Color? iconColor;
  final Color? labelColor;
  final Color? badgeBackgroundColor;
  final Color? badgeTextColor;
  final double borderRadius;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    final resolvedChipColor =
        chipColor ?? FudiColors.green.withValues(alpha: 0.3);
    final resolvedIconColor =
        iconColor ?? FudiColors.greenMidDark.withValues(alpha: 0.7);
    final resolvedBadgeBg =
        badgeBackgroundColor ?? FudiColors.greenMidDark.withValues(alpha: 0.1);
    final resolvedBadgeText = badgeTextColor ?? FudiColors.greenMidDark;
    final resolvedBorderRadius = borderRadius;

    final resolvedLabelColor =
        labelColor ?? FudiColors.greenDark.withValues(alpha: 0.7);

    final chip = AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 8),
      decoration: BoxDecoration(
        color: resolvedChipColor,
        borderRadius: BorderRadius.circular(resolvedBorderRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (item.icon != null) ...[
            Icon(item.icon, size: 14, color: resolvedIconColor),
            const SizedBox(width: 4),
          ],
          Text(
            item.label,
            style: FudiTypography.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
              color: resolvedLabelColor,
            ),
          ),
          if (item.count != null) ...[
            const SizedBox(width: 4),
            _BadgeCount(
              count: item.count!,
              backgroundColor: resolvedBadgeBg,
              textColor: resolvedBadgeText,
            ),
          ],
        ],
      ),
    );

    if (item.onTap == null) return chip;

    return FudiPressableScale(onTap: item.onTap, child: chip);
  }
}

class _BadgeCount extends StatelessWidget {
  const _BadgeCount({
    required this.count,
    required this.backgroundColor,
    required this.textColor,
  });

  final int count;
  final Color backgroundColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(FudiRadius.sm),
      ),
      child: Text(
        '$count',
        style: FudiTypography.bodySmall.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
      ),
    );
  }
}
