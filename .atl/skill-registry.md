# Fudi Skill Registry

Este archivo es la infraestructura de resolucion de habilidades y agentes para Antigravity CLI en el proyecto Fudi.

## Specialized Agents (.agents/)

Estos agentes estan disponibles para ser invocados como sub-agentes.

| Agente | Proposito |
|---|---|
| [fudi-orchestrator](file:///C:/Users/emele/Repositories/fudi/.agents/fudi-orchestrator.md) | Orquestador principal, coordina especialistas y SSOT. |
| [architect](file:///C:/Users/emele/Repositories/fudi/.agents/architect.md) | Clean Architecture, Flutter patterns, Supabase, offline-first. |
| [database-architect](file:///C:/Users/emele/Repositories/fudi/.agents/database-architect.md) | Schema SQL, RLS, migraciones, entidades core. |
| [ux-ui](file:///C:/Users/emele/Repositories/fudi/.agents/ux-ui.md) | Pantallas mockup, estados, Consumer vs Business UI. |
| [business-logic](file:///C:/Users/emele/Repositories/fudi/.agents/business-logic.md) | Maquina de estados Order, logica de disponibilidad y permisos. |
| [test-engineer](file:///C:/Users/emele/Repositories/fudi/.agents/test-engineer.md) | TDD, integration, E2E, webhooks, analytics testing. |
| [accessibility-observability](file:///C:/Users/emele/Repositories/fudi/.agents/accessibility-observability.md) | WCAG AA, Sentry, error handling detailed, retry. |
| [integrations](file:///C:/Users/emele/Repositories/fudi/.agents/integrations.md) | Contratos, pasarela, mapas, push, health checks. |
| [deployment-sre](file:///C:/Users/emele/Repositories/fudi/.agents/deployment-sre.md) | Flavors, CI/CD, Sentry releases, secrets. |
| [technical-documentation](file:///C:/Users/emele/Repositories/fudi/.agents/technical-documentation.md) | ADRs, changelog, process updates. |
| [migration-specialist](file:///C:/Users/emele/Repositories/fudi/.agents/migration-specialist.md) | Mockup-driven migration, extraction de modelos. |
| [component-library](file:///C:/Users/emele/Repositories/fudi/.agents/component-library.md) | Design tokens, Tailwind→Flutter components. |
| [performance](file:///C:/Users/emele/Repositories/fudi/.agents/performance.md) | Optimizacion render, memoria, animaciones. |
| [security-compliance](file:///C:/Users/emele/Repositories/fudi/.agents/security-compliance.md) | Auth, encryption, OWASP, GDPR, PCI. |
| [analytics-growth](file:///C:/Users/emele/Repositories/fudi/.agents/analytics-growth.md) | Funnels, A/B testing, business metrics. |
| [payments](file:///C:/Users/emele/Repositories/fudi/.agents/payments.md) | MercadoPago, flows, webhooks, refunds, splits. |

## Contextual Knowledge (docs/ai/)

Fuentes de verdad obligatorias para todos los agentes.

| Documento | Proposito |
|---|---|
| [PRODUCT_BRIEF.md](file:///C:/Users/emele/Repositories/fudi/docs/ai/PRODUCT_BRIEF.md) | Roadmap, roles, pantallas, limites fase 1. |
| [SYSTEM_ARCHITECTURE.md](file:///C:/Users/emele/Repositories/fudi/docs/ai/SYSTEM_ARCHITECTURE.md) | Stack, patterns, persistence, connectivity. |
| [ERROR_HANDLING.md](file:///C:/Users/emele/Repositories/fudi/docs/ai/ERROR_HANDLING.md) | Jerarquia excepciones, UI feedback, Sentry. |
| [PAYMENTS.md](file:///C:/Users/emele/Repositories/fudi/docs/ai/PAYMENTS.md) | Pasarela, estados transaccion, conciliacion. |
| [ANALYTICS.md](file:///C:/Users/emele/Repositories/fudi/docs/ai/ANALYTICS.md) | Event schema, tagging plan. |

## Project Standards (Compact Rules)

- **Stack**: Flutter (Riverpod), Supabase, Sentry, MercadoPago.
- **Architecture**: Clean Architecture + Feature-First.
- **Phase 1 Restrictions**: Pickup-only, no-cart (direct purchase), no persisted guests.
- **Commits**: Conventional commits, NO AI attribution.
- **Builds**: Prohibido ejecutar builds despues de cambios.
