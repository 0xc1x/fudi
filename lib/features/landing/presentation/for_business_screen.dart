import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/route_names.dart';
import '../../../core/ui/fudi_colors.dart';
import '../../../core/ui/fudi_logo.dart';
import '../../../core/ui/fudi_spacing.dart';
import '../../../core/ui/fudi_typography.dart';

class ForBusinessScreen extends StatelessWidget {
  const ForBusinessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: FudiColors.muted.withValues(alpha: 0.5),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black, size: 20),
              onPressed: () => context.go(RouteNames.landingPath),
            ),
          ),
        ),
        title: const FudiLogo(size: FudiLogoSize.md),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const _Hero(),
            const _Benefits(),
            const _HowItWorksForBusiness(),
            const _CTA(),
          ],
        ),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            FudiColors.secondary.withValues(alpha: 0.3),
            FudiColors.secondary.withValues(alpha: 0.1),
            FudiColors.primary.withValues(alpha: 0.1),
          ],
        ),
      ),
      padding: const EdgeInsets.symmetric(
        vertical: 80,
        horizontal: FudiSpacing.xl,
      ),
      child: Column(
        children: [
          Text(
            'Fudi para negocios',
            textAlign: TextAlign.center,
            style: FudiTypography.h1.copyWith(fontSize: 48),
          ),
          const SizedBox(height: 24),
          Text(
            'Únete a más de 2,000 comercios que ya están reduciendo el desperdicio y aumentando sus ingresos',
            textAlign: TextAlign.center,
            style: FudiTypography.bodyLarge.copyWith(
              color: FudiColors.mutedForeground,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 48),
          FilledButton(
            onPressed: () => context.go(RouteNames.signupPath),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              textStyle: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            child: const Text('Registrar mi negocio'),
          ),
        ],
      ),
    );
  }
}

class _Benefits extends StatelessWidget {
  const _Benefits();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 100,
        horizontal: FudiSpacing.xl,
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              const Text(
                '¿Por qué usar Fudi?',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 64),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: MediaQuery.of(context).size.width > 900
                    ? 4
                    : (MediaQuery.of(context).size.width > 600 ? 2 : 1),
                mainAxisSpacing: 32,
                crossAxisSpacing: 32,
                childAspectRatio: 0.8,
                children: const [
                  _BenefitCard(
                    icon: Icons.trending_up,
                    title: 'Reduce pérdidas',
                    description:
                        'Convierte excedentes en ingresos en lugar de desperdiciarlos',
                  ),
                  _BenefitCard(
                    icon: Icons.people_outline,
                    title: 'Nuevos clientes',
                    description:
                        'Atrae clientes que pueden convertirse en habituales',
                  ),
                  _BenefitCard(
                    icon: Icons.bar_chart,
                    title: 'Impacto medible',
                    description:
                        'Estadísticas detalladas sobre tus ventas y ahorro',
                  ),
                  _BenefitCard(
                    icon: Icons.access_time,
                    title: 'Gestión fácil',
                    description:
                        'Panel intuitivo para gestionar tus ofertas en minutos',
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

class _BenefitCard extends StatelessWidget {
  const _BenefitCard({
    required this.icon,
    required this.title,
    required this.description,
  });
  final IconData icon;
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
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: FudiColors.secondary.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: FudiColors.primary, size: 32),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: FudiTypography.bodyMedium.copyWith(
              color: FudiColors.mutedForeground,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _HowItWorksForBusiness extends StatelessWidget {
  const _HowItWorksForBusiness();

  @override
  Widget build(BuildContext context) {
    return Container(
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
              const Text(
                'Cómo funciona para tu negocio',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 64),
              _BusinessStep(
                number: '1',
                title: 'Regístrate gratis',
                description: 'Crea tu perfil de negocio en menos de 5 minutos',
              ),
              _BusinessStep(
                number: '2',
                title: 'Publica tus ofertas',
                description:
                    'Define qué productos ofreces y a qué precio cada día',
              ),
              _BusinessStep(
                number: '3',
                title: 'Recibe pedidos',
                description:
                    'Los usuarios reservan y pagan directamente en la app',
              ),
              _BusinessStep(
                number: '4',
                title: 'Entrega y cobra',
                description:
                    'Prepara los pedidos y recibe el pago en tu cuenta',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BusinessStep extends StatelessWidget {
  const _BusinessStep({
    required this.number,
    required this.title,
    required this.description,
  });
  final String number;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: FudiColors.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: FudiTypography.bodyLarge.copyWith(
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

class _CTA extends StatelessWidget {
  const _CTA();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [FudiColors.primary, Color(0xFF2E7D32)],
        ),
      ),
      padding: const EdgeInsets.symmetric(
        vertical: 100,
        horizontal: FudiSpacing.xl,
      ),
      child: Column(
        children: [
          const Text(
            '¿Listo para unirte?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 40,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Únete a Fudi y empieza a reducir el desperdicio hoy mismo',
            style: TextStyle(color: Colors.white70, fontSize: 20),
          ),
          const SizedBox(height: 48),
          FilledButton(
            onPressed: () => context.go(RouteNames.signupPath),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: FudiColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              textStyle: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            child: const Text('Registrar mi negocio'),
          ),
        ],
      ),
    );
  }
}
