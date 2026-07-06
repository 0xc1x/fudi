import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/ui/fudi_colors.dart';
import '../../../../core/ui/fudi_theme.dart';
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

  void _openProductsInfo(BuildContext context) {
    unawaited(Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const HelpCategoryDetailPage(
          title: 'Gestión de productos',
          sections: [
            HelpSection(
              title: 'Crear productos',
              items: [
                HelpItem(
                  title: 'Nuevo producto',
                  description: 'Ve a la sección de Productos y toca "Crear nuevo producto". Completa el nombre, descripción, precio original, precio con descuento, cantidad disponible y horario de recogida.',
                ),
                HelpItem(
                  title: 'Precios sugeridos',
                  description: 'El precio con descuento debe ser menor al original. Recomendamos ofrecer al menos un 30-50% de descuento para atraer más compradores.',
                ),
                HelpItem(
                  title: 'Horarios de recogida',
                  description: 'Define ventanas de recogida para que los clientes sepan cuándo pasar por tu local. Puedes establecer múltiples horarios para un mismo producto.',
                ),
              ],
            ),
            HelpSection(
              title: 'Editar productos',
              items: [
                HelpItem(
                  title: 'Modificar existentes',
                  description: 'Ve al detalle del producto y toca "Editar". Puedes cambiar cualquier campo, incluyendo precio, cantidad y horarios. Los cambios se aplican inmediatamente.',
                ),
                HelpItem(
                  title: 'Pausar productos',
                  description: 'Si un producto no está disponible temporalmente, puedes pausarlo desde la edición. Los clientes no lo verán hasta que lo reactives.',
                ),
              ],
            ),
            HelpSection(
              title: 'Administrar inventario',
              items: [
                HelpItem(
                  title: 'Control de existencias',
                  description: 'Cada vez que un cliente compra, el inventario se actualiza automáticamente. Asegúrate de que la cantidad disponible sea precisa para evitar sobreventas.',
                ),
                HelpItem(
                  title: 'Productos agotados',
                  description: 'Cuando un producto se agota, se marca automáticamente como "Agotado". Puedes crear una nueva oferta para el día siguiente con existencias renovadas.',
                ),
              ],
            ),
          ],
        ),
      ),
    ));
  }

  void _openBusinessPaymentsInfo(BuildContext context) {
    unawaited(Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const HelpCategoryDetailPage(
          title: 'Pagos y facturación',
          sections: [
            HelpSection(
              title: 'Cobros',
              items: [
                HelpItem(
                  title: 'Procesamiento de pagos',
                  description: 'Los pagos de tus clientes se procesan automáticamente a través de nuestra pasarela segura. Recibes el monto total de cada venta, menos la comisión acordada.',
                ),
                HelpItem(
                  title: 'Comisiones',
                  description: 'La comisión por transacción se descuenta automáticamente de cada pago. Puedes consultar el desglose en tu sección de Pagos y Cobros.',
                ),
              ],
            ),
            HelpSection(
              title: 'Pagos',
              items: [
                HelpItem(
                  title: 'Calendario de pagos',
                  description: 'Los pagos se procesan dos veces al mes (días 5 y 20). El dinero se transfiere a tu cuenta bancaria registrada en un plazo de 2-3 días hábiles.',
                ),
                HelpItem(
                  title: 'Consulta de pagos',
                  description: 'En la sección "Balance y Cobros" puedes ver el historial completo de transacciones, pagos procesados y próximos pagos.',
                ),
              ],
            ),
            HelpSection(
              title: 'Facturación',
              items: [
                HelpItem(
                  title: 'Facturas',
                  description: 'Puedes descargar facturas de cada período de pago desde la sección de Pagos. Las facturas incluyen el desglose de ventas, comisiones y montos transferidos.',
                ),
                HelpItem(
                  title: 'Datos fiscales',
                  description: 'Asegúrate de mantener actualizados tus datos fiscales y cuenta bancaria en la configuración de tu perfil para evitar retrasos en los pagos.',
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final themeExt = theme.extension<FudiThemeExtension>();
    final mutedBg = themeExt?.mutedBackground ?? FudiColors.muted;

    return Scaffold(
      backgroundColor: mutedBg,
      appBar: const _AppBar(),
      body: ListView(
        padding: const EdgeInsets.all(FudiSpacing.lg),
        children: [
          FudiSearchBar(
            controller: _searchController,
            onChanged: (v) => setState(() => _searchQuery = v),
            hintText: 'Buscar en ayuda...',
            fillColor: colorScheme.surface,
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
                icon: FudiIcons.package_,
                label: 'Gestión de productos',
                subtitle: 'Crear, editar y administrar',
                bgColor: FudiColors.surfaceSuccess,
                iconColor: FudiColors.primary,
                onTap: () => _openProductsInfo(context),
              ),
              FudiHelpCategory(
                icon: Icons.attach_money_rounded,
                label: 'Pagos y facturación',
                subtitle: 'Cobros y métodos de pago',
                bgColor: FudiColors.surfaceSuccess,
                iconColor: FudiColors.ecoGreen,
                onTap: () => _openBusinessPaymentsInfo(context),
              ),
              FudiHelpCategory(
                icon: Icons.menu_book_rounded,
                label: 'Guías y tutoriales',
                subtitle: 'Aprende a usar la plataforma',
                bgColor: FudiColors.surfaceWarning,
                iconColor: FudiColors.warningOrange,
                onTap: () => context.push('/how-it-works'),
              ),
              FudiHelpCategory(
                icon: Icons.shield_rounded,
                label: 'Políticas y seguridad',
                subtitle: 'Términos y privacidad',
                bgColor: FudiColors.infoSurface,
                iconColor: FudiColors.infoForeground,
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
  const _AppBar();
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeExt = theme.extension<FudiThemeExtension>();
    final mutedBg = themeExt?.mutedBackground ?? FudiColors.muted;

    return AppBar(
      leading: Padding(
        padding: const EdgeInsets.only(left: FudiSpacing.sm),
        child: FudiPressableScale(
          onTap: () => context.pop(),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: mutedBg,
              shape: BoxShape.circle,
            ),
            child: const Icon(FudiIcons.chevronLeft, size: 20),
          ),
        ),
      ),
      title: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Centro de ayuda', style: FudiTypography.h4),
          Text('Soporte y recursos', style: FudiTypography.bodySmall),
        ],
      ),
      backgroundColor: theme.colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 1,
      shadowColor: FudiColors.shadow,
    );
  }
}
