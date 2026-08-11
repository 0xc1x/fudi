# Fudi Payments Architecture

## Decision de Pasarela

**Estado: PENDIENTE de definicion.** Aun no se ha elegido la pasarela de pagos.

Candidatos evaluados (sin decision):

- **MercadoPago** — cobertura LATAM, Checkout Pro, split nativo
- **Place to Pay** — cobertura LATAM multi-pais, checkout redirect (ver ADR-001 historico en IMPLEMENTATION_PLAN.md)
- **Stripe** — candidato para expansion futura fuera de LATAM

> **Regla vigente:** No agregar SDK de pagos hasta elegir pasarela. La interfaz abstracta `PaymentGateway` (`lib/core/network/payment_gateway.dart`) y los modelos de dominio son agnosticos de pasarela y NO cambian. Solo cambia la implementacion concreta y sus env vars (`MP_*`, `PTP_*`, o los que la pasarela elegida requiera). Cuando se defina la pasarela, actualizar este doc y eliminar las opciones restantes.

La pasarela se encapsula detras de una interfaz abstracta para permitir swap sin tocar logica de negocio.

## Modelo de Dinero

### Flujo de Cobro a Cliente

```
Usuario selecciona oferta
  -> Crear intencion de pago (backend/edge function)
  -> Redirigir a checkout (checkout de la pasarela elegida)
  -> Webhook confirma pago
  -> Orden cambia a "confirmed"
  -> Usuario recibe confirmacion + instrucciones de pickup
```

### Flujo de Pago a Negocio

```
Orden completada (pickup validado)
  -> Platform fee se descuenta (comision configurable por negocio)
  -> Neto se acumula en balance del negocio
  -> Payout automatico segun schedule (semanal por defecto)
  -> Negocio recibe notificacion de deposito
```

### Split Payment

- **Platform fee:** Porcentaje configurable por negocio (default: 10%)
- **Application fee:** Se configura al crear la intencion de pago (nombre segun pasarela: `application_fee`, `marketplace_fee`, etc.)
- **Payout:** La pasarela maneja el split automaticamente

## Entidades de Dominio

### PaymentIntent

| Campo | Tipo | Descripcion |
| ------- | ------ | ------------- |
| id | UUID | PK |
| order_id | UUID | FK a orders |
| gateway | enum | place_to_pay, stripe |
| gateway_id | string | ID externo de la pasarela |
| amount | decimal | Monto total |
| currency | string | COP, MXN, etc. |
| status | enum | pending, processing, approved, rejected, cancelled, refunded |
| gateway_response | jsonb | Respuesta completa de la pasarela |
| created_at | timestamp | Creacion |

### Payout

| Campo | Tipo | Descripcion |
| ------- | ------ | ------------- |
| id | UUID | PK |
| business_id | UUID | FK a businesses |
| period_start | date | Inicio del periodo |
| period_end | date | Fin del periodo |
| gross_amount | decimal | Total antes de comision |
| platform_fee | decimal | Monto de comision |
| net_amount | decimal | Total despues de comision |
| status | enum | pending, processing, paid, failed |
| gateway_payout_id | string | ID externo del payout |
| paid_at | timestamp | Fecha de pago |

## Contratos de Integracion

### PaymentGateway (interfaz abstracta)

```dart
abstract class PaymentGateway {
  /// Crea una intencion de checkout y retorna la URL/redireccion
  Future<CheckoutResult> createCheckout(PaymentRequest request);
  
  /// Verifica el estado de un pago
  Future<PaymentStatusResult> getPaymentStatus(String gatewayId);
  
  /// Procesa un reembolso parcial o total
  Future<RefundResult> processRefund(RefundRequest request);
  
  /// Valida la firma de un webhook entrante
  bool verifyWebhookSignature(WebhookPayload payload);
  
  /// Parsea un webhook a un evento de dominio
  PaymentEvent parseWebhookEvent(WebhookPayload payload);
}
```

### CheckoutResult

```dart
class CheckoutResult {
  final String checkoutUrl;   // URL para redirigir al usuario
  final String gatewayId;      // ID en la pasarela
  final String? qrCode;        // QR si aplica (ej: Pix en Brasil)
}
```

### PaymentEvent

```dart
sealed class PaymentEvent {
  final String gatewayId;
  final String orderId;
}

class PaymentApprovedEvent extends PaymentEvent {}
class PaymentRejectedEvent extends PaymentEvent {
  final String reason;
}
class PaymentCancelledEvent extends PaymentEvent {}
class PaymentRefundedEvent extends PaymentEvent {
  final String refundId;
  final double amount;
}
```

## Webhooks

### Endpoint

`POST /api/webhooks/payments/{gateway}` (se define al elegir pasarela)

### Validacion

1. Verificar signature HMAC con secreto compartido
2. Verificar que el event_type sea conocido
3. Idempotencia: verificar `gateway_id` ya procesado antes de actuar
4. Retornar 200 inmediatamente, procesar async

### Eventos manejados

| Evento | Accion |
| -------- | -------- |
| `payment.approved` | Marcar pago como approved, confirmar orden |
| `payment.rejected` | Marcar pago como rejected, notificar usuario |
| `payment.cancelled` | Marcar pago como cancelled, liberar oferta |
| `payment.refunded` | Marcar reembolso, actualizar estado orden |
| `payout.completed` | Marcar payout como paid, notificar negocio |

## Seguridad

- **No almacenar datos de tarjeta:** la pasarela elegida maneja todo via checkout redirigido
- **Tokenizar:** Si se habilita card-on-file, usar tokens de la pasarela
- **Webhook secrets:** Almacenados en Supabase Vault, no en codigo
- **Monto validado en backend:** El precio se lee del servidor, no del cliente
- **Idempotencia:** Cada operacion usa idempotency key para evitar doble cobro
- **PCI scope:** Minimo - no tocar PAN/CVV nunca

## Reembolsos

### Politica fase 1

| Escenario | Accion |
| ----------- | -------- |
| Negocio cancela antes de pickup | Reembolso automatico completo |
| Usuario no recoge dentro de ventana | No reembolso (dinero va al negocio) |
| Oferta agotada despues de pago | Reembolso automatico completo |
| Disputa del usuario | Review manual por admin |

## Testing

### Modo sandbox

- La pasarela elegida provee credenciales de test (sandbox)
- Tarjetas de prueba documentadas en su SDK
- Webhooks de test con retardo configurable
- Payouts simulados

### Contrato de mock

```dart
class MockPaymentGateway implements PaymentGateway {
  /// Simula flujos completos: aprobado, rechazado, timeout
  /// Configurable por test para inyectar errores
  final PaymentScenario scenario;
}
```

## Configuracion por Ambiente

| Variable | Dev | Staging | Prod |
|----------|-----|---------|------|
| `PLATFORM_FEE_PCT` | 10 | 10 | Configurable por negocio |
| `PAYOUT_SCHEDULE` | manual | weekly | weekly |

> **NOTA:** Las credenciales de la pasarela (`*_API_KEY`, webhook secrets, sandbox mode) se definiran al elegirla. No inventar nombres de variables hasta esa decision.
