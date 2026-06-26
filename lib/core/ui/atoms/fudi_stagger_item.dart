import 'package:flutter/material.dart';

class FudiStaggerItem extends StatefulWidget {
  const FudiStaggerItem({
    super.key,
    required this.index,
    required this.child,
    this.staggerDelay = 60,
    this.baseDelay = 80,
    this.duration = const Duration(milliseconds: 300),
    this.slideOffset = 0.06,
  });

  final int index;
  final Widget child;
  final int staggerDelay;
  final int baseDelay;
  final Duration duration;
  final double slideOffset;

  @override
  State<FudiStaggerItem> createState() => _FudiStaggerItemState();
}

class _FudiStaggerItemState extends State<FudiStaggerItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _opacity = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: Offset(0, widget.slideOffset),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    Future.delayed(
      Duration(
        milliseconds: widget.baseDelay + widget.index * widget.staggerDelay,
      ),
      () {
        if (mounted) _controller.forward();
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}
