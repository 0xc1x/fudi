import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/ui/fudi_colors.dart';
import '../../../../core/ui/fudi_spacing.dart';
import '../../../../core/ui/atoms/icons/fudi_icons.dart';
import '../business_providers.dart';
import '../../domain/business_location.dart';

class BusinessBranchSelector extends ConsumerStatefulWidget {
  const BusinessBranchSelector({
    super.key,
    required this.locations,
  });

  final List<BusinessLocation> locations;

  @override
  ConsumerState<BusinessBranchSelector> createState() =>
      _BusinessBranchSelectorState();
}

class _BusinessBranchSelectorState
    extends ConsumerState<BusinessBranchSelector>
    with TickerProviderStateMixin {
  bool _isOpen = false;

  late final AnimationController _chevronController;
  late final AnimationController _pressController;
  late final Animation<double> _pressScale;

  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();

  @override
  void initState() {
    super.initState();

    _chevronController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 180),
    );
    _pressScale = Tween<double>(begin: 1.0, end: 0.93).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _removeOverlay();
    _chevronController.dispose();
    _pressController.dispose();
    super.dispose();
  }

  void _toggleDropdown() {
    if (_isOpen) {
      _closeDropdown();
    } else {
      _openDropdown();
    }
  }

  void _openDropdown() {
    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) => _BranchDropdownOverlay(
        layerLink: _layerLink,
        buttonWidth: size.width,
        locations: widget.locations,
        onClose: _closeDropdown,
        onBranchSelected: _onBranchSelected,
      ),
    );

    overlay.insert(_overlayEntry!);
    setState(() => _isOpen = true);
    _chevronController.forward();
  }

  void _closeDropdown() async {
    if (mounted && _isOpen) {
      setState(() => _isOpen = false);
      _chevronController.reverse();
      await Future.delayed(const Duration(milliseconds: 50));
      _removeOverlay();
    }
  }

  void _onBranchSelected(String? locationId) {
    ref.read(selectedBranchIdProvider.notifier).select(locationId);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _closeDropdown();
    });
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    final selectedId = ref.watch(selectedBranchIdProvider);
    final selectedName = selectedId == null
        ? 'Todas las sucursales'
        : widget.locations
            .where((l) => l.id == selectedId)
            .map((l) => l.name)
            .firstOrNull ?? 'Todas las sucursales';

    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: _toggleDropdown,
        onTapDown: (_) => _pressController.forward(),
        onTapUp: (_) => _pressController.reverse(),
        onTapCancel: () => _pressController.reverse(),
        behavior: HitTestBehavior.opaque,
        child: AnimatedBuilder(
          animation: _pressScale,
          builder: (context, child) => Transform.scale(
            scale: _pressScale.value,
            alignment: Alignment.centerLeft,
            child: child,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(FudiIcons.mapPin, size: 16, color: FudiColors.primary),
              const SizedBox(width: FudiSpacing.xs),
              Flexible(
                child: Text(
                  selectedName,
                  style: const TextStyle(
                    fontFamily: 'DMSans',
                    color: FudiColors.foreground,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 2),
              RotationTransition(
                turns: Tween(begin: 0.0, end: 0.5).animate(
                  CurvedAnimation(
                    parent: _chevronController,
                    curve: Curves.easeInOutCubic,
                  ),
                ),
                child: const Icon(
                  FudiIcons.chevronDown,
                  size: 16,
                  color: FudiColors.foreground,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BranchDropdownOverlay extends ConsumerStatefulWidget {
  const _BranchDropdownOverlay({
    required this.layerLink,
    required this.buttonWidth,
    required this.locations,
    required this.onClose,
    required this.onBranchSelected,
  });

  final LayerLink layerLink;
  final double buttonWidth;
  final List<BusinessLocation> locations;
  final VoidCallback onClose;
  final ValueChanged<String?> onBranchSelected;

  @override
  ConsumerState<_BranchDropdownOverlay> createState() =>
      _BranchDropdownOverlayState();
}

class _BranchDropdownOverlayState
    extends ConsumerState<_BranchDropdownOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _opacity = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, -0.06),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _scale = Tween<double>(begin: 0.96, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  Future<void> _animateClose() async {
    await _controller.reverse();
    widget.onClose();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedId = ref.watch(selectedBranchIdProvider);

    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            onTap: _animateClose,
            behavior: HitTestBehavior.opaque,
            child: const ColoredBox(color: Colors.transparent),
          ),
        ),
        CompositedTransformFollower(
          link: widget.layerLink,
          showWhenUnlinked: false,
          offset: const Offset(0, 8),
          child: FadeTransition(
            opacity: _opacity,
            child: SlideTransition(
              position: _slide,
              child: ScaleTransition(
                scale: _scale,
                alignment: Alignment.topCenter,
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    constraints: BoxConstraints(
                      minWidth: widget.buttonWidth,
                      maxWidth: 280,
                    ),
                    decoration: BoxDecoration(
                      color: FudiColors.inputBackground,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: FudiColors.borderSolid),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x1A000000),
                          blurRadius: 20,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: _DropdownContent(
                      locations: widget.locations,
                      selectedId: selectedId,
                      onBranchSelected: widget.onBranchSelected,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DropdownContent extends StatelessWidget {
  const _DropdownContent({
    required this.locations,
    required this.selectedId,
    required this.onBranchSelected,
  });

  final List<BusinessLocation> locations;
  final String? selectedId;
  final ValueChanged<String?> onBranchSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _BranchItem(
          name: 'Todas las sucursales',
          address: 'Ver todas las ofertas',
          isSelected: selectedId == null,
          onTap: () => onBranchSelected(null),
        ),
        if (locations.isEmpty)
          const Padding(
            padding: EdgeInsets.all(FudiSpacing.lg),
            child: Center(
              child: Text(
                'Sin sucursales',
                style: TextStyle(color: FudiColors.mutedForeground),
              ),
            ),
          )
        else
          for (final location in locations)
            _BranchItem(
              name: location.name,
              address: location.address,
              isSelected: location.id == selectedId,
              onTap: () => onBranchSelected(location.id),
            ),
      ],
    );
  }
}

class _BranchItem extends StatefulWidget {
  const _BranchItem({
    required this.name,
    required this.address,
    required this.isSelected,
    required this.onTap,
  });

  final String name;
  final String address;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  State<_BranchItem> createState() => _BranchItemState();
}

class _BranchItemState extends State<_BranchItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 240),
    );
    _opacity = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(-0.04, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    Future.delayed(Duration.zero, () {
      if (mounted) _controller.forward();
    });
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
      child: SlideTransition(
        position: _slide,
        child: GestureDetector(
          onTap: widget.onTap,
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) => setState(() => _isPressed = false),
          onTapCancel: () => setState(() => _isPressed = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            color: _isPressed
                ? FudiColors.primary.withValues(alpha: 0.08)
                : widget.isSelected
                    ? const Color(0x0DFA4743)
                    : Colors.transparent,
            padding: const EdgeInsets.symmetric(
              horizontal: FudiSpacing.lg,
              vertical: FudiSpacing.md,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: FudiColors.secondary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    FudiIcons.mapPin,
                    size: 16,
                    color: FudiColors.primary,
                  ),
                ),
                const SizedBox(width: FudiSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.name,
                        style: TextStyle(
                          fontFamily: 'DMSans',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: widget.isSelected
                              ? FudiColors.primary
                              : FudiColors.foreground,
                        ),
                      ),
                      Text(
                        widget.address,
                        style: const TextStyle(
                          fontFamily: 'DMSans',
                          fontSize: 12,
                          color: FudiColors.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                ),
                if (widget.isSelected) ...[
                  const SizedBox(width: FudiSpacing.sm),
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(top: 4),
                    decoration: const BoxDecoration(
                      color: FudiColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
