import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/route_names.dart';
import '../../../core/ui/fudi_colors.dart';
import '../../../core/ui/fudi_logo.dart';
import '../../../core/ui/fudi_spacing.dart';
import '../../../core/ui/fudi_typography.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _SliverHero(),
          _SliverHowItWorks(),
          _SliverBenefits(),
          _SliverCTA(),
          const SliverToBoxAdapter(child: SizedBox(height: FudiSpacing.xxl)),
        ],
      ),
    );
  }
}

class _SliverHero extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 400,
      pinned: true,
      backgroundColor: FudiColors.primary,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          color: FudiColors.primary,
          child: Stack(
            children: [
              // Placeholder for a nice background image
              Positioned.fill(
                child: Opacity(
                  opacity: 0.2,
                  child: Image.network(
                    'https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&q=80',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(FudiSpacing.xl),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const FudiLogo(variant: FudiLogoVariant.white, size: FudiLogoSize.lg),
                      const SizedBox(height: FudiSpacing.lg),
                      Text(
                        'Rescata comida,\nahorra dinero.',
                        style: FudiTypography.h1.copyWith(
                          color: Colors.white,
                          fontSize: 32,
                        ),
                      ),
                      const SizedBox(height: FudiSpacing.md),
                      Text(
                        'Descubre paquetes de comida con descuento en tus negocios favoritos.',
                        style: FudiTypography.bodyLarge.copyWith(
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                      const SizedBox(height: FudiSpacing.xl),
                      FilledButton(
                        onPressed: () => context.go(RouteNames.homePath),
                        style: FilledButton.styleFrom(
                          backgroundColor: FudiColors.ring,
                          foregroundColor: FudiColors.primary,
                          minimumSize: const Size(200, 56),
                        ),
                        child: const Text('Empezar a rescatar'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SliverHowItWorks extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(FudiSpacing.xl),
        child: Column(
          children: [
            Text('¿Cómo funciona?', style: FudiTypography.h2),
            const SizedBox(height: FudiSpacing.xl),
            _StepItem(
              number: '1',
              title: 'Explora',
              description: 'Busca ofertas cerca de ti en el mapa o en la lista.',
              icon: Icons.map_outlined,
            ),
            _StepItem(
              number: '2',
              title: 'Reserva',
              description: 'Elige tu paquete favorito y págalo de forma segura.',
              icon: Icons.shopping_bag_outlined,
            ),
            _StepItem(
              number: '3',
              title: 'Recoge',
              description: 'Ve al local en la ventana de tiempo y disfruta.',
              icon: Icons.store_outlined,
            ),
          ],
        ),
      ),
    );
  }
}

class _StepItem extends StatelessWidget {
  const _StepItem({
    required this.number,
    required this.title,
    required this.description,
    required this.icon,
  });

  final String number;
  final String title;
  final String description;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: FudiSpacing.xl),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: FudiColors.secondary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(icon, color: FudiColors.primary),
            ),
          ),
          const SizedBox(width: FudiSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$number. $title',
                  style: FudiTypography.labelMedium,
                ),
                Text(
                  description,
                  style: FudiTypography.bodyMedium.copyWith(
                    color: FudiColors.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SliverBenefits extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        color: FudiColors.muted,
        padding: const EdgeInsets.all(FudiSpacing.xl),
        child: Column(
          children: [
            Text('Beneficios', style: FudiTypography.h2),
            const SizedBox(height: FudiSpacing.xl),
            _BenefitCard(
              title: 'Para Usuarios',
              items: [
                'Comida de calidad a mitad de precio',
                'Descubre nuevos lugares',
                'Ayuda al medio ambiente',
              ],
              icon: Icons.person_outline,
            ),
            const SizedBox(height: FudiSpacing.lg),
            _BenefitCard(
              title: 'Para Negocios',
              items: [
                'Reduce el desperdicio de comida',
                'Llega a nuevos clientes',
                'Recupera costos de producción',
              ],
              icon: Icons.business_outlined,
              isPrimary: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _BenefitCard extends StatelessWidget {
  const _BenefitCard({
    required this.title,
    required this.items,
    required this.icon,
    this.isPrimary = false,
  });

  final String title;
  final List<String> items;
  final IconData icon;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(FudiSpacing.lg),
      decoration: BoxDecoration(
        color: isPrimary ? FudiColors.primary : Colors.white,
        borderRadius: BorderRadius.circular(FudiRadius.xl),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: isPrimary ? Colors.white : FudiColors.primary,
              ),
              const SizedBox(width: FudiSpacing.sm),
              Text(
                title,
                style: FudiTypography.labelMedium.copyWith(
                  color: isPrimary ? Colors.white : FudiColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: FudiSpacing.md),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 16,
                  color: isPrimary ? FudiColors.ring : FudiColors.success,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item,
                    style: FudiTypography.bodySmall.copyWith(
                      color: isPrimary ? Colors.white.withValues(alpha: 0.9) : FudiColors.foreground,
                    ),
                  ),
                ),
              ],
            ),
          )),
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
        padding: const EdgeInsets.all(FudiSpacing.xl),
        child: Container(
          padding: const EdgeInsets.all(FudiSpacing.xl),
          decoration: BoxDecoration(
            color: FudiColors.ring,
            borderRadius: BorderRadius.circular(FudiRadius.xxl),
          ),
          child: Column(
            children: [
              Text(
                '¿Tienes un negocio?',
                style: FudiTypography.h2.copyWith(color: FudiColors.primary),
              ),
              const SizedBox(height: FudiSpacing.sm),
              Text(
                'Únete a la red de rescatistas de comida y empieza a monetizar tus excedentes.',
                textAlign: TextAlign.center,
                style: FudiTypography.bodyMedium.copyWith(
                  color: FudiColors.primary.withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(height: FudiSpacing.lg),
              FilledButton(
                onPressed: () => context.go(RouteNames.signupPath),
                style: FilledButton.styleFrom(
                  backgroundColor: FudiColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(200, 56),
                ),
                child: const Text('Registrar mi negocio'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
