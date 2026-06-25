import 'package:flutter/material.dart';

class FudiPressableScale extends StatefulWidget {
  const FudiPressableScale({
    super.key,
    required this.onTap,
    required this.child,
    this.scaleEnd = 0.96,
    this.opacityEnd = 0.92,
    this.duration = const Duration(milliseconds: 100),
    this.reverseDuration = const Duration(milliseconds: 180),
    this.behavior,
  });

  final VoidCallback? onTap;
  final Widget child;
  final double scaleEnd;
  final double opacityEnd;
  final Duration duration;
  final Duration reverseDuration;
  final HitTestBehavior? behavior;

  @override
  State<FudiPressableScale> createState() => _FudiPressableScaleState();
}

class _FudiPressableScaleState extends State<FudiPressableScale>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
      reverseDuration: widget.reverseDuration,
    );
    _scale = Tween<double>(begin: 1.0, end: widget.scaleEnd).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _opacity = Tween<double>(begin: 1.0, end: widget.opacityEnd).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.onTap == null;

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: isDisabled ? null : (_) => _controller.forward(),
      onTapUp: isDisabled ? null : (_) => _controller.reverse(),
      onTapCancel: isDisabled ? null : () => _controller.reverse(),
      behavior: widget.behavior,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, child) => Opacity(
          opacity: _opacity.value,
          child: Transform.scale(scale: _scale.value, child: child),
        ),
        child: widget.child,
      ),
    );
  }
}
