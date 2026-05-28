# Fudi UI Transformation Plan: Anti-Material Strategy

Este documento detalla los pasos necesarios para alejar la identidad visual de **Fudi** del estándar de Material Design, adoptando un lenguaje visual propio ("Branded UI") que resalte la personalidad de la marca utilizando la nueva paleta de colores y el sistema de iconos Lucide.

## 1. Fase de Cimientos (Tokens & Theme)

El primer paso es neutralizar los comportamientos globales de Material 3 que vienen por defecto en Flutter.

- [ ] **Desactivar el Splash de Material:** Configurar `NoSplash.splashFactory` en el `ThemeData` para eliminar el efecto de "onda" (ripple) en toda la aplicación.
- [ ] **Redefinir Radios de Borde:** Movernos de los radios estándar de Material a un sistema más orgánico.
  - `AppRadius.sm`: 12px
  - `AppRadius.md`: 18px (Tarjetas estándar)
  - `AppRadius.lg`: 24px (Contenedores grandes)
  - `AppRadius.full`: 99px (Pills y botones)
- [ ] **Configurar Tipografía "Branded":** 
  - Implementar una fuente con peso (ej. *Clash Display* o *Sora*) para títulos (`display` y `headline`).
  - Mantener una fuente legible (ej. *Inter* o *Plus Jakarta Sans*) para cuerpo de texto.
  - Aplicar contrastes de peso agresivos (Bold para títulos, Regular para cuerpo).

## 2. Rediseño de Componentes Core (Átomos)

### Botones "Soft-Pressure"
- [ ] Crear `FudiButton` personalizado que reemplace a `FilledButton`.
- [ ] **Feedback visual:** Implementar animación de escala al presionar (`0.96x`) en lugar del efecto ripple.
- [ ] **Estilo:** Planos, sin sombras (o con sombras de color difusas), utilizando el rojo `#FA4743`.

### Inputs "Flat-Surface"
- [ ] Eliminar bordes inferiores y estados de enfoque de Material.
- [ ] Usar contenedores con fondo `#F7EFE4` (crema oscuro) y bordes que solo se activan en el foco con un grosor de 1.5px en el color primario.

### Tarjetas "Organic-Depth"
- [ ] Sustituir `elevation` por bordes sólidos delgados (`0.5px` a `1px`) en el color `#1D1D1B`.
- [ ] Implementar sombras "Soft" usando el color primario con muy baja opacidad (`spreadRadius: -2, blurRadius: 20`).

## 3. Estructura y Navegación (Shell)

### Navigation "Island"
- [ ] Rediseñar `FudiBottomNav` como un contenedor flotante.
- [ ] **Layout:** Margen inferior de 20px, radio de borde de 100px, y desenfoque de fondo (Blur) si se superpone al contenido.
- [ ] **Interacción:** Animación de icono activo que "salta" o cambia ligeramente de tamaño.

### Headers Dinámicos
- [ ] Reemplazar `AppBar` por `SliverPersistentHeader`.
- [ ] Implementar títulos de sección "Large Title" que se colapsan suavemente al hacer scroll (estilo iOS pero con estética Fudi).

## 4. Layouts y Grillas (Organismos)

### Concepto "Bento Box"
- [ ] En la Home, agrupar categorías y ofertas en bloques de distintos tamaños que encajen geométricamente.
- [ ] Romper la linealidad de la lista infinita con banners informativos planos intercalados.

### Micro-interacciones
- [ ] **Hero Transitions:** Configurar que las imágenes de comida se expandan desde la tarjeta de la lista hasta el detalle sin cortes bruscos.
- [ ] **Loading States:** Usar Shimmer en tonos crema (`#F5F1E8` a `#F7EFE4`) en lugar del gris estándar.

## 5. Roadmap de Implementación por Pantalla

1.  **Iteración 1: Global & Shell**
    - `FudiTheme` (Anti-material settings)
    - `FudiBottomNav` (Island style)
    - `FudiScaffold` (Custom persistent headers)

2.  **Iteración 2: Discovery (Home & Explore)**
    - Transformación de `DealCard` a estilo flat-border.
    - Implementación de grilla Bento en Home.
    - Filtros como "Pills" flotantes.

3.  **Iteración 3: Conversion (Product Detail & Checkout)**
    - Rediseño de selectores de cantidad y botones de acción.
    - Layout de checkout limpio, sin divisores estándar de Material.

## 6. Métricas de Éxito Visual
- La app no debe parecer una "app de Android estándar".
- El uso del color crema (`#F5F1E8`) debe ser el 80% del lienzo.
- La jerarquía visual debe guiarse por tamaño y peso tipográfico, no por sombras de elevación.
