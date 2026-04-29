# Fudi Analytics Architecture

## Decision de Herramienta

**Primaria:** Firebase Analytics + Mixpanel
**Razon:**
- Firebase Analytics: gratuito, integracion nativa con Flutter, automatic events, audience segmentation, integracion con Crashlytics/Sentry
- Mixpanel: funnel analysis avanzado, cohortes, retencion, consultas ad-hoc, mejor para equipo de producto

**Alternativa considerada:** PostHope (self-hosted, mas barato a escala) - descartado por fase 1 por complejidad de infra.

## Capas de Analitica

```
lib/core/analytics/
  analytics_service.dart       # Facade singleton
  analytics_provider.dart      # Provider Riverpod
  events/                      # Eventos tipados por feature
    auth_events.dart
    offer_events.dart
    order_events.dart
    payment_events.dart
    navigation_events.dart
    business_events.dart
  trackers/                    # Trackers por herramienta
    firebase_tracker.dart
    mixpanel_tracker.dart
  models/
    analytics_event.dart       # Modelo base
    user_properties.dart       # Propiedades de usuario
```

## Interfaz

```dart
abstract class AnalyticsService {
  /// Trackea un evento tipado
  Future<void> track(AnalyticsEvent event);
  
  /// Identifica un usuario con sus propiedades
  Future<void> identify(String userId, UserProperties properties);
  
  /// Actualiza propiedades del usuario actual
  Future<void> setUserProperties(UserProperties properties);
  
  /// Limpia identidad al logout
  Future<void> reset();
  
  /// Activa/desactiva tracking (consent)
  void setEnabled(bool enabled);
  
  /// Establece el consentimiento de analytics
  void setAnalyticsConsent(bool granted);
}
```

## Eventos por Feature

### Auth

| Evento | Props | Descripcion |
|--------|-------|-------------|
| `auth_login_started` | method (email, google, apple) | Usuario inicia login |
| `auth_login_completed` | method, is_new_user | Login exitoso |
| `auth_login_failed` | method, error_type | Login fallo |
| `auth_signup_completed` | method, role | Registro exitoso |
| `auth_logout` | - | Cierre de sesion |
| `auth_session_expired` | - | Sesion expiro |

### Offers (Discovery)

| Evento | Props | Descripcion |
|--------|-------|-------------|
| `offer_list_viewed` | source (home, explore, search), filters, count | Lista de ofertas visible |
| `offer_detail_viewed` | offer_id, business_id, price, discount_pct | Detalle de oferta |
| `offer_search_performed` | query, category, results_count | Busqueda ejecutada |
| `offer_filter_applied` | filter_type, filter_value | Filtro aplicado |
| `offer_map_interaction` | action (pan, zoom, tap_marker) | Interaccion con mapa |

### Orders (Conversion)

| Evento | Props | Descripcion |
|--------|-------|-------------|
| `order_reserve_started` | offer_id, business_id, amount | Inicio de reserva |
| `order_payment_initiated` | order_id, amount, payment_method | Pago iniciado |
| `order_payment_completed` | order_id, amount, gateway | Pago completado |
| `order_payment_failed` | order_id, error_type | Pago fallo |
| `order_pickup_confirmed` | order_id, business_id | Recogida confirmada |
| `order_cancelled` | order_id, reason, by (user, business, system) | Orden cancelada |

### Business (Operacion)

| Evento | Props | Descripcion |
|--------|-------|-------------|
| `business_offer_created` | business_id, offer_id, price | Oferta creada |
| `business_offer_updated` | business_id, offer_id, change_type | Oferta editada |
| `business_offer_disabled` | business_id, offer_id, reason | Oferta deshabilitada |
| `business_order_managed` | business_id, order_id, action | Accion sobre orden |
| `business_dashboard_viewed` | business_id | Dashboard visible |

### Navigation

| Evento | Props | Descripcion |
|--------|-------|-------------|
| `screen_viewed` | screen_name, source, role | Pantalla vista |
| `bottom_nav_tapped` | tab_index, tab_name | Tab navegado |

## User Properties

| Propiedad | Tipo | Actualizacion |
|-----------|------|---------------|
| `user_id` | string | On login |
| `role` | enum | On login/switch |
| `city` | string | On location change |
| `signup_date` | date | On signup |
| `total_orders` | int | On order completion |
| `total_saved` | decimal | On order completion |
| `favorite_categories` | array | On preference change |
| `notification_radius_km` | int | On preference change |
| `is_business` | bool | On login |
| `business_id` | string | On login (if business) |

## Funnels Criticos

### 1. Discovery-to-Reserve

```
offer_list_viewed -> offer_detail_viewed -> order_reserve_started -> order_payment_initiated -> order_payment_completed
```

**Conversion targets fase 1:**
- List to Detail: > 30%
- Detail to Reserve: > 15%
- Reserve to Payment: > 80%
- Payment to Completed: > 95%

### 2. Business Onboarding

```
business_signup -> business_profile_created -> first_offer_created -> first_order_received
```

### 3. Pickup Flow

```
order_payment_completed -> order_pickup_confirmed
```

**Target:** > 90% pickup rate

## Metricas de Negocio (Business Analytics)

### KPIs de Platforma

| Metrica | Formula | Frecuencia |
|---------|---------|------------|
| GMV | sum(order.amount) where status=completed | Diaria |
| Take Rate | platform_fee / GMV | Diaria |
| Orders per User | count(orders) / count(active_users) | Semanal |
| Avg Order Value | avg(order.amount) | Diaria |
| Pickup Rate | pickup_confirmed / payment_completed | Diaria |
| Offer Fill Rate | orders / available_offers | Diaria |
| Active Businesses | count(businesses with >=1 order in period) | Semanal |
| User Retention D7/D30 | % users returning day 7/30 | Semanal |

### KPIs de Negocio (por business)

| Metrica | Formula |
|---------|---------|
| Revenue | sum(net_amount) en periodo |
| Orders | count(orders) en periodo |
| Avg Order Value | revenue / orders |
| Top Category | category con mas orders |
| Peak Hours | horas con mas pickups |
| Waste Reduction | estimated_waste - remaining_stock |

## Consentimiento y Privacidad

- Analytics deshabilitado por defecto hasta consentimiento explicito
- `setAnalyticsConsent(bool)` controla Firebase + Mixpanel
- No trackear PII en eventos (nombre, email, telefono)
- User IDs hasheados si se requiere anonimizacion parcial
- GDPR: derecho a eliminacion de datos de analitica
- Retencion: 24 meses para datos crudos, indefinido para agregados

## Integracion con Sentry

- `Sentry.setTag('analytics_enabled', true/false)` para correlacion
- Breadcrumbs de eventos de analitica en Sentry para contexto de errores
- No enviar eventos de Sentry como eventos de analitica (separacion de concerns)

## Configuracion por Ambiente

| Variable | Dev | Staging | Prod |
|----------|-----|---------|------|
| `FIREBASE_PROJECT_ID` | fudi-dev | fudi-staging | fudi-prod |
| `MIXPANEL_TOKEN` | dev-token | staging-token | prod-token |
| `ANALYTICS_ENABLED` | true | true | true |
| `ANALYTICS_DEBUG` | true | false | false |
