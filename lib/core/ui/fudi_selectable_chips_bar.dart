import 'package:flutter/material.dart';
import 'fudi_colors.dart';
import 'fudi_pressable_scale.dart';
import 'fudi_spacing.dart';
import 'fudi_typography.dart';

class FudiSelectableChipsBar<T> extends StatefulWidget {
  const FudiSelectableChipsBar({
    super.key,
    required this.items,
    required this.selectedItem,
    required this.labelBuilder,
    required this.onSelected,
    this.iconBuilder,
    this.initialCount,
    this.activeColor = FudiColors.greenDark,
    this.activeTextColor = FudiColors.green,
    this.inactiveColor,
    this.inactiveTextColor,
    this.borderColor,
    this.borderRadius = 8.0,
    this.height = 40.0,
    this.padding = const EdgeInsets.symmetric(horizontal: FudiSpacing.lg),
    this.textStyle,
    this.horizontalChipPadding = FudiSpacing.lg,
  });

  final List<T> items;
  final T? selectedItem;
  final String Function(T) labelBuilder;
  final Widget Function(T)? iconBuilder;
  final ValueChanged<T> onSelected;
  final int? initialCount;
  final Color activeColor;
  final Color activeTextColor;
  final Color? inactiveColor;
  final Color? inactiveTextColor;
  final Color? borderColor;
  final double borderRadius;
  final double height;
  final EdgeInsets padding;
  final TextStyle? textStyle;
  final double horizontalChipPadding;

  @override
  State<FudiSelectableChipsBar<T>> createState() =>
      _FudiSelectableChipsBarState<T>();
}

class _FudiSelectableChipsBarState<T> extends State<FudiSelectableChipsBar<T>> {
  bool _showAll = false;

  @override
  Widget build(BuildContext context) {
    final hasLimit =
        widget.initialCount != null &&
        widget.items.length > widget.initialCount!;
    final displayItems = (hasLimit && !_showAll)
        ? widget.items.take(widget.initialCount!).toList()
        : widget.items;

    final remaining = widget.items.length - (widget.initialCount ?? 0);
    final showMore = hasLimit && !_showAll && remaining > 0;
    final showLess = hasLimit && _showAll;
    final extraChips = (showMore || showLess) ? 1 : 0;

    return SizedBox(
      height: widget.height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: widget.padding,
        itemCount: displayItems.length + extraChips,
        separatorBuilder: (_, _) => const SizedBox(width: FudiSpacing.sm),
        itemBuilder: (context, index) {
          if (showMore && index == displayItems.length) {
            return _MoreChip(
              label: '+$remaining',
              onTap: () => setState(() => _showAll = true),
              borderRadius: widget.borderRadius,
              horizontalPadding: widget.horizontalChipPadding,
            );
          }
          if (showLess && index == displayItems.length) {
            return _MoreChip(
              label: 'Ver menos',
              onTap: () => setState(() => _showAll = false),
              borderRadius: widget.borderRadius,
              horizontalPadding: widget.horizontalChipPadding,
            );
          }

          final item = displayItems[index];
          final isSelected = item == widget.selectedItem;

          return _SelectableChip(
            // Solo el label como key — el widget persiste entre cambios de
            // selección y didUpdateWidget dispara la animación correctamente.
            key: ValueKey(widget.labelBuilder(item)),
            label: widget.labelBuilder(item),
            icon: widget.iconBuilder?.call(item),
            isSelected: isSelected,
            onTap: () => widget.onSelected(item),
            activeColor: widget.activeColor,
            activeTextColor: widget.activeTextColor,
            inactiveColor: widget.inactiveColor,
            inactiveTextColor: widget.inactiveTextColor,
            borderColor: widget.borderColor,
            borderRadius: widget.borderRadius,
            textStyle: widget.textStyle,
            horizontalPadding: widget.horizontalChipPadding,
          );
        },
      ),
    );
  }
}

// ── Chip seleccionable con animación de press + selección ────────────────────

class _SelectableChip extends StatefulWidget {
  const _SelectableChip({
    super.key,
    required this.label,
    this.icon,
    required this.isSelected,
    required this.onTap,
    required this.activeColor,
    required this.activeTextColor,
    this.inactiveColor,
    this.inactiveTextColor,
    this.borderColor,
    required this.borderRadius,
    this.textStyle,
    required this.horizontalPadding,
  });

  final String label;
  final Widget? icon;
  final bool isSelected;
  final VoidCallback onTap;
  final Color activeColor;
  final Color activeTextColor;
  final Color? inactiveColor;
  final Color? inactiveTextColor;
  final Color? borderColor;
  final double borderRadius;
  final TextStyle? textStyle;
  final double horizontalPadding;

  @override
  State<_SelectableChip> createState() => _SelectableChipState();
}

class _SelectableChipState extends State<_SelectableChip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  // Escala: idle=1.0, pressed=0.92, selected-bounce=1.06→1.0
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );

    _scale = TweenSequence<double>([
      // Comprime al pulsar
      TweenSequenceItem(
        tween: Tween(
          begin: 1.0,
          end: 0.92,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 40,
      ),
      // Rebote al soltar
      TweenSequenceItem(
        tween: Tween(
          begin: 0.92,
          end: 1.06,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 35,
      ),
      // Asentarse en 1.0
      TweenSequenceItem(
        tween: Tween(
          begin: 1.06,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 25,
      ),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Detecta cuando este chip cambia de estado (seleccionado ↔ deseleccionado)
  // y dispara el bounce aunque el widget no se haya destruido.
  @override
  void didUpdateWidget(_SelectableChip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isSelected != widget.isSelected) {
      _controller.forward(from: 0).then((_) {
        if (mounted) _controller.reverse();
      });
    }
  }

  void _handleTap() {
    // El bounce lo dispara didUpdateWidget cuando llegue el nuevo isSelected.
    // Aquí solo notificamos al padre.
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final finalInactiveColor =
        widget.inactiveColor ?? FudiColors.green.withValues(alpha: 0.3);
    final finalInactiveTextColor =
        widget.inactiveTextColor ?? FudiColors.greenDark.withValues(alpha: 0.7);
    final finalBorderColor =
        widget.borderColor ?? FudiColors.greenDark.withValues(alpha: 0.15);
    final defaultTextStyle = widget.textStyle ?? FudiTypography.bodyMedium;

    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _scale,
        builder: (context, child) =>
            Transform.scale(scale: _scale.value, child: child),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: EdgeInsets.symmetric(
            horizontal: widget.horizontalPadding,
            vertical: FudiSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: widget.isSelected ? widget.activeColor : finalInactiveColor,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            border: Border.all(
              color: widget.isSelected ? widget.activeColor : finalBorderColor,
              width: 1,
            ),
            // Sombra sutil que aparece al seleccionar
            boxShadow: widget.isSelected
                ? [
                    BoxShadow(
                      color: widget.activeColor.withValues(alpha: 0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.icon != null) ...[
                  widget.icon!,
                  const SizedBox(width: 4),
                ],
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  style: defaultTextStyle.copyWith(
                    color: widget.isSelected
                        ? widget.activeTextColor
                        : finalInactiveTextColor,
                    fontWeight: widget.isSelected
                        ? FontWeight.w600
                        : FontWeight.w500,
                  ),
                  child: Text(widget.label),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Chip de "ver más / ver menos" ─────────────────────────────────────────────

class _MoreChip extends StatelessWidget {
  const _MoreChip({
    required this.label,
    required this.onTap,
    required this.borderRadius,
    required this.horizontalPadding,
  });

  final String label;
  final VoidCallback onTap;
  final double borderRadius;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    return FudiPressableScale(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: FudiSpacing.sm,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(color: FudiColors.borderSolid),
        ),
        child: Center(
          child: Text(
            label,
            style: FudiTypography.bodyMedium.copyWith(
              color: FudiColors.mutedForeground,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
