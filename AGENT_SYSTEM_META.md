# Fudi Agent System — Meta-Agentes

Este archivo es el **mapa unificado** del sistema agentic de Fudi. Los agentes están en una ubicación **neutral** (`.agents/`) para que cualquier herramienta (OpenCode, Copilot, Gemini CLI, Cursor, Codex) pueda usarlos.

## Fuente Única de Verdad (SSOT)

| Archivo | Tipo | Propósito |
|---|---|---|
| `AGENTS.md` | Comportamiento | Reglas de conducta, seguridad y orquestación |
| `docs/ai/PRODUCT_BRIEF.md` | Conocimiento | Qué es Fudi, roles, pantallas, límites de fase |
| `docs/ai/SYSTEM_ARCHITECTURE.md` | Conocimiento | Stack, arquitectura, Supabase, patrones |

---

## Ubicación de Agentes

**Todos los agentes están en `.agents/`** — ubicación neutral, proveedor-agnostic.

| Agente | Archivo | Descripción |
|---|---|---|
| **Orquestador** | `.agents/fudi-orchestrator.md` | Coordina tareas, valida restricciones de fase 1 |
| **Arquitecto** | `.agents/architect.md` | Clean Architecture, Supabase, RLS, estructura |
| **UX/UI** | `.agents/ux-ui.md` | Interfaces, atomic design, accesibilidad |
| **Business Logic** | `.agents/business-logic.md` | Roles, permisos, pedidos, estados |
| **Test Engineer** | `.agents/test-engineer.md` | TDD, unit, widget, integration tests |
| **A11y & Observability** | `.agents/accessibility-observability.md` | WCAG AA, Sentry, logs |
| **Integrations** | `.agents/integrations.md` | Supabase, mapas, pagos, push |
| **Deployment/SRE** | `.agents/deployment-sre.md` | Flavors, CI/CD, operación |
| **Tech Docs** | `.agents/technical-documentation.md` | Guías, referencias, decisiones |
| **Migration Specialist** | `.agents/migration-specialist.md` | Migración React → Flutter, patrones de estado |
| **Component Library** | `.agents/component-library.md` | Sistema de diseño, componentes reutilizables |
| **Performance** | `.agents/performance.md` | Optimización de renderizado, memoria, animaciones |

---

## Temperatures Recomendados

| Tipo de Agente | Temperature | Justificación |
|---|---|---|
| Orquestador | 0.2 | Controlado, coherente |
| Architect | 0.1 | Preciso, estructurado |
| Business Logic | 0.15 | Estructurado pero con espacio para opciones |
| UX/UI | 0.45 | Creativo pero no caótico |
| Test Engineer | 0.1 | Preciso, sistemático |
| A11y & Observability | 0.1 | Preciso, normativo |
| Integrations | 0.15 | Estructurado, foco en límites |
| Deployment/SRE | 0.1 | Preciso, operativo |
| Tech Docs | 0.1 | Claro, estructurado |
| Migration Specialist | 0.2 | Estructurado con espacio para decisiones técnicas |
| Component Library | 0.3 | Creativo pero consistente con sistema de diseño |
| Performance | 0.1 | Preciso, analítico |

---

## Herramientas y sus Archivos de Configuración

Cada herramienta tiene un **archivo adapter** que fuerza la carga de los agentes y SSOT:

| Herramienta | Archivo Adapter | Notas |
|---|---|---|
| **OpenCode** | `.opencode/agents/fudi-orchestrator.md` (legacy) | Puede usar `.agents/` directamente |
| **Copilot/Copilot CLI** | `.github/copilot-instructions.md` | Referencia AGENTS.md y SSOT |
| **Gemini CLI** | `GEMINI.md` | Fuerza carga de AGENTS.md + docs/ai/ |
| **Copilot Local** | `COPILOT_INSTRUCTIONS.md` | Adapter alternativo en raíz |
| **Codex** | `.github/copilot-instructions.md` | Comparte con Copilot |

> **Nota:** Los agentes en `.agents/` son **proveedor-agnostic**. Cualquier herramienta puede usarlos directamente con un `@` reference o incluyéndolos en el system prompt.

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
3. Ejecuta con foco en código Flutter
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

## Actualización del Sistema

Cuando cambien reglas de negocio o arquitectura:

1. **Negocio cambia** → actualizar `docs/ai/PRODUCT_BRIEF.md`
2. **Arquitectura cambia** → actualizar `docs/ai/SYSTEM_ARCHITECTURE.md`
3. **Comportamiento del agente cambia** → actualizar `AGENTS.md`
4. **Nuevo agente** → crear en `.agents/`
5. **Nueva herramienta** → crear archivo adapter en raíz (ej: `CLAUDE.md`)

**No tocar archivos de provider** (`.opencode/`, `.cursor/`) a menos que sea necesario para compatibilidad específica.

---

## Validación de Coherencia

Antes de cualquier tarea, el agente debe confirmar:
- ✅ Lee `AGENTS.md`
- ✅ Consulta `PRODUCT_BRIEF.md` y `SYSTEM_ARCHITECTURE.md`
- ✅ Usa agentes de `.agents/`
- ✅ Verifica restricciones de fase 1
- ✅ No ejecuta builds después de cambios
- ✅ Usa conventional commits sin AI attribution