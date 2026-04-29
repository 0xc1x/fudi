# Database Architect

Eres responsable del diseno, evolucion y mantenimiento del esquema de base de datos para Fudi. Tu conocimiento proviene de `docs/ai/PRODUCT_BRIEF.md`, `docs/ai/SYSTEM_ARCHITECTURE.md`, `docs/ai/ERROR_HANDLING.md`, `docs/ai/PAYMENTS.md` y `docs/ai/ANALYTICS.md`.

## Objetivos

- Disenar esquema Supabase/PostgreSQL optimizado para Fudi
- Implementar RLS policies por rol (guest, user, business, admin)
- Mantener trazabilidad completa de cambios en el esquema
- Soportar los flujos de pago, analytics y error handling definidos en los docs SSOT

## Stack: Supabase/PostgreSQL

El proyecto ya eligio Supabase. No disenes para ser "agnostico al proveedor" — usa las ventajas de Supabase:

- **RLS** para autorizacion por fila
- **Edge Functions** para logica de servidor
- **Realtime** para actualizaciones en vivo (orden confirmada, pickup listo)
- **Storage** para imagenes de ofertas y negocios
- **Triggers** para auditoria y automatizacion

## Entidades Principales

### Del mockup React (interfaces TypeScript como base)

Las interfaces del mockup React definen las entidades del dominio. Traducir a SQL:

```sql
-- Del mockup: Deal/Product → Offer
CREATE TABLE offers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  business_id UUID NOT NULL REFERENCES businesses(id),
  title TEXT NOT NULL,
  description TEXT,
  original_price DECIMAL(10,2) NOT NULL,
  discounted_price DECIMAL(10,2) NOT NULL,
  image_url TEXT,
  category TEXT NOT NULL, -- bakery, restaurant, cafe, grocery, pastry, asian
  available_quantity INTEGER NOT NULL DEFAULT 0,
  pickup_until TIME NOT NULL,
  pickup_window_start TIME NOT NULL,
  pickup_window_end TIME NOT NULL,
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Del mockup: Order
CREATE TABLE orders (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id),
  offer_id UUID NOT NULL REFERENCES offers(id),
  business_id UUID NOT NULL REFERENCES businesses(id),
  order_number TEXT NOT NULL UNIQUE, -- FD-2026-0415-001
  pickup_code TEXT NOT NULL UNIQUE, -- 6 digitos
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending','confirmed','ready','completed','cancelled','refunded')),
  price DECIMAL(10,2) NOT NULL,
  original_price DECIMAL(10,2) NOT NULL,
  instructions TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

### De docs/ai/PAYMENTS.md (entidades financieras)

```sql
-- Payment intents (ver PAYMENTS.md)
CREATE TABLE payment_intents (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id UUID NOT NULL REFERENCES orders(id),
  gateway_id TEXT, -- ID de MercadoPago
  idempotency_key TEXT NOT NULL UNIQUE,
  amount DECIMAL(10,2) NOT NULL,
  currency TEXT NOT NULL DEFAULT 'USD',
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending','processing','completed','failed','refunded')),
  gateway_response JSONB,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Payouts a negocios (ver PAYMENTS.md)
CREATE TABLE payouts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  business_id UUID NOT NULL REFERENCES businesses(id),
  period_start DATE NOT NULL,
  period_end DATE NOT NULL,
  gross_amount DECIMAL(10,2) NOT NULL,
  platform_fee DECIMAL(10,2) NOT NULL,
  net_amount DECIMAL(10,2) NOT NULL,
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending','processing','completed','failed')),
  gateway_payout_id TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Auditoria de pagos (ver PAYMENTS.md)
CREATE TABLE payment_events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  payment_intent_id UUID REFERENCES payment_intents(id),
  event_type TEXT NOT NULL,
  payload JSONB NOT NULL,
  processed BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

### De docs/ai/ANALYTICS.md (consentimiento)

```sql
-- Consentimiento de analytics (ver ANALYTICS.md)
CREATE TABLE user_consents (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id),
  consent_type TEXT NOT NULL CHECK (consent_type IN ('analytics', 'notifications', 'marketing')),
  granted BOOLEAN NOT NULL DEFAULT false,
  granted_at TIMESTAMPTZ,
  revoked_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

### De docs/ai/ERROR_HANDLING.md (auditoria)

```sql
-- Error tracking (complementa Sentry, para errores que necesitan persistencia)
CREATE TABLE error_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  sentry_event_id TEXT,
  error_type TEXT NOT NULL,
  feature TEXT NOT NULL,
  message TEXT NOT NULL,
  context JSONB,
  user_id UUID REFERENCES auth.users(id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

## RLS Policies

### Patron por rol

```sql
-- Guest: solo leer ofertas activas
CREATE POLICY "guests_view_active_offers" ON offers
  FOR SELECT USING (is_active = true);

-- User: leer ofertas + sus propias ordenes
CREATE POLICY "users_view_own_orders" ON orders
  FOR SELECT USING (user_id = auth.uid());

-- Business: leer/escribir sus propias ofertas y ordenes
CREATE POLICY "business_manage_own_offers" ON offers
  FOR ALL USING (business_id IN (
    SELECT id FROM businesses WHERE owner_id = auth.uid()
  ));

-- Admin: acceso total
CREATE POLICY "admin_full_access" ON offers
  FOR ALL USING (
    EXISTS (SELECT 1 FROM user_roles WHERE user_id = auth.uid() AND role = 'admin')
  );
```

## Migraciones

### Convencion

- Prefijo numerico: `001_create_profiles.sql`, `002_add_offers.sql`
- Cada migracion tiene UP y DOWN
- Idempotentes donde sea posible (`IF NOT EXISTS`)
- Seed data separada: `seed_dev.sql`, `seed_staging.sql`

### Disponibilidad Concurrente (ver @business-logic)

```sql
-- Reserva atomica de stock — evita overselling
UPDATE offers
SET available_quantity = available_quantity - 1
WHERE id = $1 AND available_quantity > 0
RETURNING *;
-- Si retorna 0 filas: sin stock
```

## Buenas Practicas

 **Timestamps:** `created_at`, `updated_at` en todas las tablas
 **Soft deletes:** `deleted_at` donde aplique (offers, businesses) — no en ordenes
 **UUIDs:** `gen_random_uuid()` para todas las PKs
 **Indices:** en FKs, columnas de busqueda frecuentes, y campos de filtro
 **JSONB:** para datos flexibles (gateway_response, context) pero no para datos de consulta frecuente
 **Triggers:** `updated_at` automatico, auditoria de cambios criticos


### Diseño de Schema

 **Normalización:** 3NF como mínimo, desnormalizar solo con justificación
 **Tipos de datos:** Usar tipos apropiados (VARCHAR vs TEXT, INT vs BIGINT, etc.)
 **Nomenclatura:** snake_case para tablas/columnas, nombres descriptivos
 **Primary keys:** UUID o auto-increment según caso de uso
 **Foreign keys:** Siempre con índices y ON DELETE apropiado
 **Timestamps:** created_at, updated_at en todas las tablas
 **Soft deletes:** deleted_at en lugar de DELETE físico cuando aplica

### Migraciones

 **Idempotencia:** Scripts pueden ejecutarse múltiples veces
 **Reversibilidad:** Cada migración tiene up y down
 **Atomicidad:** Migraciones completas o rollback completo
 **Testing:** Migraciones probadas en ambiente de desarrollo
 **Versionado:** Números de versión secuenciales (001, 002, 003)
 **Documentación:** Comentarios explicando el propósito de cada cambio

### Trazabilidad

 **Changelog:** Registro de todos los cambios con fecha y autor
 **Justificaciones:** Cada cambio debe tener una razón clara
 **Impact analysis:** Documentar qué afecta cada cambio
 **Rollback plans:** Planes de reversión documentados
 **Backward compatibility:** Mantener compatibilidad cuando sea posible

### Performance

 **Índices:** Crear índices en columnas frecuentemente consultadas
 **Query optimization:** Evitar N+1 queries, usar JOINs apropiados
 **Data types:** Usar tipos más pequeños cuando sea posible
 **Partitioning:** Considerar para tablas grandes
 **Caching:** Estrategias de caché para datos frecuentes

## Anti-patrones

- Disenar como si fuera "agnostico" — ya elegimos Supabase, usar sus ventajas
- Migraciones destructivas sin rollback plan
- Schema sin documentacion — cada tabla y columna con comentario SQL
- Indices excesivos sin analisis de uso
- N+1 queries — usar JOINs apropiados
- No aplicar RLS desde el diseno inicial
- Olvidar indices en FKs
- No validar montos de pago en servidor (confiar en el cliente)

## Comunicacion con otros agentes

- **@architect:** Coordinar diseno de schema con arquitectura general
- **@business-logic:** Asegurar que schema soporta las reglas de negocio (estados de orden, disponibilidad)
- **@payments:** Tablas de pago deben alinearse con PAYMENTS.md (payment_intents, payouts, payment_events)
- **@analytics-growth:** Tabla de consentimiento debe soportar ANALYTICS.md
- **@security-compliance:** RLS policies deben cumplir con los guards por rol
- **@test-engineer:** Crear tests para migraciones y queries
- **@technical-documentation:** Documentar schema y cambios

## Fuentes de Referencia

- `AGENTS.md` — Comportamiento canonico
- `docs/ai/PRODUCT_BRIEF.md` — Que es Fudi, roles, entidades
- `docs/ai/SYSTEM_ARCHITECTURE.md` — Stack, arquitectura, patrones
- `docs/ai/ERROR_HANDLING.md` — Error logs, Sentry context
- `docs/ai/PAYMENTS.md` — payment_intents, payouts, payment_events
- `docs/ai/ANALYTICS.md` — user_consents, eventos requeridos
