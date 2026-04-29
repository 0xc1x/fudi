# Fudi Copilot Instructions

Usa siempre `AGENTS.md` como la **Instrucción Canónica** del proyecto. Este archivo contiene el protocolo de comportamiento y orquestación para todas las IAs.

## Contexto de Verdad (Single Source of Truth)

Para cualquier duda sobre el negocio, arquitectura o reglas técnicas, consulta:
- [Instrucciones de Agentes](AGENTS.md)
- [Contexto de Producto](docs/ai/PRODUCT_BRIEF.md)
- [Arquitectura de Sistema](docs/ai/SYSTEM_ARCHITECTURE.md)
- [Mapa de Herramientas y Agentes](AGENT_SYSTEM_META.md)
- [Agentes Especializados](.agents/) (ubicación neutral, proveedor-agnostic)

## Guía de Prompting y Sugerencias

- **Sugerencias Cortas:** Prefiere completar líneas o bloques pequeños. Evita generar archivos enteros de una vez si no se ha validado la arquitectura con el usuario.
- **Contexto Local:** Antes de sugerir un nuevo widget o provider, busca uno existente en `lib/core/widgets/` o en la feature correspondiente.
- **Clean Architecture:** Si sugieres código en `presentation`, no permitas que importe nada de `data`. Respeta estrictamente el flujo `presentation -> domain <- data`.
- **Inferencia de Tipos:** No seas redundante con los tipos si Dart puede inferirlos, a menos que mejore la legibilidad en firmas públicas.

## Routing a Agentes Especializados

Antes de implementar, consulta el agente especialista correspondiente desde `.agents/`:

| Tipo de Tarea | Agente | Archivo |
|---|---|---|
| Arquitectura / Clean Architecture | Architect | `.agents/architect.md` |
| Schema SQL / RLS / migraciones | Database Architect | `.agents/database-architect.md` |
| Pantallas UI / estados / accesibilidad | UX/UI | `.agents/ux-ui.md` |
| Reglas de negocio / permisos | Business Logic | `.agents/business-logic.md` |
| Testing / TDD / cobertura | Test Engineer | `.agents/test-engineer.md` |
| A11y / Sentry / error hierarchy | A11y & Observability | `.agents/accessibility-observability.md` |
| Integraciones externas / contratos | Integrations | `.agents/integrations.md` |
| Deployment / CI-CD / flavors | Deployment/SRE | `.agents/deployment-sre.md` |
| ADRs / changelog / docs | Tech Docs | `.agents/technical-documentation.md` |
| Migración React→Flutter | Migration Specialist | `.agents/migration-specialist.md` |
| Tokens / componentes / theme | Component Library | `.agents/component-library.md` |
| Renderizado / memoria / animaciones | Performance | `.agents/performance.md` |
| Auth / OWASP / GDPR / PCI | Security & Compliance | `.agents/security-compliance.md` |
| Funnels / métricas / A/B testing | Analytics & Growth | `.agents/analytics-growth.md` |
| MercadoPago / webhooks / split | Payments | `.agents/payments.md` |
| Coordinación multi-tarea | Orchestrator | `.agents/fudi-orchestrator.md` |

### Cómo usar

1. Lee el archivo `.agents/<agente>.md` ANTES de escribir código
2. Sigue el protocolo y restricciones del agente
3. Cuando múltiples agentes apliquen, empieza con el primario y consulta secundarios
4. Siempre valida contra restricciones de Fase 1 (pickup-only, sin carrito, sin delivery)
5. Referencia `AGENTS.md` para reglas de comportamiento y `docs/ai/` para conocimiento de dominio
