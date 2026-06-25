import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../core/ui/fudi_colors.dart';
import '../../../../core/ui/fudi_spacing.dart';
import '../../../../core/ui/atoms/icons/fudi_icons.dart';

class PromoItem {
  const PromoItem({
    required this.title,
    required this.message,
    this.icon,
    this.imageUrl,
    this.isSponsored = false,
  });

  final String title;
  final String message;
  final IconData? icon;
  final String? imageUrl;
  final bool isSponsored;
}

class PromoSlider extends StatefulWidget {
  const PromoSlider({super.key});

  @override
  State<PromoSlider> createState() => _PromoSliderState();
}

class _PromoSliderState extends State<PromoSlider> {
  static const _items = [
    PromoItem(
      title: '¿Sabías que…',
      message:
          'Cada año se desperdician 1.3 mil millones de toneladas de comida en el mundo. ¡Tú puedes ayudar!',
      icon: FudiIcons.info,
      imageUrl:
          'https://images.unsplash.com/photo-1542838132-92c53300491e?w=400&fit=crop',
    ),
    PromoItem(
      title: 'Impacto ambiental',
      message:
          'Al rescatar un paquete sorpresa evitas la emisión de ~2.5kg de CO2. Cada rescate cuenta.',
      icon: FudiIcons.trendingUp,
      imageUrl:
          'https://images.unsplash.com/photo-1498837167922-ddd27525d352?w=400&fit=crop',
    ),
    PromoItem(
      title: 'Comida rescatada',
      message:
          'Los alimentos aptos para consumo pero no para venta son rescatados por negocios como los de Fudi.',
      icon: FudiIcons.package_,
      imageUrl:
          'https://images.unsplash.com/photo-1482049016688-2d3e1b311543?w=400&fit=crop',
    ),
    PromoItem(
      title: 'Gana-gana',
      message:
          'Rescatar comida no solo ahorra dinero, también reduce el desperdicio y apoya a negocios locales.',
      icon: FudiIcons.star,
      isSponsored: true,
      imageUrl:
          'https://images.unsplash.com/photo-1574484284002-952d92456975?w=400&fit=crop',
    ),
  ];

  // ── Loop infinito ─────────────────────────────────────────────────────────
  // El truco: le decimos al PageView que tiene "infinitos" items.
  // Empezamos en un offset grande divisible entre _items.length para que
  // el usuario pueda deslizar hacia atrás también sin llegar al borde.
  static const _kMultiplier = 1000;
  static int get _initialPage => _items.length * _kMultiplier;

  late final PageController _pageController;
  Timer? _timer;
  int _currentPage = _initialPage;
  bool _isPaused = false;

  int get _realIndex => _currentPage % _items.length;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _initialPage);
    _startAutoRotate();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoRotate() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!_isPaused && _items.length > 1) {
        _pageController.animateToPage(
          _currentPage + 1,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_items.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        FudiSpacing.lg,
        FudiSpacing.md,
        FudiSpacing.lg,
        0,
      ),
      child: Column(
        children: [
          SizedBox(
            height: 240,
            child: Listener(
              onPointerDown: (_) => setState(() => _isPaused = true),
              onPointerUp: (_) {
                setState(() => _isPaused = false);
                // Reiniciamos el timer al soltar para que no avance
                // inmediatamente después de un swipe manual.
                _startAutoRotate();
              },
              onPointerCancel: (_) => setState(() => _isPaused = false),
              child: PageView.builder(
                controller: _pageController,
                // itemCount: null → infinito
                onPageChanged: (page) => setState(() => _currentPage = page),
                itemBuilder: (context, index) {
                  final item = _items[index % _items.length];
                  return _PromoCard(item: item);
                },
              ),
            ),
          ),
          if (_items.length > 1) ...[
            const SizedBox(height: FudiSpacing.sm),
            _PageDots(count: _items.length, current: _realIndex),
          ],
        ],
      ),
    );
  }
}

// ── Promo card ────────────────────────────────────────────────────────────────

class _PromoCard extends StatelessWidget {
  const _PromoCard({required this.item});

  final PromoItem item;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bannerWidth = constraints.maxWidth;
        final bannerHeight = (bannerWidth * 9 / 16).clamp(0.0, 220.0);
        final halfWidth = bannerWidth / 2;

        return Container(
          width: double.infinity,
          height: bannerHeight,
          clipBehavior: Clip.none,
          child: Stack(
            children: [
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(FudiRadius.md),
                    boxShadow: [
                      BoxShadow(
                        color: FudiColors.green.withValues(alpha: 0.15),
                        blurRadius: 40,
                        spreadRadius: 6,
                        offset: const Offset(-6, -3),
                      ),
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.4),
                        blurRadius: 12,
                        spreadRadius: -4,
                      ),
                    ],
                  ),
                ),
              ),
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(FudiRadius.md),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.08),
                        width: 1,
                      ),
                      color: const Color(0xFF140D0D),
                    ),
                    child: Stack(
                      children: [
                        if (item.imageUrl != null)
                          Positioned.fill(
                            child: Image.network(
                              item.imageUrl!,
                              fit: BoxFit.cover,
                            ),
                          ),
                        if (item.imageUrl != null)
                          Positioned.fill(
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                              child: Container(color: Colors.transparent),
                            ),
                          ),
                        if (item.imageUrl != null)
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: [
                                    Colors.black.withValues(alpha: 0.5),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                          ),
                        Positioned(
                          left: 0,
                          top: 0,
                          bottom: 0,
                          width: halfWidth,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(18, 16, 10, 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _SponsorBadge(isSponsored: item.isSponsored),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.title,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: -0.2,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      item.message,
                                      style: TextStyle(
                                        color: Colors.white.withValues(
                                          alpha: 0.7,
                                        ),
                                        fontSize: 12,
                                        height: 1.4,
                                      ),
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                                // ── Botón con animación ───────────────────
                                _PromoButton(),
                              ],
                            ),
                          ),
                        ),
                        if (item.imageUrl != null)
                          Positioned(
                            right: 0,
                            top: 0,
                            bottom: 0,
                            width: halfWidth,
                            child: Image.network(
                              item.imageUrl!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                          ),
                        if (item.imageUrl == null && item.icon != null)
                          Positioned(
                            right: 0,
                            top: 0,
                            bottom: 0,
                            width: halfWidth,
                            child: Center(
                              child: Icon(
                                item.icon,
                                size: 48,
                                color: Colors.white.withValues(alpha: 0.2),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Botón animado ─────────────────────────────────────────────────────────────

class _PromoButton extends StatefulWidget {
  const _PromoButton();

  @override
  State<_PromoButton> createState() => _PromoButtonState();
}

class _PromoButtonState extends State<_PromoButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 180),
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: 0.94,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _controller.forward();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _controller.reverse();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _controller.reverse();
      },
      child: AnimatedBuilder(
        animation: _scale,
        builder: (context, child) =>
            Transform.scale(scale: _scale.value, child: child),
        child: SizedBox(
          width: double.infinity,
          height: 42,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            decoration: BoxDecoration(
              color: _isPressed
                  ? FudiColors.primary.withValues(alpha: 0.8)
                  : FudiColors.primary,
              borderRadius: BorderRadius.circular(FudiRadius.md),
              boxShadow: _isPressed
                  ? []
                  : [
                      BoxShadow(
                        color: FudiColors.primary.withValues(alpha: 0.45),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
            ),
            child: const Center(
              child: Text(
                'Ver más',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Widgets auxiliares ────────────────────────────────────────────────────────

class _SponsorBadge extends StatelessWidget {
  const _SponsorBadge({required this.isSponsored});

  final bool isSponsored;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(FudiRadius.full),
      ),
      child: Text(
        isSponsored ? 'Sponsoreado' : 'Tips',
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _PageDots extends StatelessWidget {
  const _PageDots({required this.count, required this.current});

  final int count;
  final int current;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final isActive = index == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: isActive ? 20 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive
                ? FudiColors.primary
                : FudiColors.mutedForeground.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}
