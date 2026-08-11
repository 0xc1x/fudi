# Fudi Skill Registry

Este archivo es la infraestructura de resolucion de habilidades y agentes para Antigravity CLI en el proyecto Fudi.

## Specialized Agents (.agents/)

Estos agentes estan disponibles para ser invocados como sub-agentes.

| Agente | Proposito |
| --- | --- |
| [fudi-orchestrator](.agents/fudi-orchestrator.md) | Orquestador principal, coordina especialistas y SSOT. |
| [architect](.agents/architect.md) | Clean Architecture, Flutter patterns, Supabase, offline-first. |
| [database-architect](.agents/database-architect.md) | Schema SQL, RLS, migraciones, entidades core. |
| [ux-ui](.agents/ux-ui.md) | Pantallas, estados, Consumer vs Business UI. |
| [business-logic](.agents/business-logic.md) | Maquina de estados Order, logica de disponibilidad y permisos. |
| [test-engineer](.agents/test-engineer.md) | TDD, integration, E2E, webhooks, analytics testing. |
| [accessibility-observability](.agents/accessibility-observability.md) | WCAG AA, Sentry, error handling detailed, retry. |
| [integrations](.agents/integrations.md) | Contratos, pasarela, mapas, push, health checks. |
| [deployment-sre](.agents/deployment-sre.md) | Flavors, CI/CD, Sentry releases, secrets. |
| [technical-documentation](.agents/technical-documentation.md) | ADRs, changelog, process updates. |
| [migration-specialist](.agents/migration-specialist.md) | Migracion React→Flutter completada; coherencia visual y de modelos. |
| [component-library](.agents/component-library.md) | Design tokens (FudiColors), componentes del design system. |
| [performance](.agents/performance.md) | Optimizacion render, memoria, animaciones. |
| [security-compliance](.agents/security-compliance.md) | Auth, encryption, OWASP, GDPR, PCI. |
| [analytics-growth](.agents/analytics-growth.md) | Funnels, A/B testing, business metrics. |
| [payments](.agents/payments.md) | Pasarela (pendiente de definicion), webhooks, refunds, splits. |

## Contextual Knowledge (docs/ai/)

Fuentes de verdad obligatorias para todos los agentes.

| Documento | Proposito |
| --- | --- |
| [PRODUCT_BRIEF.md](docs/ai/PRODUCT_BRIEF.md) | Roadmap, roles, pantallas, limites fase 1. |
| [SYSTEM_ARCHITECTURE.md](docs/ai/SYSTEM_ARCHITECTURE.md) | Stack, patterns, persistence, connectivity. |
| [ERROR_HANDLING.md](docs/ai/ERROR_HANDLING.md) | Jerarquia excepciones, UI feedback, Sentry. |
| [PAYMENTS.md](docs/ai/PAYMENTS.md) | Pasarela (pendiente de definicion), estados transaccion, conciliacion. |
| [ANALYTICS.md](docs/ai/ANALYTICS.md) | Event schema, tagging plan. |

## Skills (.agents/skills/)

Skills pineadas en `skills-lock.json` (raiz del repo). `npx skills add <repo>` para actualizarlas.

| Skill | Origen | Uso |
| --- | --- | --- |
| flutter-* (10) | `flutter/skills` | Skills oficiales de Flutter: widget tests, previews, integration tests, arquitectura, layout, JSON, routing, i18n, http, fix de layout. |
| [supabase](.agents/skills/supabase/SKILL.md) | `supabase/agent-skills` | Cualquier tarea con productos Supabase (Database, Auth, Edge Functions, Realtime, Storage, RLS). |
| [supabase-postgres-best-practices](.agents/skills/supabase-postgres-best-practices/SKILL.md) | `supabase/agent-skills` | Reglas de Postgres (schema, RLS, migraciones, indexes) antes de tocar la BD. |

## Project Standards (Compact Rules)

- **Stack**: Flutter (Riverpod), Supabase, Sentry, pasarela de pagos (pendiente de definicion).
- **Architecture**: Clean Architecture + Feature-First.
- **Phase 1 Restrictions**: Pickup-only, no-cart (direct purchase), no persisted guests.
- **Commits**: Conventional commits, NO AI attribution.
- **Builds**: Prohibido ejecutar builds despues de cambios.
