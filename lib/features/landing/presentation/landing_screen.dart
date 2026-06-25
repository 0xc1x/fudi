import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/route_names.dart';
import '../../../core/ui/fudi_colors.dart';
import '../../../core/ui/fudi_logo.dart';
import '../../../core/ui/fudi_spacing.dart';
import '../../../core/ui/fudi_pressable_scale.dart';
import '../../../core/ui/fudi_typography.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.offset > 50 && !_isScrolled) {
      setState(() => _isScrolled = true);
    } else if (_scrollController.offset <= 50 && _isScrolled) {
      setState(() => _isScrolled = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 900;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      drawer: isMobile ? const _MobileDrawer() : null,
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              _SliverHero(),
              _SliverFeatures(),
              _SliverHowItWorks(),
              _SliverTestimonials(),
              _SliverFAQ(),
              _SliverContact(),
              _SliverCTA(),
              _SliverFooter(),
            ],
          ),
          _StickyNavbar(
            isScrolled: _isScrolled,
            isMobile: isMobile,
            onMenuPressed: () => _scaffoldKey.currentState?.openDrawer(),
          ),
        ],
      ),
    );
  }
}

class _StickyNavbar extends StatelessWidget {
  const _StickyNavbar({
    required this.isScrolled,
    required this.isMobile,
    required this.onMenuPressed,
  });

  final bool isScrolled;
  final bool isMobile;
  final VoidCallback onMenuPressed;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 90,
      padding: const EdgeInsets.symmetric(horizontal: FudiSpacing.xl),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        border: Border(
          bottom: BorderSide(
            color: FudiColors.borderSolid.withValues(
              alpha: isScrolled ? 1.0 : 0.0,
            ),
          ),
        ),
        boxShadow: isScrolled
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            GestureDetector(
              onTap: () => context.go(RouteNames.landingPath),
              child: FudiLogo(size: FudiLogoSize.md),
            ),
            const Spacer(),
            if (!isMobile) ...[
              _NavLink(
                label: 'Cómo funciona',
                path: RouteNames.howItWorksPath,
                isDark: true,
              ),
              _NavLink(
                label: 'Para negocios',
                path: RouteNames.forBusinessPath,
                isDark: true,
              ),
              _NavLink(
                label: 'Sobre nosotros',
                path: RouteNames.aboutPath,
                isDark: true,
              ),
              _NavLink(
                label: 'Contacto',
                path: RouteNames.helpPath,
                isDark: true,
              ),
              const SizedBox(width: FudiSpacing.xl),
            ],
            FudiPressableScale(
              onTap: () => context.go(RouteNames.loginPath),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: const Text('Iniciar sesión', style: TextStyle(color: FudiColors.foreground, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(width: FudiSpacing.sm),
            FudiPressableScale(
              onTap: () => context.go(RouteNames.signupPath),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: FudiColors.primary,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: const Text('Registrarse', style: TextStyle(color: Colors.white)),
              ),
            ),
            if (isMobile) ...[
              const SizedBox(width: FudiSpacing.sm),
              FudiPressableScale(
                onTap: onMenuPressed,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.menu, color: FudiColors.foreground),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _NavLink extends StatelessWidget {
  const _NavLink({
    required this.label,
    required this.path,
    required this.isDark,
  });

  final String label;
  final String path;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: FudiSpacing.lg),
      child: FudiPressableScale(
        onTap: () => context.go(path),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: FudiSpacing.sm,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: isDark
                  ? FudiColors.foreground
                  : Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ),
      ),
    );
  }
}

class _MobileDrawer extends StatelessWidget {
  const _MobileDrawer();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(FudiSpacing.xl),
              child: FudiLogo(size: FudiLogoSize.lg),
            ),
            const Divider(),
            _DrawerItem(
              label: 'Cómo funciona',
              icon: Icons.info_outline,
              path: RouteNames.howItWorksPath,
            ),
            _DrawerItem(
              label: 'Para negocios',
              icon: Icons.business_outlined,
              path: RouteNames.forBusinessPath,
            ),
            _DrawerItem(
              label: 'Sobre nosotros',
              icon: Icons.people_outline,
              path: RouteNames.aboutPath,
            ),
            _DrawerItem(
              label: 'Contacto',
              icon: Icons.contact_mail_outlined,
              path: RouteNames.helpPath,
            ),
            _DrawerItem(
              label: 'Ayuda',
              icon: Icons.help_outline,
              path: RouteNames.helpPath,
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(FudiSpacing.xl),
              child: Column(
                children: [
                  FudiPressableScale(
                    onTap: () => context.go(RouteNames.signupPath),
                    child: Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        color: FudiColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(child: Text('Crear cuenta', style: TextStyle(color: Colors.white))),
                    ),
                  ),
                  const SizedBox(height: FudiSpacing.md),
                  FudiPressableScale(
                    onTap: () => context.go(RouteNames.loginPath),
                    child: Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        border: Border.all(color: FudiColors.primary),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(child: Text('Iniciar sesión', style: TextStyle(color: FudiColors.primary))),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.label,
    required this.icon,
    required this.path,
  });

  final String label;
  final IconData icon;
  final String path;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: FudiColors.primary),
      title: Text(label, style: FudiTypography.labelSmall),
      onTap: () {
        Navigator.pop(context);
        context.go(path);
      },
    );
  }
}

class _SliverHero extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 1024;

    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.only(top: 128, bottom: 80),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              FudiColors.secondary.withValues(alpha: 0.3),
              FudiColors.secondary.withValues(alpha: 0.1),
              FudiColors.accent.withValues(alpha: 0.1),
            ],
          ),
        ),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1200),
            padding: const EdgeInsets.symmetric(horizontal: FudiSpacing.xl),
            child: isDesktop
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(child: _HeroContent()),
                      const SizedBox(width: 80),
                      SizedBox(width: 400, child: _HeroImage()),
                    ],
                  )
                : Column(
                    children: [
                      _HeroImage(),
                      const SizedBox(height: 48),
                      _HeroContent(),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class _HeroContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 1024;
    final align = isDesktop
        ? CrossAxisAlignment.start
        : CrossAxisAlignment.center;
    final textAlign = isDesktop ? TextAlign.start : TextAlign.center;

    return Column(
      crossAxisAlignment: align,
      children: [
        RichText(
          textAlign: textAlign,
          text: TextSpan(
            style: FudiTypography.h1.copyWith(
              color: FudiColors.foreground,
              fontSize: isDesktop ? 56 : 40,
              height: 1.1,
              fontWeight: FontWeight.w800,
            ),
            children: const [
              TextSpan(text: 'Comida deliciosa, '),
              TextSpan(
                text: 'precios increíbles',
                style: TextStyle(color: FudiColors.primary),
              ),
            ],
          ),
        ),
        const SizedBox(height: FudiSpacing.xl),
        Text(
          'Rescata comida de calidad de tus comercios favoritos a precio reducido. Ahorra dinero mientras ayudas al planeta.',
          textAlign: textAlign,
          style: FudiTypography.bodyLarge.copyWith(
            color: FudiColors.mutedForeground,
            fontSize: 20,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 32),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          alignment: isDesktop ? WrapAlignment.start : WrapAlignment.center,
          children: [
            _DownloadButton(
              icon: Icons.apple,
              topLabel: 'Descargar en',
              label: 'App Store',
              onPressed: () {},
            ),
            _DownloadButton(
              icon: Icons.play_arrow,
              topLabel: 'Disponible en',
              label: 'Google Play',
              onPressed: () {},
            ),
          ],
        ),
        const SizedBox(height: 48),
        _HeroStats(isDesktop: isDesktop),
      ],
    );
  }
}

class _HeroImage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 380,
        height: 380,
        child: Stack(
          children: [
            Positioned.fill(
              child: Transform.rotate(
                angle: 0.1,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        FudiColors.primary.withValues(alpha: 0.2),
                        FudiColors.accent.withValues(alpha: 0.2),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: Transform.rotate(
                angle: -0.1,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        FudiColors.primary.withValues(alpha: 0.3),
                        FudiColors.accent.withValues(alpha: 0.3),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 40,
                      offset: const Offset(0, 20),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text('🍔', style: TextStyle(fontSize: 120)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DownloadButton extends StatelessWidget {
  const _DownloadButton({
    required this.icon,
    required this.topLabel,
    required this.label,
    required this.onPressed,
    this.isLight = false,
  });

  final IconData icon;
  final String topLabel;
  final String label;
  final VoidCallback onPressed;
  final bool isLight;

  @override
  Widget build(BuildContext context) {
    final bgColor = isLight ? Colors.white : Colors.black;
    final textColor = isLight ? FudiColors.foreground : Colors.white;

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: textColor, size: 32),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  topLabel,
                  style: TextStyle(
                    color: textColor.withValues(alpha: 0.8),
                    fontSize: 11,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroStats extends StatelessWidget {
  const _HeroStats({this.isDesktop = true});

  final bool isDesktop;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: isDesktop
          ? MainAxisAlignment.start
          : MainAxisAlignment.center,
      children: [
        _StatItem(value: '50K+', label: 'Usuarios activos'),
        const SizedBox(width: 48),
        _StatItem(value: '2000+', label: 'Comercios'),
        const SizedBox(width: 48),
        _StatItem(value: '100K+', label: 'Comidas salvadas'),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: FudiTypography.h2.copyWith(
            color: FudiColors.primary,
            fontWeight: FontWeight.w800,
            fontSize: 28,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: FudiTypography.bodySmall.copyWith(
            color: FudiColors.mutedForeground,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

class _SliverFeatures extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 100,
          horizontal: FudiSpacing.xl,
        ),
        child: Column(
          children: [
            Text(
              '¿Por qué elegir Fudi?',
              textAlign: TextAlign.center,
              style: FudiTypography.h2.copyWith(
                fontSize: 40,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: FudiSpacing.lg),
            Text(
              'Una solución que beneficia a todos: comercios, usuarios y el planeta',
              textAlign: TextAlign.center,
              style: FudiTypography.bodyLarge.copyWith(
                color: FudiColors.mutedForeground,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 80),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: MediaQuery.of(context).size.width > 900
                  ? 4
                  : (MediaQuery.of(context).size.width > 600 ? 2 : 1),
              mainAxisSpacing: 30,
              crossAxisSpacing: 30,
              childAspectRatio: 0.85,
              children: [
                _FeatureCard(
                  icon: '🍽️',
                  title: 'Reduce el desperdicio',
                  description:
                      'Ayuda a restaurantes y comercios a reducir el desperdicio de alimentos mientras ahorras dinero.',
                ),
                _FeatureCard(
                  icon: '💰',
                  title: 'Ahorra hasta 70%',
                  description:
                      'Obtén productos de calidad a precios increíbles. Paga menos de la mitad del precio original.',
                ),
                _FeatureCard(
                  icon: '🌍',
                  title: 'Impacto positivo',
                  description:
                      'Cada compra que haces ayuda al planeta y apoya a los comercios locales de tu ciudad.',
                ),
                _FeatureCard(
                  icon: '⚡',
                  title: 'Fácil y rápido',
                  description:
                      'Reserva en segundos, recoge cuando te convenga. Todo desde tu móvil.',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  final String icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: FudiColors.muted.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(icon, style: const TextStyle(fontSize: 48)),
          const SizedBox(height: 24),
          Text(
            title,
            textAlign: TextAlign.center,
            style: FudiTypography.labelMedium.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            description,
            textAlign: TextAlign.center,
            style: FudiTypography.bodyMedium.copyWith(
              color: FudiColors.mutedForeground,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _SliverHowItWorks extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        color: const Color(0xFFF8F9FA),
        padding: const EdgeInsets.symmetric(
          vertical: 100,
          horizontal: FudiSpacing.xl,
        ),
        child: Column(
          children: [
            Text(
              'Cómo funciona',
              style: FudiTypography.h2.copyWith(
                fontSize: 40,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: FudiSpacing.lg),
            Text(
              'Tres simples pasos para comenzar a ahorrar',
              textAlign: TextAlign.center,
              style: FudiTypography.bodyLarge.copyWith(
                color: FudiColors.mutedForeground,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 80),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: MediaQuery.of(context).size.width > 900 ? 3 : 1,
              mainAxisSpacing: 40,
              crossAxisSpacing: 40,
              childAspectRatio: 1.2,
              children: [
                _HowItWorksStep(
                  number: '1',
                  title: 'Explora ofertas cerca de ti',
                  description:
                      'Busca restaurantes, panaderías y más en tu zona con productos disponibles.',
                ),
                _HowItWorksStep(
                  number: '2',
                  title: 'Reserva tu bolsa sorpresa',
                  description:
                      'Elige lo que te gusta y paga directamente desde la app.',
                ),
                _HowItWorksStep(
                  number: '3',
                  title: 'Recoge y disfruta',
                  description:
                      'Pasa por el comercio en el horario indicado y recoge tu pedido.',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HowItWorksStep extends StatelessWidget {
  const _HowItWorksStep({
    required this.number,
    required this.title,
    required this.description,
  });

  final String number;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: FudiColors.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            title,
            textAlign: TextAlign.center,
            style: FudiTypography.h3.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            description,
            textAlign: TextAlign.center,
            style: FudiTypography.bodyLarge.copyWith(
              color: FudiColors.mutedForeground,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _SliverTestimonials extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 100,
          horizontal: FudiSpacing.xl,
        ),
        child: Column(
          children: [
            Text(
              'Lo que dicen nuestros usuarios',
              style: FudiTypography.h2.copyWith(
                fontSize: 40,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: FudiSpacing.lg),
            Text(
              'Miles de personas ya están ahorrando con Fudi',
              textAlign: TextAlign.center,
              style: FudiTypography.bodyLarge.copyWith(
                color: FudiColors.mutedForeground,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 80),
            SizedBox(
              height: 280,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(vertical: 10),
                children: const [
                  _TestimonialCard(
                    name: 'María González',
                    role: 'Usuario de Fudi',
                    text:
                        '¡Increíble! Ahorro dinero en comida de calidad y además ayudo al medio ambiente. Lo uso todos los días.',
                    avatar:
                        'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150&h=150&fit=crop',
                  ),
                  _TestimonialCard(
                    name: 'Carlos Ruiz',
                    role: 'Propietario de Panadería',
                    text:
                        'Fudi me ha permitido reducir el desperdicio y conectar con nuevos clientes. Una solución brillante.',
                    avatar:
                        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&h=150&fit=crop',
                  ),
                  _TestimonialCard(
                    name: 'Laura Martín',
                    role: 'Usuario de Fudi',
                    text:
                        'La mejor app para descubrir restaurantes locales y ahorrar. ¡Me encanta la variedad de opciones!',
                    avatar:
                        'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=150&h=150&fit=crop',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TestimonialCard extends StatelessWidget {
  const _TestimonialCard({
    required this.name,
    required this.role,
    required this.text,
    required this.avatar,
  });

  final String name;
  final String role;
  final String text;
  final String avatar;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 380,
      margin: const EdgeInsets.only(right: 32),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: FudiColors.muted.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.star, color: Color(0xFFFFB300), size: 20, fill: 1),
              Icon(Icons.star, color: Color(0xFFFFB300), size: 20, fill: 1),
              Icon(Icons.star, color: Color(0xFFFFB300), size: 20, fill: 1),
              Icon(Icons.star, color: Color(0xFFFFB300), size: 20, fill: 1),
              Icon(Icons.star, color: Color(0xFFFFB300), size: 20, fill: 1),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Text(
              '"$text"',
              style: FudiTypography.bodyLarge.copyWith(
                fontStyle: FontStyle.italic,
                color: FudiColors.foreground,
                height: 1.6,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              CircleAvatar(radius: 28, backgroundImage: NetworkImage(avatar)),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: FudiTypography.labelMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    role,
                    style: FudiTypography.bodySmall.copyWith(
                      color: FudiColors.mutedForeground,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SliverFAQ extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        color: const Color(0xFFF8F9FA),
        padding: const EdgeInsets.symmetric(
          vertical: 100,
          horizontal: FudiSpacing.xl,
        ),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              children: [
                Text(
                  'Preguntas frecuentes',
                  style: FudiTypography.h2.copyWith(
                    fontSize: 40,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: FudiSpacing.lg),
                Text(
                  'Todo lo que necesitas saber sobre Fudi',
                  textAlign: TextAlign.center,
                  style: FudiTypography.bodyLarge.copyWith(
                    color: FudiColors.mutedForeground,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 80),
                const _FAQItem(
                  question: '¿Qué es Fudi?',
                  answer:
                      'Fudi es una plataforma que conecta comercios con excedente de comida con usuarios que quieren ahorrar dinero mientras ayudan al planeta. Los comercios ofrecen "bolsas sorpresa" con productos del día a precios reducidos.',
                ),
                const _FAQItem(
                  question: '¿Cómo funciona el sistema de reservas?',
                  answer:
                      'Simplemente explora los comercios disponibles cerca de ti, selecciona la bolsa sorpresa que quieras, paga en la app y recoge tu pedido en el horario indicado. Todo el proceso toma menos de 2 minutos.',
                ),
                const _FAQItem(
                  question: '¿Qué viene en una bolsa sorpresa?',
                  answer:
                      'Cada bolsa sorpresa contiene una selección de productos del comercio que de otra forma se desperdiciarían. El contenido es una sorpresa, pero siempre vale más del triple de lo que pagas.',
                ),
                const _FAQItem(
                  question: '¿Cuánto puedo ahorrar?',
                  answer:
                      'Normalmente ahorrarás entre un 50% y 70% del precio original. Por ejemplo, productos que valen €15 los puedes conseguir por €4.99.',
                ),
                const _FAQItem(
                  question: '¿En qué ciudades está disponible Fudi?',
                  answer:
                      'Actualmente operamos en Barcelona, Madrid, Valencia, Sevilla y Bilbao. Estamos expandiéndonos constantemente a nuevas ciudades.',
                ),
                const _FAQItem(
                  question: '¿Cómo me registro como comercio?',
                  answer:
                      'Puedes registrar tu comercio directamente desde la app o contactándonos a través del formulario de contacto. Te guiaremos en todo el proceso de configuración.',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FAQItem extends StatelessWidget {
  const _FAQItem({required this.question, required this.answer});
  final String question;
  final String answer;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: FudiColors.muted.withValues(alpha: 0.5)),
      ),
      child: ExpansionTile(
        title: Text(
          question,
          style: FudiTypography.labelMedium.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
        tilePadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        childrenPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        collapsedShape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        children: [
          Text(
            answer,
            style: FudiTypography.bodyLarge.copyWith(
              color: FudiColors.mutedForeground,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

class _SliverCTA extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 40),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [FudiColors.primary, Color(0xFF2E7D32)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              BoxShadow(
                color: FudiColors.primary.withValues(alpha: 0.2),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: Column(
            children: [
              const Text(
                '¿Listo para empezar a ahorrar?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Descarga Fudi hoy y únete a miles de usuarios que ya están rescatando comida deliciosa',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 48),
              Wrap(
                spacing: 20,
                runSpacing: 20,
                alignment: WrapAlignment.center,
                children: [
                  _DownloadButton(
                    icon: Icons.apple,
                    topLabel: 'Descargar en',
                    label: 'App Store',
                    onPressed: () {},
                    isLight: true,
                  ),
                  _DownloadButton(
                    icon: Icons.play_arrow,
                    topLabel: 'Disponible en',
                    label: 'Google Play',
                    onPressed: () {},
                    isLight: true,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SliverFooter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        color: const Color(0xFF0F1115),
        padding: const EdgeInsets.symmetric(
          vertical: 100,
          horizontal: FudiSpacing.xl,
        ),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 300,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const FudiLogo(
                            color: Colors.white,
                            size: FudiLogoSize.lg,
                          ),
                          const SizedBox(height: 32),
                          Text(
                            'Rescata comida, ahorra dinero y ayuda al planeta. Juntos podemos hacer la diferencia.',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.5),
                              fontSize: 16,
                              height: 1.6,
                            ),
                          ),
                          const SizedBox(height: 32),
                          Row(
                            children: [
                              _SocialButton(icon: Icons.facebook),
                              _SocialButton(icon: Icons.camera_alt),
                              _SocialButton(icon: Icons.alternate_email),
                            ],
                          ),
                        ],
                      ),
                    ),
                    _FooterColumn(
                      title: 'Producto',
                      links: {
                        'Cómo funciona': RouteNames.howItWorksPath,
                        'Preguntas frecuentes': RouteNames.helpPath,
                        'Para negocios': RouteNames.forBusinessPath,
                      },
                    ),
                    _FooterColumn(
                      title: 'Compañía',
                      links: {
                        'Sobre nosotros': RouteNames.aboutPath,
                        'Contacto': RouteNames.helpPath,
                        'Inicio': RouteNames.landingPath,
                      },
                    ),
                    _FooterColumn(
                      title: 'Legal',
                      links: {
                        'Términos de uso': RouteNames.termsPath,
                        'Privacidad': RouteNames.privacyPath,
                        'Ayuda': RouteNames.helpPath,
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 80),
                const Divider(color: Colors.white10),
                const SizedBox(height: 40),
                Text(
                  '© 2026 Fudi. Todos los derechos reservados.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.3),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({required this.icon});
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 16),
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.white70, size: 20),
    );
  }
}

class _FooterColumn extends StatelessWidget {
  const _FooterColumn({required this.title, required this.links});
  final String title;
  final Map<String, String> links;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 32),
        ...links.entries.map(
          (link) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: GestureDetector(
              onTap: () => context.go(link.value),
              child: Text(
                link.key,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SliverContact extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 100,
          horizontal: FudiSpacing.xl,
        ),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Column(
              children: [
                Text(
                  'Contáctanos',
                  style: FudiTypography.h2.copyWith(
                    fontSize: 40,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: FudiSpacing.lg),
                Text(
                  '¿Tienes preguntas? Estamos aquí para ayudarte',
                  textAlign: TextAlign.center,
                  style: FudiTypography.bodyLarge.copyWith(
                    color: FudiColors.mutedForeground,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 80),
                LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth > 900) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _ContactForm()),
                          const SizedBox(width: 80),
                          SizedBox(width: 400, child: _ContactInfo()),
                        ],
                      );
                    }
                    return Column(
                      children: [
                        _ContactForm(),
                        const SizedBox(height: 80),
                        _ContactInfo(),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ContactForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _ContactField(label: 'Nombre', hint: 'Tu nombre completo'),
        const SizedBox(height: 24),
        const _ContactField(label: 'Email', hint: 'tu@email.com'),
        const SizedBox(height: 24),
        const _ContactField(label: 'Asunto', hint: '¿En qué podemos ayudarte?'),
        const SizedBox(height: 24),
        const _ContactField(
          label: 'Mensaje',
          hint: 'Escribe tu mensaje aquí...',
          maxLines: 5,
        ),
        const SizedBox(height: 40),
        FudiPressableScale(
          onTap: () {},
          child: Container(
            width: 200,
            height: 56,
            decoration: BoxDecoration(
              color: FudiColors.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(child: Text('Enviar mensaje', style: TextStyle(color: Colors.white))),
          ),
        ),
      ],
    );
  }
}

class _ContactField extends StatelessWidget {
  const _ContactField({
    required this.label,
    required this.hint,
    this.maxLines = 1,
  });
  final String label;
  final String hint;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 12),
        TextField(
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: FudiColors.mutedForeground.withValues(alpha: 0.5),
            ),
            filled: true,
            fillColor: const Color(0xFFF8F9FA),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.all(20),
          ),
        ),
      ],
    );
  }
}

class _ContactInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Información de contacto',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        const SizedBox(height: 40),
        const _ContactInfoItem(
          icon: Icons.email_outlined,
          title: 'Email',
          value: 'hola@fudi.app',
        ),
        const SizedBox(height: 32),
        const _ContactInfoItem(
          icon: Icons.phone_outlined,
          title: 'Teléfono',
          value: '+34 900 123 456',
        ),
        const SizedBox(height: 32),
        const _ContactInfoItem(
          icon: Icons.location_on_outlined,
          title: 'Oficina',
          value: 'Carrer de la Pau, 10\n08002 Barcelona, España',
        ),
      ],
    );
  }
}

class _ContactInfoItem extends StatelessWidget {
  const _ContactInfoItem({
    required this.icon,
    required this.title,
    required this.value,
  });
  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: FudiColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: FudiColors.primary, size: 24),
        ),
        const SizedBox(width: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(color: FudiColors.mutedForeground, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                height: 1.4,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
