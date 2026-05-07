# Remote Migration Inventory — 2026-05-07

Estas son las migraciones registradas en el proyecto remoto `sxqopofoynsqkztozlix`.

> IMPORTANTE: este archivo NO inventa el SQL histórico. Solo preserva el inventario verificado para mantener trazabilidad honesta.

| Orden | Versión | Nombre |
|---|---|---|
| 1 | 20260507193004 | create_enums_and_profiles |
| 2 | 20260507193215 | create_businesses_and_locations |
| 3 | 20260507193325 | create_offers_and_coupons |
| 4 | 20260507193539 | create_orders_and_events |
| 5 | 20260507193731 | create_favorites_and_reviews |
| 6 | 20260507194045 | create_payments_and_payouts |
| 7 | 20260507194301 | create_user_data_tables |
| 8 | 20260507194816 | create_sql_functions_and_triggers |
| 9 | 20260507195823 | insert_seed_auth_users_and_profiles |
| 10 | 20260507200106 | insert_seed_businesses_and_hours |
| 11 | 20260507200508 | insert_seed_offers_coupons_orders |
| 12 | 20260507201134 | fix_function_search_path_security |
| 13 | 20260507201408 | fix_security_advisor_warnings |

## Baseline local relacionado

- `docs/database/schemas/001_phase2_baseline.sql`
- `supabase/migrations/20260507210000_phase2_baseline_sync.sql`
