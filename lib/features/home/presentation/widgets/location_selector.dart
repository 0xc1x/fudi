import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/route_names.dart';
import '../../../../core/ui/fudi_colors.dart';
import '../../../../core/ui/fudi_spacing.dart';
import '../../../../core/ui/fudi_typography.dart';
import '../../../../core/ui/atoms/icons/fudi_icons.dart';
import '../../../profile/domain/saved_address_model.dart';
import '../../../profile/presentation/profile_providers.dart';

class LocationSelector extends ConsumerStatefulWidget {
  const LocationSelector({super.key});

  @override
  ConsumerState<LocationSelector> createState() => _LocationSelectorState();
}

class _LocationSelectorState extends ConsumerState<LocationSelector>
    with TickerProviderStateMixin {
  bool _isOpen = false;

  // Chevron rotate
  late final AnimationController _chevronController;

  // Press scale del trigger
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
      builder: (context) => _LocationDropdownOverlay(
        layerLink: _layerLink,
        buttonWidth: size.width,
        onClose: _closeDropdown,
        onAddressSelected: _onAddressSelected,
        onAddAddress: _onAddAddress,
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

      // Si tienes acceso al controlador del dropdown podrías hacer un reverse,
      // pero como está dentro del OverlayEntry, una forma sencilla es darle un delay
      // mínimo para que la UI respire antes de desmontar el Overlay por completo:
      await Future.delayed(const Duration(milliseconds: 50));
      _removeOverlay();
    }
  }

  // 2. Y tu _onAddressSelected se mantiene limpia:
  void _onAddressSelected(SavedAddressModel address) {
    // 1. Modificamos el estado (ahora solo mutará el pequeño Consumer del texto)
    unawaited(ref.read(userSelectedAddressProvider.notifier).select(address));

    // 2. Cerramos el dropdown en el próximo frame de forma segura
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _closeDropdown();
    });
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _onAddAddress() {
    _closeDropdown();
    context.push(RouteNames.savedAddressesPath);
  }

  @override
  Widget build(BuildContext context) {
    //final selectedAddress = ref.watch(userSelectedAddressProvider);

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
              Consumer(
                builder: (context, ref, child) {
                  final selectedAddress = ref.watch(
                    userSelectedAddressProvider,
                  );
                  return Text(
                    selectedAddress?.label ?? 'Seleccionar ubicación',
                    style: const TextStyle(
                      fontFamily: 'DMSans',
                      color: FudiColors.foreground,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  );
                },
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

// ── Overlay con animación de entrada/salida ───────────────────────────────────

class _LocationDropdownOverlay extends ConsumerStatefulWidget {
  const _LocationDropdownOverlay({
    required this.layerLink,
    required this.buttonWidth,
    required this.onClose,
    required this.onAddressSelected,
    required this.onAddAddress,
  });

  final LayerLink layerLink;
  final double buttonWidth;
  final VoidCallback onClose;
  final ValueChanged<SavedAddressModel> onAddressSelected;
  final VoidCallback onAddAddress;

  @override
  ConsumerState<_LocationDropdownOverlay> createState() =>
      _LocationDropdownOverlayState();
}

class _LocationDropdownOverlayState
    extends ConsumerState<_LocationDropdownOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  // Fade + slide-down combinados
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
      begin: const Offset(0, -0.06), // sube 6 % de su altura
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _scale = Tween<double>(
      begin: 0.96,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    // Arranca la animación de entrada en cuanto el widget se monta.
    _controller.forward();
  }

  Future<void> _animateClose() async {
    await _controller.reverse();
    widget.onClose(); // Esto llama a _closeDropdown del padre
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final addressesAsync = ref.watch(savedAddressesProvider);
    final selectedAddress = ref.watch(userSelectedAddressProvider);

    return Stack(
      children: [
        // Backdrop transparente para cerrar al tocar fuera
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
          offset: const Offset(0, _kDropdownTopOffset),
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
                      maxWidth: _kDropdownMaxWidth,
                    ),
                    decoration: BoxDecoration(
                      color: FudiColors.inputBackground,
                      borderRadius: BorderRadius.circular(FudiRadius.xl),
                      border: Border.all(color: FudiColors.borderSolid),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x1A000000),
                          blurRadius: 20,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: addressesAsync.when(
                      data: (addresses) => _DropdownContent(
                        addresses: addresses,
                        selectedAddress: selectedAddress,
                        onAddressSelected: widget.onAddressSelected,
                        onAddAddress: widget.onAddAddress,
                      ),
                      loading: () => const Padding(
                        padding: EdgeInsets.all(FudiSpacing.lg),
                        child: Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      ),
                      error: (_, _) => Padding(
                        padding: const EdgeInsets.all(FudiSpacing.lg),
                        child: Text(
                          'Error al cargar direcciones',
                          style: FudiTypography.bodySmall.copyWith(
                            color: FudiColors.destructive,
                          ),
                        ),
                      ),
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

// ── Contenido del dropdown ────────────────────────────────────────────────────

class _DropdownContent extends StatelessWidget {
  const _DropdownContent({
    required this.addresses,
    required this.selectedAddress,
    required this.onAddressSelected,
    required this.onAddAddress,
  });

  final List<SavedAddressModel> addresses;
  final SavedAddressModel? selectedAddress;
  final ValueChanged<SavedAddressModel> onAddressSelected;
  final VoidCallback onAddAddress;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Items con stagger: cada uno aparece con un delay incremental
        for (int i = 0; i < addresses.length; i++)
          _AnimatedAddressItem(
            staggerIndex: i,
            address: addresses[i],
            isSelected: addresses[i].id == selectedAddress?.id,
            onTap: () => onAddressSelected(addresses[i]),
          ),
        const Divider(height: 1, thickness: 1, color: FudiColors.borderSolid),
        _AddAddressButton(onTap: onAddAddress),
      ],
    );
  }
}

// ── Item con stagger de entrada ───────────────────────────────────────────────

class _AnimatedAddressItem extends StatefulWidget {
  const _AnimatedAddressItem({
    required this.staggerIndex,
    required this.address,
    required this.isSelected,
    required this.onTap,
  });

  final int staggerIndex;
  final SavedAddressModel address;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  State<_AnimatedAddressItem> createState() => _AnimatedAddressItemState();
}

class _AnimatedAddressItemState extends State<_AnimatedAddressItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;

  // Press
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
      begin: const Offset(-0.04, 0), // entra desde la izquierda
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    // Stagger: cada item espera un poco más que el anterior
    Future.delayed(Duration(milliseconds: 40 * widget.staggerIndex), () {
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
                        widget.address.label,
                        style: FudiTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.w500,
                          color: widget.isSelected
                              ? FudiColors.primary
                              : FudiColors.foreground,
                        ),
                      ),
                      Text(
                        widget.address.address,
                        style: FudiTypography.bodySmall,
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

// ── Botón "Agregar dirección" con press feedback ──────────────────────────────

class _AddAddressButton extends StatefulWidget {
  const _AddAddressButton({required this.onTap});
  final VoidCallback onTap;

  @override
  State<_AddAddressButton> createState() => _AddAddressButtonState();
}

class _AddAddressButtonState extends State<_AddAddressButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        color: _isPressed
            ? FudiColors.primary.withValues(alpha: 0.06)
            : Colors.transparent,
        padding: const EdgeInsets.symmetric(
          horizontal: FudiSpacing.lg,
          vertical: FudiSpacing.md,
        ),
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 120),
          style: FudiTypography.bodyMedium.copyWith(
            color: _isPressed
                ? FudiColors.primary.withValues(alpha: 0.7)
                : FudiColors.primary,
          ),
          child: const Text('+ Agregar nueva dirección'),
        ),
      ),
    );
  }
}

const double _kDropdownTopOffset = 8.0;
const double _kDropdownMaxWidth = 280.0;
