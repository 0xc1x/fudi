import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/routing/route_names.dart';
import '../../../core/ui/fudi_colors.dart';
import '../../../core/ui/fudi_spacing.dart';
import '../../../core/ui/fudi_typography.dart';
import '../../../core/ui/fudi_sticky_page_header.dart';
import '../../../core/ui/fudi_surface_card.dart';

class ForBusinessScreen extends StatelessWidget {
  const ForBusinessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const FudiStickyPageHeader(title: 'Fudi para Negocios'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(FudiSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Convierte tu merma en ingresos', style: FudiTypography.h1),
            const SizedBox(height: FudiSpacing.md),
            Text(
              'Únete a los cientos de negocios que ya están reduciendo su desperdicio de comida y llegando a nuevos clientes con Fudi.',
              style: FudiTypography.bodyLarge,
            ),
            const SizedBox(height: FudiSpacing.xl),
            const _BusinessBenefit(
              title: 'Reduce el desperdicio',
              description: 'Vende los excedentes que de otro modo tendrías que tirar al final del día.',
              icon: Icons.delete_sweep_outlined,
            ),
            const _BusinessBenefit(
              title: 'Atrae nuevos clientes',
              description: 'Los usuarios que rescatan tu comida a menudo vuelven como clientes regulares.',
              icon: Icons.groups_outlined,
            ),
            const _BusinessBenefit(
              title: 'Gestión sencilla',
              description: 'Publica ofertas en segundos y gestiona tus pedidos desde un dashboard intuitivo.',
              icon: Icons.speed_outlined,
            ),
            const SizedBox(height: FudiSpacing.xl),
            FudiSurfaceCard(
              child: Padding(
                padding: const EdgeInsets.all(FudiSpacing.lg),
                child: Column(
                  children: [
                    Text('¿Listo para empezar?', style: FudiTypography.h2),
                    const SizedBox(height: FudiSpacing.md),
                    Text(
                      'El registro es gratuito y solo cobramos una pequeña comisión por cada venta realizada.',
                      textAlign: TextAlign.center,
                      style: FudiTypography.bodyMedium,
                    ),
                    const SizedBox(height: FudiSpacing.lg),
                    FilledButton(
                      onPressed: () => context.go(RouteNames.signupPath),
                      style: FilledButton.styleFrom(
                        backgroundColor: FudiColors.primary,
                        minimumSize: const Size.fromHeight(56),
                      ),
                      child: const Text('Registrar mi negocio ahora'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BusinessBenefit extends StatelessWidget {
  const _BusinessBenefit({
    required this.title,
    required this.description,
    required this.icon,
  });

  final String title;
  final String description;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: FudiSpacing.lg),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(FudiSpacing.md),
            decoration: BoxDecoration(
              color: FudiColors.secondary,
              borderRadius: BorderRadius.circular(FudiRadius.md),
            ),
            child: Icon(icon, color: FudiColors.primary),
          ),
          const SizedBox(width: FudiSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: FudiTypography.labelMedium),
                Text(description, style: FudiTypography.bodySmall.copyWith(color: FudiColors.mutedForeground)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
