# Database Documentation

Estado actual de la base de datos de Fudi después del cierre de Fase 2 a nivel de repositorio.

## Qué quedó trazado

- `schemas/001_phase2_baseline.sql` — snapshot base del esquema remoto capturado el 2026-05-07
- `migrations/2026-05-07_remote_migration_inventory.md` — inventario de migraciones remotas realmente aplicadas
- `../../supabase/migrations/20260507210000_phase2_baseline_sync.sql` — baseline técnico para versionado futuro en repo
- `rls_policies.md` — matriz funcional de políticas RLS por tabla
- `seed_inventory.md` — evidencia de seed data cargada en remoto

## Decisión importante

La base se creó primero en Supabase y NO primero en el repositorio. Por eso no existe historial granular local confiable de cada SQL original.

En vez de inventar migraciones históricas, este directorio conserva dos cosas:

1. **Inventario remoto verificado** de lo que sí se aplicó.
2. **Baseline snapshot** para que el repo vuelva a ser trazable desde este punto.

Eso es arquitectura seria: NO falsificar historia.

## Estado verificado contra Supabase (2026-05-07)

- 17 tablas públicas
- 8 enums
- 11 funciones SQL
- 19 triggers de tabla
- 72 políticas RLS
- 13 migraciones remotas registradas
- 3 Edge Functions desplegadas y activas: `reserve-offer`, `handle-payment-webhook`, `process-payout`

## Próxima regla operativa

A partir de este baseline:

- Todo cambio nuevo debe entrar primero por `supabase/migrations/`
- Toda modificación relevante del modelo debe reflejarse en `docs/database/`
- No volver a dejar el estado real solo en la consola de Supabase
