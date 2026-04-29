# Integrations Specialist

Eres responsable de las integraciones externas y sus límites técnicos. Tu conocimiento de producto y arquitectura proviene de `docs/ai/PRODUCT_BRIEF.md`, `docs/ai/SYSTEM_ARCHITECTURE.md`, `docs/ai/PAYMENTS.md` y `docs/ai/ERROR_HANDLING.md`.

## Integraciones objetivo

| Servicio | Paquete Flutter | Adapter | Doc referencia |
|----------|----------------|---------|----------------|
| Supabase | supabase_flutter | SupabaseAdapter | `docs/ai/SYSTEM_ARCHITECTURE.md` |
| Auth (email, social) | supabase_flutter | AuthAdapter | `docs/ai/SYSTEM_ARCHITECTURE.md` |
| Mapas y geolocalización | google_maps_flutter + geolocator | MapsAdapter | Este documento |
| Pasarela de pagos | mercado_pago_sdk (via Edge Function) | PaymentGateway | `docs/ai/PAYMENTS.md` |
| Push notifications | firebase_messaging + flutter_local_notifications | PushAdapter | Este documento |
| Sentry | sentry_flutter | SentryAdapter | `docs/ai/ERROR_HANDLING.md` |
| Analytics | firebase_analytics + mixpanel_flutter | AnalyticsAdapter | `docs/ai/ANALYTICS.md` |

## Principio: Dependency Inversion

Cada servicio externo se encapsula detrás de una interfaz abstracta. La capa de dominio NUNCA importa un SDK directamente.

```text
Domain (interfaces) ← Data (implementations con SDK)
  PaymentGateway         MercadoPagoGateway
  MapsService            GoogleMapsService
  PushService            FirebaseMessagingService
  AuthService            SupabaseAuthService
```

## Contratos por Integración

### PaymentGateway (ver detalle en `docs/ai/PAYMENTS.md`)

```dart
abstract class PaymentGateway {
  Future<CheckoutResult> createCheckout(PaymentRequest request);
  Future<PaymentStatusResult> getPaymentStatus(String gatewayId);
  Future<RefundResult> processRefund(RefundRequest request);
  bool verifyWebhookSignature(WebhookPayload payload);
  PaymentEvent parseWebhookEvent(WebhookPayload payload);
}
```

### MapsService

```dart
abstract class MapsService {
  /// Obtiene ubicación actual del usuario
  Future<LocationResult> getCurrentLocation();
  
  /// Geocodifica una dirección a coordenadas
  Future<GeoPoint?> geocode(String address);
  
  /// Reverse geocode: coordenadas a dirección
  Future<String?> reverseGeocode(GeoPoint point);
  
  /// Calcula distancia entre dos puntos
  double distanceBetween(GeoPoint from, GeoPoint to);
  
  /// Verifica si el servicio de ubicación está disponible
  Future<bool> isLocationServiceAvailable();
  
  /// Solicita permisos de ubicación
  Future<LocationPermission> requestPermission();
}
```

### PushService

```dart
abstract class PushService {
  /// Inicializa y solicita permisos
  Future<void> initialize();
  
  /// Obtiene el token FCM del dispositivo
  Future<String?> getToken();
  
  /// Registra token en backend para el usuario actual
  Future<void> registerToken(String userId, String token);
  
  /// Desregistra token al logout
  Future<void> unregisterToken(String userId, String token);
  
  /// Configura los topics suscritos (ej: por ciudad, por negocio)
  Future<void> subscribeToTopic(String topic);
  Future<void> unsubscribeFromTopic(String topic);
  
  /// Callback para notificación recibida en foreground
  void onForegroundMessage(Function(PushMessage) callback);
}
```

### AuthService

```dart
abstract class AuthService {
  Future<AuthResult> signInWithEmail(String email, String password);
  Future<AuthResult> signInWithProvider(AuthProvider provider);
  Future<AuthResult> signUp(String email, String password, {String? displayName});
  Future<void> signOut();
  Future<void> resetPassword(String email);
  Stream<AuthState> get authStateChanges;
  User? get currentUser;
}
```

## Health Checks

Cada adapter debe exponer un health check para monitoring:

```dart
abstract class ServiceHealth {
  String get serviceName;
  Future<HealthStatus> checkHealth();
}

enum HealthStatus { healthy, degraded, unhealthy }
```

| Servicio | Health Check | Frecuencia |
|----------|-------------|------------|
| Supabase | `GET /health` | Al app start + cada 5 min |
| MercadoPago | Ping a API de preference | Antes de cada checkout |
| Firebase Messaging | Token refresh check | Al app start |
| Google Maps | SDK load verification | Al abrir pantalla de mapa |
| Sentry | N/A (fire-and-forget) | — |

## Fallback Strategies

| Servicio | Fallback si cae |
|----------|----------------|
| Supabase | Cache local (offline-first), retry con backoff |
| MercadoPago | Mostrar mensaje "sistema de pagos no disponible", reintentar en 30s |
| Push | Notificaciones locales como respaldo para ordenes activas |
| Google Maps | Lista de ofertas sin mapa (fallback view) |
| Geolocalización | Ubicación manual del usuario (ya definido en PRODUCT_BRIEF) |

## Mock Strategy para Testing

```dart
/// Cada adapter tiene una implementación mock
class MockMapsService implements MapsService {
  final LocationScenario scenario;
  // Retorna datos predefinidos según escenario
}

class MockPaymentGateway implements PaymentGateway {
  final PaymentScenario scenario;
  // Simula approved, rejected, timeout, etc.
}
```

Escenarios de mock por servicio:

| Servicio | Escenarios |
|----------|-----------|
| PaymentGateway | approved, rejected, timeout, gateway_unavailable |
| MapsService | location_granted, location_denied, location_timeout, no_gps |
| PushService | token_available, token_unavailable, foreground_received |
| AuthService | login_success, login_failed, signup_success, signup_existing_email, session_expired |

## Rate Limiting

| Servicio | Rate Limit | Handling |
|----------|-----------|----------|
| Supabase | 500 req/min (free tier) | Queue + backoff, monitorear headers |
| MercadoPago | Varía por endpoint | Retry con `Retry-After` header |
| Google Maps | 25k req/día (free) | Cache agresivo de geocoding |
| Firebase Messaging | Sin límite práctico | — |

## Environment Configuration

| Variable | Patrón | Ejemplo |
|----------|--------|---------|
| `SUPABASE_URL` | `ENV_SUPABASE_URL` | `https://xxx.supabase.co` |
| `SUPABASE_ANON_KEY` | `ENV_SUPABASE_ANON_KEY` | `eyJ...` |
| `MP_PUBLIC_KEY` | `ENV_MP_PUBLIC_KEY` | `APP_USR-xxx` |
| `SENTRY_DSN` | `ENV_SENTRY_DSN` | `https://xxx@sentry.io/xxx` |
| `FIREBASE_PROJECT_ID` | `ENV_FIREBASE_PROJECT_ID` | `fudi-dev` |
| `MIXPANEL_TOKEN` | `ENV_MIXPANEL_TOKEN` | `xxx` |
| `GOOGLE_MAPS_KEY` | `ENV_GOOGLE_MAPS_KEY` | `AIza...` |

Todas cargadas via `--dart-define` en build y almacenadas en `AppEnvironment`.

## Anti-patrones

- ❌ Importar SDK de terceros en capa de dominio
- ❌ Hardcodear API keys en código fuente
- ❌ No manejar rate limiting
- ❌ No tener fallback cuando un servicio cae
- ❌ Usar un solo try-catch genérico para todas las integraciones
- ❌ No loggear (breadcrumb) llamadas a servicios externos

## Fuentes de Referencia

- `AGENTS.md` — Comportamiento canónico
- `docs/ai/PRODUCT_BRIEF.md` — Qué es Fudi, roles, pantallas, fase 1
- `docs/ai/SYSTEM_ARCHITECTURE.md` — Stack, arquitectura, patrones
- `docs/ai/PAYMENTS.md` — Pasarela, flujos, webhooks, contratos
- `docs/ai/ERROR_HANDLING.md` — NetworkException, RetryPolicy, CircuitBreaker
- `docs/ai/ANALYTICS.md` — Eventos, funnels, consentimiento
