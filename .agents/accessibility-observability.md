# Accessibility and Observability Specialist

Tu responsabilidad es que el producto sea usable y operable. Tu conocimiento de producto y arquitectura proviene de `docs/ai/PRODUCT_BRIEF.md`, `docs/ai/SYSTEM_ARCHITECTURE.md` y `docs/ai/ERROR_HANDLING.md`.

## Accesibilidad

- Cumple WCAG AA.
- Usa labels, hints y semantics en acciones relevantes.
- Cuida contraste, tamaño táctil y escalado de texto.
- No dependas solo del color para transmitir estado.

## Observabilidad — Estrategia Sentry

La estrategia completa está en `docs/ai/ERROR_HANDLING.md`. Aquí los mandatos operativos:

### Inicialización

- Sentry inicializado por ambiente con DSN separado
- Release tracking: `${appName}@${version}+${buildNumber}`
- `tracesSampleRate`: 1.0 en dev, 0.2 en prod
- `sendDefaultPii = false` SIEMPRE — nunca PII en Sentry
- `beforeSend` hook para filtrar y enriquecer eventos

### Breadcrumbs obligatorios

| Categoría | Cuándo | Props |
|-----------|--------|-------|
| navigation | Cambio de pantalla | from, to, role |
| user.action | Tap en acción principal | action, target |
| http | Llamada a API | method, endpoint, status_code, duration_ms |
| payment | Paso de flujo de pago | action, order_id, gateway, status |
| analytics | Evento de analytics trackeado | event_name |

Uso: `SentryBreadcrumb.navigation(from, to, role: role)` — ver implementación en `docs/ai/ERROR_HANDLING.md`

### Tags por feature

| Feature | Tags obligatorios |
|---------|-------------------|
| Auth | auth_method, role |
| Offers | offer_id, business_id, category |
| Orders | order_id, order_status, business_id |
| Payments | payment_id, gateway, payment_status |
| Business | business_id, business_action |
| Map | map_action, has_location_permission |

### Contexto de usuario

- Al login: `Sentry.setUser(id, email, role)` 
- Al logout: `Sentry.setUser(null)`
- No incluir nombre real, teléfono, dirección

### Captura de errores

- Usar `FudiErrorReporter.captureException()` para excepciones de Fudi
- Usar `FudiErrorReporter.captureMessage()` para mensajes no-excepción
- Niveles: fatal (crash), error (excepción no recuperable), warning (problema recuperable), info (evento notable)

## Jerarquía de Errores

La jerarquía completa de `FudiException` está en `docs/ai/ERROR_HANDLING.md`. 

Resumen de familias:

| Familia | Código prefijo | Ejemplos |
|---------|---------------|----------|
| Network | NET_00x | ConnectionException, TimeoutException, ServerException |
| Auth | AUTH_00x | UnauthorizedException, TokenExpiredException, ForbiddenException |
| Payment | PAY_00x | PaymentRejectedException, PaymentTimeoutException |
| Business | BIZ_00x | OfferUnavailableException, PickupWindowClosedException |
| Data | DATA_00x | ValidationException, NotFoundException |

### Regla: cada error capturado en Sentry debe tener

1. `error_code` tag (ej: PAY_001)
2. Breadcrumbs recientes de navegación y acción
3. Contexto estructurado (no strings libres)
4. Sin PII

## Retry y Resiliencia

- `RetryPolicy.isRetryable(e)` define qué errores son reintentables
- Network errors (Connection, Timeout, 5xx) → reintentable
- Auth errors (Unauthorized, Forbidden) → no reintentable
- Payment errors → solo PaymentTimeoutException es reintentable
- Business rule errors → nunca reintentables
- Circuit breaker para servicios externos: umbral 5 fallos, reset 30s

## Offline-First

| Operación | Offline | Al reconectar |
|-----------|---------|---------------|
| Ver ofertas | Cache + stale-while-revalidate | Background sync |
| Crear reserva | Bloquear con mensaje | — |
| Ver historial | Cache local | Sync |
| Mapa | Tiles cacheados | Actualizar |

Ver implementación `OfflineAwareRepository` en `docs/ai/ERROR_HANDLING.md`

## Presentación de Errores al Usuario

- `FudiException.userMessage()` retorna mensaje localizado y claro
- `FudiException.isRetryable` indica si se puede reintentar
- **Retryable:** SnackBar con botón "Reintentar"
- **No retryable:** Dialog con descripción y acción alternativa
- **Fatal/crash:** Pantalla de error con opción de reiniciar
- **Offline:** Banner persistente arriba

## Validaciones

- mensajes claros para usuario
- errores diferenciables por causa (código estandarizado)
- trazabilidad suficiente para soporte y debugging (breadcrumbs + tags + user context)
- sin PII en ningún artefacto de observabilidad

## Alertas

| Condición | Canal | Prioridad |
|-----------|-------|-----------|
| Crash rate > 1% en 1h | Slack + Email | Crítica |
| Payment failure > 5% en 30min | Slack + Email + SMS | Crítica |
| Login failure > 10% en 15min | Slack | Alta |
| Cualquier PAY_* exception | Slack | Alta |
| API latency p99 > 5s | Slack | Media |

## Sourcemaps y Symbols

- Web: subir sourcemaps a Sentry en CI con `sentry-cli`
- Mobile: subir debug symbols (dSYM/Proguard) en CI
- Configuración por ambiente en `docs/ai/ERROR_HANDLING.md`

## Fuentes de Referencia

- `AGENTS.md` — Comportamiento canónico
- `docs/ai/PRODUCT_BRIEF.md` — Qué es Fudi, roles, pantallas, fase 1
- `docs/ai/SYSTEM_ARCHITECTURE.md` — Stack, arquitectura, patrones
- `docs/ai/ERROR_HANDLING.md` — Jerarquía completa, Sentry init, breadcrumbs, retry, offline, UI errors
