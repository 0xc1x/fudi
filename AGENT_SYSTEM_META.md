# Fudi Agent System — Meta-Agentes

Este archivo es el **mapa unificado** del sistema agentic de Fudi. Los agentes estan en una ubicacion **neutral** (`.agents/`) para que cualquier herramienta (OpenCode, Copilot, Gemini CLI, Cursor, Codex) pueda usarlos.

## Fuente Unica de Verdad (SSOT)

| Archivo | Tipo | Proposito |
|---|---|---|
| `AGENTS.md` | Comportamiento | Reglas de conducta, seguridad y orquestacion |
| `docs/ai/PRODUCT_BRIEF.md` | Conocimiento | Que es Fudi, roles, pantallas, limites de fase |
| `docs/ai/SYSTEM_ARCHITECTURE.md` | Conocimiento | Stack, arquitectura, Supabase, patrones |
| `docs/ai/ERROR_HANDLING.md` | Conocimiento | Jerarquia FudiException, Sentry, retry, offline, UI errors |
| `docs/ai/PAYMENTS.md` | Conocimiento | Pasarela MercadoPago, flujos cobro/pago, webhooks, reembolsos |
| `docs/ai/ANALYTICS.md` | Conocimiento | Eventos, funnels, metricas de negocio, consentimiento |

**Mockup React** (`/mnt/c/Users/emele/Downloads/fudi/src/`) — Fuente visual autoritativa. 45+ pantallas con UI completa y datos mock. NO es logica funcional, es guia visual.

---

## Ubicacion de Agentes

**Todos los agentes estan en `.agents/`** — ubicacion neutral, proveedor-agnostic.

| Agente | Archivo | Descripcion |
|---|---|---|
| **Orquestador** | `.agents/fudi-orchestrator.md` | Coordina tareas, enruta a 16 especialistas, prioriza features |
| **Arquitecto** | `.agents/architect.md` | Clean Architecture, capas transversales, Supabase, offline-first |
| **Database Architect** | `.agents/database-architect.md` | Schema SQL, RLS, migraciones, entidades de pago/analytics/errores |
| **UX/UI** | `.agents/ux-ui.md` | Pantallas del mockup, estados obligatorios, Consumer vs Business |
| **Business Logic** | `.agents/business-logic.md` | Maquina de estados Order, disponibilidad concurrente, permisos |
| **Test Engineer** | `.agents/test-engineer.md` | TDD, pagos, errores, E2E, webhooks, analytics |
| **A11y & Observability** | `.agents/accessibility-observability.md` | WCAG AA, Sentry detallado, jerarquia errores, retry, offline |
| **Integrations** | `.agents/integrations.md` | Contratos abstractos, pasarela, mapas, push, health checks, fallbacks |
| **Deployment/SRE** | `.agents/deployment-sre.md` | Flavors, CI/CD, Sentry releases, sourcemaps, secrets |
| **Tech Docs** | `.agents/technical-documentation.md` | ADRs, changelog, docs SSOT, proceso de actualizacion |
| **Migration Specialist** | `.agents/migration-specialist.md` | Mockup-driven migration, extraccion de modelos, mapa de pantallas |
| **Component Library** | `.agents/component-library.md` | Tokens del theme.css, OfferCard, BottomNav, FilterBar, Tailwind→Flutter |
| **Performance** | `.agents/performance.md` | Optimizacion de renderizado, memoria, animaciones |
| **Security & Compliance** | `.agents/security-compliance.md` | Auth, secure storage, certificate pinning, OWASP, GDPR, PCI |
| **Analytics & Growth** | `.agents/analytics-growth.md` | Funnels, metricas de negocio, A/B testing, consentimiento |
| **Payments** | `.agents/payments.md` | Pasarela MercadoPago, cobro/pago, webhooks, reembolsos, split |

---

## Temperatures Recomendados

| Tipo de Agente | Temperature | Justificacion |
|---|---|---|
| Orquestador | 0.2 | Controlado, coherente |
| Architect | 0.1 | Preciso, estructurado |
| Database Architect | 0.1 | Preciso, normalizado, alineado con docs SSOT |
| Business Logic | 0.15 | Estructurado pero con espacio para opciones |
| UX/UI | 0.45 | Creativo pero alineado al mockup |
| Test Engineer | 0.1 | Preciso, sistematico |
| A11y & Observability | 0.1 | Preciso, normativo |
| Integrations | 0.15 | Estructurado, foco en limites |
| Deployment/SRE | 0.1 | Preciso, operativo |
| Tech Docs | 0.1 | Claro, estructurado, con ADRs y changelog |
| Migration Specialist | 0.2 | Estructurado, mockup-driven |
| Component Library | 0.3 | Creativo pero fiel al theme.css del mockup |
| Performance | 0.1 | Preciso, analitico |
| Security & Compliance | 0.1 | Preciso, normativo, sin margen de interpretacion |
| Analytics & Growth | 0.2 | Estructurado con espacio para hipotesis de producto |
| Payments | 0.1 | Preciso, financiero, sin ambiguedad |

---

## Herramientas y sus Archivos de Configuracion

Cada herramienta tiene un **archivo adapter** que fuerza la carga de los agentes y SSOT. Los agentes reales estan en `.agents/` — los adapters solo referencian, nunca duplican.

| Herramienta | Archivo Adapter | Tipo de Adapter | Notas |
|---|---|---|---|
| **OpenCode** | `.opencode/agents/*.md` | Subagentes ejecutables (YAML frontmatter + referencia a `.agents/`) | Unico tool con `mode: subagent` real |
| **Cursor** | `.cursor/rules/20-fudi-agents.mdc` | Regla condicional (globs: *.dart, *.md, *.sql) | Tabla de routing a `.agents/` |
| **Gemini CLI** | `.gemini/settings.json` → `context.fileName` | Contexto inyectado (lista de archivos) | Carga todos los `.agents/*.md` + docs SSOT |
| **Copilot/Codex** | `.github/copilot-instructions.md` | Instrucciones con tabla de routing | Referencia `.agents/` y `docs/ai/` |
| **Copilot Local** | `COPILOT_INSTRUCTIONS.md` | Adapter alternativo en raiz | Fallback si no lee `.github/` |

### Estructura de Adapter (OpenCode — unico con subagentes reales)

```yaml
# .opencode/agents/<agente>.md
---
name: <agente>
mode: subagent
temperature: 0.X
description: "Resumen del especialista"
tools: [read, write, edit, bash, glob, grep, ...]
---
# <Agente>
Fuente unica de verdad: `.agents/<agente>.md`
[Protocolo obligatorio con pasos minimos]
```

### Principio: Referencia, no Duplicacion

- `.agents/*.md` = SSOT del conocimiento del agente (proveedor-agnostic)
- `.opencode/agents/*.md` = adapter con frontmatter + referencia
- `.cursor/rules/20-fudi-agents.mdc` = tabla de routing + referencia
- `.gemini/settings.json` = lista de archivos a cargar
- `.github/copilot-instructions.md` = tabla de routing + referencia

**SIEMPRE** que un agente se ejecuta, lee su `.agents/<name>.md` completo.

---

## Reglas de Fase 1 (No Negociables)

- **Pickup-only**: Sin delivery en fase 1
- **Sin carrito**: Flujo directo oferta → reserva → pago → pickup
- **Guest no persiste**: Es estado, no rol en BD
- **Roles en BD**: `user`, `business`, `admin`

---

## Protocolo de Uso por Herramienta

### OpenCode
```
1. Lee `.agents/fudi-orchestrator.md` o AGENTS.md
2. Identifica rol/feature afectada
3. Delega al especialista correcto en `.agents/`
4. Valida que no rompa restricciones de fase
5. Cierra con resumen y siguiente paso
```

### GitHub Copilot / Codex
```
1. Lee `.github/copilot-instructions.md`
2. Carga AGENTS.md como referencia
3. Ejecuta con foco en codigo Flutter
4. Puede invocar agentes de `.agents/` si es necesario
```

### Gemini CLI
```
1. GEMINI.md fuerza carga de contexto
2. AGENTS.md es obligatorio
3. docs/ai/ como fuente de verdad
4. agentes disponibles en `.agents/`
```

### Cursor
```
1. Lee `.cursor/rules/` (si existe)
2. Consulta AGENTS.md como fallback
3. Ejecuta tarea
4. Puede usar agentes de `.agents/`
```

---

## Actualizacion del Sistema

Cuando cambien reglas de negocio o arquitectura:

1. **Negocio cambia** → actualizar `docs/ai/PRODUCT_BRIEF.md`
2. **Arquitectura cambia** → actualizar `docs/ai/SYSTEM_ARCHITECTURE.md`
3. **Errores/analytics/pagos cambian** → actualizar `docs/ai/ERROR_HANDLING.md`, `ANALYTICS.md`, `PAYMENTS.md`
4. **Comportamiento del agente cambia** → actualizar `AGENTS.md`
5. **Nuevo agente** → crear en `.agents/`
6. **Nueva herramienta** → crear archivo adapter en raiz (ej: `CLAUDE.md`)

**No tocar archivos de provider** (`.opencode/`, `.cursor/`) a menos que sea necesario para compatibilidad especifica.

---

## Validacion de Coherencia

Antes de cualquier tarea, el agente debe confirmar:

- Lee `AGENTS.md`
- Consulta `PRODUCT_BRIEF.md`, `SYSTEM_ARCHITECTURE.md`, y docs relevantes segun feature
- Usa agentes de `.agents/`
- Verifica restricciones de fase 1
- No ejecuta builds despues de cambios
- Usa conventional commits sin AI attribution
- Si la tarea involucra UI, consulta el mockup React como fuente visual
