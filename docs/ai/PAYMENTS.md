# Fudi Payments Architecture

## Decision de Pasarela

**Primaria:** Place to Pay (reemplaza MercadoPago — ver ADR-001 en IMPLEMENTATION_PLAN.md)
**Razon:** Cobertura LATAM, soporte multi-pais, checkout redirect, webhooks robustos. Decisión del usuario.

**Secundaria (futura):** Stripe Connect (para expansion fuera de LATAM).

> **NOTA:** La integración concreta se implementará en Fase 7. Los modelos de dominio y la interfaz abstracta `PaymentGateway` son agnósticos de pasarela y NO cambian. Solo la implementación concreta cambia de MercadoPago a Place to Pay. Los env vars de configuración (`MP_*`) se reemplazarán por los que Place to Pay requiera.

La pasarela se encapsula detras de una interfaz abstracta para permitir swap sin tocar logica de negocio.

## Modelo de Dinero

### Flujo de Cobro a Cliente

```
Usuario selecciona oferta
  -> Crear intencion de pago (backend/edge function)
  -> Redirigir a checkout (MercadoPago Checkout Pro o Wallet)
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

### Split Payment (MercadoPago)

- **Platform fee:** Porcentaje configurable por negocio (default: 10%)
- **Application fee:** Se configura al crear el preference
- **Payout:** MercadoPago maneja el split automaticamente via `marketplace_fee`

## Entidades de Dominio

### PaymentIntent

| Campo | Tipo | Descripcion |
|-------|------|-------------|
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
|-------|------|-------------|
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

`POST /api/webhooks/payments/placetopay` (anteriormente `/mercadopago`)

### Validacion

1. Verificar signature HMAC con secreto compartido
2. Verificar que el event_type sea conocido
3. Idempotencia: verificar `gateway_id` ya procesado antes de actuar
4. Retornar 200 inmediatamente, procesar async

### Eventos manejados

| Evento | Accion |
|--------|--------|
| `payment.approved` | Marcar pago como approved, confirmar orden |
| `payment.rejected` | Marcar pago como rejected, notificar usuario |
| `payment.cancelled` | Marcar pago como cancelled, liberar oferta |
| `payment.refunded` | Marcar reembolso, actualizar estado orden |
| `payout.completed` | Marcar payout como paid, notificar negocio |

## Seguridad

- **No almacenar datos de tarjeta:** MercadoPago maneja todo via Checkout Pro
- **Tokenizar:** Si se habilita card-on-file, usar tokens de MercadoPago
- **Webhook secrets:** Almacenados en Supabase Vault, no en codigo
- **Monto validado en backend:** El precio se lee del servidor, no del cliente
- **Idempotencia:** Cada operacion usa idempotency key para evitar doble cobro
- **PCI scope:** Minimo - no tocar PAN/CVV nunca

## Reembolsos

### Politica fase 1

| Escenario | Accion |
|-----------|--------|
| Negocio cancela antes de pickup | Reembolso automatico completo |
| Usuario no recoge dentro de ventana | No reembolso (dinero va al negocio) |
| Oferta agotada despues de pago | Reembolso automatico completo |
| Disputa del usuario | Review manual por admin |

## Testing

### Modo sandbox

- MercadoPago provee credenciales de test
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
| `PTP_LOGIN` | test-xxx | test-xxx | prod-xxx |
| `PTP_TRANKEY` | test-xxx | test-xxx | prod-xxx |
| `PTP_WEBHOOK_SECRET` | dev-secret | staging-secret | prod-secret |
| `PTP_SANDBOX_MODE` | true | true | false |
| `PLATFORM_FEE_PCT` | 10 | 10 | Configurable por negocio |
| `PAYOUT_SCHEDULE` | manual | weekly | weekly |

> **NOTA:** Los env vars `MP_*` anteriores se reemplazan por `PTP_*` (Place to Pay). Los nombres exactos pueden ajustarse al revisar la documentación de Place to Pay SDK.
