# RLS Policy Matrix — Fase 2

Resumen funcional de las políticas RLS verificadas en el proyecto remoto.

## Reglas globales

- `guest/public`: solo lectura de recursos públicos activos
- `user`: acceso a sus propios datos
- `business`: acceso a recursos de negocios cuyo `owner_id = auth.uid()`
- `admin`: acceso ampliado mediante `profiles.role = 'admin'`
- tablas de eventos y pagos sensibles: sin `INSERT/UPDATE` directo desde cliente

## Matriz por tabla

| Tabla | Lectura pública | Usuario autenticado | Business owner | Admin | Escritura directa cliente |
|---|---|---|---|---|---|
| `profiles` | no | propio perfil | lectura de perfiles business | sí | update propio / admin |
| `businesses` | activas | según ownership | CRUD propio | full access | sí con restricciones |
| `business_locations` | activas | n/a | CRUD propio | full access | sí con restricciones |
| `business_hours` | sí | n/a | CRUD propio | full access | sí con restricciones |
| `offers` | activas | lectura + ownership | CRUD propio | full access | sí con restricciones |
| `coupons` | activas y vigentes | n/a | CRUD propio | full access | sí con restricciones |
| `orders` | no | propias | ver/actualizar propias del negocio | ver/actualizar todas | sí, restringido |
| `order_events` | no | ver propios | ver propios del negocio | ver todos | NO insert directo |
| `favorites` | no | CRUD propio | n/a | lectura administrativa | sí |
| `reviews` | sí | CRUD propio | n/a | full access | sí |
| `payment_intents` | no | ver propios | ver propios del negocio | ver todos | NO insert/update directo |
| `payment_events` | no | no | no | ver todos | NO insert/update directo |
| `payouts` | no | no | ver propios | ver todos | NO insert/update directo |
| `user_consents` | no | CRUD propio | n/a | ver todos | sí |
| `user_preferences` | no | CRUD propio | n/a | no explícito | sí |
| `saved_addresses` | no | CRUD propio | n/a | no explícito | sí |
| `device_tokens` | no | CRUD propio | n/a | no explícito | sí |

## Observación operativa

El endurecimiento aplicado el 2026-05-07 removió `pg_graphql` y revocó `EXECUTE` de funciones públicas para `public`, `anon` y `authenticated`.

Con eso:

- ya no existe superficie `/graphql/v1` para este proyecto
- las funciones `SECURITY DEFINER` del schema `public` dejaron de ser invocables desde roles públicos por RPC

Riesgo restante fuera de SQL: la protección de contraseñas filtradas en Supabase Auth sigue siendo una configuración del producto Auth y debe habilitarse desde Dashboard si se desea cerrar ese warning también.
