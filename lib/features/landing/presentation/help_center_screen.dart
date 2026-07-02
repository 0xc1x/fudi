import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

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

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Próximamente disponible'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _launchEmail(BuildContext context) async {
    final uri = Uri(
      scheme: 'mailto',
      path: 'soporte@fudi.app',
      queryParameters: {'subject': 'Contacto - Centro de ayuda'},
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo abrir el cliente de correo'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _launchPhone(BuildContext context) async {
    final uri = Uri(scheme: 'tel', path: '+525512345678');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo abrir el marcador telefónico'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _openOrdersInfo(BuildContext context) {
    unawaited(Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const HelpCategoryDetailPage(
          title: 'Pedidos y recogidas',
          sections: [
            HelpSection(
              title: 'Cómo hacer un pedido',
              items: [
                HelpItem(
                  title: 'Buscar ofertas',
                  description: 'Explora las ofertas disponibles cerca de ti en la pantalla de inicio o usando el mapa. Cada oferta muestra el precio, la cantidad disponible y el horario de recogida.',
                ),
                HelpItem(
                  title: 'Seleccionar y pagar',
                  description: 'Toca la oferta que te interese, elige la cantidad y confirma tu pedido. El pago se procesa de forma segura al momento de confirmar.',
                ),
                HelpItem(
                  title: 'Recibir código',
                  description: 'Después de confirmar, recibirás un código de recogida único de 6 dígitos. Guárdalo, lo necesitarás para recoger tu pedido.',
                ),
              ],
            ),
            HelpSection(
              title: 'Recogida',
              items: [
                HelpItem(
                  title: 'Cómo recoger',
                  description: 'Dirígete al local dentro del horario de recogida indicado. Muestra tu código de recogida al personal del negocio para recibir tu pedido.',
                ),
                HelpItem(
                  title: 'Llegar tarde',
                  description: 'Si llegas fuera del horario establecido, el negocio puede negarse a entregarte el pedido. Contacta al negocio directamente si tienes un imprevisto.',
                ),
              ],
            ),
            HelpSection(
              title: 'Cancelaciones',
              items: [
                HelpItem(
                  title: 'Antes de confirmar',
                  description: 'Puedes cancelar tu pedido sin problema mientras no haya sido confirmado por el negocio.',
                ),
                HelpItem(
                  title: 'Después de confirmar',
                  description: 'Una vez que el negocio confirma el pedido, no es posible cancelar ni obtener reembolso, a menos que sea por un error del negocio.',
                ),
              ],
            ),
          ],
        ),
      ),
    ));
  }

  void _openPaymentsInfo(BuildContext context) {
    unawaited(Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const HelpCategoryDetailPage(
          title: 'Pagos y reembolsos',
          sections: [
            HelpSection(
              title: 'Métodos de pago',
              items: [
                HelpItem(
                  title: 'Medios aceptados',
                  description: 'Aceptamos tarjetas de crédito y débito de las principales redes (Visa, Mastercard, American Express). El pago siempre se procesa de forma segura.',
                ),
                HelpItem(
                  title: 'Seguridad',
                  description: 'Todos los pagos se procesan a través de pasarelas seguras con encriptación. No almacenamos información sensible de tu tarjeta.',
                ),
              ],
            ),
            HelpSection(
              title: 'Reembolsos',
              items: [
                HelpItem(
                  title: 'Casos elegibles',
                  description: 'Los reembolsos se procesan solo en casos excepcionales, como productos en mal estado, errores del negocio o pedidos no entregados por causas ajenas a ti.',
                ),
                HelpItem(
                  title: 'Cómo solicitar',
                  description: 'Contacta a soporte dentro de las 24 horas posteriores a la recogida. Incluye los detalles de tu pedido y el motivo de tu solicitud.',
                ),
                HelpItem(
                  title: 'Tiempo de procesamiento',
                  description: 'Una vez aprobado, el reembolso se verá reflejado en tu método de pago original en un plazo de 5 a 10 días hábiles.',
                ),
              ],
            ),
          ],
        ),
      ),
    ));
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
          FudiQuickContact(
            onChatTap: () => _showComingSoon(context),
            onEmailTap: () => _launchEmail(context),
            onCallTap: () => _launchPhone(context),
          ),
          const SizedBox(height: FudiSpacing.lg),
          FudiCategoriesSection(
            categories: [
              FudiHelpCategory(
                icon: Icons.eco_rounded,
                label: 'Sobre Fudi',
                subtitle: 'Cómo funciona y misión',
                bgColor: const Color(0xFFE8F5E9),
                iconColor: FudiColors.primary,
                onTap: () => context.push('/about'),
              ),
              FudiHelpCategory(
                icon: FudiIcons.shoppingBag,
                label: 'Pedidos y recogidas',
                subtitle: 'Comprar, recoger y cancelar',
                bgColor: const Color(0xFFDCFCE7),
                iconColor: const Color(0xFF16A34A),
                onTap: () => _openOrdersInfo(context),
              ),
              FudiHelpCategory(
                icon: Icons.payment_rounded,
                label: 'Pagos y reembolsos',
                subtitle: 'Métodos de pago y devoluciones',
                bgColor: const Color(0xFFFFEDD5),
                iconColor: const Color(0xFFEA580C),
                onTap: () => _openPaymentsInfo(context),
              ),
              FudiHelpCategory(
                icon: Icons.shield_rounded,
                label: 'Políticas y privacidad',
                subtitle: 'Términos y protección de datos',
                bgColor: const Color(0xFFEFF6FF),
                iconColor: const Color(0xFF2563EB),
                onTap: () => context.push('/privacy'),
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
          FudiContactSupportCard(
            onTap: () => _launchEmail(context),
          ),
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
      title: const Row(
        children: [
          Icon(FudiIcons.helpCircle, size: 20, color: FudiColors.primary),
          SizedBox(width: FudiSpacing.sm),
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
