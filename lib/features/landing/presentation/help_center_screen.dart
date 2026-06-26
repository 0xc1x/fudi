import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/route_names.dart';
import '../../../core/ui/fudi_colors.dart';
import '../../../core/ui/atoms/icons/fudi_icons.dart';
import '../../../core/ui/fudi_spacing.dart';
import '../../../core/ui/fudi_pressable_scale.dart';
import '../../../core/ui/fudi_typography.dart';
import '../../../core/ui/fudi_search_bar.dart';
import '../../../core/ui/fudi_help_components.dart';

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
    FudiFAQData(
      id: 'c1',
      question: '¿Cómo funciona Fudi?',
      answer:
          'Fudi conecta restaurantes y tiendas con excedente de comida con personas que quieren comprarla a precios reducidos. Encuentra ofertas cerca de ti, haz tu pedido y recógelo en el horario indicado.',
      category: 'about',
    ),
    FudiFAQData(
      id: 'c2',
      question: '¿Qué es una bolsa sorpresa?',
      answer:
          'Una bolsa sorpresa es un paquete de comida que el negocio no pudo vender durante el día. El contenido varía según lo disponible, pero siempre vale más de lo que pagas.',
      category: 'about',
    ),
    FudiFAQData(
      id: 'c3',
      question: '¿Cómo hago un pedido?',
      answer:
          'Busca ofertas en la app, selecciona la que te interese, elige la cantidad y confirma tu pedido. Recibirás un código de recogida para presentar en el local.',
      category: 'orders',
    ),
    FudiFAQData(
      id: 'c4',
      question: '¿Puedo cancelar un pedido?',
      answer:
          'Puedes cancelar un pedido mientras no haya sido confirmado por el negocio. Una vez confirmado, no es posible cancelar ni obtener reembolso.',
      category: 'orders',
    ),
    FudiFAQData(
      id: 'c5',
      question: '¿Qué pasa si llego tarde a la recogida?',
      answer:
          'Si llegas fuera del horario de recogida, el negocio puede negarse a entregarte el pedido. Te recomendamos llegar puntualmente. Si tienes un imprevisto, contacta al negocio directamente.',
      category: 'orders',
    ),
    FudiFAQData(
      id: 'c6',
      question: '¿Qué métodos de pago aceptan?',
      answer:
          'Aceptamos tarjetas de crédito y débito principales. El pago se procesa de forma segura al momento de confirmar tu pedido.',
      category: 'payments',
    ),
    FudiFAQData(
      id: 'c7',
      question: '¿Puedo obtener un reembolso?',
      answer:
          'Los reembolsos se procesan solo en casos excepcionales, como productos en mal estado o errores del negocio. Contacta a soporte dentro de las 24 horas posteriores a la recogida.',
      category: 'payments',
    ),
    FudiFAQData(
      id: 'c8',
      question: '¿Cómo ayuda Fudi al medio ambiente?',
      answer:
          'Cada pedido en Fudi evita que comida perfectly good termine en la basura. Reducimos el desperdicio alimentario y las emisiones asociadas a la producción y transporte de alimentos que nadie consume.',
      category: 'about',
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
                icon: Icons.eco_rounded,
                label: 'Sobre Fudi',
                subtitle: 'Cómo funciona y misión',
                bgColor: Color(0xFFE8F5E9),
                iconColor: FudiColors.primary,
              ),
              FudiHelpCategory(
                icon: FudiIcons.shoppingBag,
                label: 'Pedidos y recogidas',
                subtitle: 'Comprar, recoger y cancelar',
                bgColor: Color(0xFFDCFCE7),
                iconColor: Color(0xFF16A34A),
              ),
              FudiHelpCategory(
                icon: Icons.payment_rounded,
                label: 'Pagos y reembolsos',
                subtitle: 'Métodos de pago y devoluciones',
                bgColor: Color(0xFFFFEDD5),
                iconColor: Color(0xFFEA580C),
              ),
              FudiHelpCategory(
                icon: Icons.shield_rounded,
                label: 'Políticas y privacidad',
                subtitle: 'Términos y protección de datos',
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
