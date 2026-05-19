import 'package:flutter/material.dart';
import '../../../core/ui/fudi_colors.dart';
import '../../../core/ui/fudi_spacing.dart';
import '../../../core/ui/fudi_typography.dart';
import '../../../core/ui/fudi_sticky_page_header.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const FudiStickyPageHeader(title: 'Sobre Fudi'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(FudiSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(
                  color: FudiColors.secondary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.eco_outlined, size: 64, color: FudiColors.primary),
              ),
            ),
            const SizedBox(height: FudiSpacing.xl),
            Text('Nuestra Misión', style: FudiTypography.h2),
            const SizedBox(height: FudiSpacing.md),
            Text(
              'En Fudi, creemos que ninguna comida deliciosa debería desperdiciarse. Nuestra misión es conectar a personas con negocios locales para rescatar excedentes de comida de alta calidad a precios increíbles.',
              style: FudiTypography.bodyLarge,
            ),
            const SizedBox(height: FudiSpacing.xl),
            Text('El Problema', style: FudiTypography.h2),
            const SizedBox(height: FudiSpacing.md),
            Text(
              'Cada año, un tercio de toda la comida producida en el mundo se desperdicia. Esto no solo es una pérdida de recursos, sino que también tiene un impacto devastador en nuestro planeta.',
              style: FudiTypography.bodyLarge,
            ),
            const SizedBox(height: FudiSpacing.xl),
            Text('Nuestra Solución', style: FudiTypography.h2),
            const SizedBox(height: FudiSpacing.md),
            Text(
              'Creamos una plataforma donde los negocios pueden publicar paquetes sorpresa con sus excedentes del día y los usuarios pueden comprarlos con un descuento significativo. Es una situación donde todos ganan: el negocio, el usuario y el planeta.',
              style: FudiTypography.bodyLarge,
            ),
            const SizedBox(height: FudiSpacing.xxl),
            const Divider(),
            const SizedBox(height: FudiSpacing.xl),
            Text(
              'Fudi v1.0.0\nHecho con ❤️ para el planeta.',
              textAlign: TextAlign.center,
              style: FudiTypography.bodySmall.copyWith(color: FudiColors.mutedForeground),
            ),
          ],
        ),
      ),
    );
  }
}
