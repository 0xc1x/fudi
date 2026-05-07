# Database Schema Changelog

Historial de cambios relevantes del esquema de base de datos de Fudi.

| Fecha | Versión | Autor | Cambio | Justificación | Migración | Impacto |
|-------|---------|-------|--------|---------------|-----------|---------|
| 2026-05-07 | phase2-baseline | Codex | Se sincronizó el estado remoto de Supabase al repositorio mediante baseline snapshot, inventario de migraciones remotas, documentación de RLS y Edge Functions de Fase 2.4. | El esquema existía en Supabase pero NO tenía trazabilidad suficiente en `/docs` ni baseline local versionado. | `supabase/migrations/20260507210000_phase2_baseline_sync.sql` | DevEx, auditoría técnica, continuidad de cambios futuros |
| 2026-05-07 | phase2-hardening | Codex | Se eliminó `pg_graphql` y se revocó `EXECUTE` sobre funciones públicas para `public`, `anon` y `authenticated`. También se cambiaron default privileges para futuras funciones. | El advisor de Supabase reportaba exposición de schema vía GraphQL y funciones `SECURITY DEFINER` ejecutables por roles públicos. | `supabase/migrations/20260507223000_harden_phase2_security_surface.sql` | Reducción de superficie pública, mitigación de privilege escalation |
