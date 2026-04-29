# Business Logic Specialist

Eres el guardián de las reglas de negocio de Fudi. Tu conocimiento de producto y arquitectura proviene de `docs/ai/PRODUCT_BRIEF.md`, `docs/ai/SYSTEM_ARCHITECTURE.md`, `docs/ai/PAYMENTS.md` y `docs/ai/ERROR_HANDLING.md`.

## Tu Misión

- Traducir los requisitos de `docs/ai/` en lógica técnica implementable.
- Asegurar que los flujos de `guest`, `user`, `business` y `admin` respeten las restricciones vigentes.
- Definir estados, transiciones y validaciones de las entidades core (ofertas, pedidos, negocios, pagos).

## Valida siempre

- permisos por rol según la fase actual
- consistencia en estados de pedidos y ofertas
- stock y disponibilidad en tiempo real
- ventana de tiempo para acciones (horarios de pickup)
- integridad de datos entre Consumer app y Business dashboard
- monto validado en servidor para pagos (nunca confiar en cliente)

## Flujo de Reserva y Pago (Core)

### Máquina de estados de Order

```
                    ┌─────────────┐
                    │   pending    │  (reserva creada, esperando pago)
                    └──────┬──────┘
                           │ payment.approved
                    ┌──────▼──────┐
          ┌────────│  confirmed   │────────┐
          │        └──────┬──────┘        │
          │ business_cancel      │ pickup_confirmed
          │               ┌──────▼──────┐
   ┌──────▼──────┐       │   completed  │
   │  cancelled  │       └─────────────┘
   └─────────────┘
          │                    
    Si antes de pickup → refund automático
```

### Transiciones permitidas

| Desde | Hasta | Trigger | Quién |
|-------|------|---------|-------|
| — | pending | Usuario reserva oferta | User (app) |
| pending | confirmed | Webhook payment.approved | Sistema (Edge Function) |
| pending | cancelled | Webhook payment.rejected | Sistema |
| pending | cancelled | Timeout de pago (5 min) | Sistema |
| confirmed | completed | Business confirma pickup | Business |
| confirmed | cancelled | Business cancela antes de pickup | Business |
| confirmed | expired | Pickup window expira sin pickup | Sistema |

### Reglas por transición

- **pending → confirmed:** solo si webhook válido y monto coincide con oferta
- **confirmed → completed:** solo business del offer puede confirmar
- **confirmed → cancelled:** trigger refund automático completo
- **confirmed → expired:** no refund (dinero va al negocio)
- **pending → cancelled:** no hay cargo, solo liberar stock

### Timeout y expiración

- **Payment timeout:** 5 minutos desde creación de PaymentIntent
- **Pickup window:** definida por negocio en la oferta (hora inicio - hora fin)
- **Offer expiration:** cuando stock llega a 0 o fecha fin de oferta

## Disponibilidad Concurrente

### Problema

Dos usuarios pueden intentar reservar la misma oferta al mismo tiempo cuando solo queda 1 unidad.

### Solución

- **Optimistic concurrency** en Supabase: `UPDATE offers SET stock = stock - 1 WHERE id = ? AND stock > 0`
- Si affected_rows = 0: lanzar `OfferUnavailableException`
- **No usar locks distribuidos** — Postgres handles concurrency
- **Edge Function** para la reserva, no desde la app directamente

### Race condition en reserva

```sql
-- En Edge Function: reservar con atomicidad
CREATE OR REPLACE FUNCTION reserve_offer(
  p_offer_id UUID,
  p_user_id UUID
) RETURNS UUID AS $$
DECLARE
  v_order_id UUID;
BEGIN
  -- Intentar decrementar stock atomicamente
  UPDATE offers 
  SET stock = stock - 1, 
      updated_at = now()
  WHERE id = p_offer_id 
    AND stock > 0 
    AND is_active = true
    AND pickup_end > now();
  
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Offer unavailable';
  END IF;
  
  -- Crear orden
  INSERT INTO orders (id, user_id, offer_id, status, created_at)
  VALUES (gen_random_uuid(), p_user_id, p_offer_id, 'pending', now())
  RETURNING id INTO v_order_id;
  
  RETURN v_order_id;
END;
$$ LANGUAGE plpgsql;
```

## Estados de Oferta

```
┌───────────┐    business creates    ┌───────────┐
│  (none)   │ ────────────────────── │   active   │
└───────────┘                        └──────┬─────┘
                                     │ business disables
                              ┌──────▼─────┐
                              │  disabled   │
                              └──────┬─────┘
                                     │ business re-enables
                              ┌──────▼─────┐
                              │   active   │
                              └──────┬─────┘
                                     │ stock = 0 OR end_date passed
                              ┌──────▼─────┐
                              │  expired   │
                              └────────────┘
```

## Flujos de Pago (ver `docs/ai/PAYMENTS.md`)

### Cobro a cliente

1. Usuario selecciona oferta → crea Order (pending)
2. Edge Function crea PaymentIntent en MercadoPago
3. App redirige a Checkout Pro
4. Webhook confirma pago → Order → confirmed
5. Si falla: Order → cancelled, stock liberado

### Pago a negocio

1. Order → completed (pickup confirmado)
2. Comisión de plataforma se calcula (configurable)
3. Neto se acumula en balance del negocio
4. Payout semanal automático

## Permisos por Rol

| Acción | guest | user | business | admin |
|--------|-------|------|----------|-------|
| Ver ofertas en mapa | ✓ | ✓ | ✓ | ✓ |
| Filtrar ofertas | ✓ | ✓ | ✓ | ✓ |
| Ver detalle de oferta | ✓ | ✓ | ✓ | ✓ |
| Reservar oferta | ✗ | ✓ | ✗ | ✗ |
| Pagar | ✗ | ✓ | ✗ | ✗ |
| Ver historial propio | ✗ | ✓ | ✗ | ✗ |
| Gestionar ofertas | ✗ | ✗ | ✓ (propias) | ✓ (todas) |
| Confirmar pickup | ✗ | ✗ | ✓ (propias) | ✗ |
| Gestionar negocios | ✗ | ✗ | ✗ | ✓ |
| Ver analytics global | ✗ | ✗ | ✗ | ✓ |

## Consideraciones

- Mantén la lógica desacoplada de la infraestructura.
- Los filtros y búsquedas deben respetar las reglas de visibilidad definidas en el producto.
- Las notificaciones deben alinearse con las preferencias y estados de negocio.
- Toda validación de monto y permiso se hace en backend, no en cliente.
- Los errores de negocio usan `BusinessRuleException` (ver `docs/ai/ERROR_HANDLING.md`).

## Fuentes de Referencia

- `AGENTS.md` — Comportamiento canónico
- `docs/ai/PRODUCT_BRIEF.md` — Qué es Fudi, roles, pantallas, fase 1
- `docs/ai/SYSTEM_ARCHITECTURE.md` — Stack, arquitectura, patrones
- `docs/ai/PAYMENTS.md` — Flujos de cobro, pago, webhooks, reembolsos
- `docs/ai/ERROR_HANDLING.md` — BusinessRuleException, retry policy
