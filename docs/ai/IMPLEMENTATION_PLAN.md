# Plan de Implementacion Fudi: Mockup React a Flutter + Supabase

> **Para Hermes:** Usar subagent-driven-development para ejecutar este plan tarea por tarea.

**Goal:** Migrar los 40 componentes del mockup React a Flutter con logica real, crear el esquema de base de datos en Supabase, e implementar los flujos core de negocio.

**Architecture:** Clean Architecture + Feature-First. 3 capas (Data/Domain/Presentation) con capas transversales de Error, Analytics, Observabilidad y Network. Supabase como backend (Auth + DB + Storage + Edge Functions). Pasarela de pagos por definir (ver decisión Place to Pay abajo). Sentry para trazabilidad.

**Tech Stack:** Flutter 3.x, Dart, Riverpod, GoRouter, Supabase Flutter, Sentry Flutter, Google Maps Flutter

**Payment Provider Decision:** Place to Pay será la pasarela de pagos (reemplaza MercadoPago). No se agrega SDK de pagos en Phase 0 — la integración se pospone hasta Fase 7. Ver ADR-001 abajo.

**Mockup fuente:** `/mnt/c/Users/emele/Downloads/fudi/src/app/` (40 pantallas, 7 componentes, 3 contextos)

**Repo destino:** `/mnt/c/Users/emele/Repositories/fudi/`

---

## ADR-001: Pasarela de Pagos — Place to Pay

**Status:** Accepted

**Context:** El plan original referenciaba MercadoPago (`mercadopago_sdk`) como pasarela de pagos. El usuario ha decidido usar Place to Pay en su lugar.

**Decision:** Usar Place to Pay como pasarela de pagos primaria. No agregar ningún SDK de pagos en Phase 0. La integración se implementará en Fase 7 con la misma interfaz abstracta `PaymentGateway` definida en PAYMENTS.md.

**Consequences:**
- `mercadopago_sdk` NO se agrega como dependencia
- La interfaz abstracta `PaymentGateway` (PAYMENTS.md) se mantiene — solo cambia la implementación concreta
- Los env vars de configuración cambiarán de `MP_*` a los que Place to Pay requiera
- Los webhooks endpoint cambiarán de `/api/webhooks/payments/mercadopago` a `/api/webhooks/payments/placetopay`
- Los sandbox/test credentials serán los de Place to Pay
- Los modelos de dominio (PaymentIntent, Payout, PaymentEvent) NO cambian — son agnósticos de pasarela

---

## FASE 0: Infraestructura y Herramientas ✅ COMPLETADA

### 0.1 Configurar MCP de Supabase ✅

**Objective:** Habilitar herramientas MCP para crear y gestionar Supabase

**Files:** Modify: `~/.hermes/config.yaml`

**Step 1:** Agregar al config:
```yaml
mcp_servers:
supabase:
command: "npx"
args: ["-y", "@supabase/mcp-server-supabase@latest"]
env:
SUPABASE_ACCESS_TOKEN: "<REQUIERE_TOKEN>"
SUPABASE_PROJECT_ID: "<REQUIERE_PROJECT_ID>"
```

**NOTA:** Se necesitan credenciales de Supabase. Crear proyecto en https://supabase.com primero.

---

### 0.2 Agregar dependencias Flutter ✅

**Objective:** Configurar todas las dependencias necesarias

**Files:** Modify: `pubspec.yaml`

**Dependencies:**
- State: flutter_riverpod, riverpod_annotation
- Navigation: go_router
- Backend: supabase_flutter
- Observabilidad: sentry_flutter
- Analytics: firebase_core, firebase_analytics, mixpanel_flutter
- Maps: google_maps_flutter, geolocator
- UI: cached_network_image, shimmer, flutter_svg, smooth_page_indicator
- Payments: ~~mercadopago_sdk~~ → **Ningún SDK de pagos en Phase 0** (ver ADR-001: Place to Pay)
- Utils: internet_connection_checker, intl, uuid, freezed_annotation, json_annotation, flutter_dotenv, shared_preferences, flutter_secure_storage, dio

**Dev:** build_runner, freezed, json_serializable, riverpod_generator, mocktail

**Verificacion:** `flutter pub get` sin errores

---

### 0.3 Crear estructura de carpetas ✅

**Objective:** Crear directorios segun architect.md

```bash
mkdir -p lib/core/{config,constants,di,error,network,observability,analytics/{events,trackers,models},routing,utils,ui}
mkdir -p lib/features/{auth,home,explore,offers,orders,profile,notifications,business,admin,landing}/{data,domain,presentation}
mkdir -p lib/shared
```

---

### 0.4 Configurar environments y flavors ✅

**Objective:** 3 ambientes (dev/staging/prod) con .env files

**Files:**
- Create: `lib/core/config/app_config.dart` — AppConfig con environment, supabaseUrl, sentryDsn, etc. ✅
- Create: `lib/core/config/app_environment.dart` — enum AppEnvironment { dev, staging, prod } ✅
- Create: `.env.dev`, `.env.staging`, `.env.prod`, `.env.example` ✅

---

### 0.5 Wire main.dart ✅ NUEVO

**Objective:** Conectar la infraestructura en el punto de entrada de la app

**Files:**
- Modify: `lib/main.dart` — Load dotenv, create AppConfig, init Supabase + Sentry, wrap with ProviderScope
- Create: `lib/core/observability/sentry_init.dart` — Sentry initialization per environment
- Create: `lib/core/observability/sentry_breadcrumb.dart` — Structured breadcrumbs (navigation, user_action, api, payment)
- Create: `lib/core/observability/fudi_error_reporter.dart` — Error capture with FudiException context
- Create: `lib/core/di/core_providers.dart` — Riverpod providers for AppConfig, AppEnvironment, SupabaseClient
- Create: `lib/core/routing/app_router.dart` — GoRouter with placeholder home route

**Startup sequence:**
1. `WidgetsFlutterBinding.ensureInitialized()`
2. Resolve `AppEnvironment` from `--dart-define=APP_ENV`
3. `dotenv.load(fileName: environment.envFileName)`
4. `AppConfig.fromEnv(environment)`
5. `Supabase.initialize(url: ..., anonKey: ...)`
6. `initSentry(config)` (only if DSN configured)
7. `runApp(ProviderScope(overrides: [...], child: FudiApp()))`

---

## FASE 1: Core Layer (Fundacion transversal)

### 1.1 Jerarquia FudiException

**Agente:** accessibility-observability

**Files:**
- Create: `lib/core/error/fudi_exception.dart` — Base abstracta con code, severity, feature, userMessage, recovery
- Create: `lib/core/error/network_exceptions.dart` — timeout, noConnection, serverError, rateLimited
- Create: `lib/core/error/auth_exceptions.dart` — unauthenticated, unauthorized, invalidCredentials, sessionExpired
- Create: `lib/core/error/payment_exceptions.dart` — paymentFailed, paymentRejected, refundFailed
- Create: `lib/core/error/business_exceptions.dart` — offerUnavailable, orderInvalidTransition, stockExceeded, pickupWindowExpired
- Create: `lib/core/error/data_exceptions.dart` — notFound, validationError, conflict, cacheExpired
- Test: `test/core/error/fudi_exception_test.dart`

---

### 1.2 Sentry init + breadcrumbs

**Agente:** accessibility-observability

**Files:**
- Create: `lib/core/observability/sentry_init.dart` — DSN por ambiente, release, beforeSend strip PII
- Create: `lib/core/observability/sentry_breadcrumb.dart` — Categories: navigation, api, payment, user_action
- Create: `lib/core/observability/fudi_error_reporter.dart` — Enriquecer con tags[feature], tags[error_code]

---

### 1.3 Analytics service

**Agente:** analytics-growth

**Files:**
- Create: `lib/core/analytics/analytics_service.dart` — Abstracto con track(), setUserProperties()
- Create: `lib/core/analytics/analytics_provider.dart` — Riverpod provider
- Create: `lib/core/analytics/events/` — auth_events, offer_events, order_events, payment_events, navigation_events, business_events
- Create: `lib/core/analytics/trackers/` — firebase_tracker, mixpanel_tracker
- Create: `lib/core/analytics/models/user_properties.dart`

---

### 1.4 Network layer con resiliencia

**Agente:** architect + accessibility-observability

**Files:**
- Create: `lib/core/network/secure_http_client.dart` — Dio con interceptors
- Create: `lib/core/network/retry_policy.dart` — 3 retries, backoff exponencial, solo idempotentes
- Create: `lib/core/network/circuit_breaker.dart` — 5 failures -> open 30s -> half-open
- Create: `lib/core/network/offline_aware_repository.dart` — Cache con stale-while-revalidate

---

### 1.5 Routing con GoRouter + guards

**Agente:** architect

**Files:**
- Create: `lib/core/routing/app_router.dart` — GoRouter con 40+ rutas
- Create: `lib/core/routing/route_guards.dart` — Auth guard + Role guard
- Create: `lib/core/routing/route_names.dart` — Constantes de rutas

**Rutas desde mockup (40 pantallas):**
- Auth: /login, /signup
- Consumer: /, /explore, /product/:id, /checkout/:id, /review-order/:id, /orders, /orders/:id, /favorites, /payment-methods, /saved-addresses
- Profile: /profile, /profile/edit, /profile/notifications, /profile/settings
- Business: /business, /business/orders, /business/orders/:id, /business/products, /business/products/:id, /business/products/:id/edit, /business/statistics, /business/payments, /business/payments/:id, /business/coupons, /business/coupons/:id/edit, /business/locations, /business/locations/:id, /business/locations/:id/edit, /business/notifications, /business/edit, /business/profile, /business/help
- Shared: /for-business, /how-it-works, /help, /about, /terms, /privacy, /landing

---

### 1.6 Dependency Injection con Riverpod

**Agente:** architect

**Files:**
- Create: `lib/core/di/core_providers.dart` — AppConfig, SentryClient, AnalyticsService, SecureHttpClient, GoRouter
- Create: `lib/core/di/supabase_providers.dart` — SupabaseClient singleton

---

## FASE 2: Supabase Schema (Base de datos)

### 2.1 Crear proyecto Supabase

**Paso manual:** Crear proyecto en https://supabase.com, obtener credenciales, configurar .env.dev

---

### 2.2 Migracion: Tablas core

**Modelos fuente del mockup React -> Tablas Supabase:**

| Interface TS | Tabla SQL | Campos clave |
|---|---|---|
| Deal (Home.tsx) | offers | id, business_id, title, image, original_price, discounted_price, rating, stock, pickup_start/end, is_active |
| Business (BusinessProfile.tsx) | businesses | id, owner_id, name, type, slug, image, cover_image, rating, review_count, description, address, phone, email, website, latitude, longitude, commission_rate, balance |
| Order (OrderHistory.tsx) | orders | id, user_id, offer_id, business_id, order_number, status, price, original_price, pickup_code, pickup_time |
| Coupon (BusinessCoupons.tsx) | coupons | id, business_id, code, name, type, value, min_order_amount, max_uses, used_count, is_active, expires_at |
| Payout (BusinessPayments.tsx) | payouts | id, business_id, amount, status, period_start, period_end |
| Favorite (Favorites.tsx) | favorites | id, user_id, offer_id |
| Location (BusinessLocations.tsx) | business_locations | id, business_id, name, address, phone, latitude, longitude |

**Tablas adicionales (no en mockup pero necesarias):**
- profiles (extiende auth.users, con role)
- business_hours
- order_items
- payment_intents (ver PAYMENTS.md)
- payment_events (log de webhooks)
- reviews
- user_consents (analytics)
- saved_addresses

**Metodo:** Usar MCP de Supabase (si configurado) o Supabase CLI para aplicar migraciones SQL

---

### 2.3 RLS Policies

**Reglas por rol (ver business-logic.md):**

- profiles: usuario ve propio, admin ve todos
- businesses: publico lee activos, owner gestiona propios
- offers: publico lee activos con stock, business gestiona propios
- orders: usuario ve propios, business ve de sus offers
- favorites: usuario gestiona propios
- coupons: publico lee activos, business gestiona propios
- payment_intents: usuario ve propios, business ve de sus orders
- payouts: business ve propios

---

### 2.4 Edge Functions

- `reserve-offer` — Reserva atomica (decrement stock + create order)
- `handle-payment-webhook` — Recibe webhook de pasarela de pagos (Place to Pay), actualiza payment_intents y orders
- `process-payout` — Payout semanal automatico a negocios

---

### 2.5 SQL Functions y triggers

- `reserve_offer()` — Reserva atomica con optimistic concurrency
- `generate_order_number()` — Auto-generar FD-YYYY-MMDD-NNN
- `generate_pickup_code()` — Codigo 6 chars aleatorio
- `update_business_rating()` — Trigger en reviews
- `check_offer_expiry()` — Auto-disable cuando stock=0

---

### 2.6 Seed data

**Extraer desde mockup React:**
- MOCK_DEALS -> INSERT offers
- MOCK_BUSINESS_PRODUCTS -> INSERT offers
- MOCK_ALL_ORDERS -> INSERT orders
- MOCK_PAYOUTS -> INSERT payouts
- Business data -> INSERT businesses

---

## FASE 3: Auth (Login + Signup + Session) ✅ COMPLETADA

### 3.1 Auth domain layer ✅

**Agente:** business-logic

**Files:**
- Create: `lib/features/auth/domain/user_profile.dart` — Modelo Dart
- Create: `lib/features/auth/domain/auth_repository.dart` — Interface abstracta
- Create: `lib/features/auth/domain/app_mode.dart` — enum AppMode { consumer, business }

---

### 3.2 Auth data layer (Supabase) ✅

**Files:**
- Create: `lib/features/auth/data/supabase_auth_repository.dart` — Implementacion real

---

### 3.3 Login screen ✅

**Agente:** migration-specialist + ux-ui

**Mockup:** `/mnt/c/Users/emele/Downloads/fudi/src/app/pages/Login.tsx`
**Flutter:** `lib/features/auth/presentation/login_screen.dart`

**Mockup tiene:** email + password + "Iniciar Sesion" + link signup + divider + Google/Apple social + "Olvidaste contrasena"
**Logica NUEVA:** validacion real, Supabase Auth signIn, Sentry breadcrumb, Analytics events, error handling tipado

---

### 3.4 Signup screen ✅

**Mockup:** `Signup.tsx` -> `lib/features/auth/presentation/signup_screen.dart`
**Logica NUEVA:** Supabase Auth signUp, seleccion de rol (user/business), crear profile, consentimiento analytics

---

### 3.5 Session management ✅

**Files:** `lib/features/auth/presentation/auth_state_provider.dart`
**Logica:** Auth state changes, redirect automatico, token refresh, session expired handling, password recovery handling, update password flow.

---

## FASE 4: UI Components (Component library)

### 4.1 Theme y tokens

**Agente:** component-library

**Colores del mockup (theme.css):**
- primary: #256646 (verde oscuro)
- secondary: #E3F7BE (verde claro)
- accent: #359C6B (verde medio)
- ring: #B8E822 (lima vibrante)
- destructive: #EF4444
- muted: #F8F8F8
- mutedForeground: #737373

**Files:**
- Create: `lib/core/ui/fudi_colors.dart`
- Create: `lib/core/ui/fudi_theme.dart`
- Create: `lib/core/ui/fudi_typography.dart`

---

### 4.2 Componentes base

| Componente React | Widget Flutter | Archivo |
|---|---|---|
| BottomNav.tsx | FudiBottomNav | lib/core/ui/fudi_bottom_nav.dart |
| Filters.tsx | FudiFilters | lib/core/ui/fudi_filters.dart |
| StarRating.tsx | FudiStarRating | lib/core/ui/fudi_star_rating.dart |
| SplashScreen.tsx | FudiSplashScreen | lib/core/ui/fudi_splash_screen.dart |
| AppLogo.tsx | FudiLogo | lib/core/ui/fudi_logo.dart |
| Layout.tsx | FudiScaffold | lib/core/ui/fudi_scaffold.dart |
| MapView.tsx | FudiMapView | lib/core/ui/fudi_map_view.dart |

---

### 4.3 Cards recurrentes

- `deal_card.dart` — Usado en Home, Explore, Favorites
- `product_card.dart` — Usado en BusinessProducts
- `order_card.dart` — Usado en OrderHistory, BusinessOrders
- `business_card.dart` — Usado en search results

---

## FASE 5: Features Consumer

### 5.1 Home screen

**Mockup:** Home.tsx (Deal interface + MOCK_DEALS)
**Flutter:** home_screen.dart + home_controller.dart + popular_deals_section + nearby_deals_section
**Logica NUEVA:** Geolocator, query Supabase offers, Google Maps markers, shimmer loading, pull-to-refresh, offline cache, analytics

---

### 5.2 Explore screen

**Mockup:** Explore.tsx (FilterState interface)
**Flutter:** explore_screen.dart + map_view.dart + filter_sheet.dart + offer_list_view.dart

---

### 5.3 Offers flow (ProductDetail + Checkout + ReviewOrder)

**Mockup:** ProductDetail.tsx, Checkout.tsx (Product interface), ReviewOrder.tsx
**Logica CRITICA NUEVA:**
- Edge Function reserve-offer
- PaymentIntent via pasarela de pagos (Place to Pay — ver ADR-001)
- Checkout redirect
- Deep link de retorno
- Payment timeout 5 min
- Sentry: payment_flow events
- Analytics: checkout_started, purchase_completed

---

### 5.4 Orders (OrderHistory + OrderDetail)

**Mockup:** OrderHistory.tsx (Order interface), OrderDetail.tsx (OrderDetail + StatusChange interfaces)
**Logica NUEVA:** Real-time subscription a cambios, status timeline, pickup code display, cancel + refund

---

### 5.5 Profile + Settings (6 pantallas)

**Mockup:** Profile.tsx, EditProfile.tsx, NotificationSettings.tsx, GeneralSettings.tsx, PaymentMethods.tsx, SavedAddresses.tsx, Favorites.tsx

---

### 5.6 Pantallas informativas (7 pantallas)

**Mockup:** HelpCenter.tsx, About.tsx, Terms.tsx, Privacy.tsx, HowItWorks.tsx, Landing.tsx, ForBusiness.tsx
**Naturaleza:** Estaticas, las mas simples

---

## FASE 6: Features Business (Dashboard de negocios)

### 6.1 Business mode switching

**Mockup:** AppModeContext.tsx -> business_mode_provider.dart
**Logica:** Toggle consumer/business, solo si user tiene business asociado, BottomNav cambia

---

### 6.2 Business Products (3 pantallas)

**Mockup:** BusinessProducts.tsx (Product interface), BusinessProductDetail.tsx, BusinessProductEdit.tsx
**Logica:** CRUD offers via Supabase, image upload a Storage, toggle is_active, stock management

---

### 6.3 Business Orders + Statistics + Payments (4 pantallas)

**Mockup:** BusinessOrders.tsx, BusinessOrderDetail.tsx (OrderDetail + StatusChange), BusinessStatistics.tsx, BusinessPayments.tsx (Payout interface), BusinessPaymentDetail.tsx (PaymentDetail interface)
**Logica:** Confirm pickup (Order -> completed), cancel order + refund, statistics query, payout tracking

---

### 6.4 Business Locations + Coupons (5 pantallas)

**Mockup:** BusinessLocations.tsx (Location interface), BusinessLocationDetail.tsx, BusinessLocationEdit.tsx, BusinessCoupons.tsx (Coupon interface), BusinessCouponEdit.tsx (CouponForm interface)

---

### 6.5 Business Profile + Notifications + Help + Edit (4 pantallas)

**Mockup:** BusinessProfile.tsx (Business interface), BusinessNotifications.tsx (NotificationSetting), BusinessEdit.tsx (BusinessForm), BusinessHelp.tsx (FAQItem)

---

## FASE 7: Integraciones de Terceros

### 7.1 Place to Pay integration (reemplaza MercadoPago — ver ADR-001)

**Agente:** payments + integrations

**Files:**
- Create: `lib/core/network/payment_gateway.dart` — Interface abstracta (sin cambios, agnóstica de pasarela)
- Create: `lib/features/offers/data/placetopay_gateway.dart` — Implementación Place to Pay
- Create: `lib/features/offers/data/mock_payment_gateway.dart` — Para testing

**Ver PAYMENTS.md para flujos completos.** Los modelos de dominio (PaymentIntent, PaymentEvent, etc.) no cambian. Solo la implementación concreta de la pasarela cambia de MercadoPago a Place to Pay.

---

### 7.2 Google Maps integration

**Files:**
- Create: `lib/core/network/maps_service.dart` — Interface
- Create: `lib/features/home/data/google_maps_service.dart` — Implementacion

---

### 7.3 Push notifications

**Files:**
- Create: `lib/core/network/push_service.dart` — Interface
- Create: `lib/features/notifications/data/firebase_push_service.dart`

---

## FASE 8: Testing

### 8.1 Unit tests

**Agente:** test-engineer

- FudiException hierarchy
- Business logic (order state machine, offer availability)
- Repository mocking con mocktail
- Payment flow validation
- Retry policy + circuit breaker

---

### 8.2 Widget tests

- Component library (deal_card, filters, star_rating, bottom_nav)
- Auth screens (login, signup)
- Home screen
- Checkout flow

---

### 8.3 Integration tests

- Full auth flow (signup -> login -> session)
- Full order flow (browse -> reserve -> pay -> pickup)
- Business flow (create offer -> receive order -> confirm pickup)

---

## FASE 9: CI/CD + Release

### 9.1 GitHub Actions

**Agente:** deployment-sre

- lint + test on PR
- build + deploy on merge to main
- Sentry release + sourcemaps/dSYMs on deploy
- Flavors (dev/staging/prod)

---

### 9.2 Store deployment

- Apple App Store: signing cert + provisioning profile + TestFlight
- Google Play: signing keystore + internal track

---

## Resumen de Mapeo Mockup -> Flutter

| # | Pantalla Mockup | Ruta Flutter | Fase | Prioridad |
|---|---|---|---|---|
| 1 | Login.tsx | /login | 3 | P0 |
| 2 | Signup.tsx | /signup | 3 | P0 |
| 3 | Home.tsx | / | 5 | P0 |
| 4 | Explore.tsx | /explore | 5 | P0 |
| 5 | ProductDetail.tsx | /product/:id | 5 | P0 |
| 6 | Checkout.tsx | /checkout/:id | 5 | P0 |
| 7 | ReviewOrder.tsx | /review-order/:id | 5 | P0 |
| 8 | OrderHistory.tsx | /orders | 5 | P0 |
| 9 | OrderDetail.tsx | /orders/:id | 5 | P0 |
| 10 | Profile.tsx | /profile | 5 | P1 |
| 11 | EditProfile.tsx | /profile/edit | 5 | P1 |
| 12 | Favorites.tsx | /favorites | 5 | P1 |
| 13 | PaymentMethods.tsx | /payment-methods | 5 | P1 |
| 14 | SavedAddresses.tsx | /saved-addresses | 5 | P2 |
| 15 | NotificationSettings.tsx | /profile/notifications | 5 | P2 |
| 16 | GeneralSettings.tsx | /profile/settings | 5 | P2 |
| 17 | BusinessProducts.tsx | /business/products | 6 | P0 |
| 18 | BusinessProductDetail.tsx | /business/products/:id | 6 | P0 |
| 19 | BusinessProductEdit.tsx | /business/products/:id/edit | 6 | P0 |
| 20 | BusinessOrders.tsx | /business/orders | 6 | P0 |
| 21 | BusinessOrderDetail.tsx | /business/orders/:id | 6 | P0 |
| 22 | BusinessStatistics.tsx | /business/statistics | 6 | P1 |
| 23 | BusinessPayments.tsx | /business/payments | 6 | P1 |
| 24 | BusinessPaymentDetail.tsx | /business/payments/:id | 6 | P1 |
| 25 | BusinessCoupons.tsx | /business/coupons | 6 | P2 |
| 26 | BusinessCouponEdit.tsx | /business/coupons/:id/edit | 6 | P2 |
| 27 | BusinessLocations.tsx | /business/locations | 6 | P2 |
| 28 | BusinessLocationDetail.tsx | /business/locations/:id | 6 | P2 |
| 29 | BusinessLocationEdit.tsx | /business/locations/:id/edit | 6 | P2 |
| 30 | BusinessNotifications.tsx | /business/notifications | 6 | P2 |
| 31 | BusinessEdit.tsx | /business/edit | 6 | P1 |
| 32 | BusinessProfile.tsx | /business/profile | 6 | P1 |
| 33 | BusinessHelp.tsx | /business/help | 6 | P2 |
| 34 | Landing.tsx | /landing | 5 | P2 |
| 35 | ForBusiness.tsx | /for-business | 5 | P2 |
| 36 | HowItWorks.tsx | /how-it-works | 5 | P2 |
| 37 | HelpCenter.tsx | /help | 5 | P2 |
| 38 | About.tsx | /about | 5 | P2 |
| 39 | Terms.tsx | /terms | 5 | P1 |
| 40 | Privacy.tsx | /privacy | 5 | P1 |

---

## Resumen de Interfaces Mockup -> Modelos Dart

| Interface TS | Modelo Dart | Tabla SQL |
|---|---|---|
| Deal | Offer | offers |
| Product (Checkout) | Offer (mismo) | offers |
| Product (Business) | BusinessOffer | offers (con sold, is_active) |
| Order (Consumer) | Order | orders |
| OrderDetail | OrderDetail | orders (extendida) |
| StatusChange | OrderStatusChange | (computed from order events) |
| Business | Business | businesses |
| Location | BusinessLocation | business_locations |
| LocationDetail | BusinessLocationDetail | business_locations |
| LocationForm | BusinessLocationForm | (form model, no table) |
| Coupon | Coupon | coupons |
| CouponForm | CouponForm | (form model, no table) |
| Payout | Payout | payouts |
| PaymentDetail | PaymentDetail | payment_intents |
| Favorite | Favorite | favorites |
| FilterState | FilterState | (state only, no table) |
| NotificationSetting | NotificationSetting | (local preferences) |
| BusinessForm | BusinessForm | (form model) |
| FAQItem | FAQItem | (static content) |
| AppMode | AppMode | profiles.role |
| MapDeal | MapOffer | offers (con lat/lng de business) |

---

## Orden de ejecucion recomendado

```
FASE 0 (infra) -> FASE 1 (core) -> FASE 4.1-4.2 (theme + componentes base)
-> FASE 3 (auth) -> FASE 2 (supabase schema, puede ser paralelo con FASE 3)
-> FASE 5 (consumer features P0) -> FASE 6 (business features P0)
-> FASE 7 (integraciones) -> FASE 5-6 (P1) -> FASE 8 (testing)
-> FASE 5-6 (P2) -> FASE 9 (CI/CD + release)
```

**Dependencias criticas:**
- Auth (FASE 3) debe estar antes que cualquier feature con datos reales
- Supabase schema (FASE 2) debe estar antes que repositories con datos reales
- Core (FASE 1) debe estar antes que todo lo demas
- Theme (FASE 4.1) debe estar antes que pantallas
- Payments (FASE 7.1) debe estar antes que Checkout funcional

**Paralelizable:**
- FASE 2 y FASE 3 pueden ir en paralelo
- FASE 5 y FASE 6 pueden ir en paralelo (consumer vs business)
- Testing (FASE 8) es continuo, no esperar al final
