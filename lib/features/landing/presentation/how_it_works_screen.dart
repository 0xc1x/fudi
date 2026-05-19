import 'package:flutter/material.dart';
import '../../../core/ui/fudi_colors.dart';
import '../../../core/ui/fudi_spacing.dart';
import '../../../core/ui/fudi_typography.dart';
import '../../../core/ui/fudi_sticky_page_header.dart';

class HowItWorksScreen extends StatelessWidget {
  const HowItWorksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const FudiStickyPageHeader(title: 'Cómo funciona'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(FudiSpacing.xl),
        child: Column(
          children: [
            _Step(
              number: '1',
              title: 'Explora y elige',
              description: 'Busca ofertas cercanas en tu mapa. Cada día, los negocios publican sus excedentes a precios reducidos.',
              icon: Icons.search_rounded,
            ),
            _Step(
              number: '2',
              title: 'Reserva tu paquete',
              description: 'Realiza el pago de forma segura a través de la app para asegurar tu paquete sorpresa.',
              icon: Icons.touch_app_rounded,
            ),
            _Step(
              number: '3',
              title: 'Recoge en el local',
              description: 'Ve al establecimiento durante la ventana de tiempo indicada y muestra tu código de recogida.',
              icon: Icons.directions_run_rounded,
            ),
            _Step(
              number: '4',
              title: 'Disfruta y ayuda',
              description: 'Disfruta de comida deliciosa mientras reduces el desperdicio y ayudas al planeta.',
              icon: Icons.sentiment_very_satisfied_rounded,
            ),
          ],
        ),
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({
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
      padding: const EdgeInsets.only(bottom: FudiSpacing.xxl),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              color: FudiColors.secondary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(icon, size: 40, color: FudiColors.primary),
            ),
          ),
          const SizedBox(height: FudiSpacing.md),
          Text('PASO $number', style: FudiTypography.bodySmall.copyWith(color: FudiColors.primary, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
          const SizedBox(height: FudiSpacing.xs),
          Text(title, style: FudiTypography.h2),
          const SizedBox(height: FudiSpacing.sm),
          Text(
            description,
            textAlign: TextAlign.center,
            style: FudiTypography.bodyLarge.copyWith(color: FudiColors.mutedForeground),
          ),
        ],
      ),
    );
  }
}
