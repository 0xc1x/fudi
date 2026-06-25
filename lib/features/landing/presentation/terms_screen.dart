import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/route_names.dart';
import '../../../core/ui/fudi_colors.dart';
import '../../../core/ui/fudi_spacing.dart';
import '../../../core/ui/fudi_pressable_scale.dart';
import '../../../core/ui/fudi_typography.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: FudiPressableScale(
          onTap: () => context.go(RouteNames.landingPath),
          child: Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(color: Colors.transparent, shape: BoxShape.circle),
            child: const Icon(Icons.chevron_left, color: Colors.black),
          ),
        ),
        title: const Text(
          'Términos de Uso',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(FudiSpacing.md),
        child: Container(
          padding: const EdgeInsets.all(FudiSpacing.xl),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: FudiColors.muted.withValues(alpha: 0.5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Última actualización: 19 de abril de 2026',
                style: FudiTypography.bodySmall.copyWith(
                  color: FudiColors.mutedForeground,
                ),
              ),
              const SizedBox(height: FudiSpacing.xl),
              const _TermsSection(
                title: '1. Aceptación de los términos',
                content:
                    'Al acceder y utilizar Fudi, aceptas estar sujeto a estos términos y condiciones. Si no estás de acuerdo con alguna parte de estos términos, no podrás utilizar nuestro servicio.',
              ),
              const _TermsSection(
                title: '2. Descripción del servicio',
                content:
                    'Fudi es una plataforma que conecta a usuarios con establecimientos comerciales para la compra de excedentes de comida a precios reducidos. El servicio es de solo recogida (pickup-only).',
              ),
              const _TermsSection(
                title: '3. Registro de cuenta',
                content:
                    'Para utilizar ciertas funciones, debes registrarte y crear una cuenta. Eres responsable de mantener la confidencialidad de tu cuenta y contraseña.',
              ),
              const _TermsSection(
                title: '4. Pedidos y pagos',
                content:
                    'Los pedidos se realizan a través de la aplicación y deben ser pagados en el momento de la reserva. El comercio es responsable de la calidad de los productos entregados.',
              ),
              const _TermsSection(
                title: '5. Cancelaciones y reembolsos',
                content:
                    'Puedes cancelar tu pedido hasta 2 horas antes del horario de recogida para obtener un reembolso completo. Pasado ese tiempo, no se aceptarán cancelaciones.',
              ),
              const _TermsSection(
                title: '6. Responsabilidades del usuario',
                content:
                    'Te comprometes a recoger tu pedido en la ventana de tiempo indicada. Si no recoges tu pedido, no tendrás derecho a reembolso.',
              ),
              const _TermsSection(
                title: '7. Limitación de responsabilidad',
                content:
                    'Fudi no se hace responsable de la calidad, seguridad o legalidad de los alimentos proporcionados por los comercios.',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TermsSection extends StatelessWidget {
  const _TermsSection({required this.title, required this.content});
  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: FudiSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: FudiSpacing.sm),
          Text(
            content,
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
