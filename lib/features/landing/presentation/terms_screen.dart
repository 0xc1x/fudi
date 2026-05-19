import 'package:flutter/material.dart';
import '../../../core/ui/fudi_spacing.dart';
import '../../../core/ui/fudi_typography.dart';
import '../../../core/ui/fudi_sticky_page_header.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: FudiStickyPageHeader(title: 'Términos y Condiciones'),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(FudiSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Section(
              title: '1. Aceptación de los términos',
              content: 'Al descargar y usar Fudi, aceptas cumplir con estos términos y condiciones. Si no estás de acuerdo, por favor no uses la aplicación.',
            ),
            _Section(
              title: '2. Uso de la plataforma',
              content: 'Fudi es una plataforma que conecta usuarios con negocios. No somos responsables de la calidad de la comida, que es responsabilidad exclusiva del establecimiento.',
            ),
            _Section(
              title: '3. Pagos y reembolsos',
              content: 'Los pagos se realizan a través de pasarelas de terceros. Los reembolsos solo aplican en casos de cancelación por parte del negocio o falta de stock.',
            ),
            _Section(
              title: '4. Propiedad intelectual',
              content: 'Todo el contenido de Fudi, incluyendo logos y diseños, está protegido por leyes de propiedad intelectual.',
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
