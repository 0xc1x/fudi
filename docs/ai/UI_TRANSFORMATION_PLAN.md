# Fudi UI Transformation Plan: Anti-Material Strategy

Este documento detalla los pasos de ingeniería y diseño necesarios para alejar la identidad visual de **Fudi** del estándar plano de Material Design, adoptando un lenguaje visual propio ("Branded UI") que resalte la personalidad de la marca utilizando la paleta de colores unificada y el sistema de iconos Lucide.

---

## 1. Fase de Cimientos (Tokens & Theme)

El primer paso es neutralizar los comportamientos genéricos de Material 3 y definir los cimientos tipográficos y cromáticos adaptados para el soporte **offline-first**.

### Desactivar el Splash y Configurar Feedback de Accesibilidad
- [ ] **Muteo Global del Splash:** Configurar `splashFactory: NoSplash.splashFactory` en `ThemeData` en [fudi_theme.dart](file:///C:/Users/emele/Repositories/fudi/lib/core/ui/fudi_theme.dart).
- [ ] **Feedback de Enfoque y Hover:** Para evitar una UI "sorda" (criterio de accesibilidad WCAG 2.1), configurar en el tema global:
  - `highlightColor: FudiColors.primary.withOpacity(0.08)` (rojo translúcido al presionar elementos).
  - `hoverColor: FudiColors.secondary.withOpacity(0.08)` (verde translúcido al pasar el cursor).

### Redefinir Radios de Borde (Consistencia de Nomenclatura)
- [ ] Actualizar los tokens en [fudi_spacing.dart](file:///C:/Users/emele/Repositories/fudi/lib/core/ui/fudi_spacing.dart) bajo la clase existente `FudiRadius` en lugar de crear nuevas clases:
  - `FudiRadius.sm`: 12.0 (Botones pequeños y badges)
  - `FudiRadius.md`: 18.0 (Inputs y tarjetas estándar)
  - `FudiRadius.lg`: 24.0 (Contenedores principales y Bento Boxes)
  - `FudiRadius.full`: 99.0 (Pills de filtros y botones redondeados)

### Estrategia de Tipografía "Branded" (Offline-First)
Para garantizar el funcionamiento sin conexión a internet (en coherencia con la arquitectura offline-first de la app), no se utilizará el paquete `google_fonts` que descarga fuentes en caliente.
- [ ] **Descargar Fuentes Locales:** Agregar los archivos TrueType (`.ttf`) a la carpeta de assets del proyecto:
  - **Títulos (Display/Headings):** *Sora* u *Outfit* (Geométricas, amigables y con alta personalidad visual).
  - **Cuerpo de texto (Body):** *Inter* o *Plus Jakarta Sans* (De alta legibilidad y formas limpias).
- [ ] **Configurar `pubspec.yaml`:** Registrar las familias tipográficas físicamente para que estén integradas en el compilado.
- [ ] **Mapear en `FudiTypography`:** Configurar [fudi_typography.dart](file:///C:/Users/emele/Repositories/fudi/lib/core/ui/fudi_typography.dart) aplicando contrastes agresivos de peso (ej. `FontWeight.w800` para títulos y `FontWeight.w400` para cuerpo).

---

## 2. Paleta de Colores y Combinaciones Estratégicas

Basándonos en la inspección de los logos oficiales ([icon.svg](file:///C:/Users/emele/Repositories/fudi/assets/svgs/icon.svg) y [role_wordmark.svg](file:///C:/Users/emele/Repositories/fudi/assets/svgs/role_wordmark.svg)), unificaremos la paleta de colores en [fudi_colors.dart](file:///C:/Users/emele/Repositories/fudi/lib/core/ui/fudi_colors.dart) y estableceremos combinaciones recomendadas para generar jerarquía.

### Unificación Cromática con la Marca
*   **Rojo Primario Fudi:** `#FA4743` (El color de acento principal del isotipo del logo).
*   **Casi Negro de Marca:** `#1A1A18` (Unificación del texto y los bordes para coincidir exactamente con el color corporativo del wordmark, reemplazando el antiguo `#1D1D1B`).
*   **Fondo Crema Principal:** `#F5F1E8` (80% del lienzo de la aplicación, aportando calidez).
*   **Crema Muted (Card/Surface):** `#F7EFE4` (Fondo para agrupaciones visuales secundarias).
*   **Verde Sostenible (Secundario):** `#B1CDB6` (Badge de éxito, rescate completado y ahorro).
*   **Pizarra Oscuro (Contraste):** `#2D4142` (Para bloques de acento tipo Bento Box).

### Combinaciones de Diseño
1.  **Esquema Hero (Default):** Canvas crema `#F5F1E8` + Tarjetas crema oscuro `#F7EFE4` con un borde sólido de `1px` en Casi Negro `#1A1A18`. Textos en `#1A1A18` y toques de llamada a la acción en Rojo Fudi `#FA4743`.
2.  **Esquema Invertido (Secciones destacadas):** Bloques en Pizarra Oscuro `#2D4142` + Texto en crema `#F5F1E8` con detalles y botones en Rojo Fudi `#FA4743`. Ideal para banners de descuento o promociones especiales.

---

## 3. Rediseño de Componentes Core (Átomos)

### Botones "Soft-Pressure" con Micro-interacciones
- [ ] Crear el widget `FudiButton` personalizado en `lib/core/ui/atoms/fudi_button.dart` con variantes `.primary`, `.secondary` y `.outlined`.
- [ ] **Animación de Escala:** Implementar un `StatefulWidget` con un `AnimationController` que reduzca la escala física del botón a `0.96x` al presionarse (`ScaleTransition`), evitando el ripple de Material.
- [ ] **Estilo Visual:** Bordes redondeados `FudiRadius.full` o `FudiRadius.sm`, colores planos y un borde sólido fino en su variante `outlined`.

### Inputs "Flat-Surface" Centralizados
- [ ] Modificar la decoración global en `inputDecorationTheme` dentro de `FudiTheme` ([fudi_theme.dart](file:///C:/Users/emele/Repositories/fudi/lib/core/ui/fudi_theme.dart)):
  - Fondo plano crema oscuro (`FudiColors.muted` = `#F7EFE4`).
  - Sin elevación ni líneas inferiores.
  - Bordes planos que solo se activan al recibir foco, con grosor de `1.5px` en el color primario de la marca.

### Tarjetas "Organic-Depth"
- [ ] Rediseñar [fudi_surface_card.dart](file:///C:/Users/emele/Repositories/fudi/lib/core/ui/fudi_surface_card.dart):
  - Sustituir la elevación o sombras grises por bordes sólidos delgados (`1px`) en el color casi negro de la marca (`#1A1A18`).
  - **Sombra Soft-Glow:** Añadir una sombra sutil de acento utilizando el color primario (`#FA4743`) con opacidad extremadamente baja (`0.05` o menor) y un `blurRadius: 16` con `spreadRadius: -2` para evitar sobrecargar visualmente el diseño.

---

## 4. Estructura y Navegación (Desacoplamiento de Cabeceras)

Para evitar romper el contrato del `Scaffold` en Flutter, se descarta el reemplazo global del `AppBar` por un Sliver en todas las pantallas. Se adopta una estrategia híbrida según la complejidad de la vista:

### Cabeceras Estáticas (90% de las pantallas)
- [ ] Mantener [FudiStickyPageHeader](file:///C:/Users/emele/Repositories/fudi/lib/core/ui/fudi_sticky_page_header.dart) como un `PreferredSizeWidget` basado en `AppBar` para pantallas utilitarias (ej. Ajustes, Métodos de Pago, Historial).
- [ ] Eliminar cualquier sombra (`elevation: 0`, `scrolledUnderElevation: 0`), pintar el fondo en el crema base `#F5F1E8` y usar tipografía pesada en Casi Negro `#1A1A18`.

### Cabeceras Colapsables y Dinámicas (Home, Explore y Business Profile)
- [ ] Crear un nuevo scaffold especializado: `FudiSliverScaffold` o un widget `FudiSliverHeaderDelegate`.
- [ ] Este widget encapsulará un `CustomScrollView` permitiendo que el header colapse visualmente hacia un "Large Title" dinámico y sutil al hacer scroll.
- [ ] **Transición del Título:** El título pasará de tamaño gigante a tamaño medio alineado en el centro del header utilizando una transición suave basada en el offset de scroll.

---

## 5. Layouts, Grillas y Transiciones (Organismos)

### Concepto "Bento Box" (Home)
- [ ] En la Home, estructurar secciones usando layouts asimétricos con tarjetas de ofertas, categorías e información.
- [ ] **Estructura:** Implementar utilizando `Row` y `Column` anidados dentro de un `SliverList` o bien integrando de forma controlada el paquete `flutter_staggered_grid_view` para grillas asimétricas fluidas.

### Micro-interacciones y Shimmer Crema
- [ ] **Hero Transitions Premium:** Envolver las tarjetas de comida y su vista de detalle en un widget `Hero`. Implementar un `flightShuttleBuilder` personalizado en las transiciones de Hero para evitar distorsiones de tamaño o saltos bruscos en las esquinas redondeadas.
- [ ] **Loading States (Shimmer):** Configurar el paquete `shimmer` para usar un degradado crema en lugar de gris:
  - Base: `#F5F1E8`
  - Highlight: `#F7EFE4`

---

## 6. Roadmap de Implementación y Pruebas

La ejecución de la transformación se realizará de forma incremental garantizando que la aplicación continúe compilando correctamente en cada paso:

### Fase 1: Cimientos y Configuración Global (Tema y Fuentes)
- [x] Detallar y acordar el plan de transformación.
- [ ] Descargar e importar fuentes en `assets/fonts/` y `pubspec.yaml`.
- [ ] Actualizar [fudi_colors.dart](file:///C:/Users/emele/Repositories/fudi/lib/core/ui/fudi_colors.dart) y [fudi_spacing.dart](file:///C:/Users/emele/Repositories/fudi/lib/core/ui/fudi_spacing.dart).
- [ ] Ajustar `FudiTheme` y `FudiTypography` en el tema base.

### Fase 2: Rediseño de Componentes Core (Botones, Inputs, Cards)
- [ ] Implementar el nuevo `FudiButton` con animación de escala.
- [ ] Modificar `FudiSurfaceCard` para incorporar bordes neo-brutalistas.
- [ ] Probar la integración de los inputs en el tema global.
- [ ] Validar todos los componentes visualmente en la pantalla [ui_gallery_screen.dart](file:///C:/Users/emele/Repositories/fudi/lib/core/ui/ui_gallery_screen.dart).

### Fase 3: Layouts y Pantallas Clave (Home, Detail, Checkout)
- [ ] Implementar la estructura Bento Box y el `FudiSliverScaffold` en la Home.
- [ ] Ajustar la transición `Hero` del listado al detalle de oferta.
- [ ] Limpiar los divisores de Material 3 y refactorizar el Checkout a un diseño puramente flat-border.

---

## 7. Métricas de Éxito Visual
- La app no debe mostrar el efecto "ripple" ni comportamientos grises genéricos de Material 3.
- El 80% del lienzo debe predominar en color crema (`#F5F1E8`).
- La jerarquía debe guiarse principalmente por tamaño, peso tipográfico y bordes negros de alta definición (`#1A1A18`), no por sombras de elevación grises.
- Todos los elementos interactivos deben proveer feedback de accesibilidad activo al ser pulsados.
