import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/route_names.dart';
import '../../../core/ui/fudi_colors.dart';
import '../../../core/ui/fudi_spacing.dart';


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
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.black),
          onPressed: () => context.go(RouteNames.landingPath),
        ),
        title: Row(
          children: [
            const Icon(Icons.help_outline, color: FudiColors.primary, size: 20),
            const SizedBox(width: 8),
            const Text('Centro de ayuda', style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(FudiSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Contacta con nosotros', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _ContactButton(icon: Icons.chat_bubble_outline, label: 'Chat en vivo', onTap: () {}),
            _ContactButton(icon: Icons.mail_outline, label: 'Email', onTap: () {}),
            _ContactButton(icon: Icons.phone_outlined, label: 'Teléfono', onTap: () {}),
            const SizedBox(height: 32),
            ..._faqCategories.map((category) => _FAQCategory(category: category)),
          ],
        ),
      ),
    );
  }
}

class _ContactButton extends StatelessWidget {
  const _ContactButton({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: FudiColors.muted.withValues(alpha: 0.5)),
            ),
            child: Row(
              children: [
                Icon(icon, color: FudiColors.primary, size: 24),
                const SizedBox(width: 16),
                Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const Spacer(),
                const Icon(Icons.chevron_right, color: FudiColors.mutedForeground),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FAQCategory extends StatelessWidget {
  const _FAQCategory({required this.category});
  final ({String title, List<String> questions}) category;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(category.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: FudiColors.muted.withValues(alpha: 0.5)),
            ),
            child: Column(
              children: List.generate(category.questions.length, (index) {
                final question = category.questions[index];
                return Column(
                  children: [
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      title: Text(question, style: const TextStyle(fontWeight: FontWeight.w500)),
                      trailing: const Icon(Icons.chevron_right, color: FudiColors.mutedForeground),
                      onTap: () {},
                    ),
                    if (index < category.questions.length - 1)
                      const SizedBox(height: 1, width: double.infinity),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
