import 'package:flutter/material.dart';

/// Breakpoints centralizados para layouts responsive.
///
/// Basado en Material Design breakpoints:
/// - Compact: < 600px (teléfonos)
/// - Medium: 600–840px (tablets plegadas)
/// - Expanded: > 840px (tablets expandidas, desktop)
class FudiBreakpoints {
  FudiBreakpoints._();

  /// Pantalla compacta (teléfono): ancho < 600px
  static const double compact = 600;

  /// Pantalla mediana (tablet pequeño): 600–840px
  static const double medium = 840;

  /// Pantalla expandida (tablet grande, desktop): > 840px
  static const double expanded = 840;

  /// Ancho máximo recomendado para contenido legible
  static const double maxContentWidth = 1200;

  /// Ancho máximo para formularios
  static const double maxFormWidth = 1024;

  /// Ancho máximo para bottom navigation
  static const double maxNavWidth = 480;

  static bool isCompact(double width) => width < compact;
  static bool isMedium(double width) => width >= compact && width < medium;
  static bool isExpanded(double width) => width >= expanded;

  static ScreenType screenType(double width) {
    if (width < compact) return ScreenType.compact;
    if (width < medium) return ScreenType.medium;
    return ScreenType.expanded;
  }
}

enum ScreenType { compact, medium, expanded }

/// Widget que construye su árbol según el ancho disponible.
///
/// Usa [LayoutBuilder] internamente para decisiones basadas en
/// el espacio del padre, no en el tamaño de la pantalla.
///
/// Ejemplo:
/// ```dart
/// FudiResponsiveBuilder(
///   compact: (context) => const MobileLayout(),
///   expanded: (context) => const DesktopLayout(),
/// )
/// ```
class FudiResponsiveBuilder extends StatelessWidget {
  const FudiResponsiveBuilder({
    super.key,
    this.compact,
    this.medium,
    this.expanded,
  });

  final Widget Function(BuildContext)? compact;
  final Widget Function(BuildContext)? medium;
  final Widget Function(BuildContext)? expanded;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final type = FudiBreakpoints.screenType(width);

        switch (type) {
          case ScreenType.expanded:
            return expanded?.call(context) ?? medium?.call(context) ?? compact?.call(context) ?? const SizedBox.shrink();
          case ScreenType.medium:
            return medium?.call(context) ?? compact?.call(context) ?? const SizedBox.shrink();
          case ScreenType.compact:
            return compact?.call(context) ?? const SizedBox.shrink();
        }
      },
    );
  }
}
