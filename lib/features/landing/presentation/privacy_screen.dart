import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/route_names.dart';
import '../../../core/ui/fudi_colors.dart';
import '../../../core/ui/fudi_spacing.dart';
import '../../../core/ui/fudi_typography.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.black),
          onPressed: () => context.go(RouteNames.landingPath),
        ),
        title: const Text('Política de Privacidad', style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
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
                style: FudiTypography.bodySmall.copyWith(color: FudiColors.mutedForeground),
              ),
              const SizedBox(height: FudiSpacing.xl),
              const _PrivacySection(
                title: '1. Información que recopilamos',
                content: 'Recopilamos información que nos proporcionas directamente al registrarte, como tu nombre, correo electrónico y número de teléfono. También recopilamos información sobre tu ubicación cuando usas la aplicación para mostrarte ofertas cercanas.',
              ),
              const _PrivacySection(
                title: '2. Uso de la información',
                content: 'Utilizamos tu información para:\n• Proveer y mantener el servicio\n• Procesar tus pedidos y pagos\n• Enviarte notificaciones sobre tus pedidos\n• Mejorar nuestra plataforma y experiencia de usuario\n• Cumplir con obligaciones legales',
              ),
              const _PrivacySection(
                title: '3. Compartir información',
                content: 'Compartimos información limitada con los establecimientos comerciales para procesar tus pedidos. No vendemos tus datos personales a terceros.',
              ),
              const _PrivacySection(
                title: '4. Seguridad de los datos',
                content: 'Implementamos medidas de seguridad técnicas y organizativas para proteger tu información personal. Sin embargo, ninguna transmisión por internet es 100% segura.',
              ),
              const _PrivacySection(
                title: '5. Tus derechos',
                content: 'Tienes derecho a acceder, rectificar o eliminar tus datos personales. Puedes gestionar tus preferencias desde la configuración de tu cuenta.',
              ),
              const _PrivacySection(
                title: '6. Cookies',
                content: 'Utilizamos cookies y tecnologías similares para mejorar la navegación y entender cómo se usa nuestro servicio.',
              ),
              const _PrivacySection(
                title: '7. Cambios en la política',
                content: 'Podemos actualizar nuestra política de privacidad periódicamente. Te notificaremos sobre cambios significativos a través de la aplicación.',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PrivacySection extends StatelessWidget {
  const _PrivacySection({required this.title, required this.content});
  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: FudiSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: FudiSpacing.sm),
          Text(
            content,
            style: FudiTypography.bodyMedium.copyWith(color: FudiColors.mutedForeground, height: 1.5),
          ),
        ],
      ),
    );
  }
}
