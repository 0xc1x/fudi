import 'package:flutter/material.dart';

import '../../../core/ui/fudi_colors.dart';
import '../../../core/ui/fudi_icons.dart';
import '../../../core/ui/fudi_spacing.dart';
import '../../../core/ui/fudi_sticky_page_header.dart';
import '../../../core/ui/fudi_surface_card.dart';
import '../../../core/ui/fudi_typography.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  static const _faqCategories = [
    (
      title: 'Sobre Fudi',
      questions: [
        '¿Cómo funciona Fudi?',
        '¿Qué es una bolsa sorpresa?',
        '¿Cómo ayuda Fudi al medio ambiente?',
      ],
    ),
    (
      title: 'Pedidos y recogidas',
      questions: [
        '¿Cómo hago un pedido?',
        '¿Puedo cancelar un pedido?',
        '¿Qué pasa si llego tarde a la recogida?',
        '¿Qué hago si no estoy satisfecho?',
      ],
    ),
    (
      title: 'Pagos',
      questions: [
        '¿Qué métodos de pago aceptan?',
        '¿Cuándo se cobra el pedido?',
        '¿Puedo obtener un reembolso?',
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const FudiStickyPageHeader(title: 'Centro de ayuda'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(FudiSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Contacta con nosotros', style: FudiTypography.labelMedium),
            const SizedBox(height: FudiSpacing.md),
            FudiSurfaceCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _ContactOption(
                    icon: FudiIcons.messageSquare,
                    label: 'Chat en vivo',
                    onTap: () {},
                  ),
                  const Divider(height: 1, indent: FudiSpacing.xxl),
                  _ContactOption(
                    icon: FudiIcons.mail,
                    label: 'Email',
                    onTap: () {},
                  ),
                  const Divider(height: 1, indent: FudiSpacing.xxl),
                  _ContactOption(
                    icon: FudiIcons.phone,
                    label: 'Teléfono',
                    onTap: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: FudiSpacing.xl),
            ...List.generate(_faqCategories.length, (i) {
              final category = _faqCategories[i];
              return Padding(
                padding: EdgeInsets.only(
                  bottom: i < _faqCategories.length - 1
                      ? FudiSpacing.xl
                      : FudiSpacing.xxl,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(category.title, style: FudiTypography.labelMedium),
                    const SizedBox(height: FudiSpacing.md),
                    FudiSurfaceCard(
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: List.generate(
                          category.questions.length,
                          (qIdx) => Column(
                            children: [
                              _FAQQuestion(question: category.questions[qIdx]),
                              if (qIdx < category.questions.length - 1)
                                const Divider(height: 1, indent: FudiSpacing.xxl),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _ContactOption extends StatelessWidget {
  const _ContactOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(FudiRadius.xl),
      child: Padding(
        padding: const EdgeInsets.all(FudiSpacing.lg),
        child: Row(
          children: [
            Icon(icon, size: 20, color: FudiColors.primary),
            const SizedBox(width: FudiSpacing.md),
            Expanded(
              child: Text(label, style: FudiTypography.labelSmall),
            ),
            const Icon(
              FudiIcons.chevronRight,
              size: 20,
              color: FudiColors.mutedForeground,
            ),
          ],
        ),
      ),
    );
  }
}

class _FAQQuestion extends StatelessWidget {
  const _FAQQuestion({required this.question});

  final String question;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(FudiRadius.xl),
      child: Padding(
        padding: const EdgeInsets.all(FudiSpacing.lg),
        child: Row(
          children: [
            Expanded(
              child: Text(question, style: FudiTypography.labelSmall),
            ),
            const Icon(
              FudiIcons.chevronRight,
              size: 20,
              color: FudiColors.mutedForeground,
            ),
          ],
        ),
      ),
    );
  }
}
