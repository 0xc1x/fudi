import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/route_names.dart';
import '../../../core/ui/fudi_colors.dart';
import '../../../core/ui/atoms/icons/fudi_icons.dart';
import '../../../core/ui/fudi_spacing.dart';
import '../../../core/ui/fudi_surface_card.dart';
import '../../../core/ui/fudi_pressable_scale.dart';
import '../../../core/ui/fudi_typography.dart';

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String? _expandedFAQ;

  static const _faqItems = [
    _FAQItem(
      id: 'c1',
      question: '¿Cómo funciona Fudi?',
      answer:
          'Fudi conecta restaurantes y tiendas con excedente de comida con personas que quieren comprarla a precios reducidos. Encuentra ofertas cerca de ti, haz tu pedido y recógelo en el horario indicado.',
      category: 'about',
    ),
    _FAQItem(
      id: 'c2',
      question: '¿Qué es una bolsa sorpresa?',
      answer:
          'Una bolsa sorpresa es un paquete de comida que el negocio no pudo vender durante el día. El contenido varía según lo disponible, pero siempre vale más de lo que pagas.',
      category: 'about',
    ),
    _FAQItem(
      id: 'c3',
      question: '¿Cómo hago un pedido?',
      answer:
          'Busca ofertas en la app, selecciona la que te interese, elige la cantidad y confirma tu pedido. Recibirás un código de recogida para presentar en el local.',
      category: 'orders',
    ),
    _FAQItem(
      id: 'c4',
      question: '¿Puedo cancelar un pedido?',
      answer:
          'Puedes cancelar un pedido mientras no haya sido confirmado por el negocio. Una vez confirmado, no es posible cancelar ni obtener reembolso.',
      category: 'orders',
    ),
    _FAQItem(
      id: 'c5',
      question: '¿Qué pasa si llego tarde a la recogida?',
      answer:
          'Si llegas fuera del horario de recogida, el negocio puede negarse a entregarte el pedido. Te recomendamos llegar puntualmente. Si tienes un imprevisto, contacta al negocio directamente.',
      category: 'orders',
    ),
    _FAQItem(
      id: 'c6',
      question: '¿Qué métodos de pago aceptan?',
      answer:
          'Aceptamos tarjetas de crédito y débito principales. El pago se procesa de forma segura al momento de confirmar tu pedido.',
      category: 'payments',
    ),
    _FAQItem(
      id: 'c7',
      question: '¿Puedo obtener un reembolso?',
      answer:
          'Los reembolsos se procesan solo en casos excepcionales, como productos en mal estado o errores del negocio. Contacta a soporte dentro de las 24 horas posteriores a la recogida.',
      category: 'payments',
    ),
    _FAQItem(
      id: 'c8',
      question: '¿Cómo ayuda Fudi al medio ambiente?',
      answer:
          'Cada pedido en Fudi evita que comida perfectly good termine en la basura. Reducimos el desperdicio alimentario y las emisiones asociadas a la producción y transporte de alimentos que nadie consume.',
      category: 'about',
    ),
  ];

  List<_FAQItem> get _filteredFAQs {
    if (_searchQuery.isEmpty) return _faqItems;
    final q = _searchQuery.toLowerCase();
    return _faqItems
        .where(
          (f) =>
              f.question.toLowerCase().contains(q) ||
              f.answer.toLowerCase().contains(q),
        )
        .toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FudiColors.muted,
      appBar: _AppBar(),
      body: ListView(
        padding: const EdgeInsets.all(FudiSpacing.lg),
        children: [
          _SearchBar(
            controller: _searchController,
            onChanged: (v) => setState(() => _searchQuery = v),
          ),
          const SizedBox(height: FudiSpacing.lg),
          _QuickContact(),
          const SizedBox(height: FudiSpacing.lg),
          _CategoriesSection(),
          const SizedBox(height: FudiSpacing.lg),
          _FAQSection(
            items: _filteredFAQs,
            expandedId: _expandedFAQ,
            onToggle: (id) =>
                setState(() => _expandedFAQ = _expandedFAQ == id ? null : id),
          ),
          const SizedBox(height: FudiSpacing.lg),
          _ContactSupportCard(),
          const SizedBox(height: FudiSpacing.lg),
          _ScheduleInfo(),
        ],
      ),
    );
  }
}

class _AppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: Padding(
        padding: const EdgeInsets.only(left: FudiSpacing.sm),
        child: FudiPressableScale(
          onTap: () => context.go(RouteNames.profilePath),
          child: Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: FudiColors.muted,
              shape: BoxShape.circle,
            ),
            child: const Icon(FudiIcons.chevronLeft, size: 20),
          ),
        ),
      ),
      title: Row(
        children: [
          Icon(FudiIcons.helpCircle, size: 20, color: FudiColors.primary),
          const SizedBox(width: FudiSpacing.sm),
          Text('Centro de ayuda', style: FudiTypography.h4),
        ],
      ),
      backgroundColor: FudiColors.background,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 1,
      shadowColor: Colors.black12,
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.controller, required this.onChanged});
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'Buscar en ayuda...',
        prefixIcon: Icon(
          Icons.search_rounded,
          color: FudiColors.mutedForeground,
          size: 20,
        ),
        filled: true,
        fillColor: FudiColors.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(FudiRadius.xl),
          borderSide: BorderSide(color: FudiColors.borderSolid),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(FudiRadius.xl),
          borderSide: BorderSide(color: FudiColors.borderSolid),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(FudiRadius.xl),
          borderSide: BorderSide(color: FudiColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: FudiSpacing.lg,
          vertical: FudiSpacing.md,
        ),
      ),
    );
  }
}

class _QuickContact extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ContactChip(
            icon: FudiIcons.messageSquare,
            label: 'Chat',
            onTap: () {},
          ),
        ),
        const SizedBox(width: FudiSpacing.md),
        Expanded(
          child: _ContactChip(
            icon: FudiIcons.mail,
            label: 'Email',
            onTap: () {},
          ),
        ),
        const SizedBox(width: FudiSpacing.md),
        Expanded(
          child: _ContactChip(
            icon: FudiIcons.phone,
            label: 'Llamar',
            onTap: () {},
          ),
        ),
      ],
    );
  }
}

class _ContactChip extends StatelessWidget {
  const _ContactChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: FudiSpacing.md),
        decoration: BoxDecoration(
          color: FudiColors.background,
          borderRadius: BorderRadius.circular(FudiRadius.xl),
          border: Border.all(color: FudiColors.borderSolid),
        ),
        child: Column(
          children: [
            Icon(icon, size: 24, color: FudiColors.primary),
            const SizedBox(height: FudiSpacing.xs),
            Text(
              label,
              style: FudiTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoriesSection extends StatelessWidget {
  static const _categories = [
    _CategoryItem(
      icon: Icons.eco_rounded,
      label: 'Sobre Fudi',
      subtitle: 'Cómo funciona y misión',
      bgColor: Color(0xFFE8F5E9),
      iconColor: FudiColors.primary,
    ),
    _CategoryItem(
      icon: FudiIcons.shoppingBag,
      label: 'Pedidos y recogidas',
      subtitle: 'Comprar, recoger y cancelar',
      bgColor: Color(0xFFDCFCE7),
      iconColor: Color(0xFF16A34A),
    ),
    _CategoryItem(
      icon: Icons.payment_rounded,
      label: 'Pagos y reembolsos',
      subtitle: 'Métodos de pago y devoluciones',
      bgColor: Color(0xFFFFEDD5),
      iconColor: Color(0xFFEA580C),
    ),
    _CategoryItem(
      icon: Icons.shield_rounded,
      label: 'Políticas y privacidad',
      subtitle: 'Términos y protección de datos',
      bgColor: Color(0xFFEFF6FF),
      iconColor: Color(0xFF2563EB),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return FudiSurfaceCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(FudiSpacing.lg),
            child: Text('Categorías', style: FudiTypography.labelSmall),
          ),
          Divider(height: 1, color: FudiColors.borderSolid),
          ..._categories.map((cat) => _CategoryRow(category: cat)),
        ],
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({required this.category});
  final _CategoryItem category;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: FudiSpacing.lg,
          vertical: FudiSpacing.md,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: category.bgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(category.icon, size: 20, color: category.iconColor),
            ),
            const SizedBox(width: FudiSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.label,
                    style: FudiTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(category.subtitle, style: FudiTypography.bodySmall),
                ],
              ),
            ),
            Icon(
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

class _FAQSection extends StatelessWidget {
  const _FAQSection({
    required this.items,
    required this.expandedId,
    required this.onToggle,
  });

  final List<_FAQItem> items;
  final String? expandedId;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    return FudiSurfaceCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(FudiSpacing.lg),
            child: Text(
              'Preguntas frecuentes',
              style: FudiTypography.labelSmall,
            ),
          ),
          Divider(height: 1, color: FudiColors.borderSolid),
          ...items.map(
            (faq) => _FAQRow(
              faq: faq,
              isExpanded: expandedId == faq.id,
              onToggle: () => onToggle(faq.id),
            ),
          ),
        ],
      ),
    );
  }
}

class _FAQRow extends StatelessWidget {
  const _FAQRow({
    required this.faq,
    required this.isExpanded,
    required this.onToggle,
  });

  final _FAQItem faq;
  final bool isExpanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onToggle,
      child: Padding(
        padding: const EdgeInsets.all(FudiSpacing.lg),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(FudiIcons.helpCircle, size: 20, color: FudiColors.primary),
            const SizedBox(width: FudiSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    faq.question,
                    style: FudiTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (isExpanded) ...[
                    const SizedBox(height: FudiSpacing.sm),
                    Text(
                      faq.answer,
                      style: FudiTypography.bodySmall.copyWith(
                        color: FudiColors.mutedForeground,
                        height: 1.5,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            AnimatedRotation(
              turns: isExpanded ? 0.25 : 0,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                FudiIcons.chevronRight,
                size: 20,
                color: FudiColors.mutedForeground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactSupportCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            FudiColors.primary,
            FudiColors.primary.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(FudiRadius.xxl),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(FudiSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '¿No encuentras lo que buscas?',
            style: FudiTypography.labelSmall.copyWith(color: Colors.white),
          ),
          const SizedBox(height: FudiSpacing.xs),
          Text(
            'Nuestro equipo de soporte está disponible para ayudarte',
            style: FudiTypography.bodySmall.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: FudiSpacing.md),
          SizedBox(
            width: double.infinity,
            child: FudiPressableScale(
              onTap: () {},
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: FudiSpacing.sm),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(FudiRadius.md),
                ),
                child: const Center(
                  child: Text(
                    'Contactar soporte',
                    style: TextStyle(color: FudiColors.primary, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScheduleInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Horario de atención', style: FudiTypography.bodySmall),
        const SizedBox(height: FudiSpacing.xs),
        Text(
          'Lunes a Viernes: 8:00 - 20:00',
          style: FudiTypography.bodyMedium.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          'Sábados: 9:00 - 18:00',
          style: FudiTypography.bodyMedium.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _FAQItem {
  const _FAQItem({
    required this.id,
    required this.question,
    required this.answer,
    required this.category,
  });

  final String id;
  final String question;
  final String answer;
  final String category;
}

class _CategoryItem {
  const _CategoryItem({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.bgColor,
    required this.iconColor,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final Color bgColor;
  final Color iconColor;
}
