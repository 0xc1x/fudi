import 'package:flutter/material.dart';
import '../../../core/ui/fudi_spacing.dart';
import '../../../core/ui/fudi_typography.dart';
import '../../../core/ui/fudi_sticky_page_header.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: FudiStickyPageHeader(title: 'Política de Privacidad'),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(FudiSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Section(
              title: '1. Recolección de datos',
              content: 'Recopilamos información básica como tu nombre, correo electrónico y ubicación para brindarte el mejor servicio.',
            ),
            _Section(
              title: '2. Uso de la información',
              content: 'Usamos tus datos para procesar pedidos, enviarte notificaciones sobre ofertas cercanas y mejorar nuestra plataforma.',
            ),
            _Section(
              title: '3. Protección de datos',
              content: 'Implementamos medidas de seguridad avanzadas para proteger tu información contra accesos no autorizados.',
            ),
            _Section(
              title: '4. Tus derechos',
              content: 'Puedes solicitar el acceso, corrección o eliminación de tus datos personales en cualquier momento desde la configuración de tu perfil.',
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.content});

  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: FudiSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: FudiTypography.labelMedium),
          const SizedBox(height: FudiSpacing.sm),
          Text(content, style: FudiTypography.bodyMedium),
        ],
      ),
    );
  }
}
