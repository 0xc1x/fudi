import 'package:flutter/material.dart';
import '../fudi_colors.dart';
import 'icons/fudi_icons.dart';

class FudiHeartButton extends StatefulWidget {
  const FudiHeartButton({
    super.key,
    required this.isFavorite,
    required this.onTap,
    this.size = 40,
    this.iconSize = 20,
    this.activeColor = const Color(0xFFEF4444),
    this.inactiveColor = FudiColors.foreground,
    this.activeBackground,
    this.inactiveBackground,
    this.duration = const Duration(milliseconds: 380),
  });

  final bool isFavorite;
  final VoidCallback onTap;
  final double size;
  final double iconSize;
  final Color activeColor;
  final Color inactiveColor;
  final Color? activeBackground;
  final Color? inactiveBackground;
  final Duration duration;

  @override
  State<FudiHeartButton> createState() => _FudiHeartButtonState();
}

class _FudiHeartButtonState extends State<FudiHeartButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _scale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.65)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 28,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.65, end: 1.4)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 44,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.4, end: 1.0)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 28,
      ),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(FudiHeartButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isFavorite != widget.isFavorite) {
      _controller.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final resolvedActiveBg = widget.activeBackground ??
        widget.activeColor.withValues(alpha: 0.15);
    final resolvedInactiveBg = widget.inactiveBackground ??
        Colors.white.withValues(alpha: 0.9);

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, child) =>
            Transform.scale(scale: _scale.value, child: child),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: widget.isFavorite ? resolvedActiveBg : resolvedInactiveBg,
            shape: BoxShape.circle,
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            widget.isFavorite ? FudiIcons.heart : FudiIcons.heartOutline,
            size: widget.iconSize,
            color: widget.isFavorite
                ? widget.activeColor
                : widget.inactiveColor,
          ),
        ),
      ),
    );
  }
}
