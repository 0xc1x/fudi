# Plan de Implementación: Soporte Integral y Persistente de Modo Oscuro en Fudi

Este documento detalla el plan técnico para dotar a la aplicación Fudi de un modo oscuro completo, consistente, persistente y adaptado a las preferencias del usuario (incluyendo la detección del tema del sistema operativo). 

El diseño se alinea con la estrategia "Anti-Material" (Branded UI) de Fudi, utilizando la paleta de colores corporativa y evitando grises genéricos de Material 3.

---

## 1. Objetivos del Plan

*   **Consistencia Absoluta:** Asegurar que ningún elemento visual de la interfaz (en cualquiera de los 3 roles: `user`, `business`, `admin`) quede huérfano de tema.
*   **Adaptabilidad al Sistema (Dynamic Mode):** Permitir al usuario elegir entre:
    *   `Light Mode` (Modo Claro)
    *   `Dark Mode` (Modo Oscuro)
    *   `System Default` (Ajustado automáticamente al sistema operativo)
*   **Persistencia Híbrida (Offline/Guest):**
    *   **Offline/Guest:** Almacenar la preferencia inmediatamente en `SharedPreferences` para que sea leída de forma síncrona en el arranque (`AppBootstrap`), evitando destellos (flashing) de luz blanca.
    *   **Online/Profile:** Sincronizar la preferencia en la tabla `user_preferences` de Supabase para usuarios autenticados, manteniendo consistencia entre dispositivos.
*   **Accesibilidad (WCAG 2.1 AA):** Garantizar un contraste de color mínimo de 4.5:1 para texto normal y de 3:1 para texto grande.

---

## 2. Decisiones de Diseño y Paleta Cromática

### Colores de Referencia para el Modo Oscuro (Branded Dark)
Evitaremos el negro puro `#000000` y los grises planos. En su lugar, utilizaremos una paleta basada en tonos Navy/Pizarra Oscura y el Rojo Fudi como acento:

*   **Fondo Base (Background):** `#05102F` (Deep Navy) o `#111C15` (Dark Slate/Green para áreas comerciales).
*   **Superficies de Tarjetas (Cards/Surfaces):** `#2D4142` (Dark Slate/Green) o `#233529` (Green Mid Dark).
*   **Texto Principal (Foreground):** `#faf9f7` (Cream).
*   **Texto Secundario (Muted):** `#B1CDB6` (Soft Green) o `#737373` (Muted Slate).
*   **Bordes de Elementos:** `#33FFFFFF` (Líneas finas de 1px semi-transparentes para mantener la estética neo-brutalista en modo oscuro).
*   **Acento/Primario:** `#bf1c19` (Rojo Fudi).

### Estructura de Tipografía y Colores
Para evitar que las fuentes carguen colores estáticos de `FudiColors.foreground`, el plan es eliminar los colores de texto fijos de la clase `FudiTypography` (o pasarlos a heredables) y configurarlos explícitamente en el `ThemeData` a través de la propiedad `textTheme`, o usar `Theme.of(context).colorScheme.onSurface` en los componentes.

---

## 3. Fase de Arquitectura (Cimientos y Inyección de Estado)

### FASE 1: Configuración de Tema y Extensiones en `lib/core/ui`
1.  **Crear `FudiThemeExtension`:**
    *   Ubicación: [fudi_theme.dart](file:///home/xcix/Repositories/fudi/lib/core/ui/fudi_theme.dart)
    *   Clase que extiende `ThemeExtension` para colores de marca personalizados (como `cardBg`, `borderColor`, `accentCardBg`) que no encajan en el `ColorScheme` estándar.
2.  **Robustecer `FudiTheme.dark()`:**
    *   Configurar un `ThemeData` oscuro completo con `brightness: Brightness.dark`.
    *   Asegurar que `cardTheme`, `inputDecorationTheme`, `filledButtonTheme`, `appBarTheme` y `textTheme` tengan sus variantes oscuras totalmente definidas utilizando `FudiColorsDark` y la extensión de tema.
3.  **Hacer `FudiTypography` Tema-Agnóstica:**
    *   Remover la propiedad estática `color` de los `TextStyle` por defecto en [fudi_typography.dart](file:///home/xcix/Repositories/fudi/lib/core/ui/fudi_typography.dart) para que hereden el color del contexto, o definir un método `FudiTypography.textTheme(bool isDark)` para inyección explícita.

### FASE 2: Controlador de Tema con Riverpod
1.  **Definir Enum `AppThemeMode`:**
    ```dart
    enum AppThemeMode { light, dark, system }
    ```
2.  **Crear `ThemeNotifier`:**
    *   Ubicación: `lib/core/ui/theme_notifier.dart`
    *   Clase que extiende `Notifier<AppThemeMode>`.
    *   **En el arranque (`build`):** Lee síncronamente el valor cacheado en `SharedPreferences` (ej. `'app_theme_mode'`). Si no existe, por defecto usa `AppThemeMode.system`.
    *   **Método `setThemeMode(AppThemeMode mode)`:**
        1. Actualiza el estado en memoria.
        2. Guarda el valor en `SharedPreferences` local.
        3. Si hay sesión activa en Supabase, envía de forma asíncrona (background task) la actualización a `user_preferences`.
3.  **Actualizar `FudiApp` en `lib/main.dart`:**
    *   Observar `themeNotifierProvider` para reconstruir `MaterialApp.router`.
    *   Configurar las propiedades:
        *   `theme: FudiTheme.light()`
        *   `darkTheme: FudiTheme.dark()`
        *   `themeMode: _mapToThemeMode(themeState)`

---

## 4. Fase de Sincronización y Configuración UI

### FASE 3: Modificación en la UI de Configuración
1.  **Modificar [general_settings_screen.dart](file:///home/xcix/Repositories/fudi/lib/features/profile/presentation/general_settings_screen.dart):**
    *   Reemplazar el simple `Switch` de "Modo Oscuro" por un selector de tres opciones (Claro, Oscuro, Sistema).
    *   Utilizar un componente estilizado (ej. `SegmentedButton` o un grupo de `FudiSurfaceCard` interactivas en horizontal) que muestre visualmente la selección actual con transiciones suaves de escala (`FudiPressableScale`).

### FASE 4: Sincronización con Base de Datos (Supabase)
1.  **Migrar `user_preferences` en Supabase:**
    *   Revisar si es necesario migrar la columna `dark_mode` (boolean) a una columna de tipo texto `theme_mode` (`'light' | 'dark' | 'system'`).
    *   *Nota de seguridad:* La actualización en Supabase debe cumplir las políticas RLS existentes (permitiendo solo al dueño del `user_id` modificarlo).
2.  **Sincronizar al Iniciar Sesión:**
    *   Al iniciar sesión con éxito, el sistema leerá la preferencia guardada en Supabase y sobreescribirá la cache local de `SharedPreferences`.

---

## 5. Fase de Refactorización y Auditoría de Componentes

Para asegurar que ningún elemento quede sin posibilidad de modo oscuro, realizaremos un barrido exhaustivo de las siguientes carpetas:

### Componentes Core (`lib/core/ui/`)
*   **[fudi_surface_card.dart](file:///home/xcix/Repositories/fudi/lib/core/ui/fudi_surface_card.dart):** Reemplazar `FudiColors.card` por `Theme.of(context).cardTheme.color` o por la extensión del tema. Reemplazar la sombra estática por una dependiente del tema.
*   **[fudi_bottom_nav.dart](file:///home/xcix/Repositories/fudi/lib/core/ui/fudi_bottom_nav.dart):** Quitar colores de fondo y texto hardcoded (actualmente `Colors.white`).
*   **Botones y Badges:** Asegurar que los componentes en `lib/core/ui/atoms/` utilicen `Theme.of(context).colorScheme` para los estados activo, inactivo y deshabilitado.

### Vistas por Rol en `lib/features/`
*   **Consumer (`home/`, `explore/`, `offers/`, `orders/`, `profile/`):**
    *   Eliminar fondos de Scaffold fijos (`Colors.white` o `FudiColors.background` de forma estática).
    *   Reemplazar colores de texto hardcoded en tarjetas de ofertas y listas.
*   **Business (`business/`):**
    *   Asegurar que los dashboards de ventas y formularios para editar paquetes de comida respondan correctamente al tema oscuro.
    *   Ajustar los gráficos (`RevenueChart`, `OrdersChart`) para que las leyendas y colores de barras utilicen una versión con suficiente contraste en fondo oscuro.
*   **Admin / Landing (`admin/`, `landing/`):**
    *   Revisar el panel web de administración y la estructura de la landing page.

---

## 6. Plan de Verificación y Calidad

### Automatización (Widget Tests)
Añadiremos casos de prueba específicos para comprobar que la inyección de temas funciona correctamente.
*   **Test del Controlador de Tema:** Validar persistencia en `SharedPreferences` y la sincronización con Supabase.
*   **Widget Tests de Componentes Core:**
    *   Pumpear `OfferCard`, `FudiSurfaceCard` y `FudiBottomNav` envolviéndolos tanto en `ThemeData.light()` como en `ThemeData.dark()`.
    *   Verificar mediante `Finder` que los colores de fondo y texto cambian dinámicamente según el brillo del tema inyectado.

### Verificación Manual
1.  **Detección de Sistema:** Cambiar el tema del simulador (iOS/Android) o del navegador (Web) a modo oscuro y comprobar que Fudi reacciona instantáneamente sin requerir reinicio.
2.  **Inicio en Frío (Cold Start):** Cerrar la app por completo en modo oscuro y verificar que al volver a abrirla inicia directamente en modo oscuro sin un parpadeo en blanco.
3.  **Auditoría de Contraste:** Utilizar las herramientas de accesibilidad (ej. *Accessibility Inspector* en iOS o *Accessibility Scanner* en Android) para verificar cumplimiento de la norma WCAG 2.1 AA.

---

## 7. Preguntas Abiertas e Implicaciones para el Usuario

> [!IMPORTANT]
> **1. Migración de Base de Datos:** ¿Deseas que migremos la base de datos de Supabase modificando el campo actual `dark_mode` (boolean) a un nuevo campo `theme_mode` (string: `'light' | 'dark' | 'system'`) para reflejar esta nueva arquitectura, o prefieres mantener el boolean `dark_mode` y mapear `system` localmente?
>
> **2. Alcance en Landing Web:** ¿El modo oscuro debe aplicarse también a la Landing Web (página estática) o esta mantendrá su diseño corporativo predominantemente claro por cuestiones comerciales?
