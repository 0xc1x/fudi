import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/ui/fudi_colors.dart';
import '../../../../core/ui/fudi_pressable_scale.dart';
import '../../../../core/ui/atoms/icons/fudi_icons.dart';
import '../../../../core/ui/fudi_spacing.dart';
import '../../../../core/ui/fudi_surface_card.dart';
import '../../../../core/ui/fudi_typography.dart';

class BusinessHelpScreen extends StatefulWidget {
  const BusinessHelpScreen({super.key});

  @override
  State<BusinessHelpScreen> createState() => _BusinessHelpScreenState();
}

class _BusinessHelpScreenState extends State<BusinessHelpScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String? _expandedFAQ;

  static const _faqItems = [
    _FAQItem(
      id: '1',
      question: '¿Cómo creo un nuevo producto?',
      answer:
          'Ve a la sección de Productos, toca el botón \'Crear nuevo producto\' y completa la información requerida: nombre, descripción, precio original, precio con descuento, cantidad disponible y horario de recogida.',
      category: 'products',
    ),
    _FAQItem(
      id: '2',
      question: '¿Cuándo recibo mis pagos?',
      answer:
          'Los pagos se procesan dos veces al mes (días 5 y 20). El dinero se transfiere a tu cuenta bancaria registrada en 2-3 días hábiles después de la fecha de procesamiento.',
      category: 'payments',
    ),
    _FAQItem(
      id: '3',
      question: '¿Cómo valido un pedido en el momento de la recogida?',
      answer:
          'El cliente te mostrará su código de recogida de 6 dígitos. En la sección de Pedidos, toca \'Validar código\' en el pedido correspondiente e ingresa el código que te muestra el cliente.',
      category: 'orders',
    ),
    _FAQItem(
      id: '4',
      question: '¿Qué hago si un cliente no recoge su pedido?',
      answer:
          'Si un cliente no aparece durante el horario de recogida, contacta al soporte. El pedido se marcará como no recogido y el cliente no será reembolsado según nuestros términos de servicio.',
      category: 'orders',
    ),
    _FAQItem(
      id: '5',
      question: '¿Puedo editar un producto después de publicarlo?',
      answer:
          'Sí, puedes editar cualquier producto en cualquier momento. Ve al detalle del producto y toca \'Editar\'. Los cambios se aplicarán inmediatamente.',
      category: 'products',
    ),
    _FAQItem(
      id: '6',
      question: '¿Cómo funcionan las reseñas?',
      answer:
          'Los clientes pueden dejar reseñas después de recoger su pedido. Las reseñas son públicas y ayudan a otros usuarios a tomar decisiones. Responde a las reseñas para mostrar tu compromiso con el servicio.',
      category: 'general',
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
          onTap: () => context.pop(),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: FudiColors.muted,
              shape: BoxShape.circle,
            ),
            child: const Icon(FudiIcons.chevronLeft, size: 20),
          ),
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Centro de ayuda', style: FudiTypography.h4),
          Text('Soporte y recursos', style: FudiTypography.bodySmall),
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
      icon: FudiIcons.package_,
      label: 'Gestión de productos',
      subtitle: 'Crear, editar y administrar',
      bgColor: Color(0xFFE8F5E9),
      iconColor: FudiColors.primary,
    ),
    _CategoryItem(
      icon: Icons.attach_money_rounded,
      label: 'Pagos y facturación',
      subtitle: 'Cobros y métodos de pago',
      bgColor: Color(0xFFDCFCE7),
      iconColor: Color(0xFF16A34A),
    ),
    _CategoryItem(
      icon: Icons.menu_book_rounded,
      label: 'Guías y tutoriales',
      subtitle: 'Aprende a usar la plataforma',
      bgColor: Color(0xFFFFEDD5),
      iconColor: Color(0xFFEA580C),
    ),
    _CategoryItem(
      icon: Icons.shield_rounded,
      label: 'Políticas y seguridad',
      subtitle: 'Términos y privacidad',
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
          FudiPressableScale(
            onTap: () {},
            child: Container(
              width: double.infinity,
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
