import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/ui/fudi_colors.dart';
import '../../../../core/ui/fudi_pressable_scale.dart';
import '../../../../core/ui/atoms/icons/fudi_icons.dart';
import '../../../../core/ui/fudi_spacing.dart';
import '../../../../core/ui/fudi_typography.dart';
import '../../../../core/ui/fudi_search_bar.dart';
import '../../../../core/ui/fudi_help_components.dart';

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
    FudiFAQData(
      id: '1',
      question: '¿Cómo creo un nuevo producto?',
      answer:
          'Ve a la sección de Productos, toca el botón \'Crear nuevo producto\' y completa la información requerida: nombre, descripción, precio original, precio con descuento, cantidad disponible y horario de recogida.',
      category: 'products',
    ),
    FudiFAQData(
      id: '2',
      question: '¿Cuándo recibo mis pagos?',
      answer:
          'Los pagos se procesan dos veces al mes (días 5 y 20). El dinero se transfiere a tu cuenta bancaria registrada en 2-3 días hábiles después de la fecha de procesamiento.',
      category: 'payments',
    ),
    FudiFAQData(
      id: '3',
      question: '¿Cómo valido un pedido en el momento de la recogida?',
      answer:
          'El cliente te mostrará su código de recogida de 6 dígitos. En la sección de Pedidos, toca \'Validar código\' en el pedido correspondiente e ingresa el código que te muestra el cliente.',
      category: 'orders',
    ),
    FudiFAQData(
      id: '4',
      question: '¿Qué hago si un cliente no recoge su pedido?',
      answer:
          'Si un cliente no aparece durante el horario de recogida, contacta al soporte. El pedido se marcará como no recogido y el cliente no será reembolsado según nuestros términos de servicio.',
      category: 'orders',
    ),
    FudiFAQData(
      id: '5',
      question: '¿Puedo editar un producto después de publicarlo?',
      answer:
          'Sí, puedes editar cualquier producto en cualquier momento. Ve al detalle del producto y toca \'Editar\'. Los cambios se aplicarán inmediatamente.',
      category: 'products',
    ),
    FudiFAQData(
      id: '6',
      question: '¿Cómo funcionan las reseñas?',
      answer:
          'Los clientes pueden dejar reseñas después de recoger su pedido. Las reseñas son públicas y ayudan a otros usuarios a tomar decisiones. Responde a las reseñas para mostrar tu compromiso con el servicio.',
      category: 'general',
    ),
  ];

  List<FudiFAQData> get _filteredFAQs {
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
          FudiSearchBar(
            controller: _searchController,
            onChanged: (v) => setState(() => _searchQuery = v),
            hintText: 'Buscar en ayuda...',
            fillColor: FudiColors.background,
            borderRadius: FudiRadius.xl,
          ),
          const SizedBox(height: FudiSpacing.lg),
          const FudiQuickContact(),
          const SizedBox(height: FudiSpacing.lg),
          const FudiCategoriesSection(
            categories: [
              FudiHelpCategory(
                icon: FudiIcons.package_,
                label: 'Gestión de productos',
                subtitle: 'Crear, editar y administrar',
                bgColor: Color(0xFFE8F5E9),
                iconColor: FudiColors.primary,
              ),
              FudiHelpCategory(
                icon: Icons.attach_money_rounded,
                label: 'Pagos y facturación',
                subtitle: 'Cobros y métodos de pago',
                bgColor: Color(0xFFDCFCE7),
                iconColor: Color(0xFF16A34A),
              ),
              FudiHelpCategory(
                icon: Icons.menu_book_rounded,
                label: 'Guías y tutoriales',
                subtitle: 'Aprende a usar la plataforma',
                bgColor: Color(0xFFFFEDD5),
                iconColor: Color(0xFFEA580C),
              ),
              FudiHelpCategory(
                icon: Icons.shield_rounded,
                label: 'Políticas y seguridad',
                subtitle: 'Términos y privacidad',
                bgColor: Color(0xFFEFF6FF),
                iconColor: Color(0xFF2563EB),
              ),
            ],
          ),
          const SizedBox(height: FudiSpacing.lg),
          FudiFAQSection(
            items: _filteredFAQs,
            expandedId: _expandedFAQ,
            onToggle: (id) =>
                setState(() => _expandedFAQ = _expandedFAQ == id ? null : id),
          ),
          const SizedBox(height: FudiSpacing.lg),
          const FudiContactSupportCard(),
          const SizedBox(height: FudiSpacing.lg),
          const FudiScheduleInfo(),
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
