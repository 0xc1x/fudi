import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/route_names.dart';
import '../../../core/ui/fudi_colors.dart';
import '../../../core/ui/fudi_logo.dart';
import '../../../core/ui/fudi_spacing.dart';
import '../../../core/ui/fudi_typography.dart';

class HowItWorksScreen extends StatelessWidget {
  const HowItWorksScreen({super.key});

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
            const _Steps(),
            const _FAQ(),
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
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: FudiSpacing.xl),
      child: Column(
        children: [
          Text(
            '¿Cómo funciona Fudi?',
            textAlign: TextAlign.center,
            style: FudiTypography.h1.copyWith(fontSize: 48),
          ),
          const SizedBox(height: 24),
          Text(
            'Rescatar comida es fácil. Solo tres pasos te separan de deliciosas ofertas.',
            textAlign: TextAlign.center,
            style: FudiTypography.bodyLarge.copyWith(color: FudiColors.mutedForeground, fontSize: 20),
          ),
        ],
      ),
    );
  }
}

class _Steps extends StatelessWidget {
  const _Steps();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 100, horizontal: FudiSpacing.xl),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Column(
            children: [
              _StepRow(
                number: '1',
                title: 'Explora ofertas',
                description: 'Busca restaurantes, panaderías y supermercados cerca de ti que tengan bolsas sorpresa disponibles. Filtra por categoría, distancia y horario de recogida.',
                details: const [
                  'Usa el mapa para ver ofertas cercanas',
                  'Filtra por tipo de comida y precio',
                  'Lee las reseñas de otros usuarios',
                  'Consulta el horario de recogida'
                ],
                emoji: '🔍',
                isReversed: false,
              ),
              const SizedBox(height: 100),
              _StepRow(
                number: '2',
                title: 'Reserva y paga',
                description: 'Selecciona la bolsa sorpresa que más te guste y paga de forma segura desde la app. Tu reserva quedará confirmada al instante.',
                details: const [
                  'Pago seguro con tarjeta o PayPal',
                  'Confirmación instantánea',
                  'Recibe un código QR para la recogida',
                  'Cancela gratis hasta 2 horas antes'
                ],
                emoji: '💳',
                isReversed: true,
              ),
              const SizedBox(height: 100),
              _StepRow(
                number: '3',
                title: 'Recoge y disfruta',
                description: 'Ve al comercio en el horario indicado, muestra tu código QR y recoge tu bolsa sorpresa. ¡Así de fácil!',
                details: const [
                  'Muestra tu código QR en el comercio',
                  'Recoge tu pedido en minutos',
                  'Descubre qué sorpresas hay dentro',
                  'Disfruta de comida de calidad a precio reducido'
                ],
                emoji: '🎁',
                isReversed: false,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({
    required this.number,
    required this.title,
    required this.description,
    required this.details,
    required this.emoji,
    required this.isReversed,
  });

  final String number;
  final String title;
  final String description;
  final List<String> details;
  final String emoji;
  final bool isReversed;

  @override
  Widget build(BuildContext context) {
    final content = Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: FudiColors.secondary.withValues(alpha: 0.3), shape: BoxShape.circle),
            child: Text(emoji, style: const TextStyle(fontSize: 32)),
          ),
          const SizedBox(height: 24),
          Text('Paso $number', style: const TextStyle(color: FudiColors.primary, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          Text(title, style: FudiTypography.h2.copyWith(fontSize: 32)),
          const SizedBox(height: 16),
          Text(description, style: FudiTypography.bodyLarge.copyWith(color: FudiColors.mutedForeground, height: 1.5)),
          const SizedBox(height: 24),
          ...details.map((detail) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: FudiColors.primary, shape: BoxShape.circle),
                      child: const Icon(Icons.check, color: Colors.white, size: 12),
                    ),
                    const SizedBox(width: 12),
                    Text(detail, style: FudiTypography.bodyMedium.copyWith(color: FudiColors.mutedForeground)),
                  ],
                ),
              )),
        ],
      ),
    );

    final image = Expanded(
      child: Container(
        height: 400,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [FudiColors.secondary.withValues(alpha: 0.2), FudiColors.primary.withValues(alpha: 0.1)],
          ),
          borderRadius: BorderRadius.circular(40),
        ),
        child: Center(child: Text(emoji, style: const TextStyle(fontSize: 120))),
      ),
    );

    return Row(
      children: isReversed ? [image, const SizedBox(width: 80), content] : [content, const SizedBox(width: 80), image],
    );
  }
}

class _FAQ extends StatelessWidget {
  const _FAQ();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF8F9FA),
      padding: const EdgeInsets.symmetric(vertical: 100, horizontal: FudiSpacing.xl),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            children: [
              const Text('Preguntas comunes', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
              const SizedBox(height: 48),
              _FAQCard(
                title: '¿Qué es una bolsa sorpresa?',
                content: 'Una bolsa sorpresa es una selección de productos que el comercio prepara con los excedentes del día. El contenido es sorpresa, pero siempre vale más del triple de lo que pagas.',
              ),
              _FAQCard(
                title: '¿Puedo elegir qué viene en mi bolsa?',
                content: 'No, el contenido es sorpresa. Sin embargo, puedes ver la categoría del comercio y algunos ejemplos de productos que suelen incluir.',
              ),
              _FAQCard(
                title: '¿Qué pasa si no puedo recoger mi pedido?',
                content: 'Puedes cancelar tu reserva hasta 2 horas antes del horario de recogida sin ningún cargo. Después de ese tiempo, no podrás obtener un reembolso.',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FAQCard extends StatelessWidget {
  const _FAQCard({required this.title, required this.content});
  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: FudiColors.muted.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text(content, style: FudiTypography.bodyMedium.copyWith(color: FudiColors.mutedForeground, height: 1.5)),
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
        gradient: LinearGradient(colors: [FudiColors.primary, Color(0xFF2E7D32)]),
      ),
      padding: const EdgeInsets.symmetric(vertical: 100, horizontal: FudiSpacing.xl),
      child: Column(
        children: [
          const Text(
            '¿Listo para empezar?',
            style: TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          const Text(
            'Descarga Fudi y comienza a ahorrar hoy mismo',
            style: TextStyle(color: Colors.white70, fontSize: 20),
          ),
          const SizedBox(height: 48),
          FilledButton(
            onPressed: () => context.go(RouteNames.signupPath),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: FudiColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            child: const Text('Crear cuenta gratis'),
          ),
        ],
      ),
    );
  }
}
