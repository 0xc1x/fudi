import 'package:flutter/material.dart';
import '../fudi_colors.dart';
import '../fudi_spacing.dart';
import '../fudi_typography.dart';

enum FudiButtonVariant { primary, secondary, outlined, text }

/// A custom branded button with soft scale press animation (0.96x) instead of ripple.
class FudiButton extends StatefulWidget {
  const FudiButton({
    required this.text,
    required this.onPressed,
    this.variant = FudiButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.fullWidth = false,
    this.padding,
    super.key,
  });

  final String text;
  final VoidCallback? onPressed;
  final FudiButtonVariant variant;
  final IconData? icon;
  final bool isLoading;
  final bool fullWidth;
  final EdgeInsetsGeometry? padding;

  @override
  State<FudiButton> createState() => _FudiButtonState();
}

class _FudiButtonState extends State<FudiButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
      lowerBound: 0.96,
      upperBound: 1.0,
      value: 1.0,
    );
    _scaleAnimation = _controller;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      _controller.reverse();
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      _controller.forward();
    }
  }

  void _onTapCancel() {
    if (widget.onPressed != null && !widget.isLoading) {
      _controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onPressed != null && !widget.isLoading;

    Color backgroundColor;
    Color foregroundColor;
    BorderSide borderSide = BorderSide.none;

    switch (widget.variant) {
      case FudiButtonVariant.primary:
        backgroundColor = isEnabled
            ? FudiColors.primary
            : FudiColors.primary.withValues(alpha: 0.5);
        foregroundColor = FudiColors.primaryForeground;
        break;
      case FudiButtonVariant.secondary:
        backgroundColor = isEnabled
            ? FudiColors.secondary
            : FudiColors.secondary.withValues(alpha: 0.5);
        foregroundColor = FudiColors.secondaryForeground;
        break;
      case FudiButtonVariant.outlined:
        backgroundColor = Colors.transparent;
        foregroundColor = isEnabled
            ? FudiColors.foreground
            : FudiColors.foreground.withValues(alpha: 0.5);
        borderSide = BorderSide(
          color: isEnabled
              ? FudiColors.foreground
              : FudiColors.foreground.withValues(alpha: 0.3),
          width: 1.5,
        );
        break;
      case FudiButtonVariant.text:
        backgroundColor = Colors.transparent;
        foregroundColor = isEnabled
            ? FudiColors.primary
            : FudiColors.primary.withValues(alpha: 0.5);
        break;
    }

    Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.isLoading) ...[
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
            ),
          ),
          const SizedBox(width: 8),
        ] else if (widget.icon != null) ...[
          Icon(widget.icon, size: 18, color: foregroundColor),
          const SizedBox(width: 8),
        ],
        Text(
          widget.text,
          style: FudiTypography.labelMedium.copyWith(
            color: foregroundColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );

    if (widget.fullWidth) {
      content = SizedBox(width: double.infinity, child: content);
    }

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: isEnabled ? widget.onPressed : null,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding:
              widget.padding ??
              const EdgeInsets.symmetric(
                horizontal: FudiSpacing.xl,
                vertical: FudiSpacing.lg - 2,
              ),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(FudiRadius.full),
            border: borderSide != BorderSide.none
                ? Border.fromBorderSide(borderSide)
                : null,
          ),
          child: content,
        ),
      ),
    );
  }
}
