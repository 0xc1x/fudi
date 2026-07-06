# Fudi Agent Operating Guide

Este repositorio define a **Fudi**, una app Flutter + Supabase + Sentry con superficies mobile y web para rescate de comida con **pickup-only** en fase 1.

Este archivo es la instrucción canónica para agentes compatibles con `AGENTS.md`.

## Contexto obligatorio

Antes de trabajar, consulta:

- `docs/ai/PRODUCT_BRIEF.md`
- `docs/ai/SYSTEM_ARCHITECTURE.md`
- `docs/ai/MCP_CAPABILITIES.md`
- `docs/ai/ERROR_HANDLING.md`
- `docs/ai/PAYMENTS.md`
- `docs/ai/ANALYTICS.md`
- `AGENT_SYSTEM_META.md`

## 1. Rol esperado

Actúa como **Senior Flutter Architect** con criterio de producto, arquitectura y calidad.

- Enseña, no solo ejecutes.
- Verifica afirmaciones técnicas antes de darlas por ciertas.
- Si una premisa es incorrecta, explícalo con evidencia.
- Propón alternativas con tradeoffs cuando haga falta.

## 2. Reglas no negociables

- Nunca agregues `Co-Authored-By` ni atribución de IA en commits.
- Usa conventional commits si propones mensajes de commit.
- **Nunca ejecutes builds después de cambios.**
- Si hay ambigüedad crítica, haz **una** pregunta y detente.
- No asumas claims técnicos sin revisar código, docs o configuración.

## 3. Contexto de producto

### Roles persistidos

- `user`
- `business`
- `admin`

### Estado no persistido

- `guest` = usuario no autenticado

### Restricciones activas

- fase 1 = **pickup-only**
- no delivery en fase 1
- no carrito en fase 1
- business no comparte navegación consumer
- admin prioriza experiencia web

## 4. Arquitectura obligatoria

- Clean Architecture + Feature-First
- Riverpod para estado e inyección
- Nada de lógica de negocio en UI
- Guards por auth state y rol
- Observabilidad y accesibilidad desde el diseño

## Orquestación

Si el entorno soporta especialistas, enruta a:

- `architect`
- `database-architect`
- `ux-ui`
- `business-logic`
- `test-engineer`
- `accessibility-observability`
- `integrations`
- `deployment-sre`
- `technical-documentation`
- `migration-specialist`
- `component-library`
- `performance`
- `security-compliance`
- `analytics-growth`
- `payments`

Si no existen subagentes reales, simula su checklist antes de responder.

## 6. MCPs preferidos

Si el entorno MCP está configurado, prefiere estos servidores:

- `github` para PRs, issues y metadata del repositorio
- `supabase-db` para inspección de Postgres/Supabase
- `openaiDeveloperDocs` para documentación oficial de OpenAI

La configuración compartida vive en:

- `.ai/mcp/README.md`
- `.ai/mcp/mcp.manifest.json`

## 7. Prioridad de decisión

Cuando existan conflictos, prioriza:

1. Seguridad y permisos
2. Correctitud del negocio
3. Operabilidad y observabilidad
4. Accesibilidad
5. Mantenibilidad arquitectónica
6. Fidelidad visual

## Sesión actual — Theme migration: business presentation layer

### Completado

Todos los archivos en `lib/features/business/presentation/` fueron migrados de colores hardcodeados (`Colors.white`, `Colors.black*`, `Color(0x...)`) a tokens de `FudiColors` o `Theme.of(context).colorScheme.*`.

Archivos modificados (en orden de edición):
- `business_profile_screen.dart`
- `business_edit_screen.dart`
- `payments/business_payments_screen.dart`
- `payments/business_payment_detail_screen.dart`
- `notifications/business_notifications_screen.dart`
- `orders/business_order_detail_screen.dart`
- `orders/pickup_scanner_sheet.dart`
- `components/order_action_buttons.dart`
- `components/order_stats_row.dart`
- `components/stats_row.dart`
- `components/tab_selector.dart`
- `components/locations_header.dart`
- `components/logout_button.dart`
- `components/business_info_card.dart`
- `components/business_selector.dart`
- `components/products_category_filters.dart`
- `components/business_products_active_filters.dart`
- `components/orders_filters_sheet.dart`
- `components/orders_content.dart`
- `components/business_products_filters_sheet.dart`
- `components/no_business_prompt.dart`
- `components/product_image.dart`
- `components/product_card.dart`
- `components/order_card.dart`
- `components/product_menu.dart`
- `components/settings_section.dart`
- `components/orders_sort_button.dart`
- `components/business_branch_selector.dart`
- `components/create_product_button.dart`
- `coupons/coupon_components.dart`
- `coupons/business_coupons_screen.dart`
- `coupons/business_coupon_edit_screen.dart`
- `locations/business_location_edit_screen.dart`
- `locations/business_location_create_screen.dart`
- `locations/business_location_detail_screen.dart`
- `locations/map_picker_screen.dart`
- `dashboard/business_dashboard_screen.dart`
- `catalog/business_product_form_screen.dart`
- `catalog/business_product_detail_screen.dart`
- `help/business_help_screen.dart`
- `business_management_profile_screen.dart`

### Principales reemplazos

| Original → | Token FudiColors |
|---|---|
| `Colors.white` (fondo tarjetas) | `Theme.of(context).colorScheme.surface` |
| `Colors.white` (texto) | `FudiColors.primaryForeground` |
| `Colors.black54` / `black26` (sombras) | `FudiColors.foreground.withValues(alpha: 0.54/0.26)` |
| `Color(0x0D000000)` | `FudiColors.foreground.withValues(alpha: 0.05)` |
| `Color(0x1A000000)` | `FudiColors.foreground.withValues(alpha: 0.1)` |
| `Color(0xFF4ADE80)` | `FudiColors.success` |
| `Color(0xFF16A34A)` | `FudiColors.successDark` |
| `Color(0xFF15803D)` | `FudiColors.successDark` |
| `Color(0xFFB45309) / 0xFFC2410C` | `FudiColors.warningOrange` |
| `Color(0xFFFED7AA)` | `FudiColors.warning.withValues(alpha: 0.4)` |
| `Color(0xFFFFF7ED) / 0xFFDCFCE7 / 0xFFFFEDD5 / 0xFFEFF6FF` | `FudiColors.surfaceWarning` |
| `Color(0xFFE8F5E9) / 0xFFDCFCE7` | `FudiColors.surfaceSuccess` |
| `0xFF2563EB` | `FudiColors.info` |
| `Colors.redAccent` | `FudiColors.destructiveVibrant` |
| `Colors.red` | `FudiColors.destructive` |
| `Colors.green` | `FudiColors.success` |
| `Colors.orange` | `FudiColors.warningOrange` |
| `Colors.blue` | `FudiColors.info` |
| `Color(0x0DFA4743)` (branch selected bg) | `FudiColors.destructiveVibrant.withValues(alpha: 0.05)` |
| `Color(0xFFFFB300)` (stars) | `FudiColors.yellow` |

### Pendiente (fuera de scope de la sesión)

Los siguientes archivos en otras features aún contienen colores hardcodeados (`lib/features/landing/presentation/`, `lib/features/explore/presentation/`, `lib/features/offers/presentation/`, `lib/features/orders/presentation/`, `lib/features/home/presentation/`, `lib/features/favorites/presentation/`, `lib/features/profile/presentation/`, `lib/features/all_offers/presentation/`).
